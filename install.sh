#!/bin/bash

#############################################################
# Linux System Update Script - Installer
# Interaktives Setup und Konfiguration
# MIT License
#############################################################

# Farbcodes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script-Verzeichnis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# XDG-konforme Config-Pfade (v1.6.0+)
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="${XDG_CONFIG_HOME}/linux-update-script"
CONFIG_FILE="${CONFIG_DIR}/config.conf"
OLD_CONFIG_FILE="${SCRIPT_DIR}/config.conf"
UPDATE_SCRIPT="${SCRIPT_DIR}/update.sh"

# Sprache auswählen und laden
select_and_load_language() {
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}   Wähle deine Sprache / Choose your language${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo
    echo "  1) Deutsch (de)"
    echo "  2) English (en)"
    echo "  3) Auto-detect / Automatisch"
    echo
    read -r -p "Selection / Auswahl [1-3]: " lang_choice

    case "$lang_choice" in
        1) INSTALLER_LANGUAGE="de" ;;
        2) INSTALLER_LANGUAGE="en" ;;
        3|"")
            # Auto-detect
            INSTALLER_LANGUAGE="${LANG%%.*}"
            INSTALLER_LANGUAGE="${INSTALLER_LANGUAGE%%_*}"
            INSTALLER_LANGUAGE="${INSTALLER_LANGUAGE:-en}"
            ;;
        *) INSTALLER_LANGUAGE="en" ;;
    esac

    # Sprachdatei für Installer laden
    local install_lang_file="${SCRIPT_DIR}/lang/install-${INSTALLER_LANGUAGE}.lang"
    if [ -f "$install_lang_file" ]; then
        # shellcheck source=/dev/null
        source "$install_lang_file"
    else
        # Fallback zu Englisch
        # shellcheck source=/dev/null
        source "${SCRIPT_DIR}/lang/install-en.lang" 2>/dev/null || {
            echo "ERROR: No language files found!"
            exit 1
        }
    fi

    # Update-Script Sprache setzen (wird in config geschrieben)
    LANGUAGE="$INSTALLER_LANGUAGE"
}

# Sprache initialisieren
select_and_load_language

#############################################################
# Funktionen
#############################################################

print_header() {
    clear
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}   ${INSTALL_HEADER}${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo
}

print_info() {
    echo -e "${GREEN}[${INSTALL_LABEL_INFO}]${NC} $1"
}

print_error() {
    echo -e "${RED}[${INSTALL_LABEL_ERROR}]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[${INSTALL_LABEL_WARNING}]${NC} $1"
}

# Ja/Nein-Frage
ask_yes_no() {
    local question="$1"
    local default="$2"
    local answer

    if [ "$default" = "y" ]; then
        echo -ne "${YELLOW}$question [J/n]:${NC} "
    else
        echo -ne "${YELLOW}$question [j/N]:${NC} "
    fi

    read -r answer

    if [ -z "$answer" ]; then
        answer="$default"
    fi

    case "$answer" in
        [JjYy]* ) return 0 ;;
        * ) return 1 ;;
    esac
}

# Eingabe mit Standardwert
ask_input() {
    local question="$1"
    local default="$2"
    local answer

    if [ -n "$default" ]; then
        echo -ne "${YELLOW}$question [$default]:${NC} " >&2
    else
        echo -ne "${YELLOW}$question:${NC} " >&2
    fi

    read -r answer

    if [ -z "$answer" ]; then
        echo "$default"
    else
        echo "$answer"
    fi
}

# Konfiguration laden (falls vorhanden)
load_existing_config() {
    # Neue XDG-Location prüfen
    if [ -f "$CONFIG_FILE" ]; then
        print_info "$INSTALL_CONFIG_EXISTS"
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
        return 0
    fi

    # Alte Location als Fallback (wird später migriert)
    if [ -f "$OLD_CONFIG_FILE" ]; then
        print_info "$INSTALL_CONFIG_EXISTS (alte Location)"
        # shellcheck source=/dev/null
        source "$OLD_CONFIG_FILE"
        return 0
    fi

    return 1
}

