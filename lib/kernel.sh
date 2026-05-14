#!/bin/bash
# lib/kernel.sh - Kernel-Schutz, NVIDIA-Kompatibilität & Secure Boot (v1.6.0)

# Zählt stabile Kernel-Versionen (Debian/Ubuntu)
count_stable_kernels_debian() {
    local kernel_count

    if command -v linux-version &> /dev/null; then
        kernel_count=$(linux-version list 2>/dev/null | wc -l || echo "0")
    else
        kernel_count=$(dpkg -l 2>/dev/null | grep -c "^ii.*linux-image-[0-9]" || echo "0")
    fi

    echo "$kernel_count"
}

# Zählt stabile Kernel-Versionen (RHEL/Fedora)
count_stable_kernels_redhat() {
    local kernel_count

    if command -v dnf &> /dev/null; then
        kernel_count=$(dnf list installed kernel 2>/dev/null | grep -c "^kernel" || echo "0")
    elif command -v rpm &> /dev/null; then
        kernel_count=$(rpm -q kernel 2>/dev/null | grep -c "^kernel" || echo "0")
    else
        kernel_count=0
    fi

    echo "$kernel_count"
}

# Sicheres autoremove mit Kernel-Schutz
safe_autoremove() {
    local pkg_manager="$1"
    local kernel_count=0
    local min_kernels="${MIN_KERNELS:-3}"
    local current_kernel
    current_kernel=$(uname -r)

    if [ "$KERNEL_PROTECTION" != "true" ]; then
        case "$pkg_manager" in
            apt)
                DEBIAN_FRONTEND=noninteractive apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
            dnf)
                dnf autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
            yum)
                yum autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
        esac
        return 0
    fi

    log_info "$MSG_KERNEL_CHECK"

    case "$pkg_manager" in
        apt)
            kernel_count=$(count_stable_kernels_debian)
            ;;
        dnf|yum)
            kernel_count=$(count_stable_kernels_redhat)
            ;;
        *)
            log_warning "Unknown package manager: $pkg_manager"
            return 1
            ;;
    esac

    # shellcheck disable=SC2059
    printf "$MSG_KERNEL_COUNT\n" "$kernel_count" | tee -a "$LOG_FILE"
    # shellcheck disable=SC2059
    printf "$MSG_KERNEL_CURRENT\n" "$current_kernel" | tee -a "$LOG_FILE"

    if [ "$kernel_count" -ge "$min_kernels" ]; then
        log_info "$MSG_KERNEL_SAFE_AUTOREMOVE"
        case "$pkg_manager" in
            apt)
                DEBIAN_FRONTEND=noninteractive apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
            dnf)
                dnf autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
            yum)
                yum autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
        esac
    else
        # shellcheck disable=SC2059
        printf "$MSG_KERNEL_SKIP_AUTOREMOVE\n" "$kernel_count" | tee -a "$LOG_FILE"
        # shellcheck disable=SC2059
        printf "$MSG_KERNEL_MIN_REQUIRED\n" "$min_kernels" | tee -a "$LOG_FILE"
        log_warning "$MSG_KERNEL_PROTECTION"
    fi
}

# Prüft ob NVIDIA-Treiber installiert sind
is_nvidia_installed() {
    if command -v nvidia-smi &> /dev/null; then
        return 0
    fi

    if lsmod 2>/dev/null | grep -q "^nvidia"; then
        return 0
    fi

    if command -v lspci &> /dev/null && lspci 2>/dev/null | grep -qi "nvidia"; then
        if [ -d /proc/driver/nvidia ] || [ -f /sys/module/nvidia/version ]; then
            return 0
        fi
    fi

    return 1
}

