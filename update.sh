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
NVIDIA_CHECK_DISABLED=false
NVIDIA_ALLOW_UNSUPPORTED_KERNEL=false
NVIDIA_AUTO_DKMS_REBUILD=false
NVIDIA_AUTO_MOK_SIGN=false

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

# Warnung wenn KEINE Config gefunden wurde
if [ -z "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}[${LABEL_WARNING}]${NC} $MSG_CONFIG_NOT_FOUND"
    echo -e "${YELLOW}[${LABEL_WARNING}]${NC} Verwende Standard-Konfiguration"
    echo -e "${YELLOW}[${LABEL_WARNING}]${NC} E-Mail- und Desktop-Benachrichtigungen sind möglicherweise nicht konfiguriert!"
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

    # Prüfen ob E-Mail aktiviert
    if [ "$ENABLE_EMAIL" != "true" ]; then
        return 0
    fi

    # Prüfen ob Empfänger konfiguriert
    if [ -z "$EMAIL_RECIPIENT" ]; then
        log_warning "E-Mail-Benachrichtigung fehlgeschlagen: EMAIL_RECIPIENT nicht konfiguriert"
        return 0
    fi

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
        log_warning "Desktop-Benachrichtigung fehlgeschlagen: notify-send nicht installiert"
        log_warning "Installiere libnotify: sudo apt install libnotify-bin (Debian/Ubuntu)"
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

#############################################################
# NVIDIA-Kernel-Kompatibilitätsprüfung
#############################################################

# Prüft ob NVIDIA-Treiber installiert sind
is_nvidia_installed() {
    # Prüfe auf nvidia-smi (NVIDIA System Management Interface)
    if command -v nvidia-smi &> /dev/null; then
        return 0
    fi

    # Prüfe auf geladene NVIDIA Kernel-Module
    if lsmod 2>/dev/null | grep -q "^nvidia"; then
        return 0
    fi

    # Prüfe auf NVIDIA in lspci
    if command -v lspci &> /dev/null && lspci 2>/dev/null | grep -qi "nvidia"; then
        # NVIDIA Hardware gefunden, prüfe ob Treiber installiert
        if [ -d /proc/driver/nvidia ] || [ -f /sys/module/nvidia/version ]; then
            return 0
        fi
    fi

    return 1
}

# Ermittelt die verfügbare Kernel-Version im Update
get_pending_kernel_version() {
    local distro="$1"
    local pending_kernel=""

    case "$distro" in
        debian|ubuntu|linuxmint|pop)
            # Prüfe verfügbare Kernel-Pakete
            if command -v apt-cache &> /dev/null; then
                pending_kernel=$(apt-cache policy linux-image-generic 2>/dev/null | \
                    grep "Candidate:" | awk '{print $2}' | grep -oP '\d+\.\d+\.\d+-\d+' | head -1)
            fi
            ;;
        fedora|rhel|centos|rocky|almalinux)
            # Prüfe verfügbare Kernel-Pakete
            if command -v dnf &> /dev/null; then
                pending_kernel=$(dnf list --available kernel 2>/dev/null | \
                    grep "^kernel" | awk '{print $2}' | head -1 | sed 's/\..*$//')
            elif command -v yum &> /dev/null; then
                pending_kernel=$(yum list available kernel 2>/dev/null | \
                    grep "^kernel" | awk '{print $2}' | head -1 | sed 's/\..*$//')
            fi
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            # Prüfe verfügbare Kernel-Pakete
            if command -v pacman &> /dev/null; then
                pending_kernel=$(pacman -Si linux 2>/dev/null | \
                    grep "^Version" | awk '{print $3}' | head -1)
            fi
            ;;
        opensuse*|sles)
            # Prüfe verfügbare Kernel-Pakete
            if command -v zypper &> /dev/null; then
                pending_kernel=$(zypper info kernel-default 2>/dev/null | \
                    grep "^Version" | awk '{print $3}' | head -1)
            fi
            ;;
        solus)
            # Prüfe verfügbare Kernel-Pakete
            if command -v eopkg &> /dev/null; then
                pending_kernel=$(eopkg info linux-current 2>/dev/null | \
                    grep "^Version" | awk '{print $3}' | head -1)
            fi
            ;;
        void)
            # Prüfe verfügbare Kernel-Pakete
            if command -v xbps-query &> /dev/null; then
                pending_kernel=$(xbps-query -R -p pkgver linux 2>/dev/null | \
                    sed 's/linux-//' | head -1)
            fi
            ;;
    esac

    echo "$pending_kernel"
}

