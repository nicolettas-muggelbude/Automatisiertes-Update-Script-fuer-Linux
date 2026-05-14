#!/usr/bin/env bats
# tests/test_upgrades.bats - Tests für lib/upgrades.sh

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

load_upgrades() {
    export SCRIPT_DIR
    export LANG="en_US.UTF-8"
    # shellcheck source=/dev/null
    source "${SCRIPT_DIR}/lib/core.sh"
    source "${SCRIPT_DIR}/lang/en.lang"
    local tmp_log
    tmp_log=$(mktemp /tmp/test-log-XXXXXX.log)
    export LOG_FILE="$tmp_log"
    source "${SCRIPT_DIR}/lib/notifications.sh"
    source "${SCRIPT_DIR}/lib/kernel.sh"
    source "${SCRIPT_DIR}/lib/upgrades.sh"
}

@test "upgrades.sh kann geladen werden" {
    run bash -c "
        SCRIPT_DIR='${SCRIPT_DIR}'
        source '${SCRIPT_DIR}/lib/core.sh'
        source '${SCRIPT_DIR}/lang/en.lang'
        LOG_FILE=/dev/null
        source '${SCRIPT_DIR}/lib/notifications.sh'
        source '${SCRIPT_DIR}/lib/kernel.sh'
        source '${SCRIPT_DIR}/lib/upgrades.sh'
    "
    [ "$status" -eq 0 ]
}

@test "DEBIAN_CODENAMES_ORDERED ist gesetzt" {
    load_upgrades
    [ -n "$DEBIAN_CODENAMES_ORDERED" ]
}

@test "get_next_debian_codename gibt bookworm nach bullseye zurück" {
    load_upgrades
    result=$(get_next_debian_codename "bullseye")
    [ "$result" = "bookworm" ]
}

@test "get_next_debian_codename gibt trixie nach bookworm zurück" {
    load_upgrades
    result=$(get_next_debian_codename "bookworm")
    [ "$result" = "trixie" ]
}

@test "get_next_debian_codename gibt leer zurück für neuesten Codename" {
    load_upgrades
    result=$(get_next_debian_codename "trixie")
    [ -z "$result" ]
}

@test "get_next_debian_codename gibt leer zurück für unbekannten Codename" {
    load_upgrades
    result=$(get_next_debian_codename "unknown_codename")
    [ -z "$result" ]
}

@test "check_upgrade_available gibt 0 zurück wenn ENABLE_UPGRADE_CHECK=false" {
    load_upgrades
    ENABLE_UPGRADE_CHECK=false
    run check_upgrade_available
    [ "$status" -eq 0 ]
}

@test "check_upgrade_available gibt 1 zurück für unbekannte Distribution" {
    load_upgrades
    ENABLE_UPGRADE_CHECK=true
    DISTRO="unknown_distro_xyz"
    run check_upgrade_available
    [ "$status" -eq 1 ]
}
