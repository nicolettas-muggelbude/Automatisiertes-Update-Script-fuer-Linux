#!/bin/bash
# lib/upgrades.sh - Distribution-Upgrade-Check System (v1.5.0+)

# Bekannte Debian-Releases in Reihenfolge (nur stabile Versionen)
DEBIAN_CODENAMES_ORDERED="buster bullseye bookworm trixie"

# Ermittelt den nächsten Debian-Codename
get_next_debian_codename() {
    local current="$1"
    local prev=""

    for codename in $DEBIAN_CODENAMES_ORDERED; do
        if [ "$prev" = "$current" ]; then
            echo "$codename"
            return 0
        fi
        prev="$codename"
    done

    echo ""
    return 1
}

# Solus Upgrade-Check
check_upgrade_solus() {
    log_info "$MSG_UPGRADE_CHECKING_SOLUS"

    local repo_info
    repo_info=$(eopkg lr 2>/dev/null || echo "")

    if [ -z "$repo_info" ]; then
        log_warning "Konnte Repository-Informationen nicht abrufen"
        return 1
    fi

    local pending_updates
    pending_updates=$(eopkg list-pending 2>/dev/null | wc -l || echo "0")

    if [ "$pending_updates" -gt 0 ]; then
        log_info "Solus: $pending_updates ausstehende Updates gefunden"
        return 2
    fi

    log_info "$MSG_UPGRADE_NO_UPGRADE"
    return 0
}

# Arch Upgrade-Check
check_upgrade_arch() {
    log_info "$MSG_UPGRADE_CHECKING_ARCH"

    if ! command -v checkupdates &> /dev/null; then
        log_warning "checkupdates nicht gefunden (pacman-contrib erforderlich)"
        return 1
    fi

    local updates
    updates=$(checkupdates 2>/dev/null | wc -l || echo "0")

    if [ "$updates" -gt 0 ]; then
        log_info "Arch: $updates verfügbare Updates"
        return 2
    fi

    log_info "$MSG_UPGRADE_NO_UPGRADE"
    return 0
}

# Debian/Ubuntu Upgrade-Check (via do-release-upgrade)
check_upgrade_debian() {
    log_info "$MSG_UPGRADE_CHECKING_DEBIAN"

    if echo "$DISTRO" | grep -qi "mx"; then
        log_info "MX-Linux: Keine automatischen Distribution-Upgrades verfügbar"
        return 1
    fi

    if ! command -v do-release-upgrade &> /dev/null; then
        log_warning "do-release-upgrade nicht gefunden"
        return 1
    fi

    local check_result
    check_result=$(do-release-upgrade -c 2>&1 || echo "")

    if echo "$check_result" | grep -q "New release"; then
        local new_version
        new_version=$(echo "$check_result" | grep "New release" | sed 's/.*New release //' | sed "s/'//g" | awk '{print $1}')
        # shellcheck disable=SC2059
        printf "$MSG_UPGRADE_AVAILABLE\n" "$VERSION" "$new_version" | tee -a "$LOG_FILE"

        if [ "$UPGRADE_NOTIFY_EMAIL" = true ]; then
            local email_body="$EMAIL_BODY_UPGRADE

Aktuelle Version: $NAME $VERSION
Neue Version: $new_version

Für Upgrade ausführen:
sudo $0 --upgrade

$MSG_UPGRADE_BACKUP_WARNING"
            send_email "$EMAIL_SUBJECT_UPGRADE" "$email_body"
        fi

        return 3
    fi

    log_info "$MSG_UPGRADE_NO_UPGRADE"
    return 0
}

