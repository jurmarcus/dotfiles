#!/usr/bin/env bash
set -euo pipefail

GIT_INFO_FILE="${HOME}/Documents/keys/git_info"

NAME="${GIT_AUTHOR_NAME:-}"
EMAIL="${GIT_AUTHOR_EMAIL:-}"

if [[ -z "$NAME" || -z "$EMAIL" ]]; then
  if [[ -f "$GIT_INFO_FILE" ]]; then
    source "$GIT_INFO_FILE"
    NAME="${GIT_AUTHOR_NAME:-$NAME}"
    EMAIL="${GIT_AUTHOR_EMAIL:-$EMAIL}"
    echo "  Using identity from $GIT_INFO_FILE"
  fi
fi

if [[ -z "$NAME" ]]; then
  existing=$(git config --global user.name 2>/dev/null || true)
  read -rp "  Git author name [${existing:-}]: " NAME
  NAME="${NAME:-$existing}"
fi

if [[ -z "$EMAIL" ]]; then
  existing=$(git config --global user.email 2>/dev/null || true)
  read -rp "  Git author email [${existing:-}]: " EMAIL
  EMAIL="${EMAIL:-$existing}"
fi

if [[ -z "$NAME" || -z "$EMAIL" ]]; then
  echo "  Error: Name and email are required"
  exit 1
fi

git config --global user.name "${NAME}"
git config --global user.email "${EMAIL}"

git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global fetch.prune true
git config --global diff.algorithm histogram
git config --global merge.conflictstyle zdiff3
git config --global rerere.enabled true

if command -v delta &>/dev/null; then
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.line-numbers true
  git config --global delta.side-by-side true
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  git config --global credential.helper osxkeychain
fi

if command -v sl &>/dev/null; then
  sl config --user ui.username "${NAME} <${EMAIL}>"
fi

if command -v gh &>/dev/null; then
  gh config set -h github.com git_protocol https
fi

echo "  VCS identity configured:"
echo "    Name:  ${NAME}"
echo "    Email: ${EMAIL}"
