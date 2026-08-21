#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# WSL Ubuntu Development Environment Setup
#
# Installs:
#   - Base development tools
#   - Homebrew
#   - Git
#   - lazygit
#   - Starship
#   - uv
#   - Python
#   - nvm
#   - Node.js
#   - Codex CLI
#
# Target:
#   - Ubuntu on WSL
#   - Bash
# ============================================================

PYTHON_VERSION="${PYTHON_VERSION:-3.14}"
NODE_VERSION="${NODE_VERSION:-lts/*}"

log() {
    printf '\n\033[1;34m==> %s\033[0m\n' "$1"
}

success() {
    printf '\033[1;32m✓ %s\033[0m\n' "$1"
}

warn() {
    printf '\033[1;33m! %s\033[0m\n' "$1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

append_once() {
    local line="$1"
    local file="$2"

    touch "$file"

    if ! grep -Fqx "$line" "$file"; then
        printf '\n%s\n' "$line" >> "$file"
    fi
}

active_line_contains() {
    local fragment="$1"
    local file="$2"
    local line=""
    local trimmed

    [ -f "$file" ] || return 1

    while IFS= read -r line || [ -n "$line" ]; do
        trimmed="${line#"${line%%[![:space:]]*}"}"

        case "$trimmed" in
            "" | \#*)
                continue
                ;;
        esac

        if [[ "$trimmed" == *"$fragment"* ]]; then
            return 0
        fi
    done < "$file"

    return 1
}

append_unless_active_line_contains() {
    local fragment="$1"
    local line="$2"
    local file="$3"

    touch "$file"

    if ! active_line_contains "$fragment" "$file"; then
        printf '\n%s\n' "$line" >> "$file"
    fi
}


# ------------------------------------------------------------
# 1. Check environment
# ------------------------------------------------------------

log "Checking environment"

if ! grep -qi microsoft /proc/version 2>/dev/null; then
    warn "This script is designed for WSL."
fi

if ! command_exists apt; then
    echo "Error: apt was not found. This script currently supports Ubuntu/Debian."
    exit 1
fi

success "WSL/Ubuntu environment detected"


# ------------------------------------------------------------
# 2. System packages
# ------------------------------------------------------------

log "Installing system packages"

sudo apt update

sudo apt install -y \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    make \
    cmake \
    clang-format \
    gcc-arm-none-eabi \
    direnv \
    procps \
    file \
    unzip \
    zip \
    jq \
    ripgrep \
    fd-find

success "System packages installed"

# ------------------------------------------------------------
# 3. Homebrew
# ------------------------------------------------------------

log "Installing Homebrew"

HOMEBREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

if [ -x "$HOMEBREW_BIN" ]; then
    eval "$("$HOMEBREW_BIN" shellenv)"
    brew update
    success "Homebrew updated: $(brew --version | head -n 1)"
else
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    eval "$("$HOMEBREW_BIN" shellenv)"
    success "Homebrew installed"
fi

append_once 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$HOME/.bashrc"


# ------------------------------------------------------------
# 4. Git
# ------------------------------------------------------------

log "Checking Git"

git --version

success "Git installed"


# ------------------------------------------------------------
# 5. lazygit
# ------------------------------------------------------------

log "Installing lazygit"

if command_exists lazygit; then
    success "lazygit already installed: $(lazygit --version)"
elif apt-cache show lazygit >/dev/null 2>&1 && sudo apt install -y lazygit; then
    success "lazygit installed with apt"
else
    warn "lazygit could not be installed with apt; falling back to Homebrew"
    brew install lazygit
    success "lazygit installed with Homebrew"
fi


# ------------------------------------------------------------
# 6. User shell configuration
# ------------------------------------------------------------

log "Configuring user binary directory"

mkdir -p "$HOME/.local/bin"

append_once 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"

export PATH="$HOME/.local/bin:$PATH"

success "~/.local/bin configured"

log "Configuring case-insensitive completion"

append_once 'set completion-ignore-case on' "$HOME/.inputrc"

success "~/.inputrc configured"


# ------------------------------------------------------------
# 7. Starship
# ------------------------------------------------------------

log "Installing Starship"

if command_exists starship; then
    success "Starship already installed: $(starship --version)"
else
    curl -sS https://starship.rs/install.sh \
        | sh -s -- -y -b "$HOME/.local/bin"

    success "Starship installed"
fi

append_once 'eval "$(starship init bash)"' "$HOME/.bashrc"


# ------------------------------------------------------------
# 8. uv
# ------------------------------------------------------------

log "Installing uv"

if command_exists uv; then
    success "uv already installed: $(uv --version)"
else
    curl -LsSf https://astral.sh/uv/install.sh | sh

    export PATH="$HOME/.local/bin:$PATH"

    success "uv installed"
fi


# ------------------------------------------------------------
# 9. Python
# ------------------------------------------------------------

log "Installing Python ${PYTHON_VERSION}"

uv python install "$PYTHON_VERSION"

success "Python installed"

uv python list --only-installed


# ------------------------------------------------------------
# 10. nvm
# ------------------------------------------------------------

log "Installing nvm"

export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    success "nvm already installed"
else
    curl -o- \
        https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh \
        | bash

    success "nvm installed"
fi

append_unless_active_line_contains \
    'export NVM_DIR="$HOME/.nvm"' \
    'export NVM_DIR="$HOME/.nvm"' \
    "$HOME/.bashrc"

append_unless_active_line_contains \
    '"$NVM_DIR/nvm.sh"' \
    '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' \
    "$HOME/.bashrc"

append_unless_active_line_contains \
    '"$NVM_DIR/bash_completion"' \
    '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' \
    "$HOME/.bashrc"

# Load nvm in this script
# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"


# ------------------------------------------------------------
# 11. Node.js
# ------------------------------------------------------------

log "Installing Node.js ${NODE_VERSION}"

nvm install "$NODE_VERSION"

nvm alias default "$NODE_VERSION"

nvm use default

success "Node.js installed: $(node --version)"
success "npm installed: $(npm --version)"


# ------------------------------------------------------------
# 12. Codex CLI
# ------------------------------------------------------------

log "Installing Codex CLI"

if command_exists codex; then
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
    success "Codex updated"
else
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
    success "Codex installed"
fi


# ------------------------------------------------------------
# 13. Verification
# ------------------------------------------------------------

log "Development environment summary"

printf '\n'

printf "Git:       "
git --version

printf "Homebrew:  "
brew --version | head -n 1

printf "lazygit:   "
lazygit --version

printf "Starship:  "
starship --version

printf "uv:        "
uv --version

printf "Python:    "
uv run python --version

printf "Node.js:   "
node --version

printf "npm:       "
npm --version

printf "Codex:     "
codex --version


# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

printf '\n'
success "WSL development environment setup completed."

printf '\n'
echo "Restart your terminal or run:"
echo
echo "    source ~/.bashrc"
echo
echo "Then authenticate Codex with:"
echo
echo "    codex"
echo
