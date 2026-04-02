# SSH Configuration

Full-mesh SSH across all Tailscale hosts using a single `tailscale` ed25519 key (no passphrase).

## Files

```
ssh/
├── .ssh/
│   └── config          # Main config (all mesh hosts inline)
└── README.md
```

## SSH Mesh Hosts

| Alias | Full Name | IP | User | Port | Status |
|-------|-----------|-----|------|------|--------|
| `studio` | `methylene-studio` | 100.112.221.98 | methylene | 22 | active |
| `macbook` | `methylene-macbook` | 100.108.7.69 | methylene | 22 | active |
| `mini` | `methylene-mini` | TBD | methylene | 22 | planned |
| `fold` | `methylene-fold` | 100.79.7.64 | u0_a395 | 8022 | active |
| `pc` | `methylene-pc` | 100.120.167.29 | methylene | 22 | planned (future Linux) |
| `hanekawa` | `hanekawa-nas` | 100.105.249.117 | methylene | 22 | active |
| `gaen` | `gaen-nas` | 100.114.109.120 | methylene | 22 | active |

## Network-Only Devices (no SSH)

| Name | Role | Notes |
|------|------|-------|
| `allenj-macbook` | Work laptop | On Tailscale, not in mesh |
| `apple-tv` | Apple TV | ADB target only |
| `methylene-senjougahara` | Nvidia Shield Pro | ADB target only |

## Keys

| Key | Location | Purpose |
|-----|----------|---------|
| `tailscale` | `~/Documents/keys/` (macOS), `~/keys/` (Termux) | All Tailscale mesh SSH |
| `jurmarcus` | `~/Documents/keys/` | GitHub |

## Adding a New Machine

1. Install Tailscale on the new machine, `tailscale up`
2. Run `bootstrap/tailscale.sh` on any existing host to regenerate configs
3. Deploy `tailscale` public key to new host: `echo 'KEY' >> ~/.ssh/authorized_keys`
4. Deploy `tailscale` private key to new host: `~/Documents/keys/tailscale`
5. Copy `~/.ssh/tailscale_config` to the new host
6. If macOS working machine: clone dotfiles, run `bootstrap/bootstrap.sh`
7. Re-run `bootstrap/tailscale.sh` on all other mesh hosts

The `tailscale.sh` script auto-discovers Tailscale peers, generates short aliases
(methylene-X → X, Y-nas → Y), and handles special hosts (Termux port/user).

## Notes

- **No passphrase on tailscale key** — hosts are only reachable via Tailscale WireGuard tunnel
- **GitHub uses a separate key** (`jurmarcus`) — not part of the mesh
- **Termux (fold)** — port 8022 (Android blocks privileged ports), keys at `~/keys/`
- **NAS boxes** — standard Linux SSH, no special config needed
- **Stowed config** — edit `~/dotfiles/ssh/.ssh/config`, then `stow -R ssh`
- **Network-only devices** — reachable by Tailscale IP for ADB, not SSH