# Prüft DKMS-Status für NVIDIA
check_nvidia_dkms_status() {
    local target_kernel="$1"

    # Prüfe ob DKMS installiert ist
    if ! command -v dkms &> /dev/null; then
        return 1  # DKMS nicht installiert
    fi

    # Prüfe ob NVIDIA DKMS-Module existieren
    local nvidia_dkms
    nvidia_dkms=$(dkms status 2>/dev/null | grep -i nvidia)

    if [ -z "$nvidia_dkms" ]; then
        return 1  # Keine NVIDIA DKMS-Module gefunden
    fi

    # Wenn target_kernel angegeben, prüfe ob Module für diesen Kernel gebaut sind
    if [ -n "$target_kernel" ]; then
        if echo "$nvidia_dkms" | grep -q "$target_kernel"; then
            return 0  # Module für target Kernel vorhanden
        else
            return 2  # Module müssen neu gebaut werden
        fi
    fi

    return 0  # DKMS-Module vorhanden (generell)
}

# Prüft ob Secure Boot aktiv ist
is_secureboot_enabled() {
    # Methode 1: mokutil (am zuverlässigsten)
    if command -v mokutil &> /dev/null; then
        if mokutil --sb-state 2>/dev/null | grep -qi "SecureBoot enabled"; then
            return 0
        fi
        if mokutil --sb-state 2>/dev/null | grep -qi "SecureBoot disabled"; then
            return 1
        fi
    fi

    # Methode 2: bootctl (systemd-boot)
    if command -v bootctl &> /dev/null; then
        if bootctl status 2>/dev/null | grep -qi "Secure Boot.*enabled"; then
            return 0
        fi
    fi

    # Methode 3: EFI-Variablen direkt lesen
    for efi_var in /sys/firmware/efi/efivars/SecureBoot-*; do
        if [ -f "$efi_var" ]; then
            local sb_value
            sb_value=$(od -An -t u1 "$efi_var" 2>/dev/null | awk '{print $NF}')
            if [ "$sb_value" = "1" ]; then
                return 0
            fi
        fi
    done

    # Konnte nicht ermittelt werden
    return 2
}

# Prüft ob MOK-Schlüssel registriert sind
check_mok_keys() {
    if ! command -v mokutil &> /dev/null; then
        return 1  # mokutil nicht installiert
    fi

    # Prüfe ob Keys enrollt sind
    if mokutil --list-enrolled 2>/dev/null | grep -qi "BEGIN CERTIFICATE"; then
        return 0  # MOK-Keys gefunden
    fi

    return 1  # Keine MOK-Keys
}

