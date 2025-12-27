#!/usr/bin/env bash

set -euo pipefail

key_file="$HOME/Documents/keys/personal"
if [[ ! -f "$key_file" ]]; then
    mkdir -p "$(dirname "$key_file")"
    ssh-keygen -t ed25519 -C "$(hostname -s)" -f "$key_file" -N ""
    echo "Created SSH key: $key_file"
    echo "Public key:"
    cat "${key_file}.pub"
    echo ""
fi

machines=$(tailscale status --json | jq -r '.Peer[] | "\(.HostName) \(.TailscaleIPs[0])"')
current_user=$(whoami)

hosts_file="$HOME/.config/tailscale/hosts"
ssh_config="$HOME/.ssh/tailscale_config"
mkdir -p "$(dirname "$hosts_file")"

{
    echo "# Tailscale hosts - $(date)"
    echo ""
    
    while IFS= read -r line; do
        hostname=$(echo "$line" | awk '{print $1}')
        ip=$(echo "$line" | awk '{print $2}')
        
        [[ "$hostname" == "localhost" ]] && continue
        
        short_alias=""
        if [[ "$hostname" == "${current_user}-"* ]]; then
            short_alias="${hostname#*-}"
        fi
        
        if [[ -n "$short_alias" && "$short_alias" != "$hostname" ]]; then
            echo "$ip $hostname $short_alias"
        else
            echo "$ip $hostname"
        fi
    done <<< "$machines"
} > "$hosts_file"

{
    echo "# Tailscale SSH config - $(date)"
    echo ""
    
    while IFS= read -r line; do
        hostname=$(echo "$line" | awk '{print $1}')
        
        [[ "$hostname" == "localhost" ]] && continue
        
        short_alias=""
        if [[ "$hostname" == "${current_user}-"* ]]; then
            short_alias="${hostname#*-}"
        fi
        
        if [[ -n "$short_alias" && "$short_alias" != "$hostname" ]]; then
            echo "Host $hostname $short_alias"
        else
            echo "Host $hostname"
        fi
        echo "    User $current_user"
        echo "    IdentityFile ~/Documents/keys/personal"
        echo ""
    done <<< "$machines"
} > "$ssh_config"

echo "Generated:"
echo "  $hosts_file (paste into /etc/hosts)"
echo "  $ssh_config (included by ~/.ssh/config)"
echo ""
cat "$hosts_file"
