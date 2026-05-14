#!/bin/bash
# lib/backup.sh - Backup-Integration & System-Last-Prüfung (v1.8.0)

# System-Last prüfen (verhindert Update bei hoher CPU-Last)
check_system_load() {
    if [ "$UPDATE_LOAD_CHECK" != "true" ]; then
        return 0
    fi

    local load_avg
    load_avg=$(awk '{print $1}' /proc/loadavg)
    local max_load="${UPDATE_MAX_LOAD:-2.0}"

    if awk "BEGIN { exit ($load_avg > $max_load) ? 0 : 1 }" 2>/dev/null; then
        # shellcheck disable=SC2059
        log_warning "$(printf "$MSG_LOAD_CHECK_HIGH" "$load_avg" "$max_load")"
        return 1
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_LOAD_CHECK_OK" "$load_avg")"
    return 0
}

# LVM-Snapshot erstellen
backup_lvm() {
    local timestamp="$1"
    local snapshot_name="update-snap-${timestamp}"

    local root_lv
    root_lv=$(findmnt -n -o SOURCE / 2>/dev/null | head -1)

    if [ -z "$root_lv" ]; then
        log_error "$MSG_BACKUP_LVM_NO_ROOT"
        return 1
    fi

    local root_vg
    root_vg=$(lvs --noheadings -o vg_name "$root_lv" 2>/dev/null | tr -d ' ')

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_BACKUP_LVM_SNAPSHOT" "$root_lv" "$snapshot_name")"

    if lvcreate -L10G -s -n "$snapshot_name" "$root_lv" 2>&1 | tee -a "$LOG_FILE"; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_BACKUP_LVM_SUCCESS" "/dev/${root_vg}/${snapshot_name}")"
        return 0
    else
        log_error "$MSG_BACKUP_LVM_FAILED"
        return 1
    fi
}

# Btrfs-Snapshot erstellen
backup_btrfs() {
    local timestamp="$1"
    local snapshot_dir="${BACKUP_TARGET}/btrfs-snapshots"
    local snapshot_name="system-${timestamp}"

    if ! findmnt -n -o FSTYPE / 2>/dev/null | grep -q "btrfs"; then
        log_error "$MSG_BACKUP_BTRFS_NOT_BTRFS"
        return 1
    fi

    mkdir -p "$snapshot_dir" 2>/dev/null

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_BACKUP_BTRFS_SNAPSHOT" "$snapshot_name")"

    if btrfs subvolume snapshot / "${snapshot_dir}/${snapshot_name}" 2>&1 | tee -a "$LOG_FILE"; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_BACKUP_BTRFS_SUCCESS" "${snapshot_dir}/${snapshot_name}")"
        return 0
    else
        log_error "$MSG_BACKUP_BTRFS_FAILED"
        return 1
    fi
}

# ZFS-Snapshot erstellen
backup_zfs() {
    local timestamp="$1"
    local snapshot_name="update-${timestamp}"

    local root_dataset
    root_dataset=$(zfs list -H -o name / 2>/dev/null | head -1)

    if [ -z "$root_dataset" ]; then
        log_error "$MSG_BACKUP_ZFS_NO_DATASET"
        return 1
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_BACKUP_ZFS_SNAPSHOT" "$root_dataset" "$snapshot_name")"

    if zfs snapshot "${root_dataset}@${snapshot_name}" 2>&1 | tee -a "$LOG_FILE"; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_BACKUP_ZFS_SUCCESS" "${root_dataset}@${snapshot_name}")"
        return 0
    else
        log_error "$MSG_BACKUP_ZFS_FAILED"
        return 1
    fi
}