# Signiert NVIDIA DKMS-Module mit MOK
sign_nvidia_modules() {
    local kernel_version="$1"

    # Prüfe ob sign-file verfügbar ist
    local sign_tool=""
    if [ -x /usr/src/linux-headers-"${kernel_version}"/scripts/sign-file ]; then
        sign_tool="/usr/src/linux-headers-${kernel_version}/scripts/sign-file"
    else
        # Suche in kbuild-Verzeichnissen
        sign_tool=$(find /usr/lib/linux-kbuild-*/scripts/sign-file 2>/dev/null | head -1)
        if [ -z "$sign_tool" ] && command -v kmodsign &> /dev/null; then
            sign_tool="kmodsign"
        fi
    fi

    if [ -z "$sign_tool" ]; then
        log_error "sign-file tool nicht gefunden"
        return 1
    fi

    # Finde DKMS MOK-Schlüssel
    local mok_key=""
    local mok_cert=""

    # Standard-Pfade prüfen
    if [ -f /var/lib/shim-signed/mok/MOK.priv ]; then
        mok_key="/var/lib/shim-signed/mok/MOK.priv"
        mok_cert="/var/lib/shim-signed/mok/MOK.der"
    elif [ -f /var/lib/dkms/mok.key ]; then
        mok_key="/var/lib/dkms/mok.key"
        mok_cert="/var/lib/dkms/mok.pub"
    fi

    if [ -z "$mok_key" ] || [ ! -f "$mok_key" ]; then
        log_warning "$MSG_NVIDIA_MOK_MISSING"
        log_warning "$MSG_NVIDIA_MOK_ENROLLMENT_NEEDED"
        return 1
    fi

    log_info "$MSG_NVIDIA_MOK_SIGN_START"

    # Finde alle NVIDIA Kernel-Module
    local module_path="/lib/modules/${kernel_version}/updates/dkms"
    if [ ! -d "$module_path" ]; then
        module_path="/lib/modules/${kernel_version}/extra"
    fi

    local signed_count=0
    local failed_count=0

    if [ -d "$module_path" ]; then
        while IFS= read -r -d '' module; do
            if [[ "$module" == *nvidia*.ko ]]; then
                if "$sign_tool" sha256 "$mok_key" "$mok_cert" "$module" 2>&1 | tee -a "$LOG_FILE"; then
                    ((signed_count++))
                else
                    ((failed_count++))
                    log_error "Fehler beim Signieren: $module"
                fi
            fi
        done < <(find "$module_path" -name "*.ko" -print0 2>/dev/null)
    fi

    if [ "$failed_count" -gt 0 ]; then
        log_error "$MSG_NVIDIA_MOK_SIGN_FAILED"
        return 1
    elif [ "$signed_count" -gt 0 ]; then
        log_info "$MSG_NVIDIA_MOK_SIGN_SUCCESS ($signed_count Module)"
        return 0
    else
        log_warning "Keine NVIDIA-Module zum Signieren gefunden"
        return 1
    fi
}

# Setzt Kernel-Hold (verhindert Update)
hold_kernel_update() {
    local distro="$1"
    local unhold_cmd=""

    case "$distro" in
        debian|ubuntu|linuxmint|pop)
            unhold_cmd="sudo apt-mark unhold linux-image-generic linux-headers-generic"

            if apt-mark hold linux-image-generic linux-headers-generic 2>&1 | tee -a "$LOG_FILE"; then
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_NVIDIA_KERNEL_HOLD_SUCCESS" "linux-image-generic")"
                log_info "$MSG_NVIDIA_KERNEL_HOLD_INFO"
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_NVIDIA_KERNEL_UNHOLD_LATER" "$unhold_cmd")"
                return 0
            fi
            ;;
        fedora|rhel|centos|rocky|almalinux)
            if command -v dnf &> /dev/null; then
                unhold_cmd="sudo dnf versionlock delete kernel kernel-core kernel-modules"

                if dnf versionlock add kernel kernel-core kernel-modules 2>&1 | tee -a "$LOG_FILE"; then
                    # shellcheck disable=SC2059
                    log_info "$(printf "$MSG_NVIDIA_KERNEL_HOLD_SUCCESS" "kernel")"
                    log_info "$MSG_NVIDIA_KERNEL_HOLD_INFO"
                    # shellcheck disable=SC2059
                    log_info "$(printf "$MSG_NVIDIA_KERNEL_UNHOLD_LATER" "$unhold_cmd")"
                    return 0
                fi
            elif command -v yum &> /dev/null; then
                log_warning "yum versionlock erfordert yum-plugin-versionlock"
                log_info "Installiere mit: sudo yum install yum-plugin-versionlock"
            fi
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            log_warning "Arch Linux: Manuelle Konfiguration erforderlich"
            log_info "Füge in /etc/pacman.conf hinzu:"
            log_info "  IgnorePkg = linux linux-headers"
            log_info "Oder installiere linux-lts statt linux"
            return 1
            ;;
        opensuse*|sles)
            unhold_cmd="sudo zypper removelock kernel-default"

            if zypper addlock kernel-default 2>&1 | tee -a "$LOG_FILE"; then
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_NVIDIA_KERNEL_HOLD_SUCCESS" "kernel-default")"
                log_info "$MSG_NVIDIA_KERNEL_HOLD_INFO"
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_NVIDIA_KERNEL_UNHOLD_LATER" "$unhold_cmd")"
                return 0
            fi
            ;;
        solus)
            log_warning "Solus: Kernel-Hold nicht standardmäßig unterstützt"
            log_info "Erwäge linux-lts Paket statt linux-current"
            return 1
            ;;
        void)
            log_warning "Void Linux: Kernel-Hold via xbps ignorepkg"
            log_info "Füge in /etc/xbps.d/10-ignore.conf hinzu:"
            log_info "  ignorepkg=linux"
            return 1
            ;;
    esac

    log_error "$MSG_NVIDIA_KERNEL_HOLD_FAILED"
    return 1
}