# Konfiguration erstellen
create_config() {
    print_header
    echo -e "${GREEN}Konfiguration wird erstellt...${NC}\n"

    # Info über Config-Location (XDG-konform seit v1.6.0)
    print_info "Konfigurations-Pfad: $CONFIG_FILE"
    echo

    # Standard-Werte
    local enable_email="false"
    local email_recipient=""
    local log_dir="/var/log/system-updates"
    local auto_reboot="false"
    local enable_desktop_notification="true"
    local notification_timeout="5000"

    # Bestehende Konfiguration laden
    if load_existing_config; then
        enable_email="${ENABLE_EMAIL:-false}"
        email_recipient="${EMAIL_RECIPIENT:-}"
        log_dir="${LOG_DIR:-/var/log/system-updates}"
        auto_reboot="${AUTO_REBOOT:-false}"
        enable_desktop_notification="${ENABLE_DESKTOP_NOTIFICATION:-true}"
        notification_timeout="${NOTIFICATION_TIMEOUT:-5000}"
        echo
    fi

    # E-Mail-Benachrichtigung
    if ask_yes_no "E-Mail-Benachrichtigung aktivieren?" "n"; then
        enable_email="true"
        echo

        # E-Mail-Adresse abfragen
        while true; do
            email_recipient=$(ask_input "E-Mail-Adresse für Benachrichtigungen" "$email_recipient")
            if [ -n "$email_recipient" ]; then
                echo
                print_info "E-Mail-Adresse gespeichert: $email_recipient"
                break
            else
                echo
                print_error "E-Mail-Adresse darf nicht leer sein"
            fi
        done

        # Mail-Programm prüfen
        echo
        if ! command -v mail &> /dev/null && ! command -v sendmail &> /dev/null; then
            echo
            print_warning "Kein Mail-Programm gefunden (mail/sendmail)"
            echo
            echo "Für E-Mail-Benachrichtigungen benötigst du:"
            echo "  1. Mail-Client (mail oder mailx)"
            echo "  2. MTA (Mail Transfer Agent) wie postfix oder ssmtp"
            echo
            echo "Installation:"
            echo "  - Debian/Ubuntu/Mint: sudo apt install mailutils postfix"
            echo "  - RHEL/Fedora: sudo dnf install mailx postfix"
            echo "  - openSUSE: sudo zypper install mailx postfix"
            echo "  - Arch/Manjaro: sudo pacman -S mailutils postfix"
            echo "  - Solus: sudo eopkg install mailutils postfix"
            echo "  - Void Linux: sudo xbps-install -S mailx postfix"
            echo
            echo "Für einfache Konfiguration (z.B. Gmail) verwende ssmtp statt postfix."
            echo "Du kannst dies jetzt installieren oder später nachrüsten."
            echo
            if ask_yes_no "Trotzdem mit E-Mail-Benachrichtigung fortfahren?" "y"; then
                print_info "E-Mail-Benachrichtigung aktiviert (Mail-Programm muss noch installiert werden)"
            else
                enable_email="false"
                print_info "E-Mail-Benachrichtigung deaktiviert"
            fi
            echo
        fi
    else
        enable_email="false"
    fi

    # Automatischer Neustart
    if ask_yes_no "Automatischen Neustart aktivieren (falls erforderlich)?" "n"; then
        auto_reboot="true"
        print_warning "System wird automatisch neu gestartet, wenn Updates dies erfordern!"
    else
        auto_reboot="false"
    fi

    # Desktop-Benachrichtigungen
    echo
    echo "$INSTALL_DESKTOP_INFO"
    if ask_yes_no "$INSTALL_DESKTOP_ENABLE" "y"; then
        # Prüfen ob notify-send installiert ist
        if ! command -v notify-send &> /dev/null; then
            echo
            print_warning "$INSTALL_DESKTOP_NO_NOTIFY"
            echo
            echo "$INSTALL_DESKTOP_REQUIREMENTS"
            echo
            echo "$INSTALL_DESKTOP_INSTALLATION"

            # Distribution erkennen und Installation anbieten
            if [ -f /etc/os-release ]; then
                # shellcheck source=/dev/null
                . /etc/os-release
                case "$ID" in
                    debian|ubuntu|linuxmint|pop)
                        echo "  sudo apt-get install libnotify-bin"
                        echo
                        if ask_yes_no "$INSTALL_DESKTOP_INSTALL_NOW" "y"; then
                            if sudo apt-get install -y libnotify-bin 2>/dev/null; then
                                print_info "$INSTALL_DESKTOP_INSTALL_SUCCESS"
                            else
                                print_error "$INSTALL_DESKTOP_INSTALL_FAILED"
                            fi
                        fi
                        ;;
                    fedora|rhel|centos|rocky|almalinux)
                        echo "  sudo dnf install libnotify"
                        echo
                        if ask_yes_no "$INSTALL_DESKTOP_INSTALL_NOW" "y"; then
                            if sudo dnf install -y libnotify 2>/dev/null; then
                                print_info "$INSTALL_DESKTOP_INSTALL_SUCCESS"
                            else
                                print_error "$INSTALL_DESKTOP_INSTALL_FAILED"
                            fi
                        fi
                        ;;
                    arch|manjaro|endeavouros|garuda|arcolinux)
                        echo "  sudo pacman -S libnotify"
                        echo
                        if ask_yes_no "$INSTALL_DESKTOP_INSTALL_NOW" "y"; then
                            if sudo pacman -S --noconfirm libnotify 2>/dev/null; then
                                print_info "$INSTALL_DESKTOP_INSTALL_SUCCESS"
                            else
                                print_error "$INSTALL_DESKTOP_INSTALL_FAILED"
                            fi
                        fi
                        ;;
                    opensuse*|sles)
                        echo "  sudo zypper install libnotify-tools"
                        echo
                        if ask_yes_no "$INSTALL_DESKTOP_INSTALL_NOW" "y"; then
                            if sudo zypper install -y libnotify-tools 2>/dev/null; then
                                print_info "$INSTALL_DESKTOP_INSTALL_SUCCESS"
                            else
                                print_error "$INSTALL_DESKTOP_INSTALL_FAILED"
                            fi
                        fi
                        ;;
                    solus)
                        echo "  sudo eopkg install libnotify"
                        echo
                        if ask_yes_no "$INSTALL_DESKTOP_INSTALL_NOW" "y"; then
                            if sudo eopkg install -y libnotify 2>/dev/null; then
                                print_info "$INSTALL_DESKTOP_INSTALL_SUCCESS"
                            else
                                print_error "$INSTALL_DESKTOP_INSTALL_FAILED"
                            fi
                        fi
                        ;;
                    void)
                        echo "  sudo xbps-install -S libnotify"
                        echo
                        if ask_yes_no "$INSTALL_DESKTOP_INSTALL_NOW" "y"; then
                            if sudo xbps-install -y libnotify 2>/dev/null; then
                                print_info "$INSTALL_DESKTOP_INSTALL_SUCCESS"
                            else
                                print_error "$INSTALL_DESKTOP_INSTALL_FAILED"
                            fi
                        fi
                        ;;
                    *)
                        echo "  Siehe Dokumentation deiner Distribution"
                        ;;
                esac
            fi

            echo
            if ask_yes_no "$INSTALL_DESKTOP_CONTINUE" "y"; then
                enable_desktop_notification="true"
                print_info "$INSTALL_DESKTOP_ENABLED"
            else
                enable_desktop_notification="false"
                print_info "$INSTALL_DESKTOP_DISABLED"
            fi
        else
            enable_desktop_notification="true"
            print_info "$INSTALL_DESKTOP_ENABLED"
        fi
    else
        enable_desktop_notification="false"
        print_info "$INSTALL_DESKTOP_DISABLED"
    fi

    # Log-Verzeichnis (optional, erweiterte Einstellung)
    echo
    print_info "Standard Log-Verzeichnis: $log_dir"
    if ask_yes_no "Möchtest du das Log-Verzeichnis ändern?" "n"; then
        log_dir=$(ask_input "Neues Log-Verzeichnis" "$log_dir")
        print_info "Log-Verzeichnis geändert auf: $log_dir"
    fi

    # Config-Verzeichnis erstellen (XDG-konform)
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR" 2>/dev/null || {
            print_error "Kann Config-Verzeichnis nicht erstellen: $CONFIG_DIR"
            exit 1
        }
    fi

    # Alte Config migrieren (falls vorhanden)
    if [ -f "$OLD_CONFIG_FILE" ] && [ ! -f "$CONFIG_FILE" ]; then
        echo
        print_info "Alte Konfiguration gefunden: $OLD_CONFIG_FILE"
        if ask_yes_no "Soll die alte Konfiguration migriert werden?" "y"; then
            if cp "$OLD_CONFIG_FILE" "$CONFIG_FILE" 2>/dev/null; then
                print_info "Konfiguration erfolgreich migriert nach: $CONFIG_FILE"
                mv "$OLD_CONFIG_FILE" "${OLD_CONFIG_FILE}.migrated" 2>/dev/null && \
                    print_info "Alte Konfiguration gesichert als: ${OLD_CONFIG_FILE}.migrated"
                echo
                print_info "Installation abgeschlossen - bestehende Konfiguration wurde übernommen"
                return 0
            else
                print_error "Fehler beim Migrieren der Konfiguration"
            fi
        fi
    fi

    # Konfigurationsdatei schreiben
    cat > "$CONFIG_FILE" << EOF
