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

# Config-Pfade (Hybrid-System: v1.6.0+)
# Primär: System-Config in /etc/
SYSTEM_CONFIG_DIR="/etc/linux-update-script"
SYSTEM_CONFIG_FILE="${SYSTEM_CONFIG_DIR}/config.conf"

# Optional: User-Config in ~/.config/ (für Override bei manuellem sudo)
USER_CONFIG_DIR="$HOME/.config/linux-update-script"
USER_CONFIG_FILE="${USER_CONFIG_DIR}/config.conf"

# Legacy
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
    # Hybrid-Ansatz: System-Config → User-Config → Alt

    # Priorität 1: System-Config (/etc/)
    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        print_info "$INSTALL_CONFIG_EXISTS (System: /etc/)"
        # shellcheck source=/dev/null
        source "$SYSTEM_CONFIG_FILE"
        return 0
    fi

    # Priorität 2: User-Config (~/.config/)
    if [ -f "$USER_CONFIG_FILE" ]; then
        print_info "$INSTALL_CONFIG_EXISTS (User: ~/.config/)"
        # shellcheck source=/dev/null
        source "$USER_CONFIG_FILE"
        return 0
    fi

    # Priorität 3: Alte Location (Script-Verzeichnis)
    if [ -f "$OLD_CONFIG_FILE" ]; then
        print_info "$INSTALL_CONFIG_EXISTS (Legacy: Script-Dir)"
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
    echo "E-Mail-Benachrichtigungen bei erfolgreichen Updates, Fehlern und Upgrades."
    echo
    if ask_yes_no "E-Mail-Benachrichtigung aktivieren?" "y"; then
        enable_email="true"
        echo

        # E-Mail-Adresse abfragen
        echo "Für lokale Benachrichtigungen: Gib deinen Benutzernamen ein (z.B. $(whoami))"
        echo "Für externe E-Mails: Gib deine vollständige E-Mail-Adresse ein"
        echo
        while true; do
            # Default: aktueller Username für lokale Mails
            local default_recipient="${email_recipient:-$(whoami)}"
            email_recipient=$(ask_input "E-Mail-Adresse oder Benutzername" "$default_recipient")
            if [ -n "$email_recipient" ]; then
                echo
                print_info "Benachrichtigungen gehen an: $email_recipient"
                break
            else
                echo
                print_error "Empfänger darf nicht leer sein"
            fi
        done

        # Mail-Programm prüfen (mail-Befehl wird für Tests benötigt)
        echo
        if ! command -v mail &> /dev/null; then
            echo
            print_warning "mail-Befehl nicht gefunden"
            echo
            echo "Für E-Mail-Tests und -Benachrichtigungen wird der 'mail'-Befehl benötigt."
            echo "Empfohlen: mailutils (liefert den mail-Befehl)"
            echo
            if command -v sendmail &> /dev/null; then
                echo "Hinweis: sendmail ist bereits installiert (z.B. durch DMA),"
                echo "aber mailutils wird trotzdem für den 'mail'-Befehl benötigt."
                echo
            fi

            # Distribution erkennen und Installation anbieten
            if [ -f /etc/os-release ]; then
                # shellcheck source=/dev/null
                . /etc/os-release
                case "$ID" in
                    debian|ubuntu|linuxmint|pop|mx|mxlinux)
                        echo "Installation für $PRETTY_NAME:"
                        echo "  sudo apt-get install mailutils"
                        echo
                        if ask_yes_no "Möchtest du mailutils jetzt installieren?" "y"; then
                            if sudo apt-get install -y mailutils 2>/dev/null; then
                                print_info "mailutils erfolgreich installiert"
                            else
                                print_error "Installation fehlgeschlagen"
                            fi
                        fi
                        ;;
                    fedora|rhel|centos|rocky|almalinux)
                        echo "Installation für $PRETTY_NAME:"
                        echo "  sudo dnf install mailx"
                        echo
                        if ask_yes_no "Möchtest du mailx jetzt installieren?" "y"; then
                            if sudo dnf install -y mailx 2>/dev/null; then
                                print_info "mailx erfolgreich installiert"
                            else
                                print_error "Installation fehlgeschlagen"
                            fi
                        fi
                        ;;
                    arch|manjaro|endeavouros|garuda|arcolinux)
                        echo "Installation für $PRETTY_NAME:"
                        echo "  sudo pacman -S mailutils"
                        echo
                        if ask_yes_no "Möchtest du mailutils jetzt installieren?" "y"; then
                            if sudo pacman -S --noconfirm mailutils 2>/dev/null; then
                                print_info "mailutils erfolgreich installiert"
                            else
                                print_error "Installation fehlgeschlagen"
                            fi
                        fi
                        ;;
                    opensuse*|sles)
                        echo "Installation für $PRETTY_NAME:"
                        echo "  sudo zypper install mailx"
                        echo
                        if ask_yes_no "Möchtest du mailx jetzt installieren?" "y"; then
                            if sudo zypper install -y mailx 2>/dev/null; then
                                print_info "mailx erfolgreich installiert"
                            else
                                print_error "Installation fehlgeschlagen"
                            fi
                        fi
                        ;;
                    solus)
                        echo "Installation für $PRETTY_NAME:"
                        echo "  sudo eopkg install mailutils"
                        echo
                        if ask_yes_no "Möchtest du mailutils jetzt installieren?" "y"; then
                            if sudo eopkg install -y mailutils 2>/dev/null; then
                                print_info "mailutils erfolgreich installiert"
                            else
                                print_error "Installation fehlgeschlagen"
                            fi
                        fi
                        ;;
                    void)
                        echo "Installation für $PRETTY_NAME:"
                        echo "  sudo xbps-install -S mailx"
                        echo
                        if ask_yes_no "Möchtest du mailx jetzt installieren?" "y"; then
                            if sudo xbps-install -y mailx 2>/dev/null; then
                                print_info "mailx erfolgreich installiert"
                            else
                                print_error "Installation fehlgeschlagen"
                            fi
                        fi
                        ;;
                    *)
                        echo "  Siehe Dokumentation deiner Distribution"
                        ;;
                esac
            fi

            echo
            print_warning "WICHTIG: Für den E-Mail-Versand wird zusätzlich ein MTA (Mail Transfer Agent) benötigt!"
            echo
            echo "Empfohlen: DMA (DragonFly Mail Agent)"
            echo "  - Keine Konfiguration erforderlich"
            echo "  - Kein laufender Dienst, kein offener Port"
            echo "  - Perfekt für lokale Mails (cron, Benachrichtigungen)"
            echo

            # DMA-Installation anbieten (nur Debian-basiert)
            if [ -f /etc/os-release ]; then
                # shellcheck source=/dev/null
                . /etc/os-release
                case "$ID" in
                    debian|ubuntu|linuxmint|pop|mx|mxlinux)
                        if ! command -v dma &> /dev/null; then
                            if ask_yes_no "Möchtest du DMA (empfohlen) jetzt installieren?" "y"; then
                                if sudo apt-get install -y dma 2>/dev/null; then
                                    print_info "DMA erfolgreich installiert - E-Mail-Versand ist bereit!"
                                else
                                    print_error "DMA-Installation fehlgeschlagen"
                                    echo
                                    echo "Alternative MTAs:"
                                    echo "  - ssmtp: sudo apt install ssmtp"
                                    echo "  - postfix: sudo apt install postfix"
                                fi
                            else
                                echo
                                echo "Alternative MTAs (manuelle Installation später möglich):"
                                echo "  - ssmtp: sudo apt install ssmtp (gut für Gmail/externe SMTP)"
                                echo "  - postfix: sudo apt install postfix (volle MTA-Funktionalität)"
                            fi
                        else
                            print_info "DMA bereits installiert!"
                        fi
                        ;;
                    *)
                        echo "DMA ist primär für Debian/Ubuntu verfügbar."
                        echo "Alternative MTAs für deine Distribution:"
                        echo "  - ssmtp (einfach)"
                        echo "  - postfix (komplex, volle Funktionalität)"
                        echo
                        echo "Siehe README.md für Details zur E-Mail-Konfiguration."
                        ;;
                esac
            fi
            echo

            if ask_yes_no "Mit E-Mail-Benachrichtigung fortfahren?" "y"; then
                print_info "E-Mail-Benachrichtigung aktiviert (MTA-Konfiguration noch erforderlich)"
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
    echo
    echo "ACHTUNG: Automatischer Neustart startet dein System ohne Rückfrage neu!"
    echo "Empfohlen: NEIN (du entscheidest selbst wann neu gestartet wird)"
    echo
    if ask_yes_no "Automatischen Neustart aktivieren?" "n"; then
        auto_reboot="true"
        print_warning "System wird automatisch neu gestartet, wenn Updates dies erfordern!"
    else
        auto_reboot="false"
    fi

    # Desktop-Benachrichtigungen
    echo
    echo "Desktop-Benachrichtigungen: Popup-Meldungen bei Updates, Fehlern und Upgrades."
    echo
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
                    debian|ubuntu|linuxmint|pop|mx|mxlinux)
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

    # System-Config-Verzeichnis erstellen (/etc/)
    if [ ! -d "$SYSTEM_CONFIG_DIR" ]; then
        echo
        print_info "Erstelle System-Konfigurationsverzeichnis: $SYSTEM_CONFIG_DIR"
        if ! sudo mkdir -p "$SYSTEM_CONFIG_DIR" 2>/dev/null; then
            print_error "Kann System-Config-Verzeichnis nicht erstellen: $SYSTEM_CONFIG_DIR"
            print_warning "Benötigt sudo-Rechte für /etc/"
            exit 1
        fi
    fi

    # Alte Config migrieren (falls vorhanden)
    if [ -f "$OLD_CONFIG_FILE" ] && [ ! -f "$SYSTEM_CONFIG_FILE" ]; then
        echo
        print_info "Alte Konfiguration gefunden: $OLD_CONFIG_FILE"
        if ask_yes_no "Soll die alte Konfiguration migriert werden?" "y"; then
            if sudo cp "$OLD_CONFIG_FILE" "$SYSTEM_CONFIG_FILE" 2>/dev/null; then
                print_info "Konfiguration erfolgreich migriert nach: $SYSTEM_CONFIG_FILE"
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

    # User-Config migrieren (falls vorhanden in ~/.config/)
    if [ -f "$USER_CONFIG_FILE" ] && [ ! -f "$SYSTEM_CONFIG_FILE" ]; then
        echo
        print_info "User-Konfiguration gefunden: $USER_CONFIG_FILE"
        if ask_yes_no "Soll die User-Konfiguration als System-Default kopiert werden?" "y"; then
            if sudo cp "$USER_CONFIG_FILE" "$SYSTEM_CONFIG_FILE" 2>/dev/null; then
                print_info "Konfiguration erfolgreich kopiert nach: $SYSTEM_CONFIG_FILE"
                print_info "User-Config bleibt erhalten für manuelle Override"
                echo
                print_info "Installation abgeschlossen - bestehende Konfiguration wurde übernommen"
                return 0
            else
                print_error "Fehler beim Kopieren der Konfiguration"
            fi
        fi
    fi

    # Konfigurationsdatei schreiben (nach /etc/)
    echo
    print_info "Erstelle System-Konfiguration: $SYSTEM_CONFIG_FILE"

    sudo tee "$SYSTEM_CONFIG_FILE" > /dev/null << EOF
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

    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        print_info "$INSTALL_CONFIG_SAVED: $SYSTEM_CONFIG_FILE"
        echo
        print_info "HINWEIS: System-Config in /etc/ funktioniert mit Cron-Jobs"
        print_info "Optional: User-Override in ~/.config/linux-update-script/config.conf möglich"
    else
        print_error "Fehler beim Erstellen der Konfigurationsdatei"
        exit 1
    fi
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

    echo "Cron-Jobs führen Updates automatisch zu festen Zeiten aus."
    echo "Du kannst täglich, wöchentlich oder monatlich wählen."
    echo
    if ! ask_yes_no "Möchtest du einen automatischen Cron-Job einrichten?" "y"; then
        print_info "Cron-Job-Einrichtung übersprungen"
        return
    fi

    # Log-Verzeichnis aus Config laden (System-Config hat Priorität)
    local log_dir="/var/log/system-updates"
    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$SYSTEM_CONFIG_FILE"
        log_dir="${LOG_DIR:-/var/log/system-updates}"
    elif [ -f "$USER_CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$USER_CONFIG_FILE"
        log_dir="${LOG_DIR:-/var/log/system-updates}"
    elif [ -f "$OLD_CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$OLD_CONFIG_FILE"
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

    echo "Zeigt deine aktuelle Konfiguration an."
    echo
    if ! ask_yes_no "Möchtest du einen Test-Durchlauf starten?" "y"; then
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
    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        echo "System-Config: $SYSTEM_CONFIG_FILE"
        cat "$SYSTEM_CONFIG_FILE"
    elif [ -f "$USER_CONFIG_FILE" ]; then
        echo "User-Config: $USER_CONFIG_FILE"
        cat "$USER_CONFIG_FILE"
    elif [ -f "$OLD_CONFIG_FILE" ]; then
        echo "Legacy-Config: $OLD_CONFIG_FILE"
        cat "$OLD_CONFIG_FILE"
    else
        echo "Keine Config-Datei gefunden!"
    fi
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

# Test-Benachrichtigungen
test_notifications() {
    print_header
    echo -e "${GREEN}Benachrichtigungs-Test${NC}\n"

    # Config laden (Hybrid-Ansatz)
    local config_loaded=false
    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$SYSTEM_CONFIG_FILE"
        config_loaded=true
        print_info "Lade System-Config: $SYSTEM_CONFIG_FILE"
    elif [ -f "$USER_CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$USER_CONFIG_FILE"
        config_loaded=true
        print_info "Lade User-Config: $USER_CONFIG_FILE"
    elif [ -f "$OLD_CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$OLD_CONFIG_FILE"
        config_loaded=true
        print_info "Lade Legacy-Config: $OLD_CONFIG_FILE"
    fi

    if [ "$config_loaded" = false ]; then
        print_error "Keine Config-Datei gefunden!"
        print_warning "Bitte führe zuerst die Konfiguration durch"
        return
    fi

    local test_sent=false

    # Desktop-Benachrichtigung testen
    if [ "$ENABLE_DESKTOP_NOTIFICATION" = "true" ]; then
        echo
        if ask_yes_no "Möchtest du eine Test-Desktop-Benachrichtigung senden?" "y"; then
            print_info "Sende Test-Desktop-Benachrichtigung..."

            if ! command -v notify-send &> /dev/null; then
                print_error "notify-send nicht installiert!"
                print_warning "Installiere: sudo apt install libnotify-bin"
            else
                # Desktop-Benachrichtigung senden
                if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
                    local user_id
                    user_id=$(id -u "$SUDO_USER")
                    sudo -u "$SUDO_USER" \
                        DISPLAY=:0 \
                        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${user_id}/bus" \
                        notify-send \
                            --urgency="normal" \
                            --icon="software-update-available" \
                            --expire-time="5000" \
                            "Linux Update-Script" \
                            "Test-Benachrichtigung - Installation erfolgreich!" 2>/dev/null && \
                        print_info "Desktop-Benachrichtigung gesendet! ✓" || \
                        print_error "Fehler beim Senden der Desktop-Benachrichtigung"
                else
                    notify-send \
                        --urgency="normal" \
                        --icon="software-update-available" \
                        --expire-time="5000" \
                        "Linux Update-Script" \
                        "Test-Benachrichtigung - Installation erfolgreich!" 2>/dev/null && \
                        print_info "Desktop-Benachrichtigung gesendet! ✓" || \
                        print_error "Fehler beim Senden der Desktop-Benachrichtigung"
                fi
                test_sent=true
            fi
        fi
    else
        print_info "Desktop-Benachrichtigungen sind deaktiviert"
    fi

    # E-Mail-Benachrichtigung testen
    if [ "$ENABLE_EMAIL" = "true" ]; then
        echo
        if ask_yes_no "Möchtest du eine Test-E-Mail senden?" "y"; then
            if [ -z "$EMAIL_RECIPIENT" ]; then
                print_error "EMAIL_RECIPIENT ist nicht konfiguriert!"
            elif ! command -v mail &> /dev/null && ! command -v sendmail &> /dev/null; then
                print_error "Kein Mail-Programm installiert (mail/sendmail)!"
                print_warning "Installiere: sudo apt install mailutils"
            else
                print_info "Sende Test-E-Mail an: $EMAIL_RECIPIENT"

                local test_body
                test_body="Dies ist eine Test-E-Mail vom Linux Update-Script.

Installation erfolgreich abgeschlossen!

Hostname: $(hostname)
Distribution: $([ -f /etc/os-release ] && . /etc/os-release && echo "$NAME $VERSION" || echo "Unbekannt")
Zeitstempel: $(date)
Config-Datei: $SYSTEM_CONFIG_FILE

Diese Benachrichtigung wurde automatisch generiert.
Bitte nicht antworten."

                if command -v mail &> /dev/null; then
                    if echo "$test_body" | mail -s "Linux Update-Script - Test-Benachrichtigung" "$EMAIL_RECIPIENT" 2>/dev/null; then
                        print_info "Test-E-Mail gesendet! ✓"
                        print_info "Prüfe dein E-Mail-Postfach: $EMAIL_RECIPIENT"
                        test_sent=true
                    else
                        print_error "Fehler beim Senden der E-Mail"
                        print_warning "Ist ein MTA (z.B. DMA, ssmtp, postfix) konfiguriert?"
                    fi
                elif command -v sendmail &> /dev/null; then
                    if echo "$test_body" | sendmail "$EMAIL_RECIPIENT" 2>/dev/null; then
                        print_info "Test-E-Mail gesendet! ✓"
                        print_info "Prüfe dein E-Mail-Postfach: $EMAIL_RECIPIENT"
                        test_sent=true
                    else
                        print_error "Fehler beim Senden der E-Mail"
                        print_warning "Ist ein MTA (z.B. DMA, ssmtp, postfix) konfiguriert?"
                    fi
                fi
            fi
        fi
    else
        print_info "E-Mail-Benachrichtigungen sind deaktiviert"
    fi

    if [ "$test_sent" = false ]; then
        echo
        print_info "Keine Test-Benachrichtigungen gesendet"
    fi

    echo
}

# Zusammenfassung anzeigen
show_summary() {
    print_header
    echo -e "${GREEN}Installation abgeschlossen!${NC}\n"

    # Zeige aktive Config-Datei
    local active_config=""
    if [ -f "$SYSTEM_CONFIG_FILE" ]; then
        active_config="$SYSTEM_CONFIG_FILE"
        echo "System-Konfiguration: $SYSTEM_CONFIG_FILE"
    elif [ -f "$USER_CONFIG_FILE" ]; then
        active_config="$USER_CONFIG_FILE"
        echo "User-Konfiguration: $USER_CONFIG_FILE"
    elif [ -f "$OLD_CONFIG_FILE" ]; then
        active_config="$OLD_CONFIG_FILE"
        echo "Legacy-Konfiguration: $OLD_CONFIG_FILE"
    else
        echo "FEHLER: Keine Konfigurationsdatei gefunden!"
    fi

    echo "Update-Script: $UPDATE_SCRIPT"
    echo
    echo "--- Konfiguration ---"
    if [ -n "$active_config" ] && [ -f "$active_config" ]; then
        cat "$active_config"
    else
        echo "Keine Konfiguration vorhanden!"
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

# Bestehende Konfiguration prüfen (Hybrid-Ansatz)
existing_config=""
config_type=""
if [ -f "$SYSTEM_CONFIG_FILE" ]; then
    existing_config="$SYSTEM_CONFIG_FILE"
    config_type="System-Config (/etc/)"
elif [ -f "$USER_CONFIG_FILE" ]; then
    existing_config="$USER_CONFIG_FILE"
    config_type="User-Config (~/.config/)"
elif [ -f "$OLD_CONFIG_FILE" ]; then
    existing_config="$OLD_CONFIG_FILE"
    config_type="Legacy-Config (Script-Dir)"
fi

if [ -n "$existing_config" ]; then
    print_header
    print_warning "Bestehende Konfiguration gefunden! ($config_type)"
    echo
    cat "$existing_config"
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

test_notifications
echo
read -r -p "Drücke Enter zum Fortfahren..."

show_summary
