#!/bin/sh

set -eu

CODEX_INSTRUCTIONS_URL="https://raw.githubusercontent.com/Gwyntoria/skills/refs/heads/main/instructions/global.md"
WAZA_SKILLS_URL="https://github.com/tw93/waza"
MATTPOCOCK_SKILLS_URL="https://github.com/mattpocock/skills"

log() {
    printf '\n\033[1;34m==> %s\033[0m\n' "$1"
}

success() {
    printf '\033[1;32m✓ %s\033[0m\n' "$1"
}

require_command() {
    command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Error: required command not found: %s\n' "$command_name" >&2
        exit 1
    fi
}

find_brew() {
    if command -v brew >/dev/null 2>&1; then
        command -v brew
        return
    fi

    for brew_path in \
        /opt/homebrew/bin/brew \
        /usr/local/bin/brew \
        /home/linuxbrew/.linuxbrew/bin/brew
    do
        if [ -x "$brew_path" ]; then
            printf '%s\n' "$brew_path"
            return
        fi
    done

    printf '%s\n' "Error: Homebrew was not found." >&2
    exit 1
}

install_codex_skills() {
    source_url="$1"

    npx skills add "$source_url" \
        --global \
        --agent codex
}

require_command curl
require_command npx

BREW_BIN="$(find_brew)"

log "Installing global Codex instructions"

mkdir -p "$HOME/.codex"
instructions_file="$(mktemp)"
trap 'rm -f "$instructions_file"' 0 HUP INT TERM

curl -fsSL "$CODEX_INSTRUCTIONS_URL" -o "$instructions_file"
install -m 0644 "$instructions_file" "$HOME/.codex/AGENTS.md"

success "Global instructions installed at ~/.codex/AGENTS.md"

log "Installing and initializing rtk for Codex"

"$BREW_BIN" install rtk
RTK_BIN="$("$BREW_BIN" --prefix rtk)/bin/rtk"

if [ ! -x "$RTK_BIN" ]; then
    printf 'Error: rtk executable was not found after installation: %s\n' "$RTK_BIN" >&2
    exit 1
fi

"$RTK_BIN" init -g --codex

success "rtk initialized for Codex"

log "Installing Codex skills"

install_codex_skills "$WAZA_SKILLS_URL"
install_codex_skills "$MATTPOCOCK_SKILLS_URL"

success "Codex skills installed"
