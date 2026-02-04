#!/usr/bin/env bash
# Hook: PreToolUse - Enforce Sapling VCS
#
# Blocks git commands in favor of Sapling (sl).
# Provides helpful suggestions for the correct command.

set -euo pipefail

TOOL_NAME="${CLAUDE_HOOK_TOOL_NAME:-}"
COMMAND="${CLAUDE_HOOK_TOOL_ARGS_command:-}"

# Only check Bash commands
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# Skip empty commands
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Block git commands (but not commands that just mention git, like "is this a git repo")
if [[ "$COMMAND" =~ ^[[:space:]]*(git)[[:space:]]+ ]]; then
  echo "❌ Use sl (Sapling) instead of git"
  echo ""
  echo "Suggested replacements:"
  echo "  git status       → sl status"
  echo "  git diff         → sl diff"
  echo "  git add          → sl addremove"
  echo "  git commit       → sl commit"
  echo "  git push         → sl push"
  echo "  git pull         → sl pull --rebase"
  echo "  git log          → sl log"
  echo "  git checkout     → sl goto"
  echo "  git branch       → sl bookmark"
  echo "  git stash        → sl shelve"
  exit 1
fi

exit 0
