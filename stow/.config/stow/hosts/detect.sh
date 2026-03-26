#!/usr/bin/env bash
# Detect hostname and load stow package list from host conf file.
#
# Usage:
#   source detect.sh
#   _detect_stow_host
#   # Now STOW_HOST and STOW_PACKAGES are set
#
# Supports HOST_OVERRIDE env var for testing:
#   HOST_OVERRIDE=methylene-macbook restow

_detect_stow_host() {
  local host="${HOST_OVERRIDE:-$(hostname -s)}"
  host=$(echo "$host" | tr '[:upper:]' '[:lower:]')

  # Resolve hosts dir relative to this script (works in bash and zsh, via symlink or source tree)
  local hosts_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    hosts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  elif [[ -n "${(%):-%x}" ]]; then
    hosts_dir="$(cd "$(dirname "${(%):-%x}")" && pwd)"
  else
    hosts_dir="${DOTFILES:-$HOME/dotfiles}/stow/.config/stow/hosts"
  fi
  local host_file="$hosts_dir/$host.conf"

  STOW_HOST="$host"
  STOW_PACKAGES=()

  if [[ -f "$host_file" ]]; then
    while IFS= read -r line; do
      line="${line%%#*}"          # strip comments
      line="${line//[[:space:]]/}" # strip whitespace
      [[ -n "$line" ]] && STOW_PACKAGES+=("$line")
    done < "$host_file"
  else
    echo "⚠️  No stow host file for '$host' — stowing all packages"
    local d
    for d in "${DOTFILES:-$HOME/dotfiles}"/*/; do
      d="${d%/}"; d="${d##*/}"
      case "$d" in
        .git*|scripts*|bin*|images*|docs*|.github*|private*|bootstrap*) continue ;;
      esac
      STOW_PACKAGES+=("$d")
    done
  fi
}
