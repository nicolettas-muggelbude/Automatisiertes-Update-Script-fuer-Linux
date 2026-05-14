#!/bin/bash
# lib/core.sh - Basis-Funktionen: Farben, Config, Logging, Distro-Erkennung
# shellcheck disable=SC2034
# Variablen werden in anderen lib/*.sh Modulen verwendet (cross-module)

#############################################################
# Farb-Codes
#############################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

#############################################################
# Standard-Konfiguration (Defaults, werden durch Config überschrieben)
#############################################################
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
ENABLE_HOOKS=true
HOOKS_DIR="/etc/update-hooks"
HOOKS_ABORT_ON_ERROR=false
HOOKS_TIMEOUT=300
ENABLE_BACKUP=false
BACKUP_METHOD="rsync"
BACKUP_TARGET="/backup/system"
BACKUP_RETENTION=3
BACKUP_BEFORE_UPGRADE=true
UPDATE_LOAD_CHECK=false
UPDATE_MAX_LOAD="2.0"
ENABLE_FWUPD=false
BANDWIDTH_LIMIT="auto"
BANDWIDTH_LIMIT_PERCENT=80
BANDWIDTH_TEST_URL=""
ENABLE_PROGRESS=true
EFFECTIVE_BANDWIDTH_LIMIT=""

#############################################################
# Config-Pfade (v2.0.0: nur System + User, kein Legacy-Pfad)
#############################################################
SYSTEM_CONFIG_FILE="/etc/linux-update-script/config.conf"

if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    USER_CONFIG_FILE="${USER_HOME}/.config/linux-update-script/config.conf"
else
    USER_CONFIG_FILE=""
fi

#############################################################
# Config laden (Hybrid: System + User Override)
#############################################################
load_config() {
    local system_config_loaded=false
    local user_config_loaded=false

    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$SYSTEM_CONFIG_FILE"
        system_config_loaded=true
        CONFIG_PRIMARY_SOURCE="System (/etc/)"
    else
        CONFIG_PRIMARY_SOURCE="Defaults (keine Config)"
    fi

    if [ -n "$USER_CONFIG_FILE" ] && [ -f "$USER_CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$USER_CONFIG_FILE"
        user_config_loaded=true

        if [ "$system_config_loaded" = false ]; then
            CONFIG_PRIMARY_SOURCE="User (~/.config/)"
            CONFIG_OVERRIDE_SOURCE="Keine"
        else
            CONFIG_OVERRIDE_SOURCE="User (~/.config/)"
        fi
    else
        CONFIG_OVERRIDE_SOURCE="Kein Override"
    fi

    if [ "$system_config_loaded" = true ] && [ "$user_config_loaded" = true ]; then
        CONFIG_SOURCE="Hybrid (System + User Override)"
    elif [ "$user_config_loaded" = true ]; then
        CONFIG_SOURCE="User (~/.config/) - kein System-Default"
    elif [ "$system_config_loaded" = true ]; then
        CONFIG_SOURCE="$CONFIG_PRIMARY_SOURCE"
    else
        CONFIG_SOURCE="$CONFIG_PRIMARY_SOURCE"
    fi

    if [ "$user_config_loaded" = true ]; then
        # shellcheck disable=SC2034
        CONFIG_FILE="$USER_CONFIG_FILE (Override von $SYSTEM_CONFIG_FILE)"
    elif [ -f "$SYSTEM_CONFIG_FILE" ]; then
        # shellcheck disable=SC2034
        CONFIG_FILE="$SYSTEM_CONFIG_FILE"
    else
        # shellcheck disable=SC2034
        CONFIG_FILE=""
    fi
}

#############################################################
# Sprache laden
#############################################################
load_language() {
    local lang="${LANGUAGE:-auto}"

    if [ "$lang" = "auto" ]; then
        lang="${LANG%%.*}"
        lang="${lang%%_*}"
        lang="${lang:-en}"
    fi

    local lang_file="${SCRIPT_DIR}/lang/${lang}.lang"
    if [ -f "$lang_file" ]; then
        # shellcheck source=/dev/null
        source "$lang_file"
    elif [ -f "${SCRIPT_DIR}/lang/en.lang" ]; then
        # shellcheck source=/dev/null
        source "${SCRIPT_DIR}/lang/en.lang"
    else
        echo "ERROR: No language files found in ${SCRIPT_DIR}/lang/"
        exit 1
    fi
}

#############################################################
# Logging initialisieren (LOG_DIR erstellen, LOG_FILE setzen)
#############################################################
init_logging() {
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE="${LOG_DIR}/update_${TIMESTAMP}.log"

    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR" 2>/dev/null || {
            echo -e "${RED}${MSG_LOG_DIR_ERROR}${NC}"
            exit 1
        }
    fi
}

