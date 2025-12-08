#!/bin/bash

#############################################################
# Linux System Update Script
# Unterstützt: Debian, Ubuntu, Mint, RHEL, Fedora, SUSE
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

# Konfiguration laden, falls vorhanden
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Timestamp für Logdatei
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="${LOG_DIR}/update_${TIMESTAMP}.log"

# Log-Verzeichnis erstellen, falls nicht vorhanden
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR" 2>/dev/null || {
        echo -e "${RED}Fehler: Kann Log-Verzeichnis nicht erstellen. Benötigt root-Rechte!${NC}"
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
    echo -e "${GREEN}[INFO]${NC} $1"
    log "[INFO] $1"
}

log_error() {
    echo -e "${RED}[FEHLER]${NC} $1"
    log "[FEHLER] $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNUNG]${NC} $1"
    log "[WARNUNG] $1"
}

# Distribution erkennen
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        log_info "Distribution erkannt: $NAME $VERSION"
    else
        log_error "Kann Distribution nicht erkennen (/etc/os-release fehlt)"
        exit 1
    fi
}

# Root-Check
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Dieses Script muss als root ausgeführt werden!"
        echo -e "${YELLOW}Versuche: sudo $0${NC}"
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
                log_info "E-Mail erfolgreich gesendet an: $EMAIL_RECIPIENT"
            else
                log_warning "E-Mail konnte nicht gesendet werden (MTA nicht konfiguriert?)"
                log_warning "Installiere und konfiguriere einen MTA wie postfix oder ssmtp"
            fi
        elif command -v sendmail &> /dev/null; then
            if echo -e "Subject: $subject\n\n$body" | sendmail "$EMAIL_RECIPIENT" 2>/dev/null; then
                log_info "E-Mail erfolgreich gesendet an: $EMAIL_RECIPIENT"
            else
                log_warning "E-Mail konnte nicht gesendet werden (MTA nicht konfiguriert?)"
                log_warning "Installiere und konfiguriere einen MTA wie postfix oder ssmtp"
            fi
        else
            log_warning "Kein Mail-Programm gefunden (mail/sendmail)"
            log_warning "Installiere 'mailutils' oder 'mailx' für E-Mail-Benachrichtigungen"
        fi
    fi
}

# Update für Debian/Ubuntu/Mint
update_debian() {
    log_info "Starte Update-Prozess für Debian-basierte Distribution..."

    apt-get update 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log_error "apt-get update fehlgeschlagen"
        return 1
    fi

    apt-get upgrade -y 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log_error "apt-get upgrade fehlgeschlagen"
        return 1
    fi

    apt-get dist-upgrade -y 2>&1 | tee -a "$LOG_FILE"
    apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
    apt-get autoclean -y 2>&1 | tee -a "$LOG_FILE"

    log_info "Update erfolgreich abgeschlossen"
    return 0
}

# Update für RHEL/Fedora
update_redhat() {
    log_info "Starte Update-Prozess für RedHat-basierte Distribution..."

    if command -v dnf &> /dev/null; then
        dnf check-update 2>&1 | tee -a "$LOG_FILE"
        dnf upgrade -y 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            log_error "dnf upgrade fehlgeschlagen"
            return 1
        fi
        dnf autoremove -y 2>&1 | tee -a "$LOG_FILE"
    elif command -v yum &> /dev/null; then
        yum check-update 2>&1 | tee -a "$LOG_FILE"
        yum update -y 2>&1 | tee -a "$LOG_FILE"
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            log_error "yum update fehlgeschlagen"
            return 1
        fi
        yum autoremove -y 2>&1 | tee -a "$LOG_FILE"
    else
        log_error "Kein Paketmanager gefunden (dnf/yum)"
        return 1
    fi

    log_info "Update erfolgreich abgeschlossen"
    return 0
}

# Update für SUSE
update_suse() {
    log_info "Starte Update-Prozess für SUSE-basierte Distribution..."

    zypper refresh 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log_error "zypper refresh fehlgeschlagen"
        return 1
    fi

    zypper update -y 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log_error "zypper update fehlgeschlagen"
        return 1
    fi

    log_info "Update erfolgreich abgeschlossen"
    return 0
}

# Update für Arch Linux
update_arch() {
    log_info "Starte Update-Prozess für Arch-basierte Distribution..."

    # Paketdatenbank synchronisieren und System aktualisieren
    pacman -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log_error "pacman -Syu fehlgeschlagen"
        return 1
    fi

    # Optional: Paket-Cache bereinigen (alte Versionen behalten)
    pacman -Sc --noconfirm 2>&1 | tee -a "$LOG_FILE"

    log_info "Update erfolgreich abgeschlossen"
    return 0
}

# Update für Void Linux
update_void() {
    log_info "Starte Update-Prozess für Void-basierte Distribution..."

    # Paketdatenbank synchronisieren und System aktualisieren
    xbps-install -Su -y 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log_error "xbps-install -Su -y fehlgeschlagen"
        return 1
    fi

        log_info "Update erfolgreich abgeschlossen"
    return 0
}

# Neustart prüfen
check_reboot_required() {
    if [ "$AUTO_REBOOT" = true ]; then
        if [ -f /var/run/reboot-required ]; then
            log_warning "Neustart erforderlich - wird automatisch durchgeführt..."
            send_email "System-Update: Neustart erforderlich" "Das System wird nach dem Update neu gestartet."
            shutdown -r +1 "System wird in 1 Minute neu gestartet (Update)"
        fi
    else
        if [ -f /var/run/reboot-required ]; then
            log_warning "Neustart erforderlich! Bitte System neu starten."
        fi
    fi
}

#############################################################
# Hauptprogramm
#############################################################

log_info "=== System-Update gestartet ==="
log_info "Hostname: $(hostname)"
log_info "Kernel: $(uname -r)"

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
    arch|manjaro|endeavouros|garuda|arcolinux)
        update_arch && UPDATE_SUCCESS=true
        ;;
    void)
        update_void && UPDATE_SUCCESS=true
        ;;
    *)
        log_error "Nicht unterstützte Distribution: $DISTRO"
        send_email "System-Update FEHLGESCHLAGEN" "Nicht unterstützte Distribution: $DISTRO"
        exit 1
        ;;
esac

# Ergebnis auswerten
if [ "$UPDATE_SUCCESS" = true ]; then
    log_info "=== System-Update erfolgreich abgeschlossen ==="

    # Neustart prüfen
    check_reboot_required

    # E-Mail senden
    EMAIL_BODY="System-Update erfolgreich abgeschlossen

Hostname: $(hostname)
Distribution: $DISTRO
Zeitpunkt: $(date)
Logdatei: $LOG_FILE"

    send_email "System-Update erfolgreich" "$EMAIL_BODY"

    exit 0
else
    log_error "=== System-Update FEHLGESCHLAGEN ==="

    EMAIL_BODY="System-Update fehlgeschlagen!

Hostname: $(hostname)
Distribution: $DISTRO
Zeitpunkt: $(date)
Logdatei: $LOG_FILE

Bitte Logdatei prüfen!"

    send_email "System-Update FEHLGESCHLAGEN" "$EMAIL_BODY"

    exit 1
fi
