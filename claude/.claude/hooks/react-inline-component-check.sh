#!/usr/bin/env bash
# Hook: PostToolUse - React Inline Component Detection
#
# Detects inline component definitions in page files that should be extracted
# to shared components. This catches the pattern that leads to duplicate UI code.
#
# Triggers on: app/**/*.tsx (Next.js page files)
#
# Detection rules:
# 1. If a page file has more than 2 function components, warn
# 2. Specifically flag functions that look like UI components (return JSX)

set -euo pipefail

TOOL_NAME="${CLAUDE_HOOK_TOOL_NAME:-}"
EDITED_FILE="${CLAUDE_HOOK_TOOL_ARGS_file_path:-}"

# Only run after Edit or Write tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Skip if no file path
if [[ -z "$EDITED_FILE" ]]; then
  exit 0
fi

# Only check Next.js page files (app directory)
if [[ ! "$EDITED_FILE" =~ /app/.*\.tsx$ ]]; then
  exit 0
fi

# Skip layout files (they legitimately have wrapper components)
if [[ "$EDITED_FILE" =~ layout\.tsx$ ]]; then
  exit 0
fi

# Count function components in the file
# Look for: function ComponentName( or const ComponentName = (
# Filter to PascalCase names (React components)
COMPONENT_COUNT=$(grep -E '^(export )?(async )?function [A-Z][a-zA-Z]+\(' "$EDITED_FILE" 2>/dev/null | wc -l || echo 0)
CONST_COMPONENT_COUNT=$(grep -E '^(export )?const [A-Z][a-zA-Z]+ = ' "$EDITED_FILE" 2>/dev/null | wc -l || echo 0)

TOTAL=$((COMPONENT_COUNT + CONST_COMPONENT_COUNT))

# Pages typically have 1 default export component
# More than 2 suggests inline components that should be extracted
if [[ $TOTAL -gt 2 ]]; then
  echo ""
  echo "⚠️  [React Composition] Found $TOTAL component definitions in page file"
  echo "   File: $EDITED_FILE"
  echo ""
  echo "   Page files should primarily contain the page component."
  echo "   Consider extracting helper components to:"
  echo "   - components/   (for reusable UI)"
  echo "   - Same folder as private component (ComponentName.tsx)"
  echo ""
  echo "   Review with: /react-composition-review"
  echo ""
  # Don't fail - just warn
fi

exit 0
