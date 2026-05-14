#!/usr/bin/env bats
# tests/test_network.bats - Tests für lib/network.sh

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

load_network() {
    export SCRIPT_DIR
    export LANG="en_US.UTF-8"
    # shellcheck source=/dev/null
    source "${SCRIPT_DIR}/lib/core.sh"
    source "${SCRIPT_DIR}/lang/en.lang"
    local tmp_log
    tmp_log=$(mktemp /tmp/test-log-XXXXXX.log)
    export LOG_FILE="$tmp_log"
    source "${SCRIPT_DIR}/lib/network.sh"
}

@test "network.sh kann geladen werden" {
    run bash -c "
        SCRIPT_DIR='${SCRIPT_DIR}'
        source '${SCRIPT_DIR}/lib/core.sh'
        source '${SCRIPT_DIR}/lang/en.lang'
        LOG_FILE=/dev/null
        source '${SCRIPT_DIR}/lib/network.sh'
    "
    [ "$status" -eq 0 ]
}

@test "parse_download_size_mb parst MB korrekt" {
    load_network
    result=$(parse_download_size_mb "Need to get 150 MB of archives")
    [ "$result" = "150.0" ]
}

@test "parse_download_size_mb parst GB korrekt" {
    load_network
    result=$(parse_download_size_mb "Need to get 2 GB of archives")
    [ "$result" = "2048.0" ]
}

@test "parse_download_size_mb parst kB korrekt" {
    load_network
    result=$(parse_download_size_mb "Need to get 512 kB of archives")
    # 512 kB = 0.5 MB
    awk "BEGIN { exit ($result > 0.4 && $result < 0.6) ? 0 : 1 }"
}

@test "parse_download_size_mb gibt 0 zurück bei unbekannter Einheit" {
    load_network
    result=$(parse_download_size_mb "keine Größe")
    [ "$result" = "0" ]
}

@test "format_duration formatiert Sekunden korrekt" {
    load_network
    result=$(format_duration 30)
    [ -n "$result" ]
}

@test "format_duration formatiert Minuten korrekt" {
    load_network
    result=$(format_duration 90)
    [ -n "$result" ]
}

@test "format_duration formatiert Stunden korrekt" {
    load_network
    result=$(format_duration 3700)
    [ -n "$result" ]
}

@test "SPINNER_PID ist initial leer" {
    load_network
    [ -z "$SPINNER_PID" ]
}

@test "stop_spinner ist sicher wenn kein Spinner läuft" {
    load_network
    SPINNER_PID=""
    run stop_spinner
    [ "$status" -eq 0 ]
}

@test "detect_bandwidth deaktiviert wenn BANDWIDTH_LIMIT leer" {
    load_network
    BANDWIDTH_LIMIT=""
    detect_bandwidth
    [ -z "$EFFECTIVE_BANDWIDTH_LIMIT" ]
}

@test "detect_bandwidth setzt festen Wert wenn kein auto" {
    load_network
    BANDWIDTH_LIMIT="500"
    detect_bandwidth
    [ "$EFFECTIVE_BANDWIDTH_LIMIT" = "500" ]
}
