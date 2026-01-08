#!/usr/bin/env bash
# Hook: PreToolUse - Enforce Package Managers
#
# Blocks npm/npx/yarn/pnpm in favor of bun/bunx
# Blocks pip/poetry/pipenv in favor of uv/uvx
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

# ─────────────────────────────────────────────────────────────────────────────
# JavaScript/TypeScript: Enforce bun/bunx
# ─────────────────────────────────────────────────────────────────────────────

# Block: npm install/add/remove/run/test/etc
if [[ "$COMMAND" =~ ^[[:space:]]*(npm)[[:space:]]+ ]]; then
  echo "❌ Use bun instead of npm"
  echo ""
  echo "Suggested replacements:"
  echo "  npm install       → bun install"
  echo "  npm run <script>  → bun run <script>"
  echo "  npm test          → bun test"
  echo "  npm add <pkg>     → bun add <pkg>"
  echo "  npm remove <pkg>  → bun remove <pkg>"
  echo "  npm init          → bun init"
  exit 1
fi

# Block: npx
if [[ "$COMMAND" =~ ^[[:space:]]*(npx)[[:space:]]+ ]]; then
  echo "❌ Use bunx instead of npx"
  echo ""
  echo "Suggested replacement:"
  echo "  npx <command>  → bunx <command>"
  echo ""
  echo "Note: bunx doesn't need --yes flag"
  exit 1
fi

# Block: yarn
if [[ "$COMMAND" =~ ^[[:space:]]*(yarn)[[:space:]]* ]]; then
  echo "❌ Use bun instead of yarn"
  echo ""
  echo "Suggested replacements:"
  echo "  yarn install      → bun install"
  echo "  yarn add <pkg>    → bun add <pkg>"
  echo "  yarn remove <pkg> → bun remove <pkg>"
  echo "  yarn <script>     → bun run <script>"
  exit 1
fi

# Block: pnpm
if [[ "$COMMAND" =~ ^[[:space:]]*(pnpm)[[:space:]]+ ]]; then
  echo "❌ Use bun instead of pnpm"
  echo ""
  echo "Suggested replacements:"
  echo "  pnpm install      → bun install"
  echo "  pnpm add <pkg>    → bun add <pkg>"
  echo "  pnpm remove <pkg> → bun remove <pkg>"
  echo "  pnpm run <script> → bun run <script>"
  exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Python: Enforce uv/uvx
# ─────────────────────────────────────────────────────────────────────────────

# Block: pip install/uninstall (but allow pip --version, pip list, etc for info)
if [[ "$COMMAND" =~ ^[[:space:]]*(pip|pip3)[[:space:]]+(install|uninstall) ]]; then
  echo "❌ Use uv instead of pip"
  echo ""
  echo "Suggested replacements:"
  echo "  pip install <pkg>   → uv add <pkg>"
  echo "  pip install -r ...  → uv pip install -r ..."
  echo "  pip uninstall <pkg> → uv remove <pkg>"
  echo ""
  echo "For one-off tools, use: uvx <tool>"
  exit 1
fi

# Block: poetry
if [[ "$COMMAND" =~ ^[[:space:]]*(poetry)[[:space:]]+ ]]; then
  echo "❌ Use uv instead of poetry"
  echo ""
  echo "Suggested replacements:"
  echo "  poetry install     → uv sync"
  echo "  poetry add <pkg>   → uv add <pkg>"
  echo "  poetry remove      → uv remove <pkg>"
  echo "  poetry run <cmd>   → uv run <cmd>"
  echo "  poetry shell       → source .venv/bin/activate"
  echo "  poetry init        → uv init"
  exit 1
fi

# Block: pipenv
if [[ "$COMMAND" =~ ^[[:space:]]*(pipenv)[[:space:]]+ ]]; then
  echo "❌ Use uv instead of pipenv"
  echo ""
  echo "Suggested replacements:"
  echo "  pipenv install     → uv sync"
  echo "  pipenv install <p> → uv add <pkg>"
  echo "  pipenv run <cmd>   → uv run <cmd>"
  echo "  pipenv shell       → source .venv/bin/activate"
  exit 1
fi

# Block: conda/mamba for package management (allow conda activate)
if [[ "$COMMAND" =~ ^[[:space:]]*(conda|mamba)[[:space:]]+(install|remove|create) ]]; then
  echo "❌ Use uv instead of conda/mamba for package management"
  echo ""
  echo "Suggested replacements:"
  echo "  conda install <pkg> → uv add <pkg>"
  echo "  conda create -n env → uv venv"
  echo ""
  echo "Note: uv uses standard venvs with pyproject.toml"
  exit 1
fi

# Block: pipx (use uvx instead)
if [[ "$COMMAND" =~ ^[[:space:]]*(pipx)[[:space:]]+ ]]; then
  echo "❌ Use uvx instead of pipx"
  echo ""
  echo "Suggested replacements:"
  echo "  pipx run <tool>     → uvx <tool>"
  echo "  pipx install <tool> → uvx <tool>  (no install needed!)"
  exit 1
fi

# All checks passed
exit 0