# Ermittelt die verfügbare Kernel-Version im Update
get_pending_kernel_version() {
    local distro="$1"
    local pending_kernel=""

    case "$distro" in
        debian|ubuntu|linuxmint|pop|mx)
            if command -v apt-cache &> /dev/null; then
                pending_kernel=$(apt-cache policy linux-image-generic 2>/dev/null | \
                    grep "Candidate:" | awk '{print $2}' | grep -oP '\d+\.\d+\.\d+-\d+' | head -1)
            fi
            ;;
        fedora|rhel|centos|rocky|almalinux)
            if command -v dnf &> /dev/null; then
                pending_kernel=$(dnf list --available kernel 2>/dev/null | \
                    grep "^kernel" | awk '{print $2}' | head -1 | sed 's/\..*$//')
            elif command -v yum &> /dev/null; then
                pending_kernel=$(yum list available kernel 2>/dev/null | \
                    grep "^kernel" | awk '{print $2}' | head -1 | sed 's/\..*$//')
            fi
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            if command -v pacman &> /dev/null; then
                pending_kernel=$(pacman -Si linux 2>/dev/null | \
                    grep "^Version" | awk '{print $3}' | head -1)
            fi
            ;;
        opensuse*|sles)
            if command -v zypper &> /dev/null; then
                pending_kernel=$(zypper info kernel-default 2>/dev/null | \
                    grep "^Version" | awk '{print $3}' | head -1)
            fi
            ;;
        solus)
            if command -v eopkg &> /dev/null; then
                pending_kernel=$(eopkg info linux-current 2>/dev/null | \
                    grep "^Version" | awk '{print $3}' | head -1)
            fi
            ;;
        void)
            if command -v xbps-query &> /dev/null; then
                pending_kernel=$(xbps-query -R -p pkgver linux 2>/dev/null | \
                    sed 's/linux-//' | head -1)
            fi
            ;;
    esac

    echo "$pending_kernel"
}

# Prüft DKMS-Status für NVIDIA
check_nvidia_dkms_status() {
    local target_kernel="$1"

    if ! command -v dkms &> /dev/null; then
        return 1
    fi

    local nvidia_dkms
    nvidia_dkms=$(dkms status 2>/dev/null | grep -i nvidia)

    if [ -z "$nvidia_dkms" ]; then
        return 1
    fi

    if [ -n "$target_kernel" ]; then
        if echo "$nvidia_dkms" | grep -q "$target_kernel"; then
            return 0
        else
            return 2
        fi
    fi

    return 0
}

# Prüft ob Secure Boot aktiv ist
is_secureboot_enabled() {
    if command -v mokutil &> /dev/null; then
        if mokutil --sb-state 2>/dev/null | grep -qi "SecureBoot enabled"; then
            return 0
        fi
        if mokutil --sb-state 2>/dev/null | grep -qi "SecureBoot disabled"; then
            return 1
        fi
    fi

    if command -v bootctl &> /dev/null; then
        if bootctl status 2>/dev/null | grep -qi "Secure Boot.*enabled"; then
            return 0
        fi
    fi

    for efi_var in /sys/firmware/efi/efivars/SecureBoot-*; do
        if [ -f "$efi_var" ]; then
            local sb_value
            sb_value=$(od -An -t u1 "$efi_var" 2>/dev/null | awk '{print $NF}')
            if [ "$sb_value" = "1" ]; then
                return 0
            fi
        fi
    done

    return 2
}

# Prüft ob MOK-Schlüssel registriert sind
check_mok_keys() {
    if ! command -v mokutil &> /dev/null; then
        return 1
    fi

    if mokutil --list-enrolled 2>/dev/null | grep -qi "BEGIN CERTIFICATE"; then
        return 0
    fi

    return 1
}

