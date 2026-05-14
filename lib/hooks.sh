#!/bin/bash
# lib/hooks.sh - Pre/Post-Update Hook-System (v1.7.0)

# Einzelnen Hook ausführen (mit Timeout)
run_single_hook() {
    local hook_file="$1"
    local hook_name
    hook_name=$(basename "$hook_file")
    local hook_timeout="${HOOKS_TIMEOUT:-300}"
    local exit_code=0

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_HOOKS_RUNNING" "$hook_name")"

    if [ ! -x "$hook_file" ]; then
        # shellcheck disable=SC2059
        log_warning "$(printf "$MSG_HOOKS_NOT_EXECUTABLE" "$hook_name")"
        return 0
    fi

    if command -v timeout &> /dev/null; then
        timeout "$hook_timeout" "$hook_file" 2>&1 | tee -a "$LOG_FILE"
        exit_code="${PIPESTATUS[0]}"

        if [ "$exit_code" -eq 124 ]; then
            # shellcheck disable=SC2059
            log_error "$(printf "$MSG_HOOKS_TIMEOUT" "$hook_name" "$hook_timeout")"
            return 1
        fi
    else
        "$hook_file" 2>&1 | tee -a "$LOG_FILE"
        exit_code="${PIPESTATUS[0]}"
    fi

    if [ "$exit_code" -ne 0 ]; then
        # shellcheck disable=SC2059
        log_error "$(printf "$MSG_HOOKS_FAILED" "$hook_name" "$exit_code")"
        return 1
    fi

    # shellcheck disable=SC2059
    log_info "$(printf "$MSG_HOOKS_SUCCESS" "$hook_name")"
    return 0
}

# Alle Hooks in einem Verzeichnis ausführen (alphabetisch)
run_hooks() {
    local hooks_dir="$1"

    if [ "${ENABLE_HOOKS:-true}" != "true" ]; then
        log_info "$MSG_HOOKS_DISABLED"
        return 0
    fi

    if [ ! -d "$hooks_dir" ]; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_HOOKS_DIR_NOT_FOUND" "$hooks_dir")"
        return 0
    fi

    local hook_count=0
    local error_count=0

    while IFS= read -r -d '' hook_file; do
        hook_count=$((hook_count + 1))

        if ! run_single_hook "$hook_file"; then
            error_count=$((error_count + 1))

            if [ "${HOOKS_ABORT_ON_ERROR:-false}" = "true" ]; then
                # shellcheck disable=SC2059
                log_error "$(printf "$MSG_HOOKS_ABORT_ON_ERROR" "$(basename "$hook_file")")"
                return 1
            fi
        fi
    done < <(find "$hooks_dir" -maxdepth 1 -name "*.sh" -type f -print0 | sort -z)

    if [ "$hook_count" -eq 0 ]; then
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_HOOKS_NONE_FOUND" "$hooks_dir")"
        return 0
    fi

    if [ "$error_count" -gt 0 ]; then
        # shellcheck disable=SC2059
        log_warning "$(printf "$MSG_HOOKS_COMPLETED_WITH_ERRORS" "$hook_count" "$error_count")"
    else
        # shellcheck disable=SC2059
        log_info "$(printf "$MSG_HOOKS_ALL_SUCCESS" "$hook_count")"
    fi

    return 0
}

# Pre-Update-Hooks ausführen
run_pre_update_hooks() {
    local hooks_dir="${HOOKS_DIR:-/etc/update-hooks}/pre.d"
    log_info "$MSG_HOOKS_PRE_START"
    run_hooks "$hooks_dir"
}

# Post-Update-Hooks ausführen
run_post_update_hooks() {
    local hooks_dir="${HOOKS_DIR:-/etc/update-hooks}/post.d"
    log_info "$MSG_HOOKS_POST_START"
    run_hooks "$hooks_dir"
}
