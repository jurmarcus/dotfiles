# SSH Configuration

SSH config managed by stow. Uses **Tailscale SSH** for machine auth (no keys).

## Files

```
ssh/
├── .ssh/
│   └── config          # SSH host configurations
└── README.md
```

## Setup

Requires Tailscale CLI (not GUI app):

```bash
# Install CLI version
brew install tailscale
sudo brew services start tailscale
tailscale up

# Enable Tailscale SSH
tailscale set --ssh
```

## Hosts

| Alias | Host | Description |
|-------|------|-------------|
| `studio` | methylene-studio | Mac Studio |
| `macbook` | methylene-macbook | MacBook |

## Usage

```bash
ssh studio              # Tailscale handles auth
ssh methylene-studio    # Same thing
mosh studio             # Persistent connection
```

## Notes

- **No SSH keys needed** - Tailscale SSH handles authentication
- **GitHub**: Use HTTPS + `gh auth` (no SSH keys)
- **Local network**: Tailscale auto-detects LAN, uses direct connection
