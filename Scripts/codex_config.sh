#!/bin/sh

set -eu

CODEX_INSTRUCTIONS_URL="https://raw.githubusercontent.com/Gwyntoria/skills/refs/heads/main/instructions/global.md"
MATTPOCOCK_SKILLS_URL="https://github.com/mattpocock/skills"
HUMANLAYER_SKILLS_URL="https://github.com/humanlayer/skills"

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
    shift

    npx skills add "$source_url" \
        "$@" \
        --global \
        --agent codex \
        --yes
}

remove_unwanted_codex_skills() {
    lock_file="$1"
    stale_skills_file="$2"

    if [ ! -f "$lock_file" ]; then
        return
    fi

    node -e '
        const fs = require("fs");
        const lock = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));

        for (const [skillName, metadata] of Object.entries(lock.skills ?? {})) {
            const isMattpocockSkill = metadata.source === "mattpocock/skills" ||
                metadata.sourceUrl === "https://github.com/mattpocock/skills.git";
            const isWazaSkill = metadata.source === "tw93/waza" ||
                metadata.sourceUrl === "https://github.com/tw93/waza.git";

            if ((isMattpocockSkill && skillName !== "grilling") || isWazaSkill) {
                if (!/^[a-z0-9][a-z0-9-]*$/.test(skillName)) {
                    throw new Error("Unexpected installed skill name: " + skillName);
                }

                process.stdout.write(skillName + "\n");
            }
        }
    ' "$lock_file" >"$stale_skills_file"

    set --

    while IFS= read -r skill_name; do
        set -- "$@" "$skill_name"
    done <"$stale_skills_file"

    if [ "$#" -gt 0 ]; then
        npx skills remove "$@" \
            --global \
            --agent codex \
            --yes
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

# Stage 5: Install global Codex skills.

log "Installing Codex skills"

# Install the Mattpocock grilling skill, then remove other Mattpocock and Waza skills.

install_codex_skills "$MATTPOCOCK_SKILLS_URL" --skill grilling
remove_unwanted_codex_skills \
    "$HOME/.agents/.skill-lock.json" \
    "$temporary_dir/stale-mattpocock-skills.txt"

# Install the Humanlayer show-me skill.

npx skills add "$HUMANLAYER_SKILLS_URL" \
    --skill show-me \
    --global \
    --agent codex \
    --yes

success "Codex skills installed"
