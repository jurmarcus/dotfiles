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

# Flags
DRY_RUN=false
VERBOSE=false

step() { echo -e "\n${BLUE}>> $1${NC}"; }
ok() { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}! $1${NC}"; }
skip() { echo -e "${YELLOW}  Skipped${NC}"; }

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[dry-run]${NC} $*"
  else
    "$@"
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Bootstrap a new macOS machine with dotfiles.

OPTIONS:
    -h, --help      Show this help message
    -n, --dry-run   Show what would be done without doing it
    -v, --verbose   Enable verbose output

STEPS:
    1. Xcode Command Line Tools
    2. Homebrew (+ PATH setup)
    3. Stow (install + symlink dotfiles)
    4. Brew bundle (remaining packages)
    5. Git identity
    6. macOS settings
    7. Default applications (duti)
    8. VSCodium extensions

EXAMPLES:
    $(basename "$0")              # Full bootstrap
    $(basename "$0") --dry-run    # Preview changes
EOF
}

cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo -e "\n${RED}Bootstrap failed at step. Check output above.${NC}"
  fi
  exit $exit_code
}

trap cleanup EXIT

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -n|--dry-run) DRY_RUN=true; shift ;;
    -v|--verbose) VERBOSE=true; set -x; shift ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${YELLOW}Running in dry-run mode. No changes will be made.${NC}"
fi

# Step 1: Xcode CLI Tools
step "Step 1: Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "Already installed"
else
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[dry-run]${NC} Would install Xcode CLI Tools"
  else
    xcode-select --install || true
    warn "Complete the GUI prompt, then re-run this script"
    exit 1
  fi
fi

# Step 2: Homebrew (+ PATH setup for this script)
step "Step 2: Homebrew"
if [[ -x /opt/homebrew/bin/brew ]] || [[ -x /usr/local/bin/brew ]]; then
  ok "Already installed"
else
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[dry-run]${NC} Would install Homebrew"
  else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ok "Installed"
  fi
fi

# Add brew to PATH for this script (dotfiles not stowed yet, can't rely on .zshrc)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Step 3: Install stow (if needed) + symlink dotfiles
step "Step 3: Install stow + symlink dotfiles"
command -v stow >/dev/null 2>&1 || run brew install stow
pushd "${DOTFILES_DIR}" >/dev/null
shopt -s nullglob
for d in */; do
  d="${d%/}"
  case "$d" in
    .git*|scripts*|bin*|images*|docs*|.github*|private*|bootstrap* ) continue ;;
  esac
  echo "  Stowing: $d"
  if [[ "$DRY_RUN" == "true" ]]; then
    stow --simulate --target="${HOME}" "$d" 2>/dev/null || stow --simulate --target="${HOME}" -R "$d"
  else
    stow --target="${HOME}" "$d" 2>/dev/null || stow --target="${HOME}" -R "$d"
  fi
done
popd >/dev/null
ok "All packages stowed"

# Step 4: Remaining Homebrew packages (stow already installed above)
step "Step 4: Homebrew packages"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_ANALYTICS=1
if brew bundle check --global >/dev/null 2>&1; then
  ok "All packages already installed"
else
  run brew bundle --global
  ok "Packages installed"
fi

# Step 5: Git identity
step "Step 5: Git identity"
if [[ -f "${BOOTSTRAP_DIR}/git.sh" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[dry-run]${NC} Would configure git identity"
  else
    bash "${BOOTSTRAP_DIR}/git.sh"
  fi
  ok "Git configured"
else
  skip
fi

# Step 6: macOS settings
step "Step 6: macOS settings"
if [[ "$(uname -s)" == "Darwin" && -f "${BOOTSTRAP_DIR}/macos.sh" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[dry-run]${NC} Would apply macOS settings"
  else
    bash "${BOOTSTRAP_DIR}/macos.sh"
  fi
  ok "Applied"
else
  skip
fi

# Step 7: Default applications (duti)
step "Step 7: Default applications"
if [[ "$(uname -s)" == "Darwin" && -f "${BOOTSTRAP_DIR}/duti.sh" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[dry-run]${NC} Would configure default applications"
  else
    bash "${BOOTSTRAP_DIR}/duti.sh"
  fi
  ok "Configured"
else
  skip
fi

# Step 8: VSCodium extensions
step "Step 8: VSCodium extensions"
if command -v codium >/dev/null 2>&1 && [[ -f "${BOOTSTRAP_DIR}/vscodium.sh" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[dry-run]${NC} Would install VSCodium extensions"
  else
    bash "${BOOTSTRAP_DIR}/vscodium.sh"
  fi
  ok "Installed"
else
  skip
fi

echo -e "\n${GREEN}✅ Bootstrap complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal for shell changes"
echo "  2. Log out/in for some macOS settings to take effect"
echo ""
