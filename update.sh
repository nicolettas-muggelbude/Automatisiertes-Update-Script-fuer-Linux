#!/bin/bash

#############################################################
# Linux System Update Script
# Unterstützt: Debian, Ubuntu, Mint, RHEL, Fedora, SUSE
# Solus, Arch, Void
# MIT License
############################################################# 

# Farbcodes für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Konfigurationsdatei laden
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# XDG-konforme Config-Pfade
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CONFIG_DIR="${XDG_CONFIG_HOME}/linux-update-script"
XDG_CONFIG_FILE="${XDG_CONFIG_DIR}/config.conf"
SYSTEM_CONFIG_FILE="/etc/linux-update-script/config.conf"
OLD_CONFIG_FILE="${SCRIPT_DIR}/config.conf"

# Standard-Konfiguration
ENABLE_EMAIL=false
EMAIL_RECIPIENT=""
LOG_DIR="/var/log/system-updates"
AUTO_REBOOT=false
LANGUAGE=auto
KERNEL_PROTECTION=true
MIN_KERNELS=3
ENABLE_UPGRADE_CHECK=true
AUTO_UPGRADE=false
UPGRADE_NOTIFY_EMAIL=true
ENABLE_DESKTOP_NOTIFICATION=true
NOTIFICATION_TIMEOUT=5000

# Config-Migration Funktion (wird nach load_language aufgerufen)
migrate_config() {
    # Neue Location bereits vorhanden? → Migration nicht nötig
    if [ -f "$XDG_CONFIG_FILE" ]; then
        return 0
    fi

    # Alte Config vorhanden? → Migrieren
    if [ -f "$OLD_CONFIG_FILE" ]; then
        # Sprache muss bereits geladen sein für Meldungen
        echo -e "${YELLOW}[${LABEL_INFO}]${NC} $MSG_CONFIG_MIGRATE_START"

        # Verzeichnis erstellen
        mkdir -p "$XDG_CONFIG_DIR" 2>/dev/null || {
            # shellcheck disable=SC2059
            echo -e "${RED}[${LABEL_ERROR}]${NC} $(printf "$MSG_CONFIG_MIGRATE_FAILED" "Kann Verzeichnis nicht erstellen")"
            return 1
        }

        # Config kopieren
        if cp "$OLD_CONFIG_FILE" "$XDG_CONFIG_FILE" 2>/dev/null; then
            # shellcheck disable=SC2059
            echo -e "${GREEN}[${LABEL_INFO}]${NC} $(printf "$MSG_CONFIG_MIGRATE_SUCCESS" "$XDG_CONFIG_FILE")"

            # Alte Config umbenennen (als Backup)
            # shellcheck disable=SC2059
            mv "$OLD_CONFIG_FILE" "${OLD_CONFIG_FILE}.migrated" 2>/dev/null && \
                echo -e "${GREEN}[${LABEL_INFO}]${NC} $(printf "$MSG_CONFIG_MIGRATE_BACKUP" "${OLD_CONFIG_FILE}.migrated")"

            return 0
        else
            # shellcheck disable=SC2059
            echo -e "${RED}[${LABEL_ERROR}]${NC} $(printf "$MSG_CONFIG_MIGRATE_FAILED" "Kann Config nicht kopieren")"
            return 1
        fi
    fi

    return 0
}

# Config-Datei finden (Fallback-Mechanismus)
find_config_file() {
    # 1. XDG-konform (bevorzugt)
    if [ -f "$XDG_CONFIG_FILE" ]; then
        CONFIG_FILE="$XDG_CONFIG_FILE"
        return 0
    fi

    # 2. System-weit
    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        CONFIG_FILE="$SYSTEM_CONFIG_FILE"
        return 0
    fi

    # 3. Alt (deprecated, nur für Backwards-Compatibility)
    if [ -f "$OLD_CONFIG_FILE" ]; then
        CONFIG_FILE="$OLD_CONFIG_FILE"
        # Warnung wird später ausgegeben (nach load_language)
        return 0
    fi

    # Keine Config gefunden
    return 1
}

# Config-Datei suchen
if ! find_config_file; then
    CONFIG_FILE=""  # Keine Config gefunden, nur Defaults nutzen
