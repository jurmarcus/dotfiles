#!/usr/bin/env bash
# Hook: PostToolUse - Test After Edit
#
# Runs relevant tests after code changes to catch regressions immediately.
# Smart targeting: uses --findRelatedTests, module paths, or specific test files.

set -euo pipefail

TOOL_NAME="${CLAUDE_HOOK_TOOL_NAME:-}"
EDITED_FILE="${CLAUDE_HOOK_TOOL_ARGS_file_path:-}"

# Only run after Edit/Write tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Skip if no file path
if [[ -z "$EDITED_FILE" ]]; then
  exit 0
fi

# Skip test files themselves (avoid infinite loops)
if [[ "$EDITED_FILE" =~ (test_|_test\.|\.test\.|\.spec\.) ]]; then
  echo "📝 Test file modified - skipping auto-test"
  exit 0
fi

# Skip non-code files
if [[ ! "$EDITED_FILE" =~ \.(ts|tsx|js|jsx|rs|py)$ ]]; then
  exit 0
fi

echo "🧪 Running targeted tests..."

# ─────────────────────────────────────────────────────────────────────────────
# TypeScript/JavaScript
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$EDITED_FILE" =~ \.(ts|tsx|js|jsx)$ ]] && [[ -f "package.json" ]]; then
  # Detect test runner (prefer bun's built-in, then vitest, then jest)
  TEST_RUNNER=""
  if grep -q '"bun-types"' package.json 2>/dev/null || [[ -f "bunfig.toml" ]]; then
    TEST_RUNNER="bun"
  elif grep -q '"vitest"' package.json 2>/dev/null; then
    TEST_RUNNER="vitest"
  elif grep -q '"jest"' package.json 2>/dev/null; then
    TEST_RUNNER="jest"
  fi

  # Default to bun test if no specific runner detected
  if [[ -z "$TEST_RUNNER" ]]; then
    TEST_RUNNER="bun"
  fi

  if [[ "$TEST_RUNNER" == "bun" ]]; then
    echo "  Running: bun test"
    if ! bun test 2>&1 | tail -20; then
      echo "⚠️  Tests failed"
      exit 1
    fi
  elif [[ "$TEST_RUNNER" == "vitest" ]]; then
    echo "  Running: bunx vitest related $EDITED_FILE --run"
    if ! bunx vitest related "$EDITED_FILE" --run --passWithNoTests 2>&1 | tail -20; then
      echo "⚠️  Tests failed"
      exit 1
    fi
  elif [[ "$TEST_RUNNER" == "jest" ]]; then
    echo "  Running: bunx jest --findRelatedTests $EDITED_FILE"
    if ! bunx jest --findRelatedTests "$EDITED_FILE" --passWithNoTests 2>&1 | tail -20; then
      echo "⚠️  Tests failed"
      exit 1
    fi
  fi

  echo "✅ Tests passed"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Rust
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$EDITED_FILE" =~ \.rs$ ]] && [[ -f "Cargo.toml" ]]; then
  # Convert file path to module path for targeted testing
  # e.g., src/analyzer/mod.rs -> analyzer
  # e.g., src/lib.rs -> (run all)
  # e.g., src/utils/helper.rs -> utils::helper

  # Remove src/ prefix and .rs suffix
  MODULE_PATH="${EDITED_FILE#src/}"
  MODULE_PATH="${MODULE_PATH%.rs}"

  # Convert / to :: and remove /mod
  MODULE_PATH="${MODULE_PATH//\/mod/}"
  MODULE_PATH="${MODULE_PATH//\//:}"

  # Handle lib.rs and main.rs (run all tests)
  if [[ "$MODULE_PATH" == "lib" || "$MODULE_PATH" == "main" ]]; then
    echo "  Running: cargo test (all tests)"
    if ! cargo test --quiet 2>&1 | tail -30; then
      echo "⚠️  Tests failed"
      exit 1
    fi
  else
    echo "  Running: cargo test $MODULE_PATH"
    if ! cargo test "$MODULE_PATH" --quiet 2>&1 | tail -30; then
      echo "⚠️  Tests failed"
      exit 1
    fi
  fi

  echo "✅ Tests passed"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Python
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$EDITED_FILE" =~ \.py$ ]] && [[ -f "pyproject.toml" ]]; then
  DIR=$(dirname "$EDITED_FILE")
  BASE=$(basename "$EDITED_FILE" .py)

  # Try to find corresponding test file
  TEST_FILE=""
  for pattern in \
    "tests/test_${BASE}.py" \
    "test/test_${BASE}.py" \
    "${DIR}/test_${BASE}.py" \
    "${DIR}/tests/test_${BASE}.py" \
    "tests/${DIR}/test_${BASE}.py"; do
    if [[ -f "$pattern" ]]; then
      TEST_FILE="$pattern"
      break
    fi
  done

  # Use uv run pytest
  if ! command -v uv &> /dev/null; then
    echo "  ⚠️  uv not found"
    exit 0
  fi
  RUNNER="uv run pytest"

  if [[ -n "$TEST_FILE" ]]; then
    echo "  Running: $RUNNER $TEST_FILE -v"
    if ! $RUNNER "$TEST_FILE" -v 2>&1 | tail -30; then
      echo "⚠️  Tests failed"
      exit 1
    fi
  else
    # No specific test file - run tests in same directory or related
    if [[ -d "tests" ]]; then
      echo "  Running: $RUNNER tests/ -v --tb=short"
      if ! $RUNNER tests/ -v --tb=short 2>&1 | tail -30; then
        echo "⚠️  Tests failed"
        exit 1
      fi
    else
      echo "  ⚠️  No test file found for $EDITED_FILE"
      exit 0
    fi
  fi

  echo "✅ Tests passed"
  exit 0
fi

# No matching language
exit 0
