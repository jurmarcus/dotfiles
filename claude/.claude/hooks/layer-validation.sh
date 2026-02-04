#!/usr/bin/env bash
# Hook: PostToolUse - Cross-Layer Boundary Validation
#
# Validates BOUNDARIES between layers in the jisho stack.
# This complements lsp-check-after-edit.sh which validates WITHIN layers.
#
#   TS ↔ Apollo ↔ GraphQL ↔ Rust ↔ SQLite
#
# Cross-layer validations:
#   - Apollo ↔ GraphQL: graphql-codegen (queries/fragments match schema)
#   - GraphQL ↔ Rust:   When schema changes, check both frontend and backend
#
# Within-layer validation (handled by lsp-check-after-edit.sh):
#   - TS layer: tsc --noEmit
#   - Rust layer: cargo check
#
# This hook focuses on interface mismatches that span layers.

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

# ─────────────────────────────────────────────────────────────────────────────
# Layer Detection
# ─────────────────────────────────────────────────────────────────────────────

detect_layer() {
  local file="$1"

  # Layer 1: TypeScript/Apollo (jisho-web)
  if [[ "$file" =~ jisho-web/.*\.(ts|tsx)$ ]]; then
    echo "ts-apollo"
    return
  fi

  # Layer 2: GraphQL Schema files
  if [[ "$file" =~ \.(graphql|gql)$ ]]; then
    echo "graphql-schema"
    return
  fi

  # Layer 3: Rust GraphQL resolvers (jisho-graphql)
  if [[ "$file" =~ jisho-graphql/.*\.rs$ ]]; then
    echo "rust-graphql"
    return
  fi

  # Layer 4: Rust Core/DB (jisho-core, jisho-cli)
  if [[ "$file" =~ jisho-core/.*\.rs$ ]]; then
    echo "rust-sqlite"
    return
  fi

  # Layer 4b: Rust MCP server
  if [[ "$file" =~ jisho-mcp/.*\.rs$ ]]; then
    echo "rust-mcp"
    return
  fi

  echo "unknown"
}

# ─────────────────────────────────────────────────────────────────────────────
# Project Root Detection
# ─────────────────────────────────────────────────────────────────────────────

find_monorepo_root() {
  local dir
  dir=$(dirname "$1")

  while [[ "$dir" != "/" ]]; do
    # Look for jisho monorepo markers
    if [[ -f "$dir/justfile" && -d "$dir/jisho-core" && -d "$dir/jisho-web" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done

  echo ""
}

find_web_root() {
  local dir
  dir=$(dirname "$1")

  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/codegen.ts" && -f "$dir/package.json" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done

  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Validation Functions
# ─────────────────────────────────────────────────────────────────────────────

validate_ts_apollo() {
  local web_root="$1"
  echo "🔍 [TS ↔ Apollo] Running TypeScript check..."

  cd "$web_root"
  if ! bunx tsc --noEmit --pretty 2>&1 | head -30; then
    echo ""
    echo "❌ [TS ↔ Apollo] TypeScript errors - types don't match Apollo usage"
    return 1
  fi

  echo "✅ [TS ↔ Apollo] TypeScript check passed"
  return 0
}

validate_apollo_graphql() {
  local web_root="$1"
  echo "🔍 [Apollo ↔ GraphQL] Running codegen validation..."

  cd "$web_root"
  local output
  output=$(bun run codegen 2>&1)
  local exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    echo "$output" | grep -A5 "Error\|error:" | head -20
    echo ""
    echo "❌ [Apollo ↔ GraphQL] Queries/fragments don't match GraphQL schema"
    return 1
  fi

  echo "✅ [Apollo ↔ GraphQL] Schema validation passed"
  return 0
}

validate_graphql_rust() {
  local monorepo_root="$1"
  echo "🔍 [GraphQL ↔ Rust] Checking resolvers..."

  cd "$monorepo_root"
  if ! cargo check -p jisho-graphql --message-format=short 2>&1 | head -30; then
    echo ""
    echo "❌ [GraphQL ↔ Rust] Resolver errors - check async-graphql types"
    return 1
  fi

  echo "✅ [GraphQL ↔ Rust] Resolvers compile"
  return 0
}

validate_rust_sqlite() {
  local monorepo_root="$1"
  echo "🔍 [Rust ↔ SQLite] Checking database layer..."

  cd "$monorepo_root"
  if ! cargo check -p jisho-core --message-format=short 2>&1 | head -30; then
    echo ""
    echo "❌ [Rust ↔ SQLite] Database layer errors"
    return 1
  fi

  echo "✅ [Rust ↔ SQLite] Database layer compiles"
  return 0
}

# ─────────────────────────────────────────────────────────────────────────────
# Main Logic
# ─────────────────────────────────────────────────────────────────────────────

LAYER=$(detect_layer "$EDITED_FILE")

# Skip unknown layers
if [[ "$LAYER" == "unknown" ]]; then
  exit 0
fi

# Find project roots
MONOREPO_ROOT=$(find_monorepo_root "$EDITED_FILE")
WEB_ROOT=$(find_web_root "$EDITED_FILE")

# Validate based on layer - focus on CROSS-LAYER boundaries
case "$LAYER" in
  ts-apollo)
    # TypeScript edit in GraphQL/Apollo directories: validate Apollo ↔ GraphQL boundary
    # Note: tsc is handled by lsp-check-after-edit.sh
    if [[ -n "$WEB_ROOT" ]]; then
      # Only validate GraphQL boundary for files that define queries/fragments
      if [[ "$EDITED_FILE" =~ /graphql/.*\.(ts|tsx)$ ]] || \
         [[ "$EDITED_FILE" =~ /apollo/.*\.(ts|tsx)$ ]]; then
        validate_apollo_graphql "$WEB_ROOT" || exit 1
      fi
      # Also check pages/components that contain gql template literals
      if [[ "$EDITED_FILE" =~ /(app|components)/.*\.(ts|tsx)$ ]]; then
        if grep -qE 'gql`' "$EDITED_FILE" 2>/dev/null; then
          validate_apollo_graphql "$WEB_ROOT" || exit 1
        fi
      fi
    fi
    ;;

  graphql-schema)
    # Schema file edit: validate BOTH directions (this is a true boundary)
    echo "📊 GraphQL schema changed - validating both directions..."
    if [[ -n "$WEB_ROOT" ]]; then
      validate_apollo_graphql "$WEB_ROOT" || exit 1
    fi
    if [[ -n "$MONOREPO_ROOT" ]]; then
      validate_graphql_rust "$MONOREPO_ROOT" || exit 1
    fi
    ;;

  rust-graphql)
    # Rust resolver edit: the resolver IS the GraphQL ↔ Rust boundary
    # Note: cargo check is also run by lsp-check-after-edit.sh, but we run it
    # specifically for jisho-graphql to get clearer error messages
    if [[ -n "$MONOREPO_ROOT" ]]; then
      validate_graphql_rust "$MONOREPO_ROOT" || exit 1
    fi
    ;;

  rust-sqlite|rust-mcp)
    # Core/DB/MCP edits: within-layer validation only
    # Let lsp-check-after-edit.sh handle cargo check
    # No cross-layer validation needed here
    exit 0
    ;;
esac

exit 0
