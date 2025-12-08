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
CONFIG_FILE="${SCRIPT_DIR}/config.conf"
UPDATE_SCRIPT="${SCRIPT_DIR}/update.sh"

#############################################################
# Funktionen
#############################################################

print_header() {
    clear
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}   Linux System Update Script - Installation${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[FEHLER]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNUNG]${NC} $1"
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
    if [ -f "$CONFIG_FILE" ]; then
        print_info "Bestehende Konfiguration gefunden"
        source "$CONFIG_FILE"
        return 0
    fi
    return 1
}

# Konfiguration erstellen
create_config() {
    print_header
    echo -e "${GREEN}Konfiguration wird erstellt...${NC}\n"

    # Standard-Werte
    local enable_email="false"
    local email_recipient=""
    local log_dir="/var/log/system-updates"
    local auto_reboot="false"

    # Bestehende Konfiguration laden
    if load_existing_config; then
        enable_email="${ENABLE_EMAIL:-false}"
        email_recipient="${EMAIL_RECIPIENT:-}"
        log_dir="${LOG_DIR:-/var/log/system-updates}"
        auto_reboot="${AUTO_REBOOT:-false}"
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

    # Log-Verzeichnis (optional, erweiterte Einstellung)
    echo
    print_info "Standard Log-Verzeichnis: $log_dir"
    if ask_yes_no "Möchtest du das Log-Verzeichnis ändern?" "n"; then
        log_dir=$(ask_input "Neues Log-Verzeichnis" "$log_dir")
        print_info "Log-Verzeichnis geändert auf: $log_dir"
    fi

    # Konfigurationsdatei schreiben
    cat > "$CONFIG_FILE" << EOF
# Update-Script Konfiguration
# Generiert am: $(date)

# E-Mail-Benachrichtigung aktivieren (true/false)
ENABLE_EMAIL=$enable_email

# E-Mail-Empfänger
EMAIL_RECIPIENT="$email_recipient"

# Log-Verzeichnis
LOG_DIR="$log_dir"

# Automatischer Neustart bei Bedarf (true/false)
AUTO_REBOOT=$auto_reboot
EOF

    print_info "Konfiguration gespeichert: $CONFIG_FILE"
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