# Test-Build für DKMS (ohne Installation)
test_dkms_build() {
    local kernel_version="$1"

    if ! command -v dkms &> /dev/null; then
        return 1
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_NVIDIA_BUILD_TEST" "$kernel_version")"

    # Ermittle NVIDIA DKMS-Modul
    local nvidia_module
    nvidia_module=$(dkms status 2>/dev/null | grep -i nvidia | head -1 | cut -d',' -f1 | tr -d ' ')

    if [ -z "$nvidia_module" ]; then
        log_warning "Kein NVIDIA DKMS-Modul gefunden für Build-Test"
        return 1
    fi

    # Versuche Build (nur build, nicht install)
    if dkms build -m "$nvidia_module" -k "$kernel_version" 2>&1 | tee -a "$LOG_FILE" | grep -qi "error\|fail"; then
        log_error "$MSG_NVIDIA_BUILD_TEST_FAILED"
        return 1
    fi

    log_info "$MSG_NVIDIA_BUILD_TEST_SUCCESS"
    return 0
}

# Hauptfunktion: NVIDIA-Kompatibilitätsprüfung vor Update
check_nvidia_compatibility() {
    # Prüfung deaktiviert?
    if [ "${NVIDIA_CHECK_DISABLED:-false}" = "true" ]; then
        log_info "$MSG_NVIDIA_SKIP_CHECK"
        return 0
    fi

    # Ist NVIDIA installiert?
    if ! is_nvidia_installed; then
        log_info "$MSG_NVIDIA_NOT_INSTALLED"
        return 0
    fi

    # NVIDIA-Treiber erkannt
    local nvidia_version=""
    if command -v nvidia-smi &> /dev/null; then
        nvidia_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)
    elif [ -f /sys/module/nvidia/version ]; then
        nvidia_version=$(cat /sys/module/nvidia/version 2>/dev/null)
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_NVIDIA_DETECTED" "$nvidia_version")"
    log_info "$MSG_NVIDIA_CHECK"

    # Ermittle pending Kernel-Version
    local pending_kernel
    pending_kernel=$(get_pending_kernel_version "$DISTRO")

    if [ -z "$pending_kernel" ]; then
        # Kein Kernel-Update verfügbar
        return 0
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_NVIDIA_KERNEL_PENDING" "$pending_kernel")"

    # Prüfe DKMS-Status
    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_NVIDIA_DKMS_CHECK" "$pending_kernel")"

    if check_nvidia_dkms_status "$pending_kernel"; then
        log_info "$MSG_NVIDIA_DKMS_OK"
        return 0
    fi

    # DKMS-Module fehlen oder müssen neu gebaut werden
    log_warning "$MSG_NVIDIA_DKMS_REBUILD"

    #######################################################
    # DEFAULT-VERHALTEN (Sicher für normale User)
    #######################################################
    if [ "${NVIDIA_ALLOW_UNSUPPORTED_KERNEL:-false}" != "true" ]; then
        # Test-Build durchführen um Kompatibilität zu prüfen
        if ! test_dkms_build "$pending_kernel"; then
            # Build fehlgeschlagen → Kernel nicht kompatibel
            # shellcheck disable=SC2059
            log_warning "$(printf "$MSG_NVIDIA_KERNEL_UNSUPPORTED" "$nvidia_version" "$pending_kernel")"
            log_warning "$MSG_NVIDIA_KERNEL_HOLD"
            log_warning "$MSG_NVIDIA_CHECK_NVIDIA_DOCS"

            # Kernel-Update zurückhalten
            if hold_kernel_update "$DISTRO"; then
                # Erfolgreich zurückgehalten, Rest des Updates fortsetzen
                return 0
            else
                # Konnte nicht zurückhalten → User fragen
                echo
                echo -e "${YELLOW}$MSG_NVIDIA_CONTINUE_ANYWAY [j/N]:${NC} "
                read -r response
                if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                    log_info "$MSG_NVIDIA_UPDATE_CANCELLED"
                    exit 0
                fi
            fi
        else
            # Test-Build erfolgreich → DKMS sollte funktionieren
            log_info "$MSG_NVIDIA_BUILD_TEST_SUCCESS"

            # Versuche DKMS autoinstall
            log_info "Führe DKMS autoinstall durch..."
            if dkms autoinstall -k "$pending_kernel" 2>&1 | tee -a "$LOG_FILE"; then
                log_info "$MSG_NVIDIA_DKMS_REBUILD_SUCCESS"

                # Prüfe Secure Boot und signiere wenn nötig
                handle_secureboot_signing "$pending_kernel"

                return 0
            else
                log_error "$MSG_NVIDIA_DKMS_REBUILD_FAILED"

                # Selbst wenn Test erfolgreich war, Build fehlgeschlagen
                # Kernel zurückhalten
                log_warning "$MSG_NVIDIA_KERNEL_HOLD"
                if hold_kernel_update "$DISTRO"; then
                    return 0
                else
                    echo -e "${YELLOW}$MSG_NVIDIA_CONTINUE_ANYWAY [j/N]:${NC} "
                    read -r response
                    if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                        log_info "$MSG_NVIDIA_UPDATE_CANCELLED"
                        exit 0
                    fi
                fi
            fi
        fi
    else
        #######################################################
        # POWER-USER-MODUS (Risiko akzeptiert)
        #######################################################
        log_warning "$MSG_NVIDIA_POWERUSER_MODE"
        log_warning "$MSG_NVIDIA_POWERUSER_RISK"

        # Frage ob DKMS rebuild durchgeführt werden soll
        if [ "${NVIDIA_AUTO_DKMS_REBUILD:-false}" != "true" ]; then
            echo -e "${YELLOW}$MSG_NVIDIA_DKMS_REBUILD_NOW [j/N]:${NC} "
            read -r response
            if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                log_info "$MSG_NVIDIA_UPDATE_CANCELLED"
                exit 0
            fi
        fi

        # DKMS rebuild durchführen (auch wenn riskant)
        log_info "Führe DKMS autoinstall durch..."
        if dkms autoinstall -k "$pending_kernel" 2>&1 | tee -a "$LOG_FILE"; then
            log_info "$MSG_NVIDIA_DKMS_REBUILD_SUCCESS"

            # Prüfe Secure Boot und signiere wenn nötig
            handle_secureboot_signing "$pending_kernel"

            return 0
        else
            log_error "$MSG_NVIDIA_DKMS_REBUILD_FAILED"

            echo -e "${YELLOW}$MSG_NVIDIA_CONTINUE_ANYWAY [j/N]:${NC} "
            read -r response
            if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                log_info "$MSG_NVIDIA_UPDATE_CANCELLED"
                exit 0
            fi
        fi
    fi

    return 0
}