# Debian Upgrade-Check (nativ, ohne do-release-upgrade)
check_upgrade_debian_native() {
    log_info "$MSG_UPGRADE_CHECKING_DEBIAN"

    local current_codename
    current_codename=$(grep "^VERSION_CODENAME=" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')

    if [ -z "$current_codename" ]; then
        log_warning "Kann Debian-Codename nicht ermitteln"
        return 1
    fi

    local next_codename
    next_codename=$(get_next_debian_codename "$current_codename")

    if [ -z "$next_codename" ]; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_UPGRADE_DEBIAN_NOT_AVAILABLE" "$current_codename")"
        return 0
    fi

    # shellcheck disable=SC2059
    printf "$MSG_UPGRADE_AVAILABLE\n" "Debian $current_codename" "Debian $next_codename" | tee -a "$LOG_FILE"

    if [ "$UPGRADE_NOTIFY_EMAIL" = true ]; then
        local email_body="$EMAIL_BODY_UPGRADE

Aktuelle Version: Debian $current_codename
Neue Version: Debian $next_codename

Für Upgrade ausführen:
sudo $0 --upgrade

$MSG_UPGRADE_BACKUP_WARNING"
        send_email "$EMAIL_SUBJECT_UPGRADE" "$email_body"
    fi

    return 3
}

# Debian Upgrade durchführen (natives Debian)
perform_upgrade_debian_native() {
    local current_codename
    current_codename=$(grep "^VERSION_CODENAME=" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')

    local next_codename
    next_codename=$(get_next_debian_codename "$current_codename")

    if [ -z "$next_codename" ]; then
        log_error "$MSG_UPGRADE_NOT_AVAILABLE"
        return 1
    fi

    # shellcheck disable=SC2059
    printf "$MSG_UPGRADE_START\n" "Debian $next_codename" | tee -a "$LOG_FILE"

    # Schritt 1: APT-Quellen sichern
    local sources_backup
    sources_backup="/etc/apt/sources.list.bak.$(date +%Y%m%d-%H%M%S)"
    if cp /etc/apt/sources.list "$sources_backup" 2>/dev/null; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_UPGRADE_DEBIAN_SOURCES_BACKUP" "$sources_backup")"
    else
        log_error "$MSG_UPGRADE_DEBIAN_SOURCES_BACKUP_FAILED"
        return 1
    fi

    # Schritt 2: Codename in sources.list ersetzen
    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_UPGRADE_DEBIAN_SOURCES_UPDATE" "$current_codename" "$next_codename")"

    if ! sed -i "s/${current_codename}/${next_codename}/g" /etc/apt/sources.list; then
        log_error "Fehler beim Aktualisieren von /etc/apt/sources.list"
        cp "$sources_backup" /etc/apt/sources.list
        return 1
    fi

    if [ -d /etc/apt/sources.list.d/ ]; then
        find /etc/apt/sources.list.d/ -type f \( -name "*.list" -o -name "*.sources" \) \
            -exec sed -i "s/${current_codename}/${next_codename}/g" {} \; 2>/dev/null || true
    fi

    # Schritt 3: apt-get update
    log_info "$MSG_UPGRADE_REFRESH_REPOS"
    if ! DEBIAN_FRONTEND=noninteractive apt-get update 2>&1 | tee -a "$LOG_FILE"; then
        log_error "$MSG_UPGRADE_REFRESH_FAILED"
        # shellcheck disable=SC2059
        log_warning "$(printf "$MSG_UPGRADE_DEBIAN_SOURCES_RESTORE" "$sources_backup")"
        cp "$sources_backup" /etc/apt/sources.list
        if [ -d /etc/apt/sources.list.d/ ]; then
            find /etc/apt/sources.list.d/ -type f \( -name "*.list" -o -name "*.sources" \) \
                -exec sed -i "s/${next_codename}/${current_codename}/g" {} \; 2>/dev/null || true
        fi
        return 1
    fi

    # Schritt 4: Dry-Run
    log_info "$MSG_UPGRADE_DRY_RUN_START"
    if ! DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade --simulate 2>&1 | tee -a "$LOG_FILE"; then
        log_error "$MSG_UPGRADE_DRY_RUN_FAILED"
        echo -n "$MSG_NVIDIA_CONTINUE_ANYWAY "
        read -r response
        if [[ ! "$response" =~ ^[jJyY]$ ]]; then
            log_info "$MSG_UPGRADE_CANCELLED"
            # shellcheck disable=SC2059
            log_warning "$(printf "$MSG_UPGRADE_DEBIAN_SOURCES_RESTORE" "$sources_backup")"
            cp "$sources_backup" /etc/apt/sources.list
            if [ -d /etc/apt/sources.list.d/ ]; then
                find /etc/apt/sources.list.d/ -type f \( -name "*.list" -o -name "*.sources" \) \
                    -exec sed -i "s/${next_codename}/${current_codename}/g" {} \; 2>/dev/null || true
            fi
            DEBIAN_FRONTEND=noninteractive apt-get update 2>/dev/null | tee -a "$LOG_FILE"
            return 1
        fi
    else
        log_info "$MSG_UPGRADE_DRY_RUN_OK"
    fi

    # Schritt 5: Upgrade durchführen
    log_info "$MSG_UPGRADE_PERFORMING"
    if DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y 2>&1 | tee -a "$LOG_FILE"; then
        safe_autoremove "apt"
        log_info "$MSG_UPGRADE_SUCCESS"
        return 0
    else
        log_error "$MSG_UPGRADE_FAILED"
        return 1
    fi
}

# Linux Mint Upgrade-Check
check_upgrade_mint() {
    log_info "$MSG_UPGRADE_CHECKING_MINT"

    if ! command -v mintupgrade &> /dev/null; then
        log_warning "$MSG_UPGRADE_MINTUPGRADE_NOT_INSTALLED"
        log_info "$MSG_UPGRADE_MINTUPGRADE_INSTALLING"

        if DEBIAN_FRONTEND=noninteractive apt-get update 2>&1 | tee -a "$LOG_FILE" && \
           DEBIAN_FRONTEND=noninteractive apt-get install -y mintupgrade 2>&1 | tee -a "$LOG_FILE"; then
            log_info "$MSG_UPGRADE_MINTUPGRADE_INSTALL_SUCCESS"
        else
            log_error "$MSG_UPGRADE_MINTUPGRADE_INSTALL_FAILED"
            log_info "$MSG_UPGRADE_MINTUPGRADE_MANUAL"
            return 1
        fi
    fi

    local check_result
    check_result=$(mintupgrade check 2>&1 || echo "")

    if echo "$check_result" | grep -qi "upgrade.*available\|new.*version"; then
        local new_version
        new_version=$(echo "$check_result" | grep -i "version" | head -1 | grep -oP '\d+(\.\d+)*' | head -1)

        if [ -n "$new_version" ]; then
            # shellcheck disable=SC2059
            printf "$MSG_UPGRADE_AVAILABLE\n" "Linux Mint $VERSION" "Linux Mint $new_version" | tee -a "$LOG_FILE"
        else
            log_info "Linux Mint Upgrade verfügbar (Version konnte nicht automatisch erkannt werden)"
        fi

        if [ "$UPGRADE_NOTIFY_EMAIL" = true ]; then
            local email_body="$EMAIL_BODY_UPGRADE

Aktuelle Version: Linux Mint $VERSION
Neue Version: Linux Mint ${new_version:-unbekannt}

Für Upgrade ausführen:
sudo $0 --upgrade

$MSG_UPGRADE_BACKUP_WARNING"
            send_email "$EMAIL_SUBJECT_UPGRADE" "$email_body"
        fi

        return 3
    fi

    log_info "$MSG_UPGRADE_NO_UPGRADE"
    return 0
}

# Fedora Upgrade-Check
check_upgrade_fedora() {
    log_info "$MSG_UPGRADE_CHECKING_FEDORA"

    if ! command -v dnf &> /dev/null; then
        log_warning "dnf nicht gefunden"
        return 1
    fi

    local check_result
    check_result=$(dnf system-upgrade download --refresh --releasever="$((VERSION + 1))" --assumeno 2>&1 || echo "")

    if echo "$check_result" | grep -q "will be installed"; then
        local new_version=$((VERSION + 1))
        # shellcheck disable=SC2059
        printf "$MSG_UPGRADE_AVAILABLE\n" "Fedora $VERSION" "Fedora $new_version" | tee -a "$LOG_FILE"

        if [ "$UPGRADE_NOTIFY_EMAIL" = true ]; then
            local email_body="$EMAIL_BODY_UPGRADE

Aktuelle Version: Fedora $VERSION
Neue Version: Fedora $new_version

Für Upgrade ausführen:
sudo $0 --upgrade

$MSG_UPGRADE_BACKUP_WARNING"
            send_email "$EMAIL_SUBJECT_UPGRADE" "$email_body"
        fi

        return 3
    fi

    log_info "$MSG_UPGRADE_NO_UPGRADE"
    return 0
}

# Hauptfunktion: Upgrade-Check
check_upgrade_available() {
    if [ "$ENABLE_UPGRADE_CHECK" != "true" ]; then
        log_info "$MSG_UPGRADE_DISABLED"
        return 0
    fi

    log_info "$MSG_UPGRADE_CHECK"

    case "$DISTRO" in
        solus)
            check_upgrade_solus
            return $?
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            check_upgrade_arch
            return $?
            ;;
        linuxmint|mint)
            check_upgrade_mint
            return $?
            ;;
        debian)
            check_upgrade_debian_native
            return $?
            ;;
        ubuntu|mx)
            check_upgrade_debian
            return $?
            ;;
        fedora)
            check_upgrade_fedora
            return $?
            ;;
        *)
            log_info "$MSG_UPGRADE_NOT_SUPPORTED"
            return 1
            ;;
    esac
}