# Rsync-Backup erstellen
backup_rsync() {
    local timestamp="$1"
    local backup_dest="${BACKUP_TARGET}/system-${timestamp}"

    if ! command -v rsync &>/dev/null; then
        log_error "$MSG_BACKUP_RSYNC_NOT_FOUND"
        return 1
    fi

    if ! mkdir -p "$backup_dest" 2>/dev/null; then
        # shellcheck disable=SC2059
        log_error "$(printf "$MSG_BACKUP_TARGET_CREATE_FAILED" "$backup_dest")"
        return 1
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_BACKUP_RSYNC_START" "$backup_dest")"

    if rsync -aAX \
        --exclude="/dev/*" \
        --exclude="/proc/*" \
        --exclude="/sys/*" \
        --exclude="/tmp/*" \
        --exclude="/run/*" \
        --exclude="/mnt/*" \
        --exclude="/media/*" \
        --exclude="/lost+found" \
        --exclude="${BACKUP_TARGET}/*" \
        --exclude="/var/log/*" \
        / "$backup_dest/" 2>&1 | tee -a "$LOG_FILE"; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_BACKUP_RSYNC_SUCCESS" "$backup_dest")"
        return 0
    else
        log_error "$MSG_BACKUP_RSYNC_FAILED"
        return 1
    fi
}

# Alte Backups rotieren
rotate_backups() {
    local method="$1"
    local retention="${BACKUP_RETENTION:-3}"

    case "$method" in
        rsync)
            local backup_count
            backup_count=$(find "$BACKUP_TARGET" -maxdepth 1 -name "system-*" -type d 2>/dev/null | wc -l)
            if [ "$backup_count" -gt "$retention" ]; then
                local to_delete=$(( backup_count - retention ))
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_BACKUP_ROTATE" "$to_delete")"
                find "$BACKUP_TARGET" -maxdepth 1 -name "system-*" -type d 2>/dev/null \
                    | sort \
                    | head -n "$to_delete" \
                    | while read -r old_backup; do
                        # shellcheck disable=SC2059
                        log_info "$(printf "$MSG_BACKUP_ROTATE_DELETE" "$old_backup")"
                        rm -rf "$old_backup" 2>&1 | tee -a "$LOG_FILE"
                    done
            fi
            ;;
        btrfs)
            local snapshot_dir="${BACKUP_TARGET}/btrfs-snapshots"
            local snap_count
            snap_count=$(find "$snapshot_dir" -maxdepth 1 -name "system-*" -type d 2>/dev/null | wc -l)
            if [ "$snap_count" -gt "$retention" ]; then
                local to_delete=$(( snap_count - retention ))
                find "$snapshot_dir" -maxdepth 1 -name "system-*" -type d 2>/dev/null \
                    | sort \
                    | head -n "$to_delete" \
                    | while read -r old_snap; do
                        # shellcheck disable=SC2059
                        log_info "$(printf "$MSG_BACKUP_ROTATE_DELETE" "$old_snap")"
                        btrfs subvolume delete "$old_snap" 2>&1 | tee -a "$LOG_FILE"
                    done
            fi
            ;;
        lvm)
            local snap_count
            snap_count=$(lvs --noheadings -o lv_name 2>/dev/null | grep -c "update-snap-" || echo "0")
            if [ "$snap_count" -gt "$retention" ]; then
                local to_delete=$(( snap_count - retention ))
                lvs --noheadings -o lv_name,lv_path 2>/dev/null \
                    | grep "update-snap-" \
                    | sort \
                    | head -n "$to_delete" \
                    | awk '{print $2}' \
                    | while read -r old_snap; do
                        # shellcheck disable=SC2059
                        log_info "$(printf "$MSG_BACKUP_ROTATE_DELETE" "$old_snap")"
                        lvremove -f "$old_snap" 2>&1 | tee -a "$LOG_FILE"
                    done
            fi
            ;;
        zfs)
            local snap_count
            snap_count=$(zfs list -H -t snapshot -o name 2>/dev/null | grep -c "@update-" || echo "0")
            if [ "$snap_count" -gt "$retention" ]; then
                local to_delete=$(( snap_count - retention ))
                zfs list -H -t snapshot -o name 2>/dev/null \
                    | grep "@update-" \
                    | sort \
                    | head -n "$to_delete" \
                    | while read -r old_snap; do
                        # shellcheck disable=SC2059
                        log_info "$(printf "$MSG_BACKUP_ROTATE_DELETE" "$old_snap")"
                        zfs destroy "$old_snap" 2>&1 | tee -a "$LOG_FILE"
                    done
            fi
            ;;
    esac
}

