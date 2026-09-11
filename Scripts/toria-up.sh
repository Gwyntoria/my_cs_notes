#!/bin/bash

PROGRAM_NAME="${0##*/}"

usage() {
    printf 'Usage: %s [options]\n' "$PROGRAM_NAME"
    printf '\n'
    printf 'Options:\n'
    printf '  -c, --clean  Run brew cleanup after updates\n'
    printf '  -h, --help   Show this help message\n'
}

run_update() {
    name="$1"
    executable="$2"
    shift 2

    printf '\n'
    printf '%s\n' "=================================================="
    printf '[%s] Starting: %s\n' "$(date '+%H:%M:%S')" "$name"
    printf 'Command:'
    printf ' %s' "$@"
    printf '\n'
    printf '%s\n' "=================================================="

    if ! command -v "$executable" >/dev/null 2>&1; then
        printf '⚠️  Skipped: command '\''%s'\'' not found\n' "$executable"
        skipped_items="${skipped_items}  ⚠️  ${name}: missing ${executable}
"
        skipped_count=$((skipped_count + 1))
        return 0
    fi

    "$@"
    rc=$?

    if [ "$rc" -eq 0 ]; then
        printf '✅ Completed: %s\n' "$name"
        success_items="${success_items}  ✅ ${name}
"
        success_count=$((success_count + 1))
    else
        printf '❌ Failed: %s\n' "$name"
        printf 'Exit code: %s\n' "$rc"
        failed_items="${failed_items}  ❌ ${name} (exit code ${rc})
"
        failed_count=$((failed_count + 1))
    fi

    # Continue with subsequent tasks whether this task succeeds or fails.
    return 0
}

main() {
    clean_homebrew=0
    success_count=0
    failed_count=0
    skipped_count=0
    success_items=""
    failed_items=""
    skipped_items=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            -c|--clean)
                clean_homebrew=1
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                printf 'Error: unknown option: %s\n\n' "$1" >&2
                usage >&2
                return 2
                ;;
        esac

        shift
    done

    printf '\n'
    printf '%s\n' "##################################################"
    printf 'Update started: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf '%s\n' "##################################################"

    run_update \
        "Skills" \
        "npx" \
        npx skills update -g -y

    run_update \
        "Codex" \
        "codex" \
        codex update

    run_update \
        "Codex Plugin Marketplace" \
        "codex" \
        codex plugin marketplace upgrade

    run_update \
        "Homebrew Packages" \
        "brew" \
        brew upgrade

    if [ "$clean_homebrew" -eq 1 ]; then
        run_update \
            "Homebrew Cleanup" \
            "brew" \
            brew cleanup
    fi

    printf '\n'
    printf '%s\n' "##################################################"
    printf 'Update finished: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf 'Succeeded: %s\n' "$success_count"
    printf 'Failed: %s\n' "$failed_count"
    printf 'Skipped: %s\n' "$skipped_count"
    printf '%s\n' "##################################################"

    if [ -n "$success_items" ]; then
        printf '\nSuccessful updates:\n'
        printf '%s' "$success_items"
    fi

    if [ -n "$failed_items" ]; then
        printf '\nFailed updates:\n'
        printf '%s' "$failed_items"
    fi

    if [ -n "$skipped_items" ]; then
        printf '\nSkipped updates:\n'
        printf '%s' "$skipped_items"
    fi

    printf '\n'

    # Return 1 if any task fails.
    # Return 0 if tasks are skipped only because their executables are unavailable.
    if [ "$failed_count" -gt 0 ]; then
        return 1
    fi

    return 0
}

main "$@"
