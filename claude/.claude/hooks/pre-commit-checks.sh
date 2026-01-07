#!/usr/bin/env bash
# Hook: PreToolUse - Pre-Commit Checks
#
# Runs comprehensive checks before sl/git commit to prevent broken commits.
# Supports both Sapling (sl) and Git.
# Checks: tests, linting, build, TODO comments, large commits.

set -euo pipefail

TOOL_NAME="${CLAUDE_HOOK_TOOL_NAME:-}"

# Only run before Bash tool with commit commands
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# Check if this is a commit command (sl or git)
COMMAND="${CLAUDE_HOOK_TOOL_ARGS_command:-}"
if [[ ! "$COMMAND" =~ (sl|git)[[:space:]]+commit ]]; then
  exit 0
fi

# Detect VCS type
if sl root &>/dev/null; then
  VCS="sl"
elif git rev-parse --git-dir &>/dev/null 2>&1; then
  VCS="git"
else
  echo "Not in a repository"
  exit 0
fi

echo "Running pre-commit checks ($VCS)..."

# Get list of changed files based on VCS
get_changed_files() {
  if [[ "$VCS" == "sl" ]]; then
    # Sapling: all modified, added, removed files (no staging concept)
    sl status --no-status -marn 2>/dev/null || true
  else
    # Git: only staged files
    git diff --cached --name-only 2>/dev/null || true
  fi
}

# Check for changes
CHANGED_FILES=$(get_changed_files)
if [[ -z "$CHANGED_FILES" ]]; then
  if [[ "$VCS" == "sl" ]]; then
    echo "No uncommitted changes"
  else
    echo "No staged changes to commit"
    echo "Run: git add <files>"
  fi
  exit 1
fi

# Format files
echo "  Formatting files..."
FORMATTED_FILES=""

format_and_track() {
  local file="$1"
  if [[ "$VCS" == "git" ]]; then
    git add "$file"  # Re-add formatted file to staging
  fi
  # Sapling doesn't need re-adding - it commits all changes
  FORMATTED_FILES="${FORMATTED_FILES}${file}\n"
}

# Format TypeScript/JavaScript files
if echo "$CHANGED_FILES" | grep -qE "\.(ts|tsx|js|jsx|json)$"; then
  if command -v bunx &>/dev/null && [[ -f "package.json" ]]; then
    for file in $(echo "$CHANGED_FILES" | grep -E "\.(ts|tsx|js|jsx|json)$"); do
      if [[ -f "$file" ]]; then
        bunx prettier --write "$file" 2>/dev/null || true
        format_and_track "$file"
      fi
    done
  fi
fi

# Format Rust files
if echo "$CHANGED_FILES" | grep -qE "\.rs$"; then
  if command -v rustfmt &>/dev/null; then
    for file in $(echo "$CHANGED_FILES" | grep -E "\.rs$"); do
      if [[ -f "$file" ]]; then
        rustfmt "$file" 2>/dev/null || true
        format_and_track "$file"
      fi
    done
  fi
fi

# Format Python files
if echo "$CHANGED_FILES" | grep -qE "\.py$"; then
  if command -v uvx &>/dev/null; then
    for file in $(echo "$CHANGED_FILES" | grep -E "\.py$"); do
      if [[ -f "$file" ]]; then
        uvx ruff format "$file" 2>/dev/null || true
        format_and_track "$file"
      fi
    done
  elif command -v ruff &>/dev/null; then
    for file in $(echo "$CHANGED_FILES" | grep -E "\.py$"); do
      if [[ -f "$file" ]]; then
        ruff format "$file" 2>/dev/null || true
        format_and_track "$file"
      fi
    done
  fi
fi

if [[ -n "$FORMATTED_FILES" ]]; then
  echo "  Formatted files"
fi

# Run LSP type checks
echo "  Checking types..."
if [[ -f "tsconfig.json" ]] && command -v bunx &>/dev/null; then
  if ! bunx tsc --noEmit 2>&1 | head -10; then
    echo "TypeScript errors found"
    exit 1
  fi
fi

