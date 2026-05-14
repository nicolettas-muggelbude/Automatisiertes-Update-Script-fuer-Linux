#!/bin/bash
# lib/network.sh - Bandbreitenmessung, Fortschritt, Snap & fwupd (v1.9.0+)

SPINNER_PID=""

start_spinner() {
    local message="$1"
    if [ "${ENABLE_PROGRESS:-true}" != "true" ] || [ ! -t 2 ]; then
        return 0
    fi
    (
        local i=0
        local chars='-\|/'
        while true; do
            printf "\r%s %s " "$message" "${chars:$i:1}" >&2
            i=$(( (i + 1) % 4 ))
            sleep 0.15
        done
    ) &
    SPINNER_PID=$!
}

stop_spinner() {
    if [ -n "${SPINNER_PID:-}" ]; then
        kill "$SPINNER_PID" 2>/dev/null
        wait "$SPINNER_PID" 2>/dev/null
        printf "\r\033[K" >&2
        SPINNER_PID=""
    fi
}

get_bandwidth_test_url() {
    if [ -n "${BANDWIDTH_TEST_URL:-}" ]; then
        echo "$BANDWIDTH_TEST_URL"
        return
    fi

    case "$DISTRO" in
        debian|ubuntu|linuxmint|mint|mx)
            echo "http://deb.debian.org/debian/ls-lR.gz"
            ;;
        rhel|centos|fedora|rocky|almalinux)
            local fedora_ver
            fedora_ver=$(rpm -E %fedora 2>/dev/null | grep -E '^[0-9]+$' || echo "41")
            echo "https://dl.fedoraproject.org/pub/fedora/linux/releases/${fedora_ver}/Everything/x86_64/os/repodata/repomd.xml"
            ;;
        opensuse*|sles|suse)
            echo "https://download.opensuse.org/distribution/openSUSE-stable/repo/oss/repodata/repomd.xml"
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            echo "https://geo.mirror.pkgbuild.com/core/os/x86_64/core.db"
            ;;
        void)
            echo "https://repo-default.voidlinux.org/current/x86_64-repodata"
            ;;
        solus)
            echo "https://mirrors.rit.edu/solus/packages/shannon/eopkg-index.xml.xz"
            ;;
        *)
            echo "http://deb.debian.org/debian/ls-lR.gz"
            ;;
    esac
}

install_curl() {
    case "$DISTRO" in
        debian|ubuntu|linuxmint|mint|mx)
            DEBIAN_FRONTEND=noninteractive apt-get install -y curl 2>/dev/null ;;
        rhel|centos|fedora|rocky|almalinux)
            if command -v dnf &>/dev/null; then
                dnf install -y curl 2>/dev/null
            else
                yum install -y curl 2>/dev/null
            fi ;;
        opensuse*|sles|suse)
            zypper install -y curl 2>/dev/null ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            pacman -S --noconfirm curl 2>/dev/null ;;
        void)
            xbps-install -y curl 2>/dev/null ;;
        solus)
            eopkg install curl 2>/dev/null ;;
        *)
            return 1 ;;
    esac
}

measure_speed_wget() {
    local test_url="$1"
    local start size elapsed
    start=$(date +%s)
    size=$(timeout 5 wget -q -O - "$test_url" 2>/dev/null | wc -c)
    elapsed=$(( $(date +%s) - start ))
    [ "$elapsed" -lt 1 ] && elapsed=1
    echo "$(( size / elapsed ))"
}

