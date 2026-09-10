#!/bin/bash

PROGRAM_NAME="${0##*/}"

usage() {
    printf 'Usage: %s [options]\n' "$PROGRAM_NAME"
    printf '\n'
    printf 'Options:\n'
    printf '  -c, --clean  Run brew cleanup after updates\n'
    printf '  -h, --help   Show this help message\n'
}

main() {
    local clean_homebrew=0
    local success_count=0
    local failed_count=0
    local skipped_count=0

    local -a success_items=()
    local -a failed_items=()
    local -a skipped_items=()

    while (( $# > 0 )); do
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

    # Run a single update task.
    #
    # Arguments:
    #   $1: Task name
    #   $2: Executable whose availability should be checked
    #   $3...: Command and arguments to execute
    run_update() {
        local name="$1"
        local executable="$2"
        shift 2

        echo
        echo "=================================================="
        echo "[$(date '+%H:%M:%S')] Starting: ${name}"
        echo "Command: $*"
        echo "=================================================="

        if ! command -v "$executable" >/dev/null 2>&1; then
            echo "⚠️  Skipped: command '${executable}' not found"
            skipped_items+=("$name: missing ${executable}")
            ((skipped_count++))
            return 0
        fi

        "$@"
        local rc=$?

        if (( rc == 0 )); then
            echo "✅ Completed: ${name}"
            success_items+=("$name")
            ((success_count++))
        else
            echo "❌ Failed: ${name}"
            echo "Exit code: ${rc}"
            failed_items+=("$name (exit code ${rc})")
            ((failed_count++))
        fi

        # Continue with subsequent tasks whether this task succeeds or fails.
        return 0
    }

    echo
    echo "##################################################"
    echo "Update started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "##################################################"

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

    if (( clean_homebrew )); then
        run_update \
            "Homebrew Cleanup" \
            "brew" \
            brew cleanup
    fi

    echo
    echo "##################################################"
    echo "Update finished: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Succeeded: ${success_count}"
    echo "Failed: ${failed_count}"
    echo "Skipped: ${skipped_count}"
    echo "##################################################"

    if (( ${#success_items[@]} > 0 )); then
        echo
        echo "Successful updates:"
        printf '  ✅ %s\n' "${success_items[@]}"
    fi

    if (( ${#failed_items[@]} > 0 )); then
        echo
        echo "Failed updates:"
        printf '  ❌ %s\n' "${failed_items[@]}"
    fi

    if (( ${#skipped_items[@]} > 0 )); then
        echo
        echo "Skipped updates:"
        printf '  ⚠️  %s\n' "${skipped_items[@]}"
    fi

    echo

    # Return 1 if any task fails.
    # Return 0 if tasks are skipped only because their executables are unavailable.
    if (( failed_count > 0 )); then
        return 1
    fi

    return 0
}

main "$@"