# Prüft ob Backup-Ziel auf demselben Laufwerk wie / liegt
check_backup_target() {
    local target="$1"

    local device_root device_target
    device_root=$(stat -c %d / 2>/dev/null)
    mkdir -p "$target" 2>/dev/null
    device_target=$(stat -c %d "$target" 2>/dev/null)

    if [ "$device_root" != "$device_target" ]; then
        return 0
    fi

    log_warning "$MSG_BACKUP_SAME_DEVICE"

    local used_kb
    used_kb=$(df -k / | awk 'NR==2 {print $3}')

    local free_kb
    free_kb=$(df -k "$target" | awk 'NR==2 {print $4}')

    local required_kb free_gb required_gb used_gb
    required_kb=$(awk "BEGIN { printf \"%d\", $used_kb * 1.2 }")
    used_gb=$(awk "BEGIN { printf \"%.1f\", $used_kb / 1048576 }")
    free_gb=$(awk "BEGIN { printf \"%.1f\", $free_kb / 1048576 }")
    required_gb=$(awk "BEGIN { printf \"%.1f\", $required_kb / 1048576 }")

    if [ "$free_kb" -ge "$required_kb" ]; then
        # shellcheck disable=SC2059
        log_warning "$(printf "$MSG_BACKUP_SAME_DEVICE_OK" "$free_gb" "$required_gb")"
        return 0
    else
        # shellcheck disable=SC2059
        log_error "$(printf "$MSG_BACKUP_SAME_DEVICE_LOW" "$free_gb" "$required_gb" "$used_gb")"
        return 1
    fi
}

# Backup erstellen (Hauptfunktion)
run_backup() {
    if [ "$ENABLE_BACKUP" != "true" ]; then
        return 0
    fi

    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local method="${BACKUP_METHOD:-rsync}"

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_BACKUP_START" "$method")"

    if [ "$method" = "rsync" ] || [ "$method" = "btrfs" ]; then
        if [ -z "$BACKUP_TARGET" ]; then
            log_error "$MSG_BACKUP_NO_TARGET"
            return 1
        fi
        if ! mkdir -p "$BACKUP_TARGET" 2>/dev/null; then
            # shellcheck disable=SC2059
            log_error "$(printf "$MSG_BACKUP_TARGET_CREATE_FAILED" "$BACKUP_TARGET")"
            return 1
        fi
        if ! check_backup_target "$BACKUP_TARGET"; then
            return 1
        fi
    fi

    local backup_exit=0

    case "$method" in
        lvm)
            if ! command -v lvcreate &>/dev/null; then
                log_error "$MSG_BACKUP_LVM_NOT_FOUND"
                backup_exit=1
            else
                backup_lvm "$timestamp" || backup_exit=1
            fi
            ;;
        btrfs)
            if ! command -v btrfs &>/dev/null; then
                log_error "$MSG_BACKUP_BTRFS_NOT_FOUND"
                backup_exit=1
            else
                backup_btrfs "$timestamp" || backup_exit=1
            fi
            ;;
        zfs)
            if ! command -v zfs &>/dev/null; then
                log_error "$MSG_BACKUP_ZFS_NOT_FOUND"
                backup_exit=1
            else
                backup_zfs "$timestamp" || backup_exit=1
            fi
            ;;
        rsync)
            backup_rsync "$timestamp" || backup_exit=1
            ;;
        *)
            # shellcheck disable=SC2059
            log_error "$(printf "$MSG_BACKUP_UNKNOWN_METHOD" "$method")"
            backup_exit=1
            ;;
    esac

    if [ "$backup_exit" -eq 0 ]; then
        rotate_backups "$method"
        log_info "$MSG_BACKUP_DONE"
    else
        log_warning "$MSG_BACKUP_FAILED_CONTINUE"
    fi

    return 0
}
