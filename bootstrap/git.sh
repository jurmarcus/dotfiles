#!/usr/bin/env bash
set -euo pipefail

NAME="jurmarcus"
EMAIL="me@jurmarcus.com"

# Git identity
git config --global user.name "${NAME}"
git config --global user.email "${EMAIL}"

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

# Sapling identity
if command -v sl &>/dev/null; then
  sl config --user ui.username "${NAME} <${EMAIL}>"
fi

# GitHub CLI
if command -v gh &>/dev/null; then
  gh config set -h github.com git_protocol https
fi

echo "  VCS identity configured:"
echo "    Name:  ${NAME}"
echo "    Email: ${EMAIL}"
