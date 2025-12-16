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
LANGUAGE=auto

# Konfiguration laden, falls vorhanden
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    LOG_DIR="${LOG_DIR:-/var/log/system-updates}"
    LANGUAGE="${LANGUAGE:-auto}"
fi

# Sprache laden
load_language() {
    local lang="${LANGUAGE:-auto}"

    # Automatische Sprach-Erkennung
    if [ "$lang" = "auto" ]; then
        lang="${LANG%%.*}"
        lang="${lang%%_*}"
        lang="${lang:-en}"
    fi

    # Sprachdatei für Log-Viewer laden
    local viewer_lang_file="${SCRIPT_DIR}/lang/viewer-${lang}.lang"
    if [ -f "$viewer_lang_file" ]; then
        # shellcheck source=/dev/null
        source "$viewer_lang_file"
    else
        # Fallback zu Englisch
        if [ -f "${SCRIPT_DIR}/lang/viewer-en.lang" ]; then
            # shellcheck source=/dev/null
            source "${SCRIPT_DIR}/lang/viewer-en.lang"
        else
            echo "ERROR: No language files found!"
            exit 1
        fi
    fi
}

# Sprache initialisieren
load_language

#############################################################
# Funktionen
#############################################################

print_header() {
    clear
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}        ${VIEWER_HEADER}${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo
}

print_info() {
    echo -e "${GREEN}[${VIEWER_LABEL_INFO}]${NC} $1"
}

print_error() {
    echo -e "${RED}[${VIEWER_LABEL_ERROR}]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[${VIEWER_LABEL_WARNING}]${NC} $1"
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
    echo -e "${GREEN}${VIEWER_NEWEST_LOG}${NC}\n"

    local logfile
    logfile=$(get_latest_log)

    if [ $? -ne 0 ] || [ -z "$logfile" ]; then
        print_error "$VIEWER_NO_LOGS: $LOG_DIR"
        echo
        echo "$VIEWER_CAUSES"
        echo "  - $VIEWER_CAUSE_NO_UPDATES"
        echo "  - $VIEWER_CAUSE_WRONG_DIR"
        echo "  - $VIEWER_CAUSE_NO_ACCESS"
        return 1
    fi

    print_info "$VIEWER_LOGFILE: $logfile"
    print_info "$VIEWER_SIZE: $(du -h "$logfile" | cut -f1)"
    print_info "$VIEWER_CREATED: $(stat -c %y "$logfile" | cut -d'.' -f1)"
    echo
    echo -e "${CYAN}${VIEWER_LOG_CONTENT}${NC}"
    echo

    if [ -r "$logfile" ]; then
        cat "$logfile"
    else
        print_error "$VIEWER_NO_PERMISSION: $logfile"
        echo "$VIEWER_TRY_SUDO $0"
        return 1
    fi
}

# Letzte 50 Zeilen anzeigen
show_tail_log() {
    print_header
    echo -e "${GREEN}${VIEWER_LAST_50}${NC}\n"

    local logfile
    logfile=$(get_latest_log)

    if [ $? -ne 0 ] || [ -z "$logfile" ]; then
        print_error "$VIEWER_NO_LOGS: $LOG_DIR"
        echo
        echo "$VIEWER_CAUSES"
        echo "  - $VIEWER_CAUSE_NO_UPDATES"
        echo "  - $VIEWER_CAUSE_WRONG_DIR"
        echo "  - $VIEWER_CAUSE_NO_ACCESS"
        return 1
    fi

    print_info "$VIEWER_LOGFILE: $logfile"
    print_info "$VIEWER_SIZE: $(du -h "$logfile" | cut -f1)"
    print_info "$VIEWER_CREATED: $(stat -c %y "$logfile" | cut -d'.' -f1)"
    echo
    echo -e "${CYAN}${VIEWER_LAST_LINES}${NC}"
    echo

    if [ -r "$logfile" ]; then
        tail -n 50 "$logfile"
    else
        print_error "$VIEWER_NO_PERMISSION: $logfile"
        echo "$VIEWER_TRY_SUDO $0"
        return 1
    fi
}

# Alle Logdateien auflisten
list_all_logs() {
    print_header
    echo -e "${GREEN}${VIEWER_ALL_LOGS}${NC}\n"

    if [ ! -d "$LOG_DIR" ]; then
        print_error "$VIEWER_NO_DIR: $LOG_DIR"
        return 1
    fi

    local logs
    # Use array to avoid SC2045
    logs=("$LOG_DIR"/update_*.log)

    if [ ! -e "${logs[0]}" ]; then
        print_warning "$VIEWER_NO_LOGS: $LOG_DIR"
        return 1
    fi

    print_info "$VIEWER_LOG_DIR: $LOG_DIR"
    echo
    echo -e "${CYAN}${VIEWER_TABLE_DATETIME}${NC}           ${CYAN}${VIEWER_TABLE_SIZE}${NC}    ${CYAN}${VIEWER_TABLE_FILENAME}${NC}"
    echo "-----------------------------------------------------------"

    ls -lth "${logs[@]}" 2>/dev/null | awk '{
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
    local count
    count=$(find "$LOG_DIR" -name "update_*.log" -type f 2>/dev/null | wc -l)
    print_info "$VIEWER_TOTAL: $count $VIEWER_LOGFILES"
}

# Logs nach Fehler durchsuchen
search_errors() {
    print_header
    echo -e "${GREEN}${VIEWER_SEARCH_ERRORS}${NC}\n"

    if [ ! -d "$LOG_DIR" ]; then
        print_error "$VIEWER_NO_DIR: $LOG_DIR"
        return 1
    fi

    print_info "$VIEWER_SEARCHING"
    echo

    local found=0
    local logfile
    # Use glob instead of ls output
    for logfile in "$LOG_DIR"/update_*.log; do
        [ -e "$logfile" ] || continue
        if grep -i "fehler\|error\|failed\|fehlgeschlagen" "$logfile" > /dev/null 2>&1; then
            echo -e "${YELLOW}=== $(basename "$logfile") ===${NC}"
            grep -i --color=always "fehler\|error\|failed\|fehlgeschlagen" "$logfile"
            echo
            found=1
        fi
    done

    if [ $found -eq 0 ]; then
        print_info "$VIEWER_NO_ERRORS"
    fi
}

# Hauptmenü
show_menu() {
    print_header

    echo -e "${CYAN}${VIEWER_MENU_PROMPT}${NC}\n"
    echo "  1) $VIEWER_MENU_1"
    echo "  2) $VIEWER_MENU_2"
    echo "  3) $VIEWER_MENU_3"
    echo "  4) $VIEWER_MENU_4"
    echo "  5) $VIEWER_MENU_5"
    echo
    echo -ne "${YELLOW}${VIEWER_MENU_CHOICE} [1-5]:${NC} "
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
            print_info "$VIEWER_GOODBYE"
            echo
            exit 0
            ;;
        *)
            print_header
            print_error "$VIEWER_INVALID_CHOICE: $choice"
            echo
            ;;
    esac

    echo
    echo -e "${CYAN}---------------------------------------------------${NC}"
    read -r -p "$VIEWER_CONTINUE"
done
