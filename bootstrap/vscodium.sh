#!/usr/bin/env bash
set -e

# VSCodium Extensions
EXTENSIONS=(
  # AI Coding Assistants
  anthropic.claude-code

  # Themes & Icons
  catppuccin.catppuccin-vsc
  catppuccin.catppuccin-vsc-icons

  # Productivity
  pedro-bronsveld.anki-editor
)

for ext in "${EXTENSIONS[@]}"; do
  [[ "$ext" =~ ^# ]] && continue
  echo "  Installing: $ext"
  codium --install-extension "$ext" --force 2>/dev/null || true
done