# Behandelt Secure Boot Signierung nach DKMS-Build
handle_secureboot_signing() {
    local kernel_version="$1"

    # Prüfe Secure Boot Status
    if is_secureboot_enabled; then
        log_info "$MSG_NVIDIA_SECUREBOOT_ACTIVE"
        log_info "$MSG_NVIDIA_MOK_CHECK"

        if check_mok_keys; then
            log_info "$MSG_NVIDIA_MOK_FOUND"
            log_info "$MSG_NVIDIA_MOK_SIGN_REQUIRED"

            # Automatische Signierung oder fragen?
            local do_sign=false
            if [ "${NVIDIA_AUTO_MOK_SIGN:-false}" = "true" ]; then
                do_sign=true
            else
                echo -e "${YELLOW}Module jetzt signieren? [J/n]:${NC} "
                read -r response
                if [[ "$response" =~ ^[jJyY]$|^$ ]]; then
                    do_sign=true
                fi
            fi

            if [ "$do_sign" = true ]; then
                if sign_nvidia_modules "$kernel_version"; then
                    log_info "$MSG_NVIDIA_MOK_SIGN_SUCCESS"
                else
                    log_warning "$MSG_NVIDIA_MOK_SIGN_FAILED"
                    log_warning "$MSG_NVIDIA_MOK_DOCS"
                fi
            fi
        else
            log_warning "$MSG_NVIDIA_MOK_MISSING"
            log_warning "$MSG_NVIDIA_MOK_ENROLLMENT_NEEDED"
            log_warning "$MSG_NVIDIA_MOK_ENROLLMENT_INFO"
            log_info "$MSG_NVIDIA_MOK_DOCS"
        fi
    elif is_secureboot_enabled; then
        case $? in
            1)
                log_info "$MSG_NVIDIA_SECUREBOOT_INACTIVE"
                ;;
            2)
                log_warning "$MSG_NVIDIA_SECUREBOOT_UNKNOWN"
                ;;
        esac
    fi
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