#############################################################
# Config-Status-Warnungen ausgeben
#############################################################
warn_config_status() {
    if [ "$CONFIG_SOURCE" = "Defaults (keine Config)" ]; then
        echo -e "${YELLOW}[${LABEL_WARNING}]${NC} $MSG_CONFIG_NOT_FOUND"
        echo -e "${YELLOW}[${LABEL_WARNING}]${NC} Verwende Standard-Konfiguration"
        echo -e "${YELLOW}[${LABEL_WARNING}]${NC} E-Mail- und Desktop-Benachrichtigungen sind möglicherweise nicht konfiguriert!"
        echo -e "${YELLOW}[${LABEL_WARNING}]${NC} Erstelle Config mit: ./install.sh"
    elif [ "$CONFIG_SOURCE" = "User (~/.config/) - kein System-Default" ]; then
        echo -e "${YELLOW}[${LABEL_INFO}]${NC} User-Config wird verwendet: ~/.config/linux-update-script/config.conf"
        echo -e "${YELLOW}[${LABEL_INFO}]${NC} HINWEIS: Für Cron-Jobs wird empfohlen auch eine System-Config anzulegen:"
        echo -e "${YELLOW}[${LABEL_INFO}]${NC} sudo mkdir -p /etc/linux-update-script"
        echo -e "${YELLOW}[${LABEL_INFO}]${NC} sudo cp ~/.config/linux-update-script/config.conf /etc/linux-update-script/"
    fi
}

#############################################################
# Logging-Funktionen
#############################################################
log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

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

#############################################################
# Distribution erkennen
#############################################################
detect_distro() {
    # MX-Linux hat ID=debian in os-release, aber DISTRIB_ID=MX in lsb-release
    if [ -f /etc/lsb-release ]; then
        # shellcheck source=/dev/null
        . /etc/lsb-release
        if [ "$DISTRIB_ID" = "MX" ] || echo "$DISTRIB_ID" | grep -qi "^mx"; then
            DISTRO="mx"
            VERSION="${DISTRIB_RELEASE:-unknown}"
            log_info "MX-Linux erkannt (via lsb-release): $DISTRIB_DESCRIPTION"
            return 0
        fi
    fi

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

#############################################################
# Root-Check
#############################################################
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "$MSG_ROOT_REQUIRED"
        echo -e "${YELLOW}${MSG_ROOT_TRY} $0${NC}"
        exit 1
    fi
}

#############################################################
# Config-Debug-Info loggen
#############################################################
log_config_debug() {
    log "=== Config-Debugging (Hybrid-Modus) ==="
    log "SUDO_USER: ${SUDO_USER:-<nicht gesetzt>}"
    log "Primäre Quelle: $CONFIG_PRIMARY_SOURCE"
    log "Override Quelle: $CONFIG_OVERRIDE_SOURCE"
    log "Gesamt: $CONFIG_SOURCE"
    log "Verfügbare Configs:"
    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        log "  ✓ System: $SYSTEM_CONFIG_FILE"
    else
        log "  ✗ System: $SYSTEM_CONFIG_FILE"
    fi
    if [ -n "$USER_CONFIG_FILE" ] && [ -f "$USER_CONFIG_FILE" ]; then
        log "  ✓ User: $USER_CONFIG_FILE"
    elif [ -n "$USER_CONFIG_FILE" ]; then
        log "  ✗ User: $USER_CONFIG_FILE"
    fi
    log "Geladene Config-Werte:"
    log "  AUTO_REBOOT='$AUTO_REBOOT'"
    log "  ENABLE_EMAIL='$ENABLE_EMAIL'"
    log "  EMAIL_RECIPIENT='$EMAIL_RECIPIENT'"
    log "  ENABLE_DESKTOP_NOTIFICATION='$ENABLE_DESKTOP_NOTIFICATION'"
    log "  KERNEL_PROTECTION='$KERNEL_PROTECTION'"
    if [ -f "$SYSTEM_CONFIG_FILE" ] && grep -q "^AUTO_REBOOT=" "$SYSTEM_CONFIG_FILE" 2>/dev/null; then
        log "  AUTO_REBOOT in System-Config: $(grep "^AUTO_REBOOT=" "$SYSTEM_CONFIG_FILE")"
    fi
    if [ -n "$USER_CONFIG_FILE" ] && [ -f "$USER_CONFIG_FILE" ] && grep -q "^AUTO_REBOOT=" "$USER_CONFIG_FILE" 2>/dev/null; then
        log "  AUTO_REBOOT in User-Config: $(grep "^AUTO_REBOOT=" "$USER_CONFIG_FILE")"
    fi
    log "=== Ende Config-Debugging ==="
}
