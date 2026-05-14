#!/bin/bash
# lib/notifications.sh - E-Mail- und Desktop-Benachrichtigungen

# E-Mail senden
send_email() {
    local subject="$1"
    local body="$2"

    if [ "$ENABLE_EMAIL" != "true" ]; then
        return 0
    fi

    if [ -z "$EMAIL_RECIPIENT" ]; then
        log_warning "E-Mail-Benachrichtigung fehlgeschlagen: EMAIL_RECIPIENT nicht konfiguriert"
        return 0
    fi

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
}

# Desktop-Benachrichtigung senden
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    local icon="${4:-dialog-information}"

    if [ "$ENABLE_DESKTOP_NOTIFICATION" != "true" ]; then
        return 0
    fi

    if ! command -v notify-send &> /dev/null; then
        log_warning "Desktop-Benachrichtigung fehlgeschlagen: notify-send nicht installiert"
        log_warning "Installiere libnotify: sudo apt install libnotify-bin (Debian/Ubuntu)"
        return 0
    fi

    local timeout="${NOTIFICATION_TIMEOUT:-5000}"

    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        local user_id
        user_id=$(id -u "$SUDO_USER")
        sudo -u "$SUDO_USER" \
            DISPLAY=:0 \
            DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${user_id}/bus" \
            notify-send \
                --urgency="$urgency" \
                --icon="$icon" \
                --expire-time="$timeout" \
                "$title" "$message" 2>/dev/null || true
    else
        notify-send \
            --urgency="$urgency" \
            --icon="$icon" \
            --expire-time="$timeout" \
            "$title" "$message" 2>/dev/null || true
    fi
}