# Update-Script Konfiguration
# $INSTALL_GENERATED_AT: $(date)

# Sprache / Language (auto|de|en)
LANGUAGE=$LANGUAGE

# E-Mail-Benachrichtigung aktivieren (true/false)
ENABLE_EMAIL=$enable_email

# E-Mail-Empfänger
EMAIL_RECIPIENT="$email_recipient"

# Log-Verzeichnis
LOG_DIR="$log_dir"

# Automatischer Neustart bei Bedarf (true/false)
AUTO_REBOOT=$auto_reboot

# Kernel-Schutz (true/false)
# Verhindert autoremove wenn zu wenige Kernel installiert sind
KERNEL_PROTECTION=true

# Minimale Anzahl stabiler Kernel (Standard: 3)
MIN_KERNELS=3

# Upgrade-Check aktivieren (true/false)
# Prüft nach regulären Updates, ob Distribution-Upgrades verfügbar sind
ENABLE_UPGRADE_CHECK=true

# Automatisches Upgrade durchführen (true/false)
# WARNUNG: Kann Breaking Changes verursachen!
AUTO_UPGRADE=false

# Upgrade-Benachrichtigungen per E-Mail (true/false)
UPGRADE_NOTIFY_EMAIL=true

# Desktop-Benachrichtigungen aktivieren (true/false)
ENABLE_DESKTOP_NOTIFICATION=$enable_desktop_notification

