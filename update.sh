#!/bin/bash

#############################################################
# Linux System Update Script v2.0.0
# Unterstützt: Debian, Ubuntu, Mint, RHEL, Fedora, SUSE
# Solus, Arch, Void
# MIT License
#############################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#############################################################
# Module laden
#############################################################
for _lib in core notifications hooks backup kernel upgrades network distros; do
    # shellcheck source=/dev/null
    source "${SCRIPT_DIR}/lib/${_lib}.sh" || {
        echo "FEHLER: Kann ${SCRIPT_DIR}/lib/${_lib}.sh nicht laden"
        exit 1
    }
done
unset _lib

#############################################################
# Initialisierung
#############################################################
load_config
load_language
init_logging
warn_config_status

#############################################################
# Hauptprogramm
#############################################################

# Command-Line Parameter verarbeiten
UPGRADE_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --upgrade)
            UPGRADE_MODE=true
            shift
            ;;
        --help|-h)
            echo "Linux System Update-Script v2.0.0"
            echo ""
            echo "Verwendung: $0 [OPTIONEN]"
            echo ""
            echo "Optionen:"
            echo "  --upgrade    Führt Distribution-Upgrade durch (falls verfügbar)"
            echo "  --help, -h   Zeigt diese Hilfe an"
            echo ""
            exit 0
            ;;
        *)
            echo "Unbekannte Option: $1"
            echo "Verwende --help für weitere Informationen"
            exit 1
            ;;
    esac
done

log_info "$MSG_HEADER_START"
log_info "$MSG_HOSTNAME: $(hostname)"
log_info "$MSG_KERNEL: $(uname -r)"

# Root-Rechte prüfen
check_root

# System-Last prüfen
if ! check_system_load; then
    log_error "$MSG_LOAD_CHECK_ABORT"
    exit 1
fi

# Config-Debug-Info ins Log schreiben
log_config_debug

# Distribution erkennen
detect_distro

# Bandbreite messen und Limit setzen
detect_bandwidth

# Update-Zeitschätzung ausgeben
estimate_update_time

# NVIDIA-Kernel-Kompatibilität prüfen (VOR dem Update!)
check_nvidia_compatibility

# Pre-Update-Hooks ausführen
if ! run_pre_update_hooks; then
    log_error "$MSG_HOOKS_PRE_ABORT"
    send_email "$EMAIL_SUBJECT_FAILED" "$MSG_HOOKS_PRE_ABORT"
    exit 1
fi

# Backup erstellen
run_backup

# Wenn Upgrade-Modus, führe Upgrade durch
if [ "$UPGRADE_MODE" = true ]; then
    if [ "$BACKUP_BEFORE_UPGRADE" = "true" ] && [ "$ENABLE_BACKUP" != "true" ]; then
        local_backup_enabled_orig="$ENABLE_BACKUP"
        ENABLE_BACKUP=true
        run_backup
        ENABLE_BACKUP="$local_backup_enabled_orig"
    fi
    if perform_upgrade; then
        run_post_update_hooks
        log_info "$MSG_UPGRADE_SUCCESS"
        send_email "$EMAIL_SUBJECT_UPGRADE" "$MSG_UPGRADE_SUCCESS"
        exit 0
    else
        run_post_update_hooks
        log_error "$MSG_UPGRADE_FAILED"
        send_email "$EMAIL_SUBJECT_FAILED" "$MSG_UPGRADE_FAILED"
        exit 1
    fi
fi

# Update durchführen basierend auf Distribution
UPDATE_SUCCESS=false

case "$DISTRO" in
    debian|ubuntu|linuxmint|mint|mx)
        update_debian && UPDATE_SUCCESS=true
        ;;
    rhel|centos|fedora|rocky|almalinux)
        update_redhat && UPDATE_SUCCESS=true
        ;;
    opensuse|opensuse-leap|opensuse-tumbleweed|sles|suse)
        update_suse && UPDATE_SUCCESS=true
        ;;
    solus)
        update_solus && UPDATE_SUCCESS=true
        ;;
    arch|manjaro|endeavouros|garuda|arcolinux)
        update_arch && UPDATE_SUCCESS=true
        ;;
    void)
        update_void && UPDATE_SUCCESS=true
        ;;
    *)
        log_error "$MSG_DISTRO_NOT_SUPPORTED: $DISTRO"
        send_email "$EMAIL_SUBJECT_FAILED" "$MSG_DISTRO_NOT_SUPPORTED: $DISTRO"
        exit 1
        ;;
esac

# Snap-Pakete aktualisieren (falls installiert und Auto-Updates inaktiv)
update_snap

# Firmware-Updates via fwupd
update_fwupd

# Post-Update-Hooks ausführen (immer, unabhängig vom Ergebnis)
run_post_update_hooks

# Ergebnis auswerten
if [ "$UPDATE_SUCCESS" = true ]; then
    log_info "$MSG_HEADER_SUCCESS"

    send_notification \
        "$NOTIFICATION_UPDATE_SUCCESS" \
        "$NOTIFICATION_UPDATE_SUCCESS_BODY" \
        "normal" \
        "software-update-available"

    check_reboot_required

    check_upgrade_available
    UPGRADE_CHECK_RESULT=$?

    if [ "$UPGRADE_CHECK_RESULT" -eq 3 ] && [ "$AUTO_UPGRADE" = true ]; then
        log_info "AUTO_UPGRADE aktiviert, starte Upgrade-Prozess"
        perform_upgrade
    elif [ "$UPGRADE_CHECK_RESULT" -eq 3 ]; then
        # shellcheck disable=SC2059
        printf "$MSG_UPGRADE_INFO\n" "$0" | tee -a "$LOG_FILE"

        send_notification \
            "$NOTIFICATION_UPGRADE_AVAILABLE" \
            "$NOTIFICATION_UPGRADE_AVAILABLE_BODY" \
            "normal" \
            "system-software-update"
    fi

    EMAIL_BODY="$EMAIL_BODY_SUCCESS

$MSG_HOSTNAME: $(hostname)
$MSG_DISTRIBUTION: $DISTRO
$MSG_TIMESTAMP: $(date)
$MSG_LOGFILE: $LOG_FILE"

    send_email "$EMAIL_SUBJECT_SUCCESS" "$EMAIL_BODY"

    exit 0
else
    log_error "$MSG_HEADER_FAILED"

    send_notification \
        "$NOTIFICATION_UPDATE_FAILED" \
        "$NOTIFICATION_UPDATE_FAILED_BODY: $LOG_FILE" \
        "critical" \
        "dialog-error"

    EMAIL_BODY="$EMAIL_BODY_FAILED

$MSG_HOSTNAME: $(hostname)
$MSG_DISTRIBUTION: $DISTRO
$MSG_TIMESTAMP: $(date)
$MSG_LOGFILE: $LOG_FILE

$EMAIL_BODY_CHECK_LOG"

    send_email "$EMAIL_SUBJECT_FAILED" "$EMAIL_BODY"

    exit 1
fi
