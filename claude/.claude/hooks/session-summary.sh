#!/usr/bin/env bash
# Hook: SessionEnd - Session Summary
#
# Provides a summary of changes made during the session and reminds
# about documentation updates, pending TODOs, and uncommitted changes.

set -euo pipefail

echo ""
echo "📊 Session Summary"
echo "════════════════════════════════════════════════════════════════"

# Check if in a Sapling repo
if ! sl root > /dev/null 2>&1; then
  echo "Not in a Sapling repository"
  exit 0
fi

# Show modified files
MODIFIED=$(sl status 2>/dev/null | grep "^M" | wc -l | tr -d ' ')
ADDED=$(sl status 2>/dev/null | grep "^A" | wc -l | tr -d ' ')
UNTRACKED=$(sl status 2>/dev/null | grep "^?" | wc -l | tr -d ' ')

echo ""
echo "📝 File Changes:"
if [[ $MODIFIED -gt 0 ]]; then
  echo "  • $MODIFIED modified files"
fi
if [[ $ADDED -gt 0 ]]; then
  echo "  • $ADDED staged files"
fi
if [[ $UNTRACKED -gt 0 ]]; then
  echo "  • $UNTRACKED untracked files"
fi

# Show recently modified files (last 30 minutes)
echo ""
echo "📂 Recently Edited:"
find . -type f -mmin -30 ! -path "*/.*" ! -path "*/node_modules/*" ! -path "*/target/*" 2>/dev/null | head -10 | while read -r file; do
  echo "  • $file"
done

# Check for TODO/FIXME comments in modified files
echo ""
echo "📌 TODO Comments:"
TODO_FILES=$(sl status --no-status -man 2>/dev/null | xargs grep -l "TODO\|FIXME\|XXX\|HACK" 2>/dev/null | head -5)
if [[ -n "$TODO_FILES" ]]; then
  echo "$TODO_FILES" | while read -r file; do
    COUNT=$(grep -c "TODO\|FIXME\|XXX\|HACK" "$file" 2>/dev/null || true)
    echo "  • $file ($COUNT items)"
  done
else
  echo "  ✓ No new TODOs"
fi

# Remind about documentation
echo ""
echo "📚 Documentation Reminders:"
if sl status --no-status -man 2>/dev/null | grep -q "src/\|lib/\|components/"; then
  if ! sl status --no-status -man 2>/dev/null | grep -q "CLAUDE.md\|README.md"; then
    echo "  ⚠️  Code changed but no documentation updates"
    echo "  Consider updating:"
    echo "    - CLAUDE.md (architecture/patterns)"
    echo "    - README.md (user-facing changes)"
  else
    echo "  ✓ Documentation updated"
  fi
fi

# Check for uncommitted changes
echo ""
if [[ -z "$(sl status --no-status -man 2>/dev/null)" ]]; then
  echo "✅ All changes committed"
else
  echo "⚠️  Uncommitted changes detected"
  echo ""
  echo "Next steps:"
  echo "  • Review: sl status"
  echo "  • Add/remove: sl addremove"
  echo "  • Commit: sl commit -m \"message\""
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
exit 0