fi

# Konfiguration laden, falls vorhanden
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

# Sprache laden
load_language() {
    local lang="${LANGUAGE:-auto}"

    # Automatische Sprach-Erkennung
    if [ "$lang" = "auto" ]; then
        # System-Locale auslesen (z.B. de_DE.UTF-8 -> de)
        lang="${LANG%%.*}"    # Entferne .UTF-8
        lang="${lang%%_*}"    # Entferne _DE
        lang="${lang:-en}"    # Fallback zu Englisch
    fi

    # Sprachdatei laden
    local lang_file="${SCRIPT_DIR}/lang/${lang}.lang"
    if [ -f "$lang_file" ]; then
        # shellcheck source=/dev/null
        source "$lang_file"
    else
        # Fallback zu Englisch
        if [ -f "${SCRIPT_DIR}/lang/en.lang" ]; then
            # shellcheck source=/dev/null
            source "${SCRIPT_DIR}/lang/en.lang"
        else
            # Notfall: Keine Sprachdatei gefunden
            echo "ERROR: No language files found!"
            exit 1
        fi
    fi
}

# Sprache initialisieren
load_language

# Config-Migration durchführen (falls nötig)
migrate_config

# Warnung bei alter Config-Location
if [ "$CONFIG_FILE" = "$OLD_CONFIG_FILE" ] && [ -f "$OLD_CONFIG_FILE" ]; then
    echo -e "${YELLOW}[${LABEL_WARNING}]${NC} $MSG_CONFIG_OLD_LOCATION"
    echo -e "${YELLOW}[${LABEL_WARNING}]${NC} $MSG_CONFIG_OLD_DEPRECATED"
fi

# Timestamp für Logdatei
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="${LOG_DIR}/update_${TIMESTAMP}.log"

# Log-Verzeichnis erstellen, falls nicht vorhanden
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR" 2>/dev/null || {
        echo -e "${RED}${MSG_LOG_DIR_ERROR}${NC}"
        exit 1
    }
fi

#############################################################
# Funktionen
#############################################################

# Logging-Funktion
log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

# Farbige Ausgabe mit Logging
log_info() {
    echo -e "${GREEN}[${LABEL_INFO}]${NC} $1"
    log "[${LABEL_INFO}] $1"
}

log_error() {
    echo -e "${RED}[${LABEL_ERROR}]${NC} $1"
    log "[${LABEL_ERROR}] $1"
}

log_warning() {
    echo -e "${YELLOW}[${LABEL_WARNING}]${NC} $1"
    log "[${LABEL_WARNING}] $1"
}

# Distribution erkennen
detect_distro() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        log_info "$MSG_DISTRO_DETECTED: $NAME $VERSION"
    else
        log_error "$MSG_DISTRO_NOT_FOUND"
        exit 1
    fi
}

# Root-Check
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "$MSG_ROOT_REQUIRED"
        echo -e "${YELLOW}${MSG_ROOT_TRY} $0${NC}"
        exit 1
    fi
}

# E-Mail senden
send_email() {
    local subject="$1"
    local body="$2"

    if [ "$ENABLE_EMAIL" = true ] && [ -n "$EMAIL_RECIPIENT" ]; then
        if command -v mail &> /dev/null; then
            if echo "$body" | mail -s "$subject" "$EMAIL_RECIPIENT" 2>/dev/null; then
                log_info "$MSG_EMAIL_SENT: $EMAIL_RECIPIENT"
            else
                log_warning "$MSG_EMAIL_FAILED"
                log_warning "$MSG_EMAIL_INSTALL_MTA"
            fi
        elif command -v sendmail &> /dev/null; then
            if echo -e "Subject: $subject\n\n$body" | sendmail "$EMAIL_RECIPIENT" 2>/dev/null; then
                log_info "$MSG_EMAIL_SENT: $EMAIL_RECIPIENT"
            else
                log_warning "$MSG_EMAIL_FAILED"
                log_warning "$MSG_EMAIL_INSTALL_MTA"
            fi
        else
            log_warning "$MSG_EMAIL_NO_PROGRAM"
            log_warning "$MSG_EMAIL_INSTALL_CLIENT"
        fi
    fi
}

