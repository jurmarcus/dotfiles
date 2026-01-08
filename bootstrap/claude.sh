#!/usr/bin/env bash
#
# Claude Code configuration setup
# Registers hooks in settings.json with correct paths for this machine
# Note: commands, skills, hooks are symlinked via stow
#
set -euo pipefail

CLAUDE_HOME="${HOME}/.claude"
HOOKS_DIR="${CLAUDE_HOME}/hooks"
SETTINGS_FILE="${CLAUDE_HOME}/settings.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

step() { echo -e "${BLUE}>> $1${NC}"; }
ok() { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}! $1${NC}"; }

# Hook definitions: which hooks run on which events with what matcher
# Format: "event:matcher:script:timeout"
HOOK_DEFS=(
  # PreToolUse - Bash commands
  "PreToolUse:Bash:enforce-justfile.sh:10"
  "PreToolUse:Bash:enforce-package-managers.sh:10"
  "PreToolUse:Bash:pre-commit-checks.sh:60"
  # PostToolUse - Edit/Write
  "PostToolUse:Edit|Write:lsp-check-after-edit.sh:30"
  "PostToolUse:Edit|Write:format-on-edit.sh:30"
  "PostToolUse:Edit|Write:test-after-edit.sh:60"
  "PostToolUse:Edit|Write:layer-validation.sh:30"
  "PostToolUse:Edit|Write:react-inline-component-check.sh:10"
  # Session hooks
  "SessionStart::session-start-context.sh:10"
  "SessionEnd::session-summary.sh:30"
)

step "Setting up Claude Code hooks"

# Ensure ~/.claude exists
mkdir -p "${CLAUDE_HOME}"

# Check if hooks directory exists
if [[ ! -d "$HOOKS_DIR" ]]; then
  warn "Hooks directory not found: $HOOKS_DIR"
  warn "Run 'stow claude' from ~/dotfiles first"
  exit 1
fi

# Build hooks JSON
build_hooks_json() {
  local json='{'
  local events=()
  local current_event=""
  local current_matcher=""
  local event_json=""

  # Group hooks by event and matcher
  declare -A event_matchers

  for def in "${HOOK_DEFS[@]}"; do
    IFS=':' read -r event matcher script timeout <<< "$def"
    local hook_path="${HOOKS_DIR}/${script}"

    # Skip if hook doesn't exist (might be disabled)
    if [[ ! -x "$hook_path" ]]; then
      continue
    fi

    local key="${event}:${matcher}"
    local hook_json="{\"type\":\"command\",\"command\":\"${hook_path}\",\"timeout\":${timeout}}"

    if [[ -z "${event_matchers[$key]:-}" ]]; then
      event_matchers[$key]="$hook_json"
    else
      event_matchers[$key]="${event_matchers[$key]},$hook_json"
    fi
  done

  # Build JSON structure
  declare -A event_entries
  for key in "${!event_matchers[@]}"; do
    IFS=':' read -r event matcher <<< "$key"
    local hooks_array="[${event_matchers[$key]}]"

    local entry
    if [[ -n "$matcher" ]]; then
      entry="{\"matcher\":\"${matcher}\",\"hooks\":${hooks_array}}"
    else
      entry="{\"hooks\":${hooks_array}}"
    fi

    if [[ -z "${event_entries[$event]:-}" ]]; then
      event_entries[$event]="$entry"
    else
      event_entries[$event]="${event_entries[$event]},$entry"
    fi
  done

  # Combine all events
  local first=true
  for event in "${!event_entries[@]}"; do
    if [[ "$first" == "true" ]]; then
      first=false
    else
      json+=','
    fi
    json+="\"${event}\":[${event_entries[$event]}]"
  done

  json+='}'
  echo "$json"
}

# Create or update settings.json
if [[ -f "$SETTINGS_FILE" ]]; then
  # Preserve existing settings, update hooks
  hooks_json=$(build_hooks_json)

  # Use jq to merge if available, otherwise warn
  if command -v jq &>/dev/null; then
    tmp_file=$(mktemp)
    jq --argjson hooks "$hooks_json" '.hooks = $hooks' "$SETTINGS_FILE" > "$tmp_file"
    mv "$tmp_file" "$SETTINGS_FILE"
    ok "Updated hooks in existing settings.json"
  else
    warn "jq not found - cannot merge settings"
    warn "Please manually update hooks in $SETTINGS_FILE"
    echo "Hooks JSON:"
    echo "$hooks_json" | python3 -m json.tool 2>/dev/null || echo "$hooks_json"
    exit 1
  fi
else
  # Create new settings.json
  hooks_json=$(build_hooks_json)
  echo "{\"hooks\":${hooks_json}}" | jq '.' > "$SETTINGS_FILE"
  ok "Created settings.json with hooks"
fi

# Show registered hooks
echo ""
ok "Claude Code setup complete!"
echo "  Hooks registered:"
for def in "${HOOK_DEFS[@]}"; do
  IFS=':' read -r event matcher script timeout <<< "$def"
  if [[ -x "${HOOKS_DIR}/${script}" ]]; then
    echo "    ${event}: ${script}"
  fi
done
