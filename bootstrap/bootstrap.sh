#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"
BOOTSTRAP_DIR="${DOTFILES_DIR}/bootstrap"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

step() { echo -e "\n${BLUE}>> $1${NC}"; }
ok() { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}! $1${NC}"; }

# Step 1: Xcode CLI Tools
step "Step 1: Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "Already installed"
else
  xcode-select --install || true
  warn "Complete the GUI prompt, then re-run this script"
  exit 1
fi

# Step 2: Homebrew
step "Step 2: Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "Already installed"
else
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Installed"
fi

# Ensure brew is in PATH
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Step 3: Stow + dotfiles
step "Step 3: Stow dotfiles"
command -v stow >/dev/null 2>&1 || brew install stow
pushd "${DOTFILES_DIR}" >/dev/null
shopt -s nullglob
for d in */; do
  d="${d%/}"
  case "$d" in
    .git*|scripts*|bin*|images*|docs*|.github*|private*|bootstrap* ) continue ;;
  esac
  echo "  Stowing: $d"
  stow --target="${HOME}" "$d" 2>/dev/null || stow --target="${HOME}" -R "$d"
done
popd >/dev/null
ok "All packages stowed"

# Step 4: Homebrew packages
step "Step 4: Homebrew packages"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_ANALYTICS=1
brew bundle --global
ok "Packages installed"

# Step 5: macOS settings
step "Step 5: macOS settings"
if [[ "$(uname -s)" == "Darwin" && -f "${BOOTSTRAP_DIR}/macos.sh" ]]; then
  bash "${BOOTSTRAP_DIR}/macos.sh"
  ok "Applied"
else
  warn "Skipped"
fi

# Step 6: VSCodium extensions
step "Step 6: VSCodium extensions"
if command -v codium >/dev/null 2>&1 && [[ -f "${BOOTSTRAP_DIR}/vscodium.sh" ]]; then
  bash "${BOOTSTRAP_DIR}/vscodium.sh"
  ok "Installed"
else
  warn "Skipped"
fi

echo -e "\n${GREEN}✅ Bootstrap complete!${NC}"
echo "Open a new shell for changes to take effect."
