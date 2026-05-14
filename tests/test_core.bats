#!/usr/bin/env bats
# tests/test_core.bats - Tests für lib/core.sh

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# Hilfsfunktion: Lädt core.sh mit minimaler Umgebung
load_core() {
    export SCRIPT_DIR
    export LANG="en_US.UTF-8"
    # shellcheck source=/dev/null
    source "${SCRIPT_DIR}/lib/core.sh"
    # Lade Englisch als Sprache für Tests
    source "${SCRIPT_DIR}/lang/en.lang"
}

@test "core.sh kann geladen werden" {
    run bash -c "source '${SCRIPT_DIR}/lib/core.sh'"
    [ "$status" -eq 0 ]
}

@test "Standard-Konfigurationswerte sind gesetzt" {
    load_core
    [ "$ENABLE_EMAIL" = "false" ]
    [ "$AUTO_REBOOT" = "false" ]
    [ "$KERNEL_PROTECTION" = "true" ]
    [ "$MIN_KERNELS" -eq 3 ]
    [ "$ENABLE_UPGRADE_CHECK" = "true" ]
    [ "$ENABLE_BACKUP" = "false" ]
    [ "$ENABLE_FWUPD" = "false" ]
}

@test "SYSTEM_CONFIG_FILE Pfad ist korrekt" {
    load_core
    [ "$SYSTEM_CONFIG_FILE" = "/etc/linux-update-script/config.conf" ]
}

@test "load_language lädt en.lang korrekt" {
    load_core
    load_language
    [ -n "$LABEL_INFO" ]
    [ -n "$LABEL_ERROR" ]
    [ -n "$LABEL_WARNING" ]
    [ -n "$MSG_ROOT_REQUIRED" ]
}

@test "load_language fällt auf Englisch zurück bei unbekannter Sprache" {
    load_core
    LANGUAGE="xx_UNKNOWN"
    load_language
    [ -n "$LABEL_INFO" ]
}

@test "load_config setzt CONFIG_SOURCE bei fehlender Config auf Defaults" {
    load_core
    SYSTEM_CONFIG_FILE="/tmp/nonexistent-config-$RANDOM.conf"
    USER_CONFIG_FILE=""
    load_config
    [ "$CONFIG_SOURCE" = "Defaults (keine Config)" ]
}

@test "load_config lädt System-Config korrekt" {
    load_core
    local tmp_config
    tmp_config=$(mktemp /tmp/test-config-XXXXXX.conf)
    echo 'ENABLE_EMAIL=true' > "$tmp_config"
    echo 'EMAIL_RECIPIENT=test@example.com' >> "$tmp_config"
    SYSTEM_CONFIG_FILE="$tmp_config"
    USER_CONFIG_FILE=""
    load_config
    [ "$ENABLE_EMAIL" = "true" ]
    [ "$EMAIL_RECIPIENT" = "test@example.com" ]
    [ "$CONFIG_SOURCE" = "System (/etc/)" ]
    rm -f "$tmp_config"
}

@test "load_config wendet User-Override an" {
    load_core
    local tmp_system tmp_user
    tmp_system=$(mktemp /tmp/test-system-XXXXXX.conf)
    tmp_user=$(mktemp /tmp/test-user-XXXXXX.conf)
    echo 'ENABLE_EMAIL=false' > "$tmp_system"
    echo 'ENABLE_EMAIL=true' > "$tmp_user"
    SYSTEM_CONFIG_FILE="$tmp_system"
    USER_CONFIG_FILE="$tmp_user"
    export SUDO_USER="testuser"
    load_config
    [ "$ENABLE_EMAIL" = "true" ]
    [ "$CONFIG_SOURCE" = "Hybrid (System + User Override)" ]
    rm -f "$tmp_system" "$tmp_user"
    unset SUDO_USER
}

@test "log_info schreibt in LOG_FILE" {
    load_core
    load_language
    local tmp_log
    tmp_log=$(mktemp /tmp/test-log-XXXXXX.log)
    LOG_FILE="$tmp_log"
    log_info "Test-Nachricht"
    grep -q "Test-Nachricht" "$tmp_log"
    rm -f "$tmp_log"
}

@test "log_error schreibt in LOG_FILE" {
    load_core
    load_language
    local tmp_log
    tmp_log=$(mktemp /tmp/test-log-XXXXXX.log)
    LOG_FILE="$tmp_log"
    log_error "Fehler-Nachricht"
    grep -q "Fehler-Nachricht" "$tmp_log"
    rm -f "$tmp_log"
}

@test "init_logging erstellt LOG_DIR" {
    load_core
    load_language
    local tmp_dir
    tmp_dir=$(mktemp -d /tmp/test-logdir-XXXXXX)
    LOG_DIR="${tmp_dir}/subdir"
    init_logging
    [ -d "$LOG_DIR" ]
    rm -rf "$tmp_dir"
}

@test "check_root schlägt fehl wenn nicht root" {
    run bash -c "
        source '${SCRIPT_DIR}/lib/core.sh'
        source '${SCRIPT_DIR}/lang/en.lang'
        LOG_FILE=/dev/null
        check_root
    "
    # Schlägt fehl wenn nicht root (EUID != 0)
    if [ "$EUID" -ne 0 ]; then
        [ "$status" -ne 0 ]
    else
        skip "Test läuft als root"
    fi
}