# Notification-Dauer in Millisekunden
NOTIFICATION_TIMEOUT=$notification_timeout
EOF

    print_info "$INSTALL_CONFIG_SAVED: $CONFIG_FILE"
    echo

    # Log-Verzeichnis erstellen
    if [ ! -d "$log_dir" ]; then
        # Erst ohne sudo versuchen
        if mkdir -p "$log_dir" 2>/dev/null; then
            print_info "Log-Verzeichnis erstellt: $log_dir"
        else
            # Benötigt root-Rechte
            print_warning "Log-Verzeichnis benötigt root-Rechte: $log_dir"
            echo
            if ask_yes_no "Soll das Log-Verzeichnis jetzt mit sudo angelegt werden?" "y"; then
                if sudo mkdir -p "$log_dir" 2>/dev/null; then
                    print_info "Log-Verzeichnis erfolgreich erstellt: $log_dir"
                    # Berechtigungen setzen, damit Logs lesbar sind
                    sudo chmod 755 "$log_dir" 2>/dev/null
                else
                    print_error "Fehler beim Erstellen des Log-Verzeichnisses"
                    print_info "Wird beim ersten Ausführen von 'sudo ./update.sh' erstellt"
                fi
            else
                print_info "Log-Verzeichnis wird beim ersten Update-Durchlauf erstellt"
            fi
            echo
        fi
    else
        print_info "Log-Verzeichnis existiert bereits: $log_dir"
    fi
}

# Cron-Job einrichten
setup_cron() {
    print_header
    echo -e "${GREEN}Cron-Job Einrichtung${NC}\n"

    if ! ask_yes_no "Möchtest du einen automatischen Cron-Job einrichten?" "y"; then
        print_info "Cron-Job-Einrichtung übersprungen"
        return
    fi

    # Log-Verzeichnis aus Config laden
    local log_dir="/var/log/system-updates"
    if [ -f "$CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
        log_dir="${LOG_DIR:-/var/log/system-updates}"
    fi

    echo
    echo "Wähle die Häufigkeit:"
    echo "  1) Täglich um 3:00 Uhr"
    echo "  2) Wöchentlich (Sonntag, 3:00 Uhr)"
    echo "  3) Monatlich (1. des Monats, 3:00 Uhr)"
    echo "  4) Benutzerdefiniert"
    echo "  5) Überspringen"
    echo

    local choice
    choice=$(ask_input "Auswahl [1-5]" "1")
    # Whitespace entfernen und nur erste Zeile nehmen
    choice=$(echo "$choice" | head -n 1 | tr -d ' \t\n\r')

    echo
    local cron_schedule=""
    case "$choice" in
        1)
            cron_schedule="0 3 * * *"
            echo
            print_info "Gewählt: Täglich um 3:00 Uhr"
            ;;
        2)
            cron_schedule="0 3 * * 0"
            echo
            print_info "Gewählt: Wöchentlich (Sonntag, 3:00 Uhr)"
            ;;
        3)
            cron_schedule="0 3 1 * *"
            echo
            print_info "Gewählt: Monatlich (1. des Monats, 3:00 Uhr)"
            ;;
        4)
            echo
            echo "Cron-Format: Minute Stunde Tag Monat Wochentag"
            echo "Beispiel: 0 3 * * * (Täglich um 3:00 Uhr)"
            echo
            cron_schedule=$(ask_input "Cron-Schedule")
            if [ -n "$cron_schedule" ]; then
                print_info "Benutzerdefinierter Schedule: $cron_schedule"
            fi
            ;;
        5)
            print_info "Cron-Job-Einrichtung übersprungen"
            return
            ;;
        *)
            print_error "Ungültige Auswahl: '$choice'"
            print_info "Cron-Job-Einrichtung übersprungen"
            return
            ;;
    esac

    if [ -z "$cron_schedule" ]; then
        print_error "Ungültiger Cron-Schedule"
        return
    fi

    # Cron-Job hinzufügen (im root-Crontab, da Update-Script root-Rechte benötigt)
    local cron_command="$cron_schedule $UPDATE_SCRIPT >> $log_dir/cron.log 2>&1"
    local cron_comment="# Automatisches System-Update"

    echo
    print_info "Der Cron-Job wird im root-Crontab eingerichtet (benötigt sudo)..."
    echo

    # Prüfen ob bereits vorhanden
    if sudo crontab -l 2>/dev/null | grep -q "$UPDATE_SCRIPT"; then
        print_warning "Cron-Job bereits im root-Crontab vorhanden"
        if ask_yes_no "Möchtest du den bestehenden Cron-Job ersetzen?" "y"; then
            # Alten Eintrag entfernen
            sudo crontab -l 2>/dev/null | grep -v "$UPDATE_SCRIPT" | sudo crontab -
        else
            return
        fi
    fi

    # Neuen Cron-Job hinzufügen
    if (sudo crontab -l 2>/dev/null; echo "$cron_comment"; echo "$cron_command") | sudo crontab -; then
        print_info "Cron-Job erfolgreich eingerichtet"
        echo
        echo "Aktueller root-Cron-Job:"
        sudo crontab -l | grep -A1 "Automatisches System-Update"
    else
        print_error "Fehler beim Einrichten des Cron-Jobs"
        echo
        print_warning "Manuell einrichten mit: sudo crontab -e"
        echo "Dann folgende Zeilen hinzufügen:"
        echo "$cron_comment"
        echo "$cron_command"
    fi
}