# Desktop-Benachrichtigung senden
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"  # low, normal, critical
    local icon="${4:-dialog-information}"

    # Prüfen ob Desktop-Benachrichtigungen aktiviert
    if [ "$ENABLE_DESKTOP_NOTIFICATION" != "true" ]; then
        return 0
    fi

    # notify-send verfügbar?
    if ! command -v notify-send &> /dev/null; then
        return 0  # Kein Fehler, nur nicht verfügbar
    fi

    # Notification-Timeout
    local timeout="${NOTIFICATION_TIMEOUT:-5000}"

    # Wenn als root ausgeführt, Notification für SUDO_USER anzeigen
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        local user_id
        user_id=$(id -u "$SUDO_USER")

        # DISPLAY und DBUS_SESSION_BUS_ADDRESS für User setzen
        sudo -u "$SUDO_USER" \
            DISPLAY=:0 \
            DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${user_id}/bus" \
            notify-send \
                --urgency="$urgency" \
                --icon="$icon" \
                --expire-time="$timeout" \
                "$title" "$message" 2>/dev/null || true
    else
        # Direkt aufrufen wenn nicht als root
        notify-send \
            --urgency="$urgency" \
            --icon="$icon" \
            --expire-time="$timeout" \
            "$title" "$message" 2>/dev/null || true
    fi
}

# Zählt stabile Kernel-Versionen (Debian/Ubuntu)
count_stable_kernels_debian() {
    # Zähle installierte linux-image Pakete (keine RC, unsigned, etc.)
    local kernel_count
    kernel_count=$(dpkg -l 2>/dev/null | grep -c "^ii.*linux-image-[0-9]" || echo "0")
    echo "$kernel_count"
}

# Zählt stabile Kernel-Versionen (RHEL/Fedora)
count_stable_kernels_redhat() {
    local kernel_count
    if command -v dnf &> /dev/null; then
        kernel_count=$(dnf list installed kernel 2>/dev/null | grep -c "^kernel" || echo "0")
    elif command -v rpm &> /dev/null; then
        kernel_count=$(rpm -q kernel 2>/dev/null | grep -c "^kernel" || echo "0")
    else
        kernel_count=0
    fi
    echo "$kernel_count"
}

# Sicheres autoremove mit Kernel-Schutz
# Parameter: $1 = Paketmanager (apt, dnf, yum)
safe_autoremove() {
    local pkg_manager="$1"
    local kernel_count=0
    local min_kernels="${MIN_KERNELS:-3}"
    local current_kernel
    current_kernel=$(uname -r)

    # Wenn Kernel-Schutz deaktiviert ist, autoremove ohne Prüfung ausführen
    if [ "$KERNEL_PROTECTION" != "true" ]; then
        case "$pkg_manager" in
            apt)
                apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
            dnf)
                dnf autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
            yum)
                yum autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
        esac
        return 0
    fi

    log_info "$MSG_KERNEL_CHECK"

    # Kernel zählen je nach Distribution
    case "$pkg_manager" in
        apt)
            kernel_count=$(count_stable_kernels_debian)
            ;;
        dnf|yum)
            kernel_count=$(count_stable_kernels_redhat)
            ;;
        *)
            log_warning "Unknown package manager: $pkg_manager"
            return 1
            ;;
    esac

    # Kernel-Informationen loggen
    # shellcheck disable=SC2059
    printf "$MSG_KERNEL_COUNT\n" "$kernel_count" | tee -a "$LOG_FILE"
    # shellcheck disable=SC2059
    printf "$MSG_KERNEL_CURRENT\n" "$current_kernel" | tee -a "$LOG_FILE"

    # Prüfen ob genügend Kernel vorhanden sind
    if [ "$kernel_count" -ge "$min_kernels" ]; then
        log_info "$MSG_KERNEL_SAFE_AUTOREMOVE"
        case "$pkg_manager" in
            apt)
                apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
            dnf)
                dnf autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
            yum)
                yum autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
        esac
    else
        # shellcheck disable=SC2059
        printf "$MSG_KERNEL_SKIP_AUTOREMOVE\n" "$kernel_count" | tee -a "$LOG_FILE"
        # shellcheck disable=SC2059
        printf "$MSG_KERNEL_MIN_REQUIRED\n" "$min_kernels" | tee -a "$LOG_FILE"
        log_warning "$MSG_KERNEL_PROTECTION"
    fi
}

