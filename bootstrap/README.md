# Bootstrap Scripts

Setup scripts for new machine configuration.

## Files

```
bootstrap/
├── bootstrap.sh   # Main orchestrator
├── macos.sh       # System preferences
├── git.sh         # Git identity
├── duti.sh        # Default apps
└── vscodium.sh    # Editor extensions
```

## bootstrap.sh

Runs in order:
1. Xcode CLI Tools
2. Homebrew
3. GNU Stow + symlinks
4. Brew bundle
5. Tailscale SSH setup
6. Git identity
7. macOS settings
8. Default apps (duti)
9. VSCodium extensions

## macos.sh

Key settings:
- Caps Lock -> Control
- Fast key repeat
- Tap to click, three-finger drag
- Finder: hidden files, path bar, list view
- Dock: right side, auto-hide
- Screenshots: ~/Screenshots, PNG
- Firewall enabled

## git.sh

- Prompts for name/email
- Sets rebase, prune, histogram diff
- Configures delta pager
- macOS keychain credentials

## duti.sh

Sets VSCodium as default for code files (40+ extensions).

## Running

```bash
# Full setup
./bootstrap/bootstrap.sh

# Individual script
./bootstrap/macos.sh
```

Scripts are idempotent (safe to re-run).

## Post-Bootstrap

After running bootstrap, enable Tailscale SSH:

```bash
sudo brew services start tailscale
tailscale up
tailscale set --ssh
```
