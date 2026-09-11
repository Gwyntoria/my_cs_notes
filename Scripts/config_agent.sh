#!/usr/bin/env bash

set -eu

CODEX_INSTRUCTIONS_URL="https://raw.githubusercontent.com/Gwyntoria/skills/refs/heads/main/instructions/global.md"
MATTPOCOCK_SKILLS_URL="https://github.com/mattpocock/skills"
MATTPOCOCK_ENGINEERING_URL="$MATTPOCOCK_SKILLS_URL/tree/main/skills/engineering"
MATTPOCOCK_PRODUCTIVITY_URL="$MATTPOCOCK_SKILLS_URL/tree/main/skills/productivity"
HUMANLAYER_SKILLS_URL="https://github.com/humanlayer/skills"
UNWANTED_CODEX_SKILLS=()
PI_EXTENSIONS=(
    "npm:pi-web-access"
)

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
    local source_url="$1"
    shift

    npx skills add "$source_url" \
        "$@" \
        --global \
        --agent codex \
        --yes
}

remove_installed_codex_skills() {
    local agents_dir
    local skills_dir
    local lock_file

    if [ -z "${HOME:-}" ] || [ "$HOME" = "/" ]; then
        printf '%s\n' "Error: HOME does not identify a safe user directory." >&2
        exit 1
    fi

    case "$HOME" in
        /*) ;;
        *)
            printf '%s\n' "Error: HOME must be an absolute path." >&2
            exit 1
            ;;
    esac

    agents_dir="$HOME/.agents"
    skills_dir="$agents_dir/skills"
    lock_file="$agents_dir/.skill-lock.json"

    rm -rf "$skills_dir"
    rm -f "$lock_file"
}

remove_unwanted_codex_skills() {
    local lock_file="$HOME/.agents/.skill-lock.json"
    local skill_name

    if (( ${#UNWANTED_CODEX_SKILLS[@]} == 0 )); then
        log "No unwanted Codex skills configured; skipping cleanup"
        return 0
    fi

    for skill_name in "${UNWANTED_CODEX_SKILLS[@]}"; do
        if [[ ! "$skill_name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
            printf 'Error: unexpected skill name: %s\n' "$skill_name" >&2
            exit 1
        fi
    done

    npx skills remove "${UNWANTED_CODEX_SKILLS[@]}" \
        --global \
        --yes

    for skill_name in "${UNWANTED_CODEX_SKILLS[@]}"; do
        rm -rf "$HOME/.agents/skills/$skill_name"
    done

    if [ -f "$lock_file" ]; then
        node -e '
            const fs = require("fs");
            const lockPath = process.argv[1];
            const unwantedSkills = process.argv.slice(2);
            const lock = JSON.parse(fs.readFileSync(lockPath, "utf8"));

            for (const skillName of unwantedSkills) {
                delete lock.skills?.[skillName];
            }

            fs.writeFileSync(lockPath, JSON.stringify(lock, null, 2) + "\n");
        ' "$lock_file" "${UNWANTED_CODEX_SKILLS[@]}"
    fi
}

# Stage 1: Check required commands.

require_command curl
require_command node
require_command npx

# Stage 2: Detect an existing rtk installation.

if command -v rtk >/dev/null 2>&1; then
    RTK_BIN="$(command -v rtk)"
else
    RTK_BIN=""
fi

# Stage 3: Install the global Codex instructions.

log "Installing global Codex instructions"

mkdir -p "$HOME/.codex"
temporary_dir="$(mktemp -d)"
instructions_file="$temporary_dir/AGENTS.md"
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM

curl -fsSL "$CODEX_INSTRUCTIONS_URL" -o "$instructions_file"
install -m 0644 "$instructions_file" "$HOME/.codex/AGENTS.md"

success "Global instructions installed at ~/.codex/AGENTS.md"

# Stage 4: Install rtk and initialize its Codex integration.

log "Installing and initializing rtk for Codex"

if [ -n "$RTK_BIN" ]; then
    log "rtk is already installed at $RTK_BIN; skipping installation"
else
    BREW_BIN="$(find_brew)"
    "$BREW_BIN" install rtk
    RTK_BIN="$("$BREW_BIN" --prefix rtk)/bin/rtk"
fi

if [ ! -x "$RTK_BIN" ]; then
    printf 'Error: rtk executable was not found after installation: %s\n' "$RTK_BIN" >&2
    exit 1
fi

"$RTK_BIN" init -g --codex

success "rtk initialized for Codex"

# Stage 5: Remove existing global Codex skills.

log "Removing existing Codex skills"

remove_installed_codex_skills

success "Existing Codex skills removed"

# Stage 6: Install global Codex skills.

log "Installing Codex skills"

# Install the Mattpocock engineering and productivity skills.

install_codex_skills "$MATTPOCOCK_ENGINEERING_URL"
install_codex_skills "$MATTPOCOCK_PRODUCTIVITY_URL"

# Install the Humanlayer show-me skill.

npx skills add "$HUMANLAYER_SKILLS_URL" \
    --skill show-me \
    --global \
    --agent codex \
    --yes

# Remove skills that are not part of the desired setup.

remove_unwanted_codex_skills

success "Codex skills installed"

# Stage 7: Install Pi extensions.

require_command pi

log "Installing Pi extensions"

for extension in "${PI_EXTENSIONS[@]}"; do
    pi install "$extension"
done

success "Pi extensions installed"
