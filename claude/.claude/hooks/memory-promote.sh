#!/usr/bin/env bash
# Hook: SessionEnd - Memory Promotion Reminder
#
# Checks if any memories were written to project scopes this session
# that look like they should be global (type: user, type: feedback about style).

set -euo pipefail

GLOBAL_MEMORY="$HOME/.claude/memory"

# Skip if no global memory dir
[ -d "$GLOBAL_MEMORY" ] || exit 0

# Find project memory files modified in the last 2 hours
RECENT_MEMORIES=$(find "$HOME/.claude/projects"/*/memory -name "*.md" -mmin -120 ! -name "MEMORY.md" 2>/dev/null || true)

if [ -z "$RECENT_MEMORIES" ]; then
  exit 0
fi

# Check each for type: user or cross-project feedback
PROMOTE_CANDIDATES=""
while IFS= read -r file; do
  [ -f "$file" ] || continue
  TYPE=$(head -10 "$file" | grep "^type:" | head -1 | sed 's/type: *//')
  if [ "$TYPE" = "user" ]; then
    PROMOTE_CANDIDATES="$PROMOTE_CANDIDATES\n  → $file (type: user)"
  fi
done <<< "$RECENT_MEMORIES"

if [ -n "$PROMOTE_CANDIDATES" ]; then
  echo ""
  echo "🧠 Memory Sync"
  echo "  Recent project memories that may belong in global (~/.claude/memory/):"
  echo -e "$PROMOTE_CANDIDATES"
  echo "  Run /memory-sync to promote them."
fi

exit 0