#############################################################
# Upgrade-Check Funktionen
#############################################################

# Solus Upgrade-Check
check_upgrade_solus() {
    log_info "$MSG_UPGRADE_CHECKING_SOLUS"

    # Solus verwendet eopkg für Updates
    # Prüfe auf verfügbare Repository-Updates die eine neue Version signalisieren
    local repo_info
    repo_info=$(eopkg lr 2>/dev/null || echo "")

    if [ -z "$repo_info" ]; then
        log_warning "Konnte Repository-Informationen nicht abrufen"
        return 1
    fi

    # Hinweis: Solus ist ein Rolling Release, daher gibt es keine klassischen Version-Upgrades
    # Wir prüfen auf wichtige Systemupdates
    local pending_updates
    pending_updates=$(eopkg list-pending 2>/dev/null | wc -l || echo "0")

    if [ "$pending_updates" -gt 0 ]; then
        log_info "Solus: $pending_updates ausstehende Updates gefunden"
        return 2  # Updates verfügbar aber kein Major-Upgrade
    fi

    log_info "$MSG_UPGRADE_NO_UPGRADE"
    return 0
}

# Arch Upgrade-Check
check_upgrade_arch() {
    log_info "$MSG_UPGRADE_CHECKING_ARCH"

    # Arch ist ein Rolling Release - prüfe auf wichtige Updates
    if ! command -v checkupdates &> /dev/null; then
        log_warning "checkupdates nicht gefunden (pacman-contrib erforderlich)"
        return 1
    fi

    local updates
    updates=$(checkupdates 2>/dev/null | wc -l || echo "0")

    if [ "$updates" -gt 0 ]; then
        log_info "Arch: $updates verfügbare Updates"
        return 2  # Updates verfügbar
    fi

    log_info "$MSG_UPGRADE_NO_UPGRADE"
    return 0
}

# Debian/Ubuntu Upgrade-Check
check_upgrade_debian() {
    log_info "$MSG_UPGRADE_CHECKING_DEBIAN"

    if ! command -v do-release-upgrade &> /dev/null; then
        log_warning "do-release-upgrade nicht gefunden"
        return 1
    fi

    # Prüfe auf neue Release-Version
    local check_result
    check_result=$(do-release-upgrade -c 2>&1 || echo "")

    if echo "$check_result" | grep -q "New release"; then
        local new_version
        new_version=$(echo "$check_result" | grep "New release" | sed 's/.*New release //' | sed "s/'//g" | awk '{print $1}')
        # shellcheck disable=SC2059
        printf "$MSG_UPGRADE_AVAILABLE\n" "$VERSION" "$new_version" | tee -a "$LOG_FILE"

        # E-Mail-Benachrichtigung
        if [ "$UPGRADE_NOTIFY_EMAIL" = true ]; then
            local email_body="$EMAIL_BODY_UPGRADE

Aktuelle Version: $NAME $VERSION
Neue Version: $new_version

Für Upgrade ausführen:
sudo $0 --upgrade

$MSG_UPGRADE_BACKUP_WARNING"
            send_email "$EMAIL_SUBJECT_UPGRADE" "$email_body"
        fi

        return 3  # Upgrade verfügbar
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

    # Prüfe auf neue Fedora-Version
    local check_result
    check_result=$(dnf system-upgrade download --refresh --releasever="$((VERSION + 1))" --assumeno 2>&1 || echo "")

    if echo "$check_result" | grep -q "will be installed"; then
        local new_version=$((VERSION + 1))
        # shellcheck disable=SC2059
        printf "$MSG_UPGRADE_AVAILABLE\n" "Fedora $VERSION" "Fedora $new_version" | tee -a "$LOG_FILE"

        # E-Mail-Benachrichtigung
        if [ "$UPGRADE_NOTIFY_EMAIL" = true ]; then
            local email_body="$EMAIL_BODY_UPGRADE

Aktuelle Version: Fedora $VERSION
Neue Version: Fedora $new_version

Für Upgrade ausführen:
sudo $0 --upgrade

$MSG_UPGRADE_BACKUP_WARNING"
            send_email "$EMAIL_SUBJECT_UPGRADE" "$email_body"
        fi

        return 3  # Upgrade verfügbar
    fi

    log_info "$MSG_UPGRADE_NO_UPGRADE"
    return 0
}

