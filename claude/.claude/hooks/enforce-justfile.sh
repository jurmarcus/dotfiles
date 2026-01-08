#!/usr/bin/env bash
# Hook: PreToolUse - Enforce Justfile Usage
#
# Behavior:
# - If justfile exists: block raw build commands, suggest `just` equivalent
# - If no justfile exists: block and instruct to create one first

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

# ─────────────────────────────────────────────────────────────────────────────
# Build command patterns to intercept
# ─────────────────────────────────────────────────────────────────────────────

# Check for cargo commands
if [[ "$COMMAND" =~ ^[[:space:]]*(cargo)[[:space:]]+(build|test|fmt|clippy|check|run) ]]; then
  JUST_CMD="build"
  [[ "$COMMAND" =~ cargo[[:space:]]+test ]] && JUST_CMD="test"
  [[ "$COMMAND" =~ cargo[[:space:]]+(fmt|clippy) ]] && JUST_CMD="fix"
  DESC="Rust"
fi

# Check for cargo pgrx commands
if [[ "$COMMAND" =~ ^[[:space:]]*(cargo)[[:space:]]+(pgrx) ]]; then
  JUST_CMD="install"
  [[ "$COMMAND" =~ pgrx[[:space:]]+test ]] && JUST_CMD="test"
  DESC="PostgreSQL extension"
fi

# Check for npm/pnpm/bun build/test commands
if [[ "$COMMAND" =~ ^[[:space:]]*(npm|pnpm|bun)[[:space:]]+(run[[:space:]]+)?(build|test|lint|format) ]]; then
  JUST_CMD="build"
  [[ "$COMMAND" =~ (test) ]] && JUST_CMD="test"
  [[ "$COMMAND" =~ (lint|format) ]] && JUST_CMD="fix"
  DESC="Node.js"
fi

# Check for uv/uvx Python commands
if [[ "$COMMAND" =~ ^[[:space:]]*(uv[[:space:]]+run[[:space:]]+pytest|uvx[[:space:]]+(ruff|ty)) ]]; then
  JUST_CMD="test"
  [[ "$COMMAND" =~ (ruff|ty) ]] && JUST_CMD="fix"
  DESC="Python"
fi

# Check for wasm-pack
if [[ "$COMMAND" =~ ^[[:space:]]*(wasm-pack)[[:space:]]+(build) ]]; then
  JUST_CMD="build"
  DESC="WASM"
fi

# Check for make
if [[ "$COMMAND" =~ ^[[:space:]]*(make)[[:space:]]+ ]]; then
  JUST_CMD="build"
  DESC="Make"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Block server-starting commands (user starts their own servers)
# ─────────────────────────────────────────────────────────────────────────────

# Check for just dev/serve commands
if [[ "$COMMAND" =~ ^[[:space:]]*(just)[[:space:]]+(dev|serve|start|graphql|web|mcp) ]]; then
  echo "❌ Do not start servers automatically"
  echo ""
  echo "The user will start their own development servers when ready."
  echo "Your role is to write code, not manage the development environment."
  exit 2
fi

# Check for cargo run (server binaries)
if [[ "$COMMAND" =~ ^[[:space:]]*(cargo)[[:space:]]+run ]]; then
  echo "❌ Do not start servers automatically"
  echo ""
  echo "The user will run cargo binaries themselves when ready."
  exit 2
fi

# Check for npm/bun/pnpm dev/start commands
if [[ "$COMMAND" =~ ^[[:space:]]*(npm|pnpm|bun)[[:space:]]+(run[[:space:]]+)?(dev|start|serve) ]]; then
  echo "❌ Do not start servers automatically"
  echo ""
  echo "The user will start their own development servers when ready."
  exit 2
fi

# Check for Python server commands
if [[ "$COMMAND" =~ ^[[:space:]]*(uv[[:space:]]+run[[:space:]]+(uvicorn|fastapi|flask|django)|python[[:space:]]+-m[[:space:]]+(uvicorn|http\.server)) ]]; then
  echo "❌ Do not start servers automatically"
  echo ""
  echo "The user will start their own Python servers when ready."
  exit 2
fi

# If no build command matched, proceed
if [[ -z "${JUST_CMD:-}" ]]; then
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Check for justfile
# ─────────────────────────────────────────────────────────────────────────────

find_justfile() {
  local dir="${CLAUDE_PROJECT_DIR:-$PWD}"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/justfile" ]] || [[ -f "$dir/Justfile" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

JUSTFILE_DIR=$(find_justfile || echo "")

if [[ -n "$JUSTFILE_DIR" ]]; then
  # Justfile exists - block and suggest just command
  echo "❌ justfile detected at $JUSTFILE_DIR"
  echo ""
  echo "Use \`just $JUST_CMD\` instead of raw $DESC command."
  echo ""
  echo "Run \`just --list\` to see available recipes."
  exit 2  # Exit code 2 = blocking error
else
  # No justfile - block and instruct to create one
  echo "❌ No justfile found in project"
  echo ""
  echo "Before running raw build commands, create a justfile for this project."
  echo ""
  echo "Use the Task tool with subagent_type='general-purpose' to analyze"
  echo "the project and create an appropriate justfile with standard recipes"
  echo "(dict-setup, build, test, fix, env, etc.)."
  echo ""
  echo "Base it on existing sudachi-* project justfiles in ~/CODE/ for patterns."
  exit 2  # Exit code 2 = blocking error
fi
