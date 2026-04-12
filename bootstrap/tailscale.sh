#!/usr/bin/env bash

set -euo pipefail

key_file="$HOME/Documents/keys/tailscale"
if [[ ! -f "$key_file" ]]; then
    mkdir -p "$(dirname "$key_file")"
    ssh-keygen -t ed25519 -C "methylene-tailscale" -f "$key_file" -N ""
    echo "Created SSH key: $key_file"
    echo "Public key:"
    cat "${key_file}.pub"
    echo ""
    echo "Add this key to ~/.ssh/authorized_keys on all Tailscale hosts."
fi

# Hosts excluded from SSH mesh (network-only, no SSH)
SKIP_SSH=(
    "apple-tv"
    "methylene-shield"
    "allenj-macbook"
)

# Special hosts that need non-default settings
declare -A HOST_USER
declare -A HOST_PORT
HOST_USER["methylene-fold"]="u0_a395"
HOST_PORT["methylene-fold"]="8022"

machines=$(tailscale status --json | jq -r '.Peer[] | "\(.HostName) \(.TailscaleIPs[0])"')

hosts_file="$HOME/.config/tailscale/hosts"
ssh_config="$HOME/.ssh/tailscale_config"
mkdir -p "$(dirname "$hosts_file")"

# Helper: check if hostname should be skipped for SSH
skip_ssh() {
    local h="$1"
    for skip in "${SKIP_SSH[@]}"; do
        [[ "$h" == "$skip" ]] && return 0
    done
    return 1
}

# Helper: generate short alias from hostname
get_alias() {
    local h="$1"
    if [[ "$h" == methylene-* ]]; then
        echo "${h#methylene-}"
    elif [[ "$h" == *-nas ]]; then
        echo "${h%-nas}"
    fi
}

# Generate /etc/hosts file (all peers, including network-only)
{
    echo "# Tailscale hosts - $(date)"
    echo ""

    while IFS= read -r line; do
        hostname=$(echo "$line" | awk '{print $1}')
        ip=$(echo "$line" | awk '{print $2}')

        [[ "$hostname" == "localhost" ]] && continue

        short_alias=$(get_alias "$hostname")

        if [[ -n "$short_alias" && "$short_alias" != "$hostname" ]]; then
            echo "$ip $hostname $short_alias"
        else
            echo "$ip $hostname"
        fi
    done <<< "$machines"
} > "$hosts_file"

# Generate SSH config (mesh hosts only)
{
    echo "# Tailscale mesh SSH config - $(date)"
    echo ""

    while IFS= read -r line; do
        hostname=$(echo "$line" | awk '{print $1}')
        ip=$(echo "$line" | awk '{print $2}')

        [[ "$hostname" == "localhost" ]] && continue
        skip_ssh "$hostname" && continue

        short_alias=$(get_alias "$hostname")

        if [[ -n "$short_alias" && "$short_alias" != "$hostname" ]]; then
            echo "Host $hostname $short_alias"
        else
            echo "Host $hostname"
        fi
        echo "    HostName $ip"

        user="${HOST_USER[$hostname]:-methylene}"
        echo "    User $user"

        port="${HOST_PORT[$hostname]:-22}"
        [[ "$port" != "22" ]] && echo "    Port $port"

        # Key path differs on Termux (no ~/Documents)
        if [[ "$user" == u0_a* ]]; then
            echo "    IdentityFile ~/keys/tailscale"
        else
            echo "    IdentityFile ~/Documents/keys/tailscale"
        fi
        echo "    IdentitiesOnly yes"
        echo ""
    done <<< "$machines"
} > "$ssh_config"

echo "Generated:"
echo "  $hosts_file (all Tailscale peers)"
echo "  $ssh_config (SSH mesh hosts only)"
echo ""
echo "Mesh hosts:"
grep "^Host " "$ssh_config" | sed 's/Host /  /'
echo ""
echo "Skipped (network-only):"
for skip in "${SKIP_SSH[@]}"; do
    echo "  $skip"
done