# Hauptfunktion: Upgrade-Check
check_upgrade_available() {
    # Prüfe ob Upgrade-Check aktiviert ist
    if [ "$ENABLE_UPGRADE_CHECK" != "true" ]; then
        log_info "$MSG_UPGRADE_DISABLED"
        return 0
    fi

    log_info "$MSG_UPGRADE_CHECK"

    # Distributionsspezifischer Check
    case "$DISTRO" in
        solus)
            check_upgrade_solus
            return $?
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            check_upgrade_arch
            return $?
            ;;
        debian|ubuntu|linuxmint|mint)
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

    # Bestätigung einholen (außer bei AUTO_UPGRADE)
    if [ "$AUTO_UPGRADE" != "true" ]; then
        echo -n "$MSG_UPGRADE_CONFIRM "
        read -r response
        if [[ ! "$response" =~ ^[jJyY]$ ]]; then
            log_info "$MSG_UPGRADE_CANCELLED"
            return 1
        fi
    fi

    # Distributionsspezifisches Upgrade
    case "$DISTRO" in
        debian|ubuntu|linuxmint|mint)
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
            printf "$MSG_UPGRADE_START\n" "Fedora $new_version" | tee -a "$LOG_FILE"
            if dnf system-upgrade download -y --releasever="$new_version" 2>&1 | tee -a "$LOG_FILE" && \
               dnf system-upgrade reboot 2>&1 | tee -a "$LOG_FILE"; then
                log_info "$MSG_UPGRADE_SUCCESS"
                return 0
            else
                log_error "$MSG_UPGRADE_FAILED"
                return 1
            fi
            ;;
        *)
            log_error "$MSG_UPGRADE_NOT_SUPPORTED"
            return 1
            ;;
    esac
}

