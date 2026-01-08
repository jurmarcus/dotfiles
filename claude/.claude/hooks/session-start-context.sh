#!/usr/bin/env bash
# Hook: SessionStart - Load Project Context
#
# Primes Claude with relevant context at session start:
# 1. Project CLAUDE.md (if exists)
# 2. Recent/matching plan files from ~/plans/
# 3. Active TODO files

set -euo pipefail

echo "📚 Loading project context..."

# Get current directory name for matching
PROJECT_NAME=$(basename "$PWD")
PLANS_DIR="$HOME/plans"

# ─────────────────────────────────────────────────────────────────────────────
# 1. Project CLAUDE.md
# ─────────────────────────────────────────────────────────────────────────────
if [[ -f "CLAUDE.md" ]]; then
  echo "  ✓ Found project CLAUDE.md"
fi

if [[ -f ".claude/CLAUDE.md" ]]; then
  echo "  ✓ Found .claude/CLAUDE.md"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 2. Plan files (matching project name or recently modified)
# ─────────────────────────────────────────────────────────────────────────────
if [[ -d "$PLANS_DIR" ]]; then
  # Find plans matching project name
  MATCHING_PLANS=$(find "$PLANS_DIR" -maxdepth 2 -name "*.md" -type f 2>/dev/null | xargs grep -l -i "$PROJECT_NAME" 2>/dev/null | head -3)

  if [[ -n "$MATCHING_PLANS" ]]; then
    echo "  ✓ Found plans mentioning '$PROJECT_NAME':"
    echo "$MATCHING_PLANS" | while read -r plan; do
      echo "    → $(basename "$plan")"
    done
  fi

  # Find recently modified plans (last 24 hours)
  RECENT_PLANS=$(find "$PLANS_DIR" -maxdepth 2 -name "*.md" -type f -mtime -1 2>/dev/null | head -3)

  if [[ -n "$RECENT_PLANS" ]]; then
    echo "  ✓ Recent plans (last 24h):"
    echo "$RECENT_PLANS" | while read -r plan; do
      echo "    → $(basename "$plan")"
    done
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 3. Active plan in ~/.claude/plans/ for this project
# ─────────────────────────────────────────────────────────────────────────────
CLAUDE_PLANS="$HOME/.claude/plans"
if [[ -d "$CLAUDE_PLANS" ]]; then
  # Find plans modified in last 7 days
  ACTIVE_CLAUDE_PLANS=$(find "$CLAUDE_PLANS" -name "*.md" -type f -mtime -7 2>/dev/null | head -3)

  if [[ -n "$ACTIVE_CLAUDE_PLANS" ]]; then
    echo "  ✓ Active Claude plans:"
    echo "$ACTIVE_CLAUDE_PLANS" | while read -r plan; do
      # Show first line (title) of each plan
      TITLE=$(head -1 "$plan" | sed 's/^#* *//')
      echo "    → $TITLE"
    done
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 4. Check for TODO.md or active tasks
# ─────────────────────────────────────────────────────────────────────────────
if [[ -f "TODO.md" ]]; then
  PENDING=$(grep -c "^\s*- \[ \]" TODO.md 2>/dev/null || echo "0")
  echo "  ✓ Found TODO.md ($PENDING pending tasks)"
fi

echo ""
echo "💡 Tip: Use '/plan' to view or create implementation plans"
exit 0