# Test-Durchlauf
test_script() {
    print_header
    echo -e "${GREEN}Test-Durchlauf${NC}\n"

    if ! ask_yes_no "Möchtest du einen Test-Durchlauf starten?" "n"; then
        return
    fi

    print_warning "Der Test-Durchlauf führt die Updates NICHT aus, prüft aber die Konfiguration"
    echo

    if [ ! -x "$UPDATE_SCRIPT" ]; then
        print_error "Update-Script nicht ausführbar: $UPDATE_SCRIPT"
        return
    fi

    print_info "Starte Test..."
    echo
    echo "--- Konfiguration ---"
    cat "$CONFIG_FILE"
    echo
    echo "--- Distribution ---"
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        echo "Distribution: $NAME $VERSION"
        echo "ID: $ID"
    fi
    echo
}

# Zusammenfassung anzeigen
show_summary() {
    print_header
    echo -e "${GREEN}Installation abgeschlossen!${NC}\n"

    echo "Konfigurationsdatei: $CONFIG_FILE"
    echo "Update-Script: $UPDATE_SCRIPT"
    echo
    echo "--- Konfiguration ---"
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    fi
    echo
    echo -e "${YELLOW}Nächste Schritte:${NC}"
    echo "1. Update-Script manuell ausführen:"
    echo "   sudo $UPDATE_SCRIPT"
    echo
    echo "2. Konfiguration später ändern:"
    echo "   $0"
    echo
    echo "3. Cron-Jobs anzeigen:"
    echo "   crontab -l"
    echo
}

#############################################################
# Hauptprogramm
#############################################################

# Prüfen ob Update-Script existiert
if [ ! -f "$UPDATE_SCRIPT" ]; then
    print_error "Update-Script nicht gefunden: $UPDATE_SCRIPT"
    exit 1
fi

# Update-Script ausführbar machen
if [ ! -x "$UPDATE_SCRIPT" ]; then
    chmod +x "$UPDATE_SCRIPT" 2>/dev/null
fi

# Bestehende Konfiguration prüfen
if [ -f "$CONFIG_FILE" ]; then
    print_header
    print_warning "Bestehende Konfiguration gefunden!"
    echo
    cat "$CONFIG_FILE"
    echo

    if ! ask_yes_no "Möchtest du die Konfiguration ändern?" "y"; then
        print_info "Installation abgebrochen"
        exit 0
    fi
fi

# Installation durchführen
create_config
echo
read -r -p "Drücke Enter zum Fortfahren..."

setup_cron
echo
read -r -p "Drücke Enter zum Fortfahren..."

test_script
echo
read -r -p "Drücke Enter zum Fortfahren..."

show_summary
