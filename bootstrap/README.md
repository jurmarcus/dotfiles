# Bootstrap Scripts

Setup scripts for new macOS machine configuration.

## Quick Start

```bash
./bootstrap/bootstrap.sh              # Full bootstrap
./bootstrap/bootstrap.sh --dry-run    # Preview changes
./bootstrap/bootstrap.sh --help       # Show options
```

## Files

```
bootstrap/
├── bootstrap.sh    # Main orchestrator
├── macos.sh        # System preferences
├── git.sh          # Git/Sapling identity
├── duti.sh         # Default file associations
├── vscodium.sh     # Editor extensions
└── tailscale.sh    # Generate /etc/hosts from Tailscale (manual)
```

## bootstrap.sh

Main orchestrator with CLI flags:

| Flag | Description |
|------|-------------|
| `-h, --help` | Show usage |
| `-n, --dry-run` | Preview without changes |
| `-v, --verbose` | Debug output |

### Steps

1. **Xcode CLI Tools** - Required for git, compilers
2. **Homebrew** - Package manager + PATH setup for this script
3. **Stow** - Install via brew (if needed) + symlink dotfiles
4. **Brew bundle** - Remaining packages (stow already installed)
5. **Git identity** - Prompt for name/email
6. **macOS settings** - System preferences
7. **Default apps** - File associations via duti
8. **VSCodium extensions** - Editor plugins

## git.sh

Configures Git, Sapling, and GitHub CLI identity.

**Identity sources** (in order):
1. `GIT_AUTHOR_NAME` / `GIT_AUTHOR_EMAIL` env vars
2. `~/Documents/keys/git_info` file (iCloud synced)
3. Existing git config (shown as default in prompt)
4. Interactive prompt

**git_info format:**
```bash
GIT_AUTHOR_NAME="Jurmarcus"
GIT_AUTHOR_EMAIL="me@jurmarcus.com"
```

**Settings applied:**
- `pull.rebase true`
- `push.autoSetupRemote true`
- `fetch.prune true`
- `diff.algorithm histogram`
- `merge.conflictstyle zdiff3`
- `rerere.enabled true`
- Delta pager (if installed)
- macOS Keychain credential helper

## macos.sh

Applies system preferences. Closes System Settings first to prevent conflicts.

| Category | Settings |
|----------|----------|
| Keyboard | Fast repeat, disable auto-correct/capitalize/dash/period/quote |
| Trackpad | Speed 3.0, tap to click, three-finger drag |
| Finder | Hidden files, extensions, path bar, list view, folders first |
| Dock | Right side, auto-hide, no delay, no recents, 48px icons |
| Desktop | Hide icons, disable click-to-show |
| Screenshots | ~/Screenshots, PNG, no shadow |
| Security | Firewall enabled, stealth mode, immediate password on sleep |
| Continuity | Disable Universal Control (cross-device pointer/keyboard) |
| Safari | Full URL, Develop menu, no AutoFill |
| Misc | Expanded save/print panels, save to disk not iCloud |

**Requires logout/restart:** Some settings (trackpad, keyboard modifiers)

## duti.sh

Sets default applications by file extension using duti.

| Type | Application | Extensions |
|------|-------------|------------|
| Code | VSCodium | .py, .js, .ts, .go, .rs, .json, .yaml, .md, etc. |
| Web | Safari | .html, .htm, .url, .webloc |
| PDF | Preview | .pdf |
| Images | Preview | .png, .jpg, .gif, .webp, etc. |

## vscodium.sh

Installs VSCodium extensions:
- AI: Claude, Gemini, ChatGPT
- Theme: Catppuccin
- Productivity: Anki Editor

## Idempotency

All scripts are safe to re-run:
- Checks existing state before changes
- `brew bundle check` skips if packages installed
- Git identity shows existing values as defaults
- Stow handles existing symlinks

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `GIT_AUTHOR_NAME` | Skip git name prompt |
| `GIT_AUTHOR_EMAIL` | Skip git email prompt |

## SSH Keys & Identity

Stored in iCloud-synced `~/Documents/keys/`:

| File | Purpose |
|------|---------|
| `personal` | SSH private key |
| `personal.pub` | SSH public key |
| `git_info` | Git identity (name/email) |

These sync automatically across machines via iCloud Drive.

## tailscale.sh (Manual)

Generates host entries from Tailscale network peers. Run manually when needed:

```bash
./bootstrap/tailscale.sh
```

**Creates:**
- `~/.config/tailscale/hosts` - Host entries to paste into /etc/hosts
- `~/.ssh/tailscale_config` - SSH config with host aliases

**Not part of bootstrap flow** - run separately after Tailscale app is configured.

## Post-Bootstrap

```bash
# Open new terminal for shell changes
exec zsh  # or: exec fish

# Log out/in for some macOS settings to take effect
```
