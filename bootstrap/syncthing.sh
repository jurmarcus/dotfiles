#!/usr/bin/env bash
#
# Per-machine bootstrap for Syncthing (claude memory sync).
# Idempotent: safe to re-run.
#
# Steps:
#   1. Verify syncthing is installed
#   2. Start brew services syncthing (no-op if running)
#   3. Wait for REST API
#   4. Read device ID + API key
#   5. For each folder in ~/.config/claude-sync/folders.conf:
#        - Register via API if missing
#        - Deploy .stignore from template
#   6. Write device ID to ~/.claude/.syncthing-device-id
#
# Run from any macOS host AFTER `stow sync` has been applied.
#
set -euo pipefail

CONF_FILE="$HOME/.config/claude-sync/folders.conf"
STIGNORE_DIR="$HOME/.config/claude-sync/stignore"
CONFIG_XML="$HOME/Library/Application Support/Syncthing/config.xml"
API_URL="http://127.0.0.1:8384/rest"
DEVICE_ID_FILE="$HOME/.claude/.syncthing-device-id"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'
step() { echo -e "\n${BLUE}>> $1${NC}"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
die()  { echo -e "${RED}error:${NC} $1" >&2; exit 1; }

# 1. Verify syncthing installed
step "Verifying syncthing is installed"
command -v syncthing >/dev/null 2>&1 \
  || die "syncthing not installed. Run 'brewsync' first (it's in the brew sync module)."
ok "syncthing $(syncthing --version | awk '{print $2}') present"

# 2. Verify config file present (start service if not)
step "Ensuring syncthing daemon is running"
if [[ ! -f "$CONFIG_XML" ]]; then
  # First run: launch briefly to generate config, then stop, so we can use brew services cleanly
  ok "first run — generating initial config"
  syncthing --no-browser --no-restart --logflags=0 >/dev/null 2>&1 &
  st_pid=$!
  for _ in $(seq 1 30); do
    [[ -f "$CONFIG_XML" ]] && break
    sleep 0.5
  done
  kill "$st_pid" 2>/dev/null || true
  wait "$st_pid" 2>/dev/null || true
  [[ -f "$CONFIG_XML" ]] || die "config.xml never appeared at $CONFIG_XML"
fi

if brew services list 2>/dev/null | awk '/^syncthing /{print $2}' | grep -q '^started$'; then
  ok "brew service already running"
else
  brew services start syncthing >/dev/null
  ok "brew service started"
fi

# 3. Read API key from config.xml (Syncthing v2+ requires auth on all endpoints)
step "Reading API key from config"
api_key=$(xmllint --xpath 'string(/configuration/gui/apikey)' "$CONFIG_XML" 2>/dev/null) \
  || die "failed to read API key from $CONFIG_XML"
[[ -n "$api_key" ]] || die "API key empty in $CONFIG_XML"

curl_api() {
  curl -sf -H "X-API-Key: $api_key" "$@"
}

# 4. Wait for API (authenticated — v2 returns 403 CSRF on unauthenticated /rest/*)
step "Waiting for REST API"
for i in $(seq 1 20); do
  if curl_api "$API_URL/system/ping" >/dev/null 2>&1; then
    ok "API responding ($i tries)"
    break
  fi
  sleep 0.5
  [[ $i -eq 20 ]] && die "API did not come up after 10s"
done

# 4b. Read device ID via authenticated API
device_id=$(curl_api "$API_URL/system/status" | jq -r '.myID')
[[ -n "$device_id" && "$device_id" != "null" ]] || die "could not read device ID from API"
ok "device ID: $device_id"

# 5. Configure folders from folders.conf
step "Configuring folders from $CONF_FILE"
[[ -f "$CONF_FILE" ]] || die "folders.conf missing — run 'stow sync' first"

# Ensure target parent dirs exist (e.g. ~/.claude/memory)
mkdir -p "$HOME/.claude/memory" "$HOME/.claude/projects"

existing_folders=$(curl_api "$API_URL/config/folders" | jq -r '.[].id')

while IFS= read -r line; do
  # Strip comments and blank lines
  line="${line%%#*}"
  [[ -z "${line// }" ]] && continue

  # Parse: id path "label with spaces" stignore_template
  if [[ "$line" =~ ^[[:space:]]*([a-z][a-z0-9-]+)[[:space:]]+(\$HOME[^[:space:]]+|/[^[:space:]]+)[[:space:]]+\"([^\"]+)\"[[:space:]]+([a-z][a-z0-9-]+|none)[[:space:]]*$ ]]; then
    fid="${BASH_REMATCH[1]}"
    fpath="${BASH_REMATCH[2]/#\$HOME/$HOME}"
    label="${BASH_REMATCH[3]}"
    stignore="${BASH_REMATCH[4]}"
  else
    warn "could not parse folders.conf line: $line"
    continue
  fi

  mkdir -p "$fpath"

  if echo "$existing_folders" | grep -qx "$fid"; then
    ok "$fid already configured"
  else
    body=$(jq -n \
      --arg id "$fid" \
      --arg label "$label" \
      --arg path "$fpath" \
      '{
         id: $id,
         label: $label,
         path: $path,
         type: "sendreceive",
         fsWatcherEnabled: true,
         fsWatcherDelayS: 10,
         rescanIntervalS: 3600,
         versioning: { type: "simple", params: { keep: "5" } },
         devices: []
       }')
    curl -sf -H "X-API-Key: $api_key" -H "Content-Type: application/json" \
      -X POST -d "$body" "$API_URL/config/folders" >/dev/null \
      || die "failed to register folder $fid"
    ok "registered $fid → $fpath"
  fi

  # Deploy .stignore from template (overwrite to keep template authoritative)
  if [[ "$stignore" != "none" ]]; then
    template="$STIGNORE_DIR/$stignore"
    [[ -f "$template" ]] || die "stignore template missing: $template"
    install -m 644 "$template" "$fpath/.stignore"
    ok "deployed .stignore: $fpath/.stignore (from $stignore)"
  fi
done < "$CONF_FILE"

# 6. Write device ID file
step "Writing device ID file"
mkdir -p "$HOME/.claude"
echo "$device_id" > "$DEVICE_ID_FILE"
chmod 644 "$DEVICE_ID_FILE"
ok "$DEVICE_ID_FILE"

# Summary
echo
echo -e "${GREEN}✓ Syncthing claude memory sync configured${NC}"
echo
echo "  Device ID: $device_id"
folder_count=$(curl_api "$API_URL/config/folders" 2>/dev/null | jq -r '[.[] | select(.id | startswith("claude-"))] | length' 2>/dev/null || echo "?")
echo "  Folders:   $folder_count configured"
echo
echo "Next: from any macOS peer, run"
echo "  ~/dotfiles/bootstrap/syncthing-mesh.sh --seed-from <canonical-host>"
echo "to wire device pairings across the mesh."
