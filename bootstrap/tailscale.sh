#!/usr/bin/env bash

# Get Tailscale status in JSON format
machines=$(tailscale status --json | jq -r '.Peer[] | "\(.HostName) \(.TailscaleIPs[0])"')

# Get current user for SSH
current_user=$(whoami)

# Output file
ssh_config="$HOME/.ssh/tailscale_config"

# Generate config
echo "# Generated Tailscale SSH config - $(date)" > "$ssh_config"
echo "" >> "$ssh_config"

while IFS= read -r line; do
    hostname=$(echo "$line" | awk '{print $1}')
    ip=$(echo "$line" | awk '{print $2}')
    
    cat >> "$ssh_config" << EOF
Host $hostname
    HostName $ip
    User $current_user

EOF
done <<< "$machines"

echo "Generated SSH config at: $ssh_config"
echo ""
echo "To use it, add this to your ~/.ssh/config:"
echo "Include ~/.ssh/tailscale_config"
echo ""
echo "Or append it directly:"
echo "cat $ssh_config >> ~/.ssh/config"