# Update für Debian/Ubuntu/Mint
update_debian() {
    log_info "$MSG_UPDATE_START_DEBIAN"

    apt-get update 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_APT_UPDATE_FAILED"
        return 1
    fi

    apt-get upgrade -y 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_APT_UPGRADE_FAILED"
        return 1
    fi

    apt-get dist-upgrade -y 2>&1 | tee -a "$LOG_FILE"
    safe_autoremove "apt"
    apt-get autoclean -y 2>&1 | tee -a "$LOG_FILE"

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Update für RHEL/Fedora
update_redhat() {
    log_info "$MSG_UPDATE_START_REDHAT"

    if command -v dnf &> /dev/null; then
        dnf check-update 2>&1 | tee -a "$LOG_FILE"
        dnf upgrade -y 2>&1 | tee -a "$LOG_FILE"
        if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            log_error "$MSG_DNF_FAILED"
            return 1
        fi
        safe_autoremove "dnf"
    elif command -v yum &> /dev/null; then
        yum check-update 2>&1 | tee -a "$LOG_FILE"
        yum update -y 2>&1 | tee -a "$LOG_FILE"
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

# Update für SUSE
update_suse() {
    log_info "$MSG_UPDATE_START_SUSE"

    zypper refresh 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_ZYPPER_REFRESH_FAILED"
        return 1
    fi

    zypper update -y 2>&1 | tee -a "$LOG_FILE"
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

    eopkg upgrade -y 2>&1 | tee -a "$LOG_FILE"
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

    # Paketdatenbank synchronisieren und System aktualisieren
    pacman -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_PACMAN_FAILED"
        return 1
    fi

    # Optional: Paket-Cache bereinigen (alte Versionen behalten)
    pacman -Sc --noconfirm 2>&1 | tee -a "$LOG_FILE"

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Update für Void Linux
update_void() {
    log_info "$MSG_UPDATE_START_VOID"

    # Paketdatenbank synchronisieren und System aktualisieren
    xbps-install -Su -y 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_XBPS_FAILED"
        return 1
    fi

    log_info "$MSG_UPDATE_SUCCESS"
    return 0
}

# Neustart prüfen
check_reboot_required() {
    if [ "$AUTO_REBOOT" = true ]; then
        if [ -f /var/run/reboot-required ]; then
            log_warning "$MSG_REBOOT_AUTO"
            send_email "$EMAIL_SUBJECT_REBOOT" "$MSG_REBOOT_NOTIFICATION"
            send_notification \
                "$NOTIFICATION_REBOOT_REQUIRED" \
                "$NOTIFICATION_REBOOT_REQUIRED_BODY" \
                "critical" \
                "system-reboot"
            shutdown -r +1 "System wird in 1 Minute neu gestartet (Update)"
        fi
    else
        if [ -f /var/run/reboot-required ]; then
            log_warning "$MSG_REBOOT_MANUAL"
            send_notification \
                "$NOTIFICATION_REBOOT_REQUIRED" \
                "$NOTIFICATION_REBOOT_REQUIRED_BODY" \
                "normal" \
                "system-reboot"
        fi
    fi
}

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
            echo "Linux System Update-Script"
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

# Info über verwendete Config-Datei (nur im Log)
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC2059
    log "$(printf "$MSG_CONFIG_LOCATION" "$CONFIG_FILE")"
fi

# Distribution erkennen
detect_distro

# Wenn Upgrade-Modus, führe Upgrade durch
if [ "$UPGRADE_MODE" = true ]; then
    if perform_upgrade; then
        log_info "$MSG_UPGRADE_SUCCESS"
        send_email "$EMAIL_SUBJECT_UPGRADE" "$MSG_UPGRADE_SUCCESS"
        exit 0
    else
        log_error "$MSG_UPGRADE_FAILED"
        send_email "$EMAIL_SUBJECT_FAILED" "$MSG_UPGRADE_FAILED"
        exit 1
    fi
fi

# Update durchführen basierend auf Distribution
UPDATE_SUCCESS=false

case "$DISTRO" in
    debian|ubuntu|linuxmint|mint)
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

# Ergebnis auswerten
if [ "$UPDATE_SUCCESS" = true ]; then
    log_info "$MSG_HEADER_SUCCESS"

    # Desktop-Benachrichtigung: Update erfolgreich
    send_notification \
        "$NOTIFICATION_UPDATE_SUCCESS" \
        "$NOTIFICATION_UPDATE_SUCCESS_BODY" \
        "normal" \
        "software-update-available"

    # Neustart prüfen
    check_reboot_required

    # Upgrade-Check durchführen
    check_upgrade_available
    UPGRADE_CHECK_RESULT=$?

    # Wenn Upgrade verfügbar und AUTO_UPGRADE aktiviert
    if [ "$UPGRADE_CHECK_RESULT" -eq 3 ] && [ "$AUTO_UPGRADE" = true ]; then
        log_info "AUTO_UPGRADE aktiviert, starte Upgrade-Prozess"
        perform_upgrade
    elif [ "$UPGRADE_CHECK_RESULT" -eq 3 ]; then
        # shellcheck disable=SC2059
        printf "$MSG_UPGRADE_INFO\n" "$0" | tee -a "$LOG_FILE"

        # Desktop-Benachrichtigung: Upgrade verfügbar
        send_notification \
            "$NOTIFICATION_UPGRADE_AVAILABLE" \
            "$NOTIFICATION_UPGRADE_AVAILABLE_BODY" \
            "normal" \
            "system-software-update"
    fi

    # E-Mail senden
    EMAIL_BODY="$EMAIL_BODY_SUCCESS

$MSG_HOSTNAME: $(hostname)
$MSG_DISTRIBUTION: $DISTRO
$MSG_TIMESTAMP: $(date)
$MSG_LOGFILE: $LOG_FILE"

    send_email "$EMAIL_SUBJECT_SUCCESS" "$EMAIL_BODY"

    exit 0
else
    log_error "$MSG_HEADER_FAILED"

    # Desktop-Benachrichtigung: Update fehlgeschlagen
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
