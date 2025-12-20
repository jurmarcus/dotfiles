#!/usr/bin/env bash
set -euo pipefail

# Check if git identity is already configured
current_name=$(git config --global user.name 2>/dev/null || true)
current_email=$(git config --global user.email 2>/dev/null || true)

if [[ -n "${current_name}" && -n "${current_email}" ]]; then
  echo "  Git identity already configured:"
  echo "    Name:  ${current_name}"
  echo "    Email: ${current_email}"
  read -rp "  Overwrite? [y/N] " overwrite
  [[ "${overwrite}" != "y" && "${overwrite}" != "Y" ]] && exit 0
fi

# Prompt for identity
read -rp "  Enter your name: " name
read -rp "  Enter your email: " email

# Set git identity
git config --global user.name "${name}"
git config --global user.email "${email}"

# Set useful defaults
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global fetch.prune true
git config --global diff.algorithm histogram
git config --global merge.conflictstyle zdiff3
git config --global rerere.enabled true

# Use delta if available (should be installed via brew)
if command -v delta &>/dev/null; then
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.line-numbers true
  git config --global delta.side-by-side true
fi

# macOS-specific: use Keychain for credentials
if [[ "$(uname -s)" == "Darwin" ]]; then
  git config --global credential.helper osxkeychain
fi

echo "  Git configured:"
echo "    Name:  $(git config --global user.name)"
echo "    Email: $(git config --global user.email)"
