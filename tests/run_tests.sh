#!/bin/bash
# tests/run_tests.sh - Führt alle bats-Tests aus

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_DIR="${SCRIPT_DIR}/tests"

echo "=== Linux Update-Script v2.0.0 Test-Suite ==="
echo ""

# Prüfe ob bats installiert ist
if ! command -v bats &>/dev/null; then
    echo "FEHLER: bats ist nicht installiert."
    echo "Installation:"
    echo "  Debian/Ubuntu: sudo apt install bats"
    echo "  Arch:          sudo pacman -S bash-automated-testing-system"
    echo "  Via Git:       git clone https://github.com/bats-core/bats-core.git"
    echo "                 sudo ./bats-core/install.sh /usr/local"
    exit 1
fi

# ShellCheck laufen lassen (falls vorhanden)
if command -v shellcheck &>/dev/null; then
    echo "--- ShellCheck ---"
    shellcheck_failed=false
    for f in "${SCRIPT_DIR}/update.sh" "${SCRIPT_DIR}/lib/"*.sh; do
        if ! shellcheck -x "$f" 2>&1; then
            shellcheck_failed=true
        fi
    done
    if [ "$shellcheck_failed" = false ]; then
        echo "ShellCheck: Alle Dateien OK"
    fi
    echo ""
fi

# bats-Tests ausführen
echo "--- bats Tests ---"
bats "${TESTS_DIR}"/*.bats
