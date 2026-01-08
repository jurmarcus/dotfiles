#!/usr/bin/env bash
# Hook: PostToolUse - Unified LSP Check
#
# Runs after Edit/Write tools to catch type errors immediately.
# Supports: TypeScript, Python, Rust
# Detects language by file extension and validates project markers.

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

# Find project root (check current dir, then parent)
find_project_root() {
  local marker="$1"
  if [[ -f "$marker" ]]; then
    echo "."
  elif [[ -f "../$marker" ]]; then
    echo ".."
  else
    echo ""
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# TypeScript / JavaScript
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$EDITED_FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
  PROJECT_ROOT=$(find_project_root "tsconfig.json")
  [[ -z "$PROJECT_ROOT" ]] && exit 0

  echo "🔍 Running TypeScript check..."
  cd "$PROJECT_ROOT"

  if ! bunx tsc --noEmit --pretty 2>&1 | head -30; then
    echo ""
    echo "❌ TypeScript errors detected"
    echo "Run: bunx tsc --noEmit"
    exit 1
  fi

  echo "✅ TypeScript check passed"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Python
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$EDITED_FILE" =~ \.py$ ]]; then
  # Check for pyproject.toml or setup.py
  if [[ -f "pyproject.toml" || -f "setup.py" ]]; then
    PROJECT_ROOT="."
  elif [[ -f "../pyproject.toml" || -f "../setup.py" ]]; then
    PROJECT_ROOT=".."
  else
    exit 0
  fi

  echo "🔍 Running Python type check..."
  cd "$PROJECT_ROOT"

  if command -v uvx &> /dev/null; then
    if ! uvx ty check 2>&1 | head -30; then
      echo "❌ Python type errors detected"
      echo "Run: uvx ty check"
      exit 1
    fi
  else
    echo "⚠️  uvx not found"
    exit 0
  fi

  echo "✅ Python type check passed"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Rust
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$EDITED_FILE" =~ \.rs$ ]]; then
  PROJECT_ROOT=$(find_project_root "Cargo.toml")
  [[ -z "$PROJECT_ROOT" ]] && exit 0

  echo "🔍 Running Rust check..."
  cd "$PROJECT_ROOT"

  if ! cargo check --all-targets --message-format=short 2>&1 | head -50; then
    echo ""
    echo "❌ Rust errors detected"
    echo "Run: cargo check --all-targets"
    exit 1
  fi

  echo "✅ Rust check passed"
  exit 0
fi

# No matching language - silently exit
exit 0
