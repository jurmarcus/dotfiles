#!/usr/bin/env bash
# Hook: PostToolUse - Format On Edit
#
# Auto-format files after editing using project-specific formatters.
# Runs formatters in-place so next read shows formatted code.

set -euo pipefail

TOOL_NAME="${CLAUDE_HOOK_TOOL_NAME:-}"
EDITED_FILE="${CLAUDE_HOOK_TOOL_ARGS_file_path:-}"

# Only run after Edit/Write tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Skip if no file path
if [[ -z "$EDITED_FILE" || ! -f "$EDITED_FILE" ]]; then
  exit 0
fi

echo "🎨 Auto-formatting $EDITED_FILE..."

# TypeScript/JavaScript (Prettier)
if [[ "$EDITED_FILE" =~ \.(ts|tsx|js|jsx|json|md|yaml|yml)$ ]]; then
  if command -v bunx &> /dev/null && [[ -f "package.json" ]]; then
    if bunx prettier --write "$EDITED_FILE" 2>&1 | grep -v "unchanged"; then
      echo "  ✓ Formatted with Prettier"
    fi
  fi
fi

# Rust (rustfmt)
if [[ "$EDITED_FILE" =~ \.rs$ ]]; then
  if command -v rustfmt &> /dev/null; then
    if rustfmt "$EDITED_FILE" 2>&1; then
      echo "  ✓ Formatted with rustfmt"
    fi
  fi
fi

# Python (ruff format or black)
if [[ "$EDITED_FILE" =~ \.py$ ]]; then
  # Try ruff first (faster)
  if command -v uvx &> /dev/null; then
    if uvx ruff format "$EDITED_FILE" 2>&1 | grep -v "unchanged"; then
      echo "  ✓ Formatted with ruff"
    fi
  elif command -v ruff &> /dev/null; then
    if ruff format "$EDITED_FILE" 2>&1 | grep -v "unchanged"; then
      echo "  ✓ Formatted with ruff"
    fi
  elif command -v black &> /dev/null; then
    if black "$EDITED_FILE" 2>&1 | grep "reformatted"; then
      echo "  ✓ Formatted with black"
    fi
  fi
fi

exit 0
