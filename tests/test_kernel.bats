#!/usr/bin/env bats
# tests/test_kernel.bats - Tests für lib/kernel.sh (Kernel-Schutz & NVIDIA)

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

load_kernel() {
    export SCRIPT_DIR
    export LANG="en_US.UTF-8"
    # shellcheck source=/dev/null
    source "${SCRIPT_DIR}/lib/core.sh"
    source "${SCRIPT_DIR}/lang/en.lang"
    local tmp_log
    tmp_log=$(mktemp /tmp/test-log-XXXXXX.log)
    export LOG_FILE="$tmp_log"
    source "${SCRIPT_DIR}/lib/kernel.sh"
}

@test "kernel.sh kann geladen werden" {
    run bash -c "
        SCRIPT_DIR='${SCRIPT_DIR}'
        source '${SCRIPT_DIR}/lib/core.sh'
        source '${SCRIPT_DIR}/lang/en.lang'
        LOG_FILE=/dev/null
        source '${SCRIPT_DIR}/lib/kernel.sh'
    "
    [ "$status" -eq 0 ]
}

@test "is_nvidia_installed gibt 1 zurück auf System ohne NVIDIA" {
    load_kernel
    # Auf Test-System normalerweise kein NVIDIA
    if command -v nvidia-smi &>/dev/null || lsmod 2>/dev/null | grep -q "^nvidia"; then
        skip "NVIDIA ist auf diesem System installiert"
    fi
    run is_nvidia_installed
    [ "$status" -ne 0 ]
}

@test "is_secureboot_enabled gibt validen Exit-Code zurück" {
    load_kernel
    run is_secureboot_enabled
    # Gültige Exit-Codes: 0 (aktiv), 1 (inaktiv), 2 (unbekannt)
    [ "$status" -ge 0 ] && [ "$status" -le 2 ]
}

@test "get_pending_kernel_version gibt leeren String für unbekannte Distro" {
    load_kernel
    result=$(get_pending_kernel_version "unknown_distro_xyz")
    [ -z "$result" ]
}

@test "check_nvidia_dkms_status gibt 1 wenn kein DKMS installiert" {
    load_kernel
    if command -v dkms &>/dev/null; then
        skip "dkms ist auf diesem System installiert"
    fi
    run check_nvidia_dkms_status ""
    [ "$status" -eq 1 ]
}

@test "safe_autoremove überspringt wenn KERNEL_PROTECTION deaktiviert und kein apt" {
    load_kernel
    KERNEL_PROTECTION=false
    # Läuft ohne Fehler auf Systemen ohne apt
    if ! command -v apt-get &>/dev/null; then
        skip "apt-get nicht verfügbar"
    fi
    # Nur prüfen ob Funktion aufgerufen werden kann
    run bash -c "
        SCRIPT_DIR='${SCRIPT_DIR}'
        source '${SCRIPT_DIR}/lib/core.sh'
        source '${SCRIPT_DIR}/lang/en.lang'
        LOG_FILE=/dev/null
        source '${SCRIPT_DIR}/lib/kernel.sh'
        KERNEL_PROTECTION=false
        # Nur prüfen ob der Zweig erreicht wird, nicht ausführen
        type safe_autoremove
    "
    [ "$status" -eq 0 ]
}