# Signiert NVIDIA DKMS-Module mit MOK
sign_nvidia_modules() {
    local kernel_version="$1"

    local sign_tool=""
    if [ -x /usr/src/linux-headers-"${kernel_version}"/scripts/sign-file ]; then
        sign_tool="/usr/src/linux-headers-${kernel_version}/scripts/sign-file"
    else
        sign_tool=$(find /usr/lib/linux-kbuild-*/scripts/sign-file 2>/dev/null | head -1)
        if [ -z "$sign_tool" ] && command -v kmodsign &> /dev/null; then
            sign_tool="kmodsign"
        fi
    fi

    if [ -z "$sign_tool" ]; then
        log_error "sign-file tool nicht gefunden"
        return 1
    fi

    local mok_key=""
    local mok_cert=""

    if [ -f /var/lib/shim-signed/mok/MOK.priv ]; then
        mok_key="/var/lib/shim-signed/mok/MOK.priv"
        mok_cert="/var/lib/shim-signed/mok/MOK.der"
    elif [ -f /var/lib/dkms/mok.key ]; then
        mok_key="/var/lib/dkms/mok.key"
        mok_cert="/var/lib/dkms/mok.pub"
    fi

    if [ -z "$mok_key" ] || [ ! -f "$mok_key" ]; then
        log_warning "$MSG_NVIDIA_MOK_MISSING"
        log_warning "$MSG_NVIDIA_MOK_ENROLLMENT_NEEDED"
        return 1
    fi

    log_info "$MSG_NVIDIA_MOK_SIGN_START"

    local module_path="/lib/modules/${kernel_version}/updates/dkms"
    if [ ! -d "$module_path" ]; then
        module_path="/lib/modules/${kernel_version}/extra"
    fi

    local signed_count=0
    local failed_count=0

    if [ -d "$module_path" ]; then
        while IFS= read -r -d '' module; do
            if [[ "$module" == *nvidia*.ko ]]; then
                if "$sign_tool" sha256 "$mok_key" "$mok_cert" "$module" 2>&1 | tee -a "$LOG_FILE"; then
                    ((signed_count++))
                else
                    ((failed_count++))
                    log_error "Fehler beim Signieren: $module"
                fi
            fi
        done < <(find "$module_path" -name "*.ko" -print0 2>/dev/null)
    fi

    if [ "$failed_count" -gt 0 ]; then
        log_error "$MSG_NVIDIA_MOK_SIGN_FAILED"
        return 1
    elif [ "$signed_count" -gt 0 ]; then
        log_info "$MSG_NVIDIA_MOK_SIGN_SUCCESS ($signed_count Module)"
        return 0
    else
        log_warning "Keine NVIDIA-Module zum Signieren gefunden"
        return 1
    fi
}

# Setzt Kernel-Hold (verhindert Kernel-Update)
hold_kernel_update() {
    local distro="$1"
    local unhold_cmd=""

    case "$distro" in
        debian|ubuntu|linuxmint|pop|mx)
            unhold_cmd="sudo apt-mark unhold linux-image-generic linux-headers-generic"

            if apt-mark hold linux-image-generic linux-headers-generic 2>&1 | tee -a "$LOG_FILE"; then
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_NVIDIA_KERNEL_HOLD_SUCCESS" "linux-image-generic")"
                log_info "$MSG_NVIDIA_KERNEL_HOLD_INFO"
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_NVIDIA_KERNEL_UNHOLD_LATER" "$unhold_cmd")"
                return 0
            fi
            ;;
        fedora|rhel|centos|rocky|almalinux)
            if command -v dnf &> /dev/null; then
                unhold_cmd="sudo dnf versionlock delete kernel kernel-core kernel-modules"

                if dnf versionlock add kernel kernel-core kernel-modules 2>&1 | tee -a "$LOG_FILE"; then
                    # shellcheck disable=SC2059
                    log_info "$(printf "$MSG_NVIDIA_KERNEL_HOLD_SUCCESS" "kernel")"
                    log_info "$MSG_NVIDIA_KERNEL_HOLD_INFO"
                    # shellcheck disable=SC2059
                    log_info "$(printf "$MSG_NVIDIA_KERNEL_UNHOLD_LATER" "$unhold_cmd")"
                    return 0
                fi
            elif command -v yum &> /dev/null; then
                log_warning "yum versionlock erfordert yum-plugin-versionlock"
                log_info "Installiere mit: sudo yum install yum-plugin-versionlock"
            fi
            ;;
        arch|manjaro|endeavouros|garuda|arcolinux)
            log_warning "Arch Linux: Manuelle Konfiguration erforderlich"
            log_info "Füge in /etc/pacman.conf hinzu:"
            log_info "  IgnorePkg = linux linux-headers"
            log_info "Oder installiere linux-lts statt linux"
            return 1
            ;;
        opensuse*|sles)
            unhold_cmd="sudo zypper removelock kernel-default"

            if zypper addlock kernel-default 2>&1 | tee -a "$LOG_FILE"; then
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_NVIDIA_KERNEL_HOLD_SUCCESS" "kernel-default")"
                log_info "$MSG_NVIDIA_KERNEL_HOLD_INFO"
                # shellcheck disable=SC2059
                log_info "$(printf "$MSG_NVIDIA_KERNEL_UNHOLD_LATER" "$unhold_cmd")"
                return 0
            fi
            ;;
        solus)
            log_warning "Solus: Kernel-Hold nicht standardmäßig unterstützt"
            log_info "Erwäge linux-lts Paket statt linux-current"
            return 1
            ;;
        void)
            log_warning "Void Linux: Kernel-Hold via xbps ignorepkg"
            log_info "Füge in /etc/xbps.d/10-ignore.conf hinzu:"
            log_info "  ignorepkg=linux"
            return 1
            ;;
    esac

    log_error "$MSG_NVIDIA_KERNEL_HOLD_FAILED"
    return 1
}