detect_bandwidth() {
    EFFECTIVE_BANDWIDTH_LIMIT=""

    if [ -z "${BANDWIDTH_LIMIT:-}" ]; then
        log_info "$MSG_BANDWIDTH_DISABLED"
        return 0
    fi

    if [ "${BANDWIDTH_LIMIT}" != "auto" ]; then
        EFFECTIVE_BANDWIDTH_LIMIT="$BANDWIDTH_LIMIT"
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_BANDWIDTH_MANUAL" "$EFFECTIVE_BANDWIDTH_LIMIT")"
        return 0
    fi

    local test_url
    test_url=$(get_bandwidth_test_url)

    local use_wget=false

    if command -v curl &>/dev/null; then
        :
    elif command -v wget &>/dev/null; then
        log_info "$MSG_BANDWIDTH_USING_WGET"
        use_wget=true
    else
        log_info "$MSG_BANDWIDTH_INSTALLING_CURL"
        if install_curl && command -v curl &>/dev/null; then
            log_info "$MSG_BANDWIDTH_CURL_INSTALLED"
        else
            log_warning "$MSG_BANDWIDTH_NO_TOOL"
            return 0
        fi
    fi

    start_spinner "$MSG_BANDWIDTH_MEASURING"

    local speed_bytes
    if [ "$use_wget" = true ]; then
        speed_bytes=$(measure_speed_wget "$test_url")
    else
        speed_bytes=$(curl -s -w "%{speed_download}" -o /dev/null --max-time 5 "$test_url" 2>/dev/null)
    fi

    stop_spinner

    if [ -z "$speed_bytes" ] || awk "BEGIN { exit ($speed_bytes > 0) ? 0 : 1 }" 2>/dev/null && [ "$(awk "BEGIN { printf \"%d\", $speed_bytes }" 2>/dev/null)" -le 0 ] 2>/dev/null; then
        log_warning "$MSG_BANDWIDTH_MEASURE_FAILED"
        return 0
    fi

    local percent="${BANDWIDTH_LIMIT_PERCENT:-80}"
    local speed_kbs
    speed_kbs=$(awk "BEGIN { printf \"%d\", $speed_bytes / 1024 }")
    local limit_kbs
    limit_kbs=$(awk "BEGIN { printf \"%d\", ($speed_bytes / 1024) * ($percent / 100) }")

    if [ "$limit_kbs" -lt 10 ]; then
        limit_kbs=10
    fi

    EFFECTIVE_BANDWIDTH_LIMIT="$limit_kbs"
    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_BANDWIDTH_DETECTED" "$speed_kbs" "$limit_kbs" "$percent")"
}

parse_download_size_mb() {
    local line="$1"
    local value unit
    value=$(echo "$line" | grep -oE '[0-9][0-9,.]*' | head -1 | tr -d ',')
    unit=$(echo "$line" | grep -oE '\bGB\b|\bMB\b|\bkB\b|\bB\b' | head -1)
    case "$unit" in
        GB) awk "BEGIN { printf \"%.1f\", $value * 1024 }" ;;
        MB) awk "BEGIN { printf \"%.1f\", $value }" ;;
        kB) awk "BEGIN { printf \"%.1f\", $value / 1024 }" ;;
        *)  echo "0" ;;
    esac
}

format_duration() {
    local seconds="$1"
    if [ "$seconds" -lt 60 ]; then
        # shellcheck disable=SC2059
        printf "$MSG_ESTIMATE_SECONDS" "$seconds"
    elif [ "$seconds" -lt 3600 ]; then
        # shellcheck disable=SC2059
        printf "$MSG_ESTIMATE_MINUTES" "$(( seconds / 60 ))"
    else
        # shellcheck disable=SC2059
        printf "$MSG_ESTIMATE_HOURS" "$(( seconds / 3600 ))" "$(( (seconds % 3600) / 60 ))"
    fi
}