if [[ -f "Cargo.toml" ]] && command -v cargo &>/dev/null; then
  if ! cargo check --quiet 2>&1; then
    echo "Rust errors found"
    exit 1
  fi
  # Also run clippy for lints
  if cargo clippy --version &>/dev/null 2>&1; then
    if ! cargo clippy --quiet -- -D warnings 2>&1 | head -20; then
      echo "  Clippy warnings found (run: cargo clippy --fix)"
    fi
  fi
fi

if [[ -f "pyproject.toml" ]] && command -v uvx &>/dev/null; then
  if ! uvx ty check 2>&1 | head -20; then
    echo "Python type errors found"
    exit 1
  fi
fi

# Run tests on changed files
echo "  Running tests..."

# Run tests for TypeScript/JavaScript
if echo "$CHANGED_FILES" | grep -qE "\.(ts|tsx|js|jsx)$"; then
  if [[ -f "package.json" ]] && command -v bun &>/dev/null; then
    if ! bun test --silent 2>&1 | tail -10; then
      echo "Tests failed"
      exit 1
    fi
  fi
fi

# Run tests for Rust
if echo "$CHANGED_FILES" | grep -qE "\.rs$"; then
  if [[ -f "Cargo.toml" ]]; then
    if ! cargo test --quiet 2>&1 | tail -10; then
      echo "Tests failed"
      exit 1
    fi
  fi
fi

# Run tests for Python
if echo "$CHANGED_FILES" | grep -qE "\.py$"; then
  if [[ -f "pyproject.toml" ]] && command -v uv &>/dev/null; then
    if ! uv run pytest --quiet 2>&1 | tail -10; then
      echo "Tests failed"
      exit 1
    fi
  fi
fi

# Dead code detection
echo "  Scanning for dead code..."
DEADCODE_WARNINGS=""

# Python: Check for unused imports and variables
if echo "$CHANGED_FILES" | grep -qE "\.py$"; then
  if command -v uvx &>/dev/null; then
    for file in $(echo "$CHANGED_FILES" | grep -E "\.py$"); do
      if [[ -f "$file" ]]; then
        # F401=unused imports, F841=unused variables
        OUTPUT=$(uvx ruff check --select=F401,F841 --output-format=concise "$file" 2>/dev/null || true)
        if [[ -n "$OUTPUT" ]]; then
          DEADCODE_WARNINGS="${DEADCODE_WARNINGS}${OUTPUT}\n"
        fi
      fi
    done
  fi
fi

# TypeScript/JavaScript: Check for unused exports with knip
if echo "$CHANGED_FILES" | grep -qE "\.(ts|tsx|js|jsx)$"; then
  if [[ -f "package.json" ]] && command -v bunx &>/dev/null; then
    OUTPUT=$(bunx knip --no-exit-code --include files,exports,duplicates 2>/dev/null | head -20 || true)
    if [[ -n "$OUTPUT" && ! "$OUTPUT" =~ "No issues found" ]]; then
      DEADCODE_WARNINGS="${DEADCODE_WARNINGS}${OUTPUT}\n"
    fi
  fi
fi

if [[ -n "$DEADCODE_WARNINGS" ]]; then
  echo "  Potential dead code found:"
  echo -e "$DEADCODE_WARNINGS" | head -15
  echo "  Consider cleaning up unused code"
fi

# Scan for TODO/FIXME comments in changed files
echo "  Scanning for TODO comments..."
TODO_COUNT=0

get_diff_command() {
  local file="$1"
  if [[ "$VCS" == "sl" ]]; then
    sl diff "$file" 2>/dev/null || true
  else
    git diff --cached "$file" 2>/dev/null || true
  fi
}

while IFS= read -r file; do
  if [[ -f "$file" ]]; then
    COUNT=$(get_diff_command "$file" | grep -c "^+.*\(TODO\|FIXME\|XXX\|HACK\)" || true)
    TODO_COUNT=$((TODO_COUNT + COUNT))
  fi
done <<< "$CHANGED_FILES"

if [[ $TODO_COUNT -gt 0 ]]; then
  echo "  Found $TODO_COUNT new TODO/FIXME comments"
  echo "  Consider addressing before committing"
fi

# Warn about large commits
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
if [[ $FILE_COUNT -gt 20 ]]; then
  echo "  Large commit: $FILE_COUNT files"
  echo "  Consider breaking into smaller commits"
fi

echo "Pre-commit checks passed"
exit 0