# Linux Mint Upgrade-Check
check_upgrade_mint() {
    log_info "$MSG_UPGRADE_CHECKING_MINT"

    # Prüfe ob mintupgrade installiert ist
    if ! command -v mintupgrade &> /dev/null; then
        log_warning "$MSG_UPGRADE_MINTUPGRADE_NOT_INSTALLED"
        log_info "$MSG_UPGRADE_MINTUPGRADE_INSTALLING"

        if apt-get update 2>&1 | tee -a "$LOG_FILE" && \
           apt-get install -y mintupgrade 2>&1 | tee -a "$LOG_FILE"; then
            log_info "$MSG_UPGRADE_MINTUPGRADE_INSTALL_SUCCESS"
        else
            log_error "$MSG_UPGRADE_MINTUPGRADE_INSTALL_FAILED"
            log_info "$MSG_UPGRADE_MINTUPGRADE_MANUAL"
            return 1
        fi
    fi

    # Prüfe auf neue Mint-Version
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

        # E-Mail-Benachrichtigung
        if [ "$UPGRADE_NOTIFY_EMAIL" = true ]; then
            local email_body="$EMAIL_BODY_UPGRADE

Aktuelle Version: Linux Mint $VERSION
Neue Version: Linux Mint ${new_version:-unbekannt}

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
        linuxmint|mint)
            check_upgrade_mint
            return $?
            ;;
        debian|ubuntu)
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
        linuxmint|mint)
            # Linux Mint: mintupgrade verwenden
            if ! command -v mintupgrade &> /dev/null; then
                log_warning "$MSG_UPGRADE_MINTUPGRADE_NOT_INSTALLED"
                log_info "$MSG_UPGRADE_MINTUPGRADE_INSTALLING"

                if apt-get update 2>&1 | tee -a "$LOG_FILE" && \
                   apt-get install -y mintupgrade 2>&1 | tee -a "$LOG_FILE"; then
                    log_info "$MSG_UPGRADE_MINTUPGRADE_INSTALL_SUCCESS"
                else
                    log_error "$MSG_UPGRADE_MINTUPGRADE_INSTALL_FAILED"
                    log_info "$MSG_UPGRADE_MINTUPGRADE_MANUAL"
                    return 1
                fi
            fi

            # Dry-Run: Prüfe Abhängigkeiten und Konflikte
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

            # Führe Mint-Upgrade durch
            # shellcheck disable=SC2059
            printf "$MSG_UPGRADE_START\n" "neue Linux Mint Version" | tee -a "$LOG_FILE"
            if mintupgrade 2>&1 | tee -a "$LOG_FILE"; then
                log_info "$MSG_UPGRADE_SUCCESS"
                return 0
            else
                log_error "$MSG_UPGRADE_FAILED"
                return 1
            fi
            ;;
        debian|ubuntu)
            # Debian/Ubuntu: do-release-upgrade verwenden
            if ! command -v do-release-upgrade &> /dev/null; then
                log_error "do-release-upgrade nicht gefunden"
                return 1
            fi

            # Dry-Run: Prüfe Abhängigkeiten und Konflikte
            log_info "$MSG_UPGRADE_DRY_RUN_START"
            if ! do-release-upgrade -c 2>&1 | tee -a "$LOG_FILE" | grep -qi "new release\|upgrade"; then
                log_warning "$MSG_UPGRADE_DRY_RUN_FAILED"
            else
                log_info "$MSG_UPGRADE_DRY_RUN_OK"
            fi

            # Führe Upgrade durch
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

            # Dry-Run: Prüfe Download ohne Installation
            log_info "$MSG_UPGRADE_DRY_RUN_START"
            if ! dnf system-upgrade download --refresh --releasever="$new_version" --assumeno 2>&1 | tee -a "$LOG_FILE" | grep -qi "will be installed"; then
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

            # Führe Upgrade durch
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
    # Prüfe ob Neustart erforderlich ist (mehrere Methoden)
    local reboot_needed=false

    # Methode 1: /var/run/reboot-required (Debian/Ubuntu/Mint)
    if [ -f /var/run/reboot-required ]; then
        reboot_needed=true
    fi

    # Methode 2: Kernel-Update (neuer Kernel != laufender Kernel)
    local current_kernel
    local installed_kernel
    current_kernel=$(uname -r)

    case "$DISTRO" in
        debian|ubuntu|linuxmint|mint)
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

    # Wenn kein Neustart erforderlich, zurück
    if [ "$reboot_needed" = false ]; then
        return 0
    fi

    # Neustart erforderlich - prüfe AUTO_REBOOT (robuste Prüfung)
    if [ "$AUTO_REBOOT" = "true" ] || [ "$AUTO_REBOOT" = true ]; then
        log_warning "$MSG_REBOOT_AUTO_COUNTDOWN"
        log "AUTO_REBOOT ist aktiviert, starte Neustart-Countdown"

        send_email "$EMAIL_SUBJECT_REBOOT" "$MSG_REBOOT_NOTIFICATION"
        send_notification \
            "$NOTIFICATION_REBOOT_REQUIRED" \
            "$NOTIFICATION_REBOOT_AUTO_BODY" \
            "critical" \
            "system-reboot"

        # Shutdown mit Countdown
        log "Führe Shutdown-Befehl aus: shutdown -r +5"
        shutdown -r +5 "System wird in 5 Minuten neu gestartet (Update)" 2>&1 | tee -a "$LOG_FILE"

        # Bestätigung im Log
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

# NVIDIA-Kernel-Kompatibilität prüfen (VOR dem Update!)
check_nvidia_compatibility

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
