#!/usr/bin/env bash
set -euo pipefail

# Claude Code setup - creates symlinks for synced directories

NOTES_PLANS="${HOME}/Notes/plans/claude"
CLAUDE_PLANS="${HOME}/.claude/plans"

# Symlink ~/.claude/plans -> ~/Notes/plans/claude
if [[ -d "$NOTES_PLANS" ]]; then
  if [[ -L "$CLAUDE_PLANS" ]]; then
    echo "  ~/.claude/plans already symlinked"
  elif [[ -d "$CLAUDE_PLANS" ]]; then
    if [[ -z "$(ls -A "$CLAUDE_PLANS")" ]]; then
      rmdir "$CLAUDE_PLANS"
      ln -s "$NOTES_PLANS" "$CLAUDE_PLANS"
      echo "  Linked ~/.claude/plans -> ~/Notes/plans"
    else
      echo "  Warning: ~/.claude/plans exists and is not empty"
      echo "  Move contents to ~/Notes/plans/current/ and re-run"
    fi
  else
    mkdir -p "${HOME}/.claude"
    ln -s "$NOTES_PLANS" "$CLAUDE_PLANS"
    echo "  Linked ~/.claude/plans -> ~/Notes/plans"
  fi
else
  echo "  Skipped: ~/Notes/plans does not exist"
fi
