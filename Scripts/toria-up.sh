#!/bin/bash

toria-up() {
    local success_count=0
    local failed_count=0
    local skipped_count=0

    local -a success_items=()
    local -a failed_items=()
    local -a skipped_items=()

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
        "Claude" \
        "claude" \
        claude update

    run_update \
        "Codex Plugin Marketplace" \
        "codex" \
        codex plugin marketplace upgrade

    run_update \
        "Homebrew Repository Metadata" \
        "brew" \
        brew update

    run_update \
        "Homebrew Packages" \
        "brew" \
        brew upgrade

    run_update \
        "Homebrew Cleanup" \
        "brew" \
        brew cleanup

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