estimate_update_time() {
    if [ "${ENABLE_PROGRESS:-true}" != "true" ]; then
        return 0
    fi

    local pkg_count=0
    local download_mb=0
    local has_size=false
    local sim_output size_line

    case "$DISTRO" in
        debian|ubuntu|linuxmint|mint|mx)
            sim_output=$(DEBIAN_FRONTEND=noninteractive apt-get -s dist-upgrade 2>/dev/null)
            pkg_count=$(echo "$sim_output" | grep -c "^Inst" || true)
            size_line=$(echo "$sim_output" | grep "Need to get" || true)
            if [ -n "$size_line" ]; then
                download_mb=$(parse_download_size_mb "$size_line")
                has_size=true
            fi
            ;;
        rhel|centos|fedora|rocky|almalinux)
            if command -v dnf &>/dev/null; then
                sim_output=$(dnf upgrade --assumeno 2>/dev/null || true)
                pkg_count=$(echo "$sim_output" | grep -c "^Upgrading\|^Installing" || true)
                size_line=$(echo "$sim_output" | grep "Total download size" || true)
                if [ -n "$size_line" ]; then
                    download_mb=$(parse_download_size_mb "$size_line")
                    has_size=true
                fi
            fi
            ;;
        opensuse*|sles|suse)
            pkg_count=$(zypper --non-interactive lu 2>/dev/null | grep -c "^v " || true)
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            pkg_count=$(pacman -Qu 2>/dev/null | wc -l || true)
            ;;
        void)
            pkg_count=$(xbps-install -Sun 2>/dev/null | grep -c "will be" || true)
            ;;
        solus)
            pkg_count=$(eopkg list-upgrades 2>/dev/null | wc -l || true)
            ;;
    esac

    if [ "$pkg_count" -le 0 ]; then
        return 0
    fi

    local install_seconds=$(( pkg_count * 3 ))
    local total_seconds=$install_seconds
    local time_str

    if [ "$has_size" = true ] && [ -n "${EFFECTIVE_BANDWIDTH_LIMIT:-}" ] && [ "${EFFECTIVE_BANDWIDTH_LIMIT}" -gt 0 ]; then
        local download_seconds
        download_seconds=$(awk "BEGIN { printf \"%d\", ($download_mb * 1024) / ${EFFECTIVE_BANDWIDTH_LIMIT} }")
        total_seconds=$(( download_seconds + install_seconds ))
    fi

    time_str=$(format_duration "$total_seconds")

    if [ "$has_size" = true ]; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_ESTIMATE_WITH_SIZE" "$pkg_count" "$download_mb" "$time_str")"
    else
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_ESTIMATE_NO_SIZE" "$pkg_count" "$time_str")"
    fi
}

# Snap-Pakete aktualisieren
update_snap() {
    if ! command -v snap &> /dev/null; then
        return 0
    fi

    log_info "$MSG_SNAP_CHECK"

    if systemctl is-active snapd.timer &> /dev/null; then
        log_info "$MSG_SNAP_AUTO_ACTIVE"
        return 0
    fi

    log_info "$MSG_SNAP_REFRESH_START"
    snap refresh 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        log_error "$MSG_SNAP_REFRESH_FAILED"
        return 1
    fi

    log_info "$MSG_SNAP_REFRESH_SUCCESS"
    return 0
}

install_fwupd() {
    case "$DISTRO" in
        debian|ubuntu|linuxmint|mint|mx)
            DEBIAN_FRONTEND=noninteractive apt-get install -y fwupd 2>&1 | tee -a "$LOG_FILE" ;;
        rhel|centos|fedora|rocky|almalinux)
            if command -v dnf &>/dev/null; then
                dnf install -y fwupd 2>&1 | tee -a "$LOG_FILE"
            else
                yum install -y fwupd 2>&1 | tee -a "$LOG_FILE"
            fi ;;
        opensuse*|sles|suse)
            zypper install -y fwupd 2>&1 | tee -a "$LOG_FILE" ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            pacman -S --noconfirm fwupd 2>&1 | tee -a "$LOG_FILE" ;;
        void)
            xbps-install -y fwupd 2>&1 | tee -a "$LOG_FILE" ;;
        *)
            return 1 ;;
    esac
}

# Firmware-Updates via fwupd (v1.9.1)
update_fwupd() {
    if [ "${ENABLE_FWUPD:-false}" != "true" ]; then
        return 0
    fi

    if ! command -v fwupdmgr &>/dev/null; then
        log_info "$MSG_FWUPD_INSTALLING"
        if install_fwupd && command -v fwupdmgr &>/dev/null; then
            log_info "$MSG_FWUPD_INSTALLED"
        else
            log_warning "$MSG_FWUPD_INSTALL_FAILED"
            return 0
        fi
    fi

    log_info "$MSG_FWUPD_START"

    fwupdmgr refresh --force 2>&1 | tee -a "$LOG_FILE"

    fwupdmgr update --assume-yes 2>&1 | tee -a "$LOG_FILE"
    local exit_code=${PIPESTATUS[0]}

    if [ "$exit_code" -eq 0 ]; then
        log_info "$MSG_FWUPD_SUCCESS"
    elif [ "$exit_code" -eq 2 ]; then
        log_info "$MSG_FWUPD_NO_UPDATES"
    else
        log_warning "$MSG_FWUPD_FAILED"
    fi

    return 0
}
