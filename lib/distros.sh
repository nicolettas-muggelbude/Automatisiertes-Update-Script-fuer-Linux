#!/bin/bash
# lib/distros.sh - Distributionsspezifische Paketmanager-Updates & Reboot-Check

# Update für Debian/Ubuntu/Mint
update_debian() {
    log_info "$MSG_UPDATE_START_DEBIAN"

    local bw_opts=()
    if [ -n "${EFFECTIVE_BANDWIDTH_LIMIT:-}" ]; then
        bw_opts=("-o" "Acquire::http::Dl-Limit=${EFFECTIVE_BANDWIDTH_LIMIT}")
    fi

    DEBIAN_FRONTEND=noninteractive apt-get update "${bw_opts[@]}" 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_APT_UPDATE_FAILED"
        return 1
    fi

    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y "${bw_opts[@]}" 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_APT_UPGRADE_FAILED"
        return 1
    fi

    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y "${bw_opts[@]}" 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_APT_DIST_UPGRADE_FAILED"
        return 1
    fi

    safe_autoremove "apt"
    DEBIAN_FRONTEND=noninteractive apt-get autoclean -y 2>&1 | tee -a "$LOG_FILE"

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Update für RHEL/Fedora
update_redhat() {
    log_info "$MSG_UPDATE_START_REDHAT"

    local bw_opts=()
    if [ -n "${EFFECTIVE_BANDWIDTH_LIMIT:-}" ]; then
        bw_opts=("--setopt=throttle=${EFFECTIVE_BANDWIDTH_LIMIT}k")
    fi

    if command -v dnf &> /dev/null; then
        dnf check-update 2>&1 | tee -a "$LOG_FILE"
        dnf upgrade -y "${bw_opts[@]}" 2>&1 | tee -a "$LOG_FILE"
        if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            log_error "$MSG_DNF_FAILED"
            return 1
        fi
        safe_autoremove "dnf"
    elif command -v yum &> /dev/null; then
        yum check-update 2>&1 | tee -a "$LOG_FILE"
        yum update -y "${bw_opts[@]}" 2>&1 | tee -a "$LOG_FILE"
        if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            log_error "$MSG_YUM_FAILED"
            return 1
        fi
        safe_autoremove "yum"
    else
        log_error "$MSG_NO_PKG_MANAGER"
        return 1
    fi

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Bandbreiten-Wrapper via trickle (Fallback für Distros ohne natives Limit)
run_with_trickle() {
    if [ -n "${EFFECTIVE_BANDWIDTH_LIMIT:-}" ] && command -v trickle &>/dev/null; then
        trickle -s -d "$EFFECTIVE_BANDWIDTH_LIMIT" "$@"
    else
        if [ -n "${EFFECTIVE_BANDWIDTH_LIMIT:-}" ] && ! command -v trickle &>/dev/null; then
            # shellcheck disable=SC2059
            log_info "$(printf "$MSG_BANDWIDTH_NO_TRICKLE" "$1")"
        fi
        "$@"
    fi
}

# Update für openSUSE
update_suse() {
    log_info "$MSG_UPDATE_START_SUSE"

    zypper refresh 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_ZYPPER_REFRESH_FAILED"
        return 1
    fi

    run_with_trickle zypper update -y 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_ZYPPER_UPDATE_FAILED"
        return 1
    fi

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Update für Solus
update_solus() {
    log_info "$MSG_UPDATE_START_SOLUS"

    eopkg update-repo 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_EOPKG_REPO_FAILED"
        return 1
    fi

    run_with_trickle eopkg upgrade -y 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_EOPKG_UPGRADE_FAILED"
        return 1
    fi

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Update für Arch Linux
update_arch() {
    log_info "$MSG_UPDATE_START_ARCH"

    run_with_trickle pacman -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_PACMAN_FAILED"
        return 1
    fi

    pacman -Sc --noconfirm 2>&1 | tee -a "$LOG_FILE"

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Update für Void Linux
update_void() {
    log_info "$MSG_UPDATE_START_VOID"

    run_with_trickle xbps-install -Su -y 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_XBPS_FAILED"
        return 1
    fi

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Neustart prüfen
check_reboot_required() {
    local reboot_needed=false

    # Methode 1: /var/run/reboot-required (Debian/Ubuntu/Mint)
    if [ -f /var/run/reboot-required ]; then
        reboot_needed=true
    fi

    # Methode 2: Kernel-Update (neuer Kernel != laufender Kernel)
    local current_kernel installed_kernel
    current_kernel=$(uname -r)

    case "$DISTRO" in
        debian|ubuntu|linuxmint|mint|mx)
            installed_kernel=$(dpkg -l | grep "^ii.*linux-image-[0-9]" | awk '{print $2}' | sort -V | tail -1 | sed 's/linux-image-//')
            if [ -n "$installed_kernel" ] && [ "$installed_kernel" != "$current_kernel" ]; then
                reboot_needed=true
            fi
            ;;
        fedora|rhel|centos|rocky|almalinux)
            installed_kernel=$(rpm -q kernel --last | head -1 | awk '{print $1}' | sed 's/kernel-//')
            if [ -n "$installed_kernel" ] && [ "$installed_kernel" != "$current_kernel" ]; then
                reboot_needed=true
            fi
            ;;
    esac

    if [ "$reboot_needed" = false ]; then
        return 0
    fi

    if [ "$AUTO_REBOOT" = "true" ] || [ "$AUTO_REBOOT" = true ]; then
        log_warning "$MSG_REBOOT_AUTO_COUNTDOWN"
        log "AUTO_REBOOT ist aktiviert, starte Neustart-Countdown"

        send_email "$EMAIL_SUBJECT_REBOOT" "$MSG_REBOOT_NOTIFICATION"
        send_notification \
            "$NOTIFICATION_REBOOT_REQUIRED" \
            "$NOTIFICATION_REBOOT_AUTO_BODY" \
            "critical" \
            "system-reboot"

        log "Führe Shutdown-Befehl aus: /sbin/shutdown -r +5"
        /sbin/shutdown -r +5 "System wird in 5 Minuten neu gestartet (Update)" 2>&1 | tee -a "$LOG_FILE"

        log_info "Neustart geplant in 5 Minuten"
        log_info "Abbrechen mit: sudo shutdown -c"
    else
        log_warning "$MSG_REBOOT_MANUAL"
        log "AUTO_REBOOT ist deaktiviert (aktueller Wert: $AUTO_REBOOT)"

        send_notification \
            "$NOTIFICATION_REBOOT_REQUIRED" \
            "$NOTIFICATION_REBOOT_REQUIRED_BODY" \
            "normal" \
            "system-reboot"
    fi
}