# Upgrade durchführen
perform_upgrade() {
    log_warning "$MSG_UPGRADE_BACKUP_WARNING"

    if [ "$AUTO_UPGRADE" != "true" ]; then
        echo -n "$MSG_UPGRADE_CONFIRM "
        read -r response
        if [[ ! "$response" =~ ^[jJyY]$ ]]; then
            log_info "$MSG_UPGRADE_CANCELLED"
            return 1
        fi
    fi

    case "$DISTRO" in
        linuxmint|mint)
            if ! command -v mintupgrade &> /dev/null; then
                log_warning "$MSG_UPGRADE_MINTUPGRADE_NOT_INSTALLED"
                log_info "$MSG_UPGRADE_MINTUPGRADE_INSTALLING"

                if DEBIAN_FRONTEND=noninteractive apt-get update 2>&1 | tee -a "$LOG_FILE" && \
                   DEBIAN_FRONTEND=noninteractive apt-get install -y mintupgrade 2>&1 | tee -a "$LOG_FILE"; then
                    log_info "$MSG_UPGRADE_MINTUPGRADE_INSTALL_SUCCESS"
                else
                    log_error "$MSG_UPGRADE_MINTUPGRADE_INSTALL_FAILED"
                    log_info "$MSG_UPGRADE_MINTUPGRADE_MANUAL"
                    return 1
                fi
            fi

            log_info "$MSG_UPGRADE_MINTUPGRADE_CHECK"
            if ! mintupgrade check 2>&1 | tee -a "$LOG_FILE"; then
                log_error "$MSG_UPGRADE_MINTUPGRADE_CHECK_FAILED"
                return 1
            fi

            log_info "$MSG_UPGRADE_DRY_RUN_START"
            if ! mintupgrade --dry-run 2>&1 | tee -a "$LOG_FILE"; then
                log_error "$MSG_UPGRADE_DRY_RUN_FAILED"
                echo -n "$MSG_NVIDIA_CONTINUE_ANYWAY "
                read -r response
                if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                    log_info "$MSG_UPGRADE_CANCELLED"
                    return 1
                fi
            else
                log_info "$MSG_UPGRADE_DRY_RUN_OK"
            fi

            # shellcheck disable=SC2059
            printf "$MSG_UPGRADE_START\n" "neue Linux Mint Version" | tee -a "$LOG_FILE"
            log_info "$MSG_UPGRADE_MINTUPGRADE_DOWNLOAD"
            if ! mintupgrade download 2>&1 | tee -a "$LOG_FILE"; then
                log_error "$MSG_UPGRADE_MINTUPGRADE_DOWNLOAD_FAILED"
                return 1
            fi

            log_info "$MSG_UPGRADE_MINTUPGRADE_UPGRADE"
            if mintupgrade upgrade 2>&1 | tee -a "$LOG_FILE"; then
                log_info "$MSG_UPGRADE_SUCCESS"
                return 0
            else
                log_error "$MSG_UPGRADE_FAILED"
                return 1
            fi
            ;;
        debian)
            perform_upgrade_debian_native
            return $?
            ;;
        ubuntu|mx)
            if echo "$DISTRO" | grep -qi "mx"; then
                log_error "MX-Linux: Keine automatischen Distribution-Upgrades verfügbar"
                log_info "Bitte nutze MX Package Installer für Distribution-Upgrades"
                return 1
            fi

            if ! command -v do-release-upgrade &> /dev/null; then
                log_error "do-release-upgrade nicht gefunden"
                return 1
            fi

            log_info "$MSG_UPGRADE_CHECK_AVAILABLE"
            local check_result
            check_result=$(do-release-upgrade -c 2>&1 || echo "")

            if ! echo "$check_result" | grep -qi "new release\|upgrade"; then
                log_error "$MSG_UPGRADE_NOT_AVAILABLE"
                return 1
            fi
            log_info "$MSG_UPGRADE_AVAILABLE_CONFIRMED"

            log_info "$MSG_UPGRADE_DRY_RUN_START"
            if ! do-release-upgrade -c -f DistUpgradeViewNonInteractive 2>&1 | tee -a "$LOG_FILE"; then
                log_error "$MSG_UPGRADE_DRY_RUN_FAILED"
                echo -n "$MSG_NVIDIA_CONTINUE_ANYWAY "
                read -r response
                if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                    log_info "$MSG_UPGRADE_CANCELLED"
                    return 1
                fi
            else
                log_info "$MSG_UPGRADE_DRY_RUN_OK"
            fi

            # shellcheck disable=SC2059
            printf "$MSG_UPGRADE_START\n" "neue Version" | tee -a "$LOG_FILE"
            if do-release-upgrade -f DistUpgradeViewNonInteractive 2>&1 | tee -a "$LOG_FILE"; then
                log_info "$MSG_UPGRADE_SUCCESS"
                return 0
            else
                log_error "$MSG_UPGRADE_FAILED"
                return 1
            fi
            ;;
        fedora)
            local new_version=$((VERSION + 1))

            # shellcheck disable=SC2059
            printf "$MSG_UPGRADE_CHECK_AVAILABLE\n" | tee -a "$LOG_FILE"
            if ! dnf list --available --releasever="$new_version" fedora-release 2>&1 | grep -q "fedora-release"; then
                # shellcheck disable=SC2059
                printf "$MSG_UPGRADE_NOT_AVAILABLE\n" "Fedora $new_version" | tee -a "$LOG_FILE"
                return 1
            fi
            log_info "$MSG_UPGRADE_AVAILABLE_CONFIRMED"

            log_info "$MSG_UPGRADE_DRY_RUN_START"
            if ! dnf system-upgrade download --refresh --releasever="$new_version" --assumeno 2>&1 | tee -a "$LOG_FILE" | grep -qi "will be installed\|will be upgraded"; then
                log_error "$MSG_UPGRADE_DRY_RUN_FAILED"
                echo -n "$MSG_NVIDIA_CONTINUE_ANYWAY "
                read -r response
                if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                    log_info "$MSG_UPGRADE_CANCELLED"
                    return 1
                fi
            else
                log_info "$MSG_UPGRADE_DRY_RUN_OK"
            fi

            # shellcheck disable=SC2059
            printf "$MSG_UPGRADE_START\n" "Fedora $new_version" | tee -a "$LOG_FILE"
            log_info "$MSG_UPGRADE_DOWNLOADING"
            if ! dnf system-upgrade download -y --releasever="$new_version" 2>&1 | tee -a "$LOG_FILE"; then
                log_error "$MSG_UPGRADE_DOWNLOAD_ERROR"
                return 1
            fi

            log_info "$MSG_UPGRADE_REBOOT_PENDING"
            if dnf system-upgrade reboot 2>&1 | tee -a "$LOG_FILE"; then
                log_info "$MSG_UPGRADE_SUCCESS"
                return 0
            else
                log_error "$MSG_UPGRADE_FAILED"
                return 1
            fi
            ;;
        opensuse*|sles)
            if ! command -v zypper &> /dev/null; then
                log_error "zypper nicht gefunden"
                return 1
            fi

            log_info "$MSG_UPGRADE_REFRESH_REPOS"
            if ! zypper refresh 2>&1 | tee -a "$LOG_FILE"; then
                log_error "$MSG_UPGRADE_REFRESH_FAILED"
                return 1
            fi

            log_info "$MSG_UPGRADE_DRY_RUN_START"
            if ! zypper dup --dry-run --no-confirm 2>&1 | tee -a "$LOG_FILE"; then
                log_error "$MSG_UPGRADE_DRY_RUN_FAILED"
                echo -n "$MSG_NVIDIA_CONTINUE_ANYWAY "
                read -r response
                if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                    log_info "$MSG_UPGRADE_CANCELLED"
                    return 1
                fi
            else
                log_info "$MSG_UPGRADE_DRY_RUN_OK"
            fi

            # shellcheck disable=SC2059
            printf "$MSG_UPGRADE_START\n" "neue openSUSE Version" | tee -a "$LOG_FILE"
            log_info "$MSG_UPGRADE_PERFORMING"
            if zypper dup --no-confirm 2>&1 | tee -a "$LOG_FILE"; then
                log_info "$MSG_UPGRADE_SUCCESS"
                return 0
            else
                log_error "$MSG_UPGRADE_FAILED"
                return 1
            fi
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            log_info "Arch-basierte Distributionen verwenden Rolling Release"
            log_info "Ein vollständiges System-Update entspricht einem Upgrade"
            log_warning "$MSG_UPGRADE_NOT_SUPPORTED"
            log_info "Verwende: sudo $0 (reguläres Update)"
            return 1
            ;;
        solus)
            log_info "Solus verwendet Rolling Release"
            log_warning "$MSG_UPGRADE_NOT_SUPPORTED"
            log_info "Verwende: sudo $0 (reguläres Update)"
            return 1
            ;;
        *)
            log_error "$MSG_UPGRADE_NOT_SUPPORTED"
            return 1
            ;;
    esac
}
