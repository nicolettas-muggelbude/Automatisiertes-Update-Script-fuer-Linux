#!/bin/bash

#############################################################
# Linux System Update Script - Log Viewer
# Zeigt Update-Logs in verschiedenen Formaten an
# MIT License
#############################################################

# Farbcodes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script-Verzeichnis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.conf"

# Standard-Log-Verzeichnis
LOG_DIR="/var/log/system-updates"

# Konfiguration laden, falls vorhanden
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    LOG_DIR="${LOG_DIR:-/var/log/system-updates}"
fi

#############################################################
# Funktionen
#############################################################

print_header() {
    clear
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}        Update-Script Log Viewer${NC}"
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

# Neueste Logdatei finden
get_latest_log() {
    if [ ! -d "$LOG_DIR" ]; then
        return 1
    fi

    local latest=$(ls -t "$LOG_DIR"/update_*.log 2>/dev/null | head -n 1)
    if [ -z "$latest" ]; then
        return 1
    fi

    echo "$latest"
    return 0
}

# Neueste Logdatei komplett anzeigen
show_full_log() {
    print_header
    echo -e "${GREEN}Neueste Logdatei${NC}\n"

    local logfile=$(get_latest_log)

    if [ $? -ne 0 ] || [ -z "$logfile" ]; then
        print_error "Keine Logdateien gefunden in: $LOG_DIR"
        echo
        echo "Mögliche Ursachen:"
        echo "  - Noch keine Updates durchgeführt"
        echo "  - Falsches Log-Verzeichnis konfiguriert"
        echo "  - Keine Leseberechtigung"
        return 1
    fi

    print_info "Logdatei: $logfile"
    print_info "Größe: $(du -h "$logfile" | cut -f1)"
    print_info "Erstellt: $(stat -c %y "$logfile" | cut -d'.' -f1)"
    echo
    echo -e "${CYAN}--- Loginhalt ---${NC}"
    echo

    if [ -r "$logfile" ]; then
        cat "$logfile"
    else
        print_error "Keine Leseberechtigung für: $logfile"
        echo "Versuche: sudo $0"
        return 1
    fi
}

# Letzte 50 Zeilen anzeigen
show_tail_log() {
    print_header
    echo -e "${GREEN}Letzte 50 Zeilen des neuesten Logs${NC}\n"

    local logfile=$(get_latest_log)

    if [ $? -ne 0 ] || [ -z "$logfile" ]; then
        print_error "Keine Logdateien gefunden in: $LOG_DIR"
        echo
        echo "Mögliche Ursachen:"
        echo "  - Noch keine Updates durchgeführt"
        echo "  - Falsches Log-Verzeichnis konfiguriert"
        echo "  - Keine Leseberechtigung"
        return 1
    fi

    print_info "Logdatei: $logfile"
    print_info "Größe: $(du -h "$logfile" | cut -f1)"
    print_info "Erstellt: $(stat -c %y "$logfile" | cut -d'.' -f1)"
    echo
    echo -e "${CYAN}--- Letzte 50 Zeilen ---${NC}"
    echo

    if [ -r "$logfile" ]; then
        tail -n 50 "$logfile"
    else
        print_error "Keine Leseberechtigung für: $logfile"
        echo "Versuche: sudo $0"
        return 1
    fi
}

# Alle Logdateien auflisten
list_all_logs() {
    print_header
    echo -e "${GREEN}Alle verfügbaren Logdateien${NC}\n"

    if [ ! -d "$LOG_DIR" ]; then
        print_error "Log-Verzeichnis nicht gefunden: $LOG_DIR"
        return 1
    fi

    local logs=$(ls -t "$LOG_DIR"/update_*.log 2>/dev/null)

    if [ -z "$logs" ]; then
        print_warning "Keine Logdateien gefunden in: $LOG_DIR"
        return 1
    fi

    print_info "Log-Verzeichnis: $LOG_DIR"
    echo
    echo -e "${CYAN}Datum/Zeit${NC}           ${CYAN}Größe${NC}    ${CYAN}Dateiname${NC}"
    echo "-----------------------------------------------------------"

    ls -lth "$LOG_DIR"/update_*.log 2>/dev/null | awk '{
        # Datum und Zeit
        datetime = $6 " " $7 " " $8
        # Größe
        size = $5
        # Dateiname (nur Basename)
        split($9, arr, "/")
        filename = arr[length(arr)]

        printf "%-20s %-8s %s\n", datetime, size, filename
    }'

    echo
    local count=$(ls "$LOG_DIR"/update_*.log 2>/dev/null | wc -l)
    print_info "Gesamt: $count Logdatei(en)"
}

# Logs nach Fehler durchsuchen
search_errors() {
    print_header
    echo -e "${GREEN}Fehler in Logdateien suchen${NC}\n"

    if [ ! -d "$LOG_DIR" ]; then
        print_error "Log-Verzeichnis nicht gefunden: $LOG_DIR"
        return 1
    fi

    print_info "Durchsuche alle Logs nach Fehlern..."
    echo

    local found=0
    for logfile in $(ls -t "$LOG_DIR"/update_*.log 2>/dev/null); do
        if grep -i "fehler\|error\|failed\|fehlgeschlagen" "$logfile" > /dev/null 2>&1; then
            echo -e "${YELLOW}=== $(basename "$logfile") ===${NC}"
            grep -i --color=always "fehler\|error\|failed\|fehlgeschlagen" "$logfile"
            echo
            found=1
        fi
    done

    if [ $found -eq 0 ]; then
        print_info "Keine Fehler in den Logdateien gefunden"
    fi
}

# Hauptmenü
show_menu() {
    print_header

    echo -e "${CYAN}Wähle eine Option:${NC}\n"
    echo "  1) Neueste Logdatei komplett anzeigen"
    echo "  2) Letzte 50 Zeilen des neuesten Logs"
    echo "  3) Alle Logdateien auflisten"
    echo "  4) Nach Fehlern in Logs suchen"
    echo "  5) Beenden"
    echo
    echo -ne "${YELLOW}Auswahl [1-5]:${NC} "
}

#############################################################
# Hauptprogramm
#############################################################

# Endlosschleife für Menü
while true; do
    show_menu
    read -r choice

    case "$choice" in
        1)
            show_full_log
            ;;
        2)
            show_tail_log
            ;;
        3)
            list_all_logs
            ;;
        4)
            search_errors
            ;;
        5|q|Q)
            print_header
            print_info "Tschüß!"
            echo
            exit 0
            ;;
        *)
            print_header
            print_error "Ungültige Auswahl: $choice"
            echo
            ;;
    esac

    echo
    echo -e "${CYAN}---------------------------------------------------${NC}"
    read -r -p "Drücke Enter um fortzufahren..."
done
