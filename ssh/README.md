# SSH Configuration

SSH config managed by stow. Uses **Tailscale SSH** for machine auth (no keys).

## Files

```
ssh/
├── .ssh/
│   └── config          # Main config (includes tailscale_config)
└── README.md
```

Generated at runtime:
- `~/.ssh/tailscale_config` - Auto-generated from Tailscale network

## Setup

Requires Tailscale CLI (not GUI app):

```bash
brew install tailscale
sudo brew services start tailscale
tailscale up
tailscale set --ssh

# Generate SSH config from Tailscale peers
~/dotfiles/bootstrap/tailscale.sh
```

## Hosts

Hosts are dynamically generated from your Tailscale network. Run `tailscale.sh` to regenerate.

Short aliases are created automatically: `methylene-studio` becomes `studio`.

```bash
ssh studio              # Short alias
ssh methylene-studio    # Full hostname
mosh studio             # Persistent connection
```

## Notes

- **No SSH keys needed** - Tailscale SSH handles authentication
- **GitHub**: Use HTTPS + `gh auth` (no SSH keys)
- **Local network**: Tailscale auto-detects LAN, uses direct connection
- **Regenerate config**: Run `~/dotfiles/bootstrap/tailscale.sh` when Tailscale network changes
