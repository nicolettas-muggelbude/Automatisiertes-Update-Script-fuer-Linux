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
CONFIG_FILE="${SCRIPT_DIR}/config.conf"

# Standard-Konfiguration
ENABLE_EMAIL=false
EMAIL_RECIPIENT=""
LOG_DIR="/var/log/system-updates"
AUTO_REBOOT=false
LANGUAGE=auto

# Konfiguration laden, falls vorhanden
if [ -f "$CONFIG_FILE" ]; then
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
        source "$lang_file"
    else
        # Fallback zu Englisch
        if [ -f "${SCRIPT_DIR}/lang/en.lang" ]; then
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
    apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
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
        dnf autoremove -y 2>&1 | tee -a "$LOG_FILE"
    elif command -v yum &> /dev/null; then
        yum check-update 2>&1 | tee -a "$LOG_FILE"
        yum update -y 2>&1 | tee -a "$LOG_FILE"
        if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            log_error "$MSG_YUM_FAILED"
            return 1
        fi
        yum autoremove -y 2>&1 | tee -a "$LOG_FILE"
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
            shutdown -r +1 "System wird in 1 Minute neu gestartet (Update)"
        fi
    else
        if [ -f /var/run/reboot-required ]; then
            log_warning "$MSG_REBOOT_MANUAL"
        fi
    fi
}

#############################################################
# Hauptprogramm
#############################################################

log_info "$MSG_HEADER_START"
log_info "$MSG_HOSTNAME: $(hostname)"
log_info "$MSG_KERNEL: $(uname -r)"

# Root-Rechte prüfen
check_root

# Distribution erkennen
detect_distro

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

    # Neustart prüfen
    check_reboot_required

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

    EMAIL_BODY="$EMAIL_BODY_FAILED

$MSG_HOSTNAME: $(hostname)
$MSG_DISTRIBUTION: $DISTRO
$MSG_TIMESTAMP: $(date)
$MSG_LOGFILE: $LOG_FILE

$EMAIL_BODY_CHECK_LOG"

    send_email "$EMAIL_SUBJECT_FAILED" "$EMAIL_BODY"

    exit 1
fi