# Test-Build für DKMS (ohne Installation)
test_dkms_build() {
    local kernel_version="$1"

    if ! command -v dkms &> /dev/null; then
        return 1
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_NVIDIA_BUILD_TEST" "$kernel_version")"

    local nvidia_module
    nvidia_module=$(dkms status 2>/dev/null | grep -i nvidia | head -1 | cut -d',' -f1 | tr -d ' ')

    if [ -z "$nvidia_module" ]; then
        log_warning "Kein NVIDIA DKMS-Modul gefunden für Build-Test"
        return 1
    fi

    if dkms build -m "$nvidia_module" -k "$kernel_version" 2>&1 | tee -a "$LOG_FILE" | grep -qi "error\|fail"; then
        log_error "$MSG_NVIDIA_BUILD_TEST_FAILED"
        return 1
    fi

    log_info "$MSG_NVIDIA_BUILD_TEST_SUCCESS"
    return 0
}

# Behandelt Secure Boot Signierung nach DKMS-Build
handle_secureboot_signing() {
    local kernel_version="$1"

    if is_secureboot_enabled; then
        log_info "$MSG_NVIDIA_SECUREBOOT_ACTIVE"
        log_info "$MSG_NVIDIA_MOK_CHECK"

        if check_mok_keys; then
            log_info "$MSG_NVIDIA_MOK_FOUND"
            log_info "$MSG_NVIDIA_MOK_SIGN_REQUIRED"

            local do_sign=false
            if [ "${NVIDIA_AUTO_MOK_SIGN:-false}" = "true" ]; then
                do_sign=true
            else
                echo -e "${YELLOW}Module jetzt signieren? [J/n]:${NC} "
                read -r response
                if [[ "$response" =~ ^[jJyY]$|^$ ]]; then
                    do_sign=true
                fi
            fi

            if [ "$do_sign" = true ]; then
                if sign_nvidia_modules "$kernel_version"; then
                    log_info "$MSG_NVIDIA_MOK_SIGN_SUCCESS"
                else
                    log_warning "$MSG_NVIDIA_MOK_SIGN_FAILED"
                    log_warning "$MSG_NVIDIA_MOK_DOCS"
                fi
            fi
        else
            log_warning "$MSG_NVIDIA_MOK_MISSING"
            log_warning "$MSG_NVIDIA_MOK_ENROLLMENT_NEEDED"
            log_warning "$MSG_NVIDIA_MOK_ENROLLMENT_INFO"
            log_info "$MSG_NVIDIA_MOK_DOCS"
        fi
    elif is_secureboot_enabled; then
        case $? in
            1) log_info "$MSG_NVIDIA_SECUREBOOT_INACTIVE" ;;
            2) log_warning "$MSG_NVIDIA_SECUREBOOT_UNKNOWN" ;;
        esac
    fi
}

