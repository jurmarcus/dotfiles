#!/usr/bin/env bash
#
# One-shot Syncthing mesh pairing for claude memory sync.
# Run from any one macOS peer AFTER all peers have run bootstrap/syncthing.sh.
#
# Discovers macOS peers via tailscale, reads each peer's device ID over SSH,
# then opens SSH tunnels to each peer's REST API and adds device entries +
# folder shares everywhere.
#
# Trust anchor: the existing Tailscale SSH mesh (~/.ssh/tailscale_config).
#
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'
step() { echo -e "\n${BLUE}>> $1${NC}"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
die()  { echo -e "${RED}error:${NC} $1" >&2; exit 1; }

# Folders that should be shared with all paired peers — read from config (single source of truth)
CONF_FILE="$HOME/.config/claude-sync/folders.conf"
[[ -f "$CONF_FILE" ]] || die "folders.conf missing — run 'stow sync' first"
mapfile -t FOLDER_IDS < <(
  awk '
    # strip inline comments
    { sub(/#.*/, "") }
    # skip blank lines
    NF == 0 { next }
    # first field is the folder ID
    { print $1 }
  ' "$CONF_FILE"
)
[[ ${#FOLDER_IDS[@]} -gt 0 ]] || die "no folders defined in $CONF_FILE"

DRY_RUN=false
SEED_FROM=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [--seed-from <hostname>] [--dry-run]

Options:
  --seed-from <host>   rsync ~/.claude/memory/ and project memory/ dirs
                       from <host> to all peers BEFORE adding device entries
                       (prevents .sync-conflict files on first sync)
  --dry-run            preview API calls without applying
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seed-from) SEED_FROM="$2"; shift 2 ;;
    --dry-run)   DRY_RUN=true; shift ;;
    -h|--help)   usage; exit 0 ;;
    *)           usage; exit 1 ;;
  esac
done

self_host="$(hostname -s | tr '[:upper:]' '[:lower:]')"

# 1. Discover macOS peers via tailscale
step "Discovering macOS peers via Tailscale"
command -v tailscale >/dev/null 2>&1 || die "tailscale not installed"
peers_json=$(tailscale status --json) || die "tailscale status failed"
mapfile -t peer_hosts < <(
  echo "$peers_json" \
    | jq -r '.Peer[] | select(.OS == "macOS") | .HostName' \
    | grep -v "^$self_host\$" \
    | sort -u
)
[[ ${#peer_hosts[@]} -gt 0 ]] || die "no macOS peers found in tailscale mesh"
ok "peers: ${peer_hosts[*]}"

# 2. Verify each peer is bootstrapped (skip unreachable ones — macOS mesh is often partial)
step "Verifying peers have run bootstrap/syncthing.sh"
reachable_peers=()
for h in "${peer_hosts[@]}"; do
  if ssh -o ConnectTimeout=5 -o BatchMode=yes "$h" 'test -f ~/.claude/.syncthing-device-id' 2>/dev/null; then
    ok "$h: bootstrapped"
    reachable_peers+=("$h")
  else
    warn "$h: unreachable or not bootstrapped — skipping (run bootstrap/syncthing.sh there later)"
  fi
done
peer_hosts=("${reachable_peers[@]}")
[[ ${#peer_hosts[@]} -gt 0 ]] || die "no reachable bootstrapped peers — run bootstrap/syncthing.sh on at least one peer first"
all_hosts=("$self_host" "${peer_hosts[@]}")

# 3. Optional seeding
if [[ -n "$SEED_FROM" ]]; then
  step "Seeding from $SEED_FROM"
  if [[ "$DRY_RUN" == "true" ]]; then
    warn "[dry-run] would rsync ~/.claude/memory and ~/.claude/projects/*/memory from $SEED_FROM to others"
  else
    seed_targets=("$self_host")
    for h in "${peer_hosts[@]}"; do
      [[ "$h" == "$SEED_FROM" ]] || seed_targets+=("$h")
    done
    for tgt in "${seed_targets[@]}"; do
      [[ "$tgt" == "$SEED_FROM" ]] && continue
      ok "rsync $SEED_FROM:~/.claude/memory/ → $tgt:~/.claude/memory/"
      if [[ "$tgt" == "$self_host" ]]; then
        rsync -a --delete "$SEED_FROM:.claude/memory/" "$HOME/.claude/memory/"
      else
        ssh "$tgt" "mkdir -p ~/.claude/memory ~/.claude/projects"
        ssh "$SEED_FROM" "rsync -a --delete ~/.claude/memory/ $tgt:.claude/memory/"
      fi
      # Per-project memories: only sync subdirs that actually have a memory/ inside.
      ok "rsync $SEED_FROM:~/.claude/projects/*/memory/ → $tgt:~/.claude/projects/"
      if [[ "$tgt" == "$self_host" ]]; then
        ssh "$SEED_FROM" 'cd ~/.claude/projects && find . -mindepth 2 -maxdepth 2 -type d -name memory -print0' \
          | while IFS= read -r -d '' relmem; do
              # relmem is like "./<slug>/memory"
              slug=$(dirname "${relmem#./}")
              mkdir -p "$HOME/.claude/projects/$slug"
              rsync -a --delete "$SEED_FROM:.claude/projects/$slug/memory/" \
                "$HOME/.claude/projects/$slug/memory/"
            done
      else
        # remote → remote rsync routed via local
        ssh "$SEED_FROM" "cd ~/.claude/projects && tar cf - \$(find . -mindepth 2 -maxdepth 2 -type d -name memory)" \
          | ssh "$tgt" "cd ~/.claude/projects && tar xf -"
      fi
    done
  fi
fi

# 4. Collect device IDs
step "Collecting device IDs"
declare -A DEVICE_ID
for h in "${all_hosts[@]}"; do
  if [[ "$h" == "$self_host" ]]; then
    DEVICE_ID["$h"]=$(cat "$HOME/.claude/.syncthing-device-id")
  else
    DEVICE_ID["$h"]=$(ssh "$h" 'cat ~/.claude/.syncthing-device-id')
  fi
  ok "$h: ${DEVICE_ID[$h]}"
done

# 5. Wire pairings on each machine
step "Wiring pairings via REST API"

read_api_key() {
  local h="$1"
  if [[ "$h" == "$self_host" ]]; then
    xmllint --xpath 'string(/configuration/gui/apikey)' \
      "$HOME/Library/Application Support/Syncthing/config.xml"
  else
    ssh "$h" "xmllint --xpath 'string(/configuration/gui/apikey)' \
      \"\$HOME/Library/Application Support/Syncthing/config.xml\""
  fi
}

api_call() {
  local host="$1" method="$2" path="$3" body="${4:-}" key="$5" port="$6"
  local args=(-sf -H "X-API-Key: $key" -X "$method")
  [[ -n "$body" ]] && args+=(-H "Content-Type: application/json" -d "$body")
  if [[ "$DRY_RUN" == "true" && "$method" != "GET" ]]; then
    echo "[dry-run] curl $method http://127.0.0.1:$port$path  body=$body" >&2
    echo "{}"
    return 0
  fi
  curl "${args[@]}" "http://127.0.0.1:$port$path"
}

configure_target() {
  local target="$1"
  local port tunnel_pid=""

  echo
  echo -e "${BLUE}-- configuring $target --${NC}"

  # Open tunnel for remote hosts
  if [[ "$target" == "$self_host" ]]; then
    port=8384
  else
    port=$(( 18384 + RANDOM % 1000 ))
    ssh -fNL "127.0.0.1:$port:127.0.0.1:8384" "$target"
    sleep 0.5
    tunnel_pid=$(pgrep -f "ssh -fNL 127.0.0.1:$port" | tail -1 || true)
  fi

  cleanup() { [[ -n "${tunnel_pid:-}" ]] && kill "$tunnel_pid" 2>/dev/null || true; }
  trap cleanup RETURN

  local api_key
  api_key=$(read_api_key "$target")

  # Add other devices
  local other other_id body
  for other in "${all_hosts[@]}"; do
    [[ "$other" == "$target" ]] && continue
    other_id="${DEVICE_ID[$other]}"
    body=$(jq -n --arg id "$other_id" --arg name "$other" \
      '{deviceID: $id, name: $name, addresses: ["dynamic"], compression: "metadata"}')
    if api_call "$target" POST /rest/config/devices "$body" "$api_key" "$port" >/dev/null 2>&1; then
      ok "$target: added device $other"
    else
      # Already exists — verify
      if api_call "$target" GET "/rest/config/devices/$other_id" "" "$api_key" "$port" >/dev/null 2>&1; then
        ok "$target: device $other already present"
      else
        warn "$target: failed to add device $other (check syncthing logs)"
      fi
    fi
  done

  # Share each folder with all other devices
  local fid other_ids_json folder merged
  for fid in "${FOLDER_IDS[@]}"; do
    other_ids_json=$(
      for h in "${all_hosts[@]}"; do
        [[ "$h" == "$target" ]] && continue
        echo "${DEVICE_ID[$h]}"
      done | jq -R '{deviceID: .}' | jq -s '.'
    )
    folder=$(api_call "$target" GET "/rest/config/folders/$fid" "" "$api_key" "$port" 2>/dev/null || echo "{}")
    [[ -z "$folder" || "$folder" == "{}" ]] && { warn "$target: folder $fid not found, skipping"; continue; }
    merged=$(echo "$folder" | jq --argjson devs "$other_ids_json" '.devices = $devs')
    if api_call "$target" PUT "/rest/config/folders/$fid" "$merged" "$api_key" "$port" >/dev/null 2>&1; then
      ok "$target: shared $fid with $(echo "$other_ids_json" | jq 'length') peers"
    else
      warn "$target: failed to update folder $fid share list"
    fi
  done
}

for target in "${all_hosts[@]}"; do
  configure_target "$target"
done

# 6. Verify connections
if [[ "$DRY_RUN" != "true" ]]; then
  step "Waiting for peer connections (5s grace)"
  sleep 5
  api_key=$(read_api_key "$self_host")
  conns=$(curl -sf -H "X-API-Key: $api_key" "http://127.0.0.1:8384/rest/system/connections" | jq -r '.connections | to_entries[] | select(.value.connected) | .key')
  for h in "${peer_hosts[@]}"; do
    if echo "$conns" | grep -qx "${DEVICE_ID[$h]}"; then
      ok "$h connected"
    else
      warn "$h not yet connected (may take a minute; verify with claude-sync-status)"
    fi
  done
fi

echo
echo -e "${GREEN}✓ Mesh pairing complete${NC}"
echo "  Run 'claude-sync-status' on any machine to verify."
