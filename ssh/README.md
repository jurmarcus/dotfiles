# SSH Configuration

SSH config managed by stow.

## Files

```
ssh/
├── .ssh/
│   └── config          # SSH host configurations
└── README.md
```

## Hosts

| Alias | Host | Description |
|-------|------|-------------|
| `studio` | methylene-studio | Mac Studio (Tailscale) |
| `macbook` | methylene-macbook | MacBook (Tailscale) |
| `github.com` | github.com | GitHub |

## Usage

```bash
# SSH with short alias
ssh studio

# SSH with full hostname
ssh methylene-studio

# Mosh (persistent connection)
mosh studio

# Quick connect with Zellij (defined in zshrc)
studio          # mosh + zellij attach
mstudio         # mosh only
tssh studio     # explicit function call
```

## Shell Functions (in .zshrc)

| Function/Alias | Description |
|----------------|-------------|
| `tssh [host]` | Mosh to host with Zellij attach (fallback to SSH) |
| `studio` | Quick connect to methylene-studio |
| `mstudio` | Mosh to methylene-studio |

## Notes

- Uses Tailscale MagicDNS (hostnames resolve automatically)
- Keys stored in `~/.ssh/id_ed25519` (not managed by stow)
- `ServerAliveInterval` keeps connections alive