# Hauptfunktion: NVIDIA-Kompatibilitätsprüfung vor Update
check_nvidia_compatibility() {
    if [ "${NVIDIA_CHECK_DISABLED:-false}" = "true" ]; then
        log_info "$MSG_NVIDIA_SKIP_CHECK"
        return 0
    fi

    if ! is_nvidia_installed; then
        log_info "$MSG_NVIDIA_NOT_INSTALLED"
        return 0
    fi

    local nvidia_version=""
    if command -v nvidia-smi &> /dev/null; then
        nvidia_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)
    elif [ -f /sys/module/nvidia/version ]; then
        nvidia_version=$(cat /sys/module/nvidia/version 2>/dev/null)
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_NVIDIA_DETECTED" "$nvidia_version")"
    log_info "$MSG_NVIDIA_CHECK"

    local pending_kernel
    # shellcheck disable=SC2153
    pending_kernel=$(get_pending_kernel_version "$DISTRO")

    if [ -z "$pending_kernel" ]; then
        return 0
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_NVIDIA_KERNEL_PENDING" "$pending_kernel")"
    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_NVIDIA_DKMS_CHECK" "$pending_kernel")"

    if check_nvidia_dkms_status "$pending_kernel"; then
        log_info "$MSG_NVIDIA_DKMS_OK"
        return 0
    fi

    log_warning "$MSG_NVIDIA_DKMS_REBUILD"

    if [ "${NVIDIA_ALLOW_UNSUPPORTED_KERNEL:-false}" != "true" ]; then
        # Standard-Modus: Test-Build vor Update
        if ! test_dkms_build "$pending_kernel"; then
            # shellcheck disable=SC2059
            log_warning "$(printf "$MSG_NVIDIA_KERNEL_UNSUPPORTED" "$nvidia_version" "$pending_kernel")"
            log_warning "$MSG_NVIDIA_KERNEL_HOLD"
            log_warning "$MSG_NVIDIA_CHECK_NVIDIA_DOCS"

            if hold_kernel_update "$DISTRO"; then
                return 0
            else
                echo
                echo -e "${YELLOW}$MSG_NVIDIA_CONTINUE_ANYWAY [j/N]:${NC} "
                read -r response
                if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                    log_info "$MSG_NVIDIA_UPDATE_CANCELLED"
                    exit 0
                fi
            fi
        else
            log_info "$MSG_NVIDIA_BUILD_TEST_SUCCESS"
            log_info "Führe DKMS autoinstall durch..."
            if dkms autoinstall -k "$pending_kernel" 2>&1 | tee -a "$LOG_FILE"; then
                log_info "$MSG_NVIDIA_DKMS_REBUILD_SUCCESS"
                handle_secureboot_signing "$pending_kernel"
                return 0
            else
                log_error "$MSG_NVIDIA_DKMS_REBUILD_FAILED"
                log_warning "$MSG_NVIDIA_KERNEL_HOLD"
                if hold_kernel_update "$DISTRO"; then
                    return 0
                else
                    echo -e "${YELLOW}$MSG_NVIDIA_CONTINUE_ANYWAY [j/N]:${NC} "
                    read -r response
                    if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                        log_info "$MSG_NVIDIA_UPDATE_CANCELLED"
                        exit 0
                    fi
                fi
            fi
        fi
    else
        # Power-User-Modus
        log_warning "$MSG_NVIDIA_POWERUSER_MODE"
        log_warning "$MSG_NVIDIA_POWERUSER_RISK"

        if [ "${NVIDIA_AUTO_DKMS_REBUILD:-false}" != "true" ]; then
            echo -e "${YELLOW}$MSG_NVIDIA_DKMS_REBUILD_NOW [j/N]:${NC} "
            read -r response
            if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                log_info "$MSG_NVIDIA_UPDATE_CANCELLED"
                exit 0
            fi
        fi

        log_info "Führe DKMS autoinstall durch..."
        if dkms autoinstall -k "$pending_kernel" 2>&1 | tee -a "$LOG_FILE"; then
            log_info "$MSG_NVIDIA_DKMS_REBUILD_SUCCESS"
            handle_secureboot_signing "$pending_kernel"
            return 0
        else
            log_error "$MSG_NVIDIA_DKMS_REBUILD_FAILED"
            echo -e "${YELLOW}$MSG_NVIDIA_CONTINUE_ANYWAY [j/N]:${NC} "
            read -r response
            if [[ ! "$response" =~ ^[jJyY]$ ]]; then
                log_info "$MSG_NVIDIA_UPDATE_CANCELLED"
                exit 0
            fi
        fi
    fi

    return 0
}
