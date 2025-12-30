# Dotfiles

macOS development environment managed with GNU Stow.

## Rules

- **Never edit files in `~/`** - modify in `~/dotfiles/`, run `stow -R <pkg>`
- Brew packages go in `brew/.config/brew/modules/`
- **When working on a component, read its README.md first** (e.g., `zsh/README.md` for shell changes)

## Components

| Package | README | Purpose |
|---------|--------|---------|
| bootstrap | `bootstrap/README.md` | Setup scripts |
| brew | `brew/README.md` | Modular Homebrew |
| zsh | `zsh/README.md` | Shell config |
| fish | `fish/README.md` | Shell config |
| templates | `templates/README.md` | Shared MCP templates |
| nvim | `nvim/README.md` | Neovim (NvChad) |
| ghostty | `ghostty/README.md` | Terminal |
| starship | `starship/README.md` | Prompt |
| zellij | `zellij/README.md` | Multiplexer |
| git | `git/README.md` | Git + delta |
| karabiner | `karabiner/README.md` | Keyboard |
| stow | `stow/README.md` | Symlink config |

## Quick Reference

### CLI Aliases
`ls`→eza, `cat`→bat, `grep`→rg, `find`→fd, `cd`→zoxide, `diff`→delta, `top`→btop, `vim`→nvim, `code`→codium

### Development
- Python: `py`, `py-init`, `pyr`, `pyt`, `pya`
- TypeScript: `ts-init`, `tsr`, `tst`, `tsa`
- MCP: `py-init-mcp`, `ts-init-mcp`

### Functions
- `restow` - Re-stow all packages
- `brewsync` - Sync Homebrew (skips if current)

## Bootstrap

```bash
./bootstrap/bootstrap.sh              # Full setup
./bootstrap/bootstrap.sh --dry-run    # Preview
./bootstrap/bootstrap.sh --help       # Options
```

**Scripts:** bootstrap.sh, macos.sh, git.sh, duti.sh, vscodium.sh, tailscale.sh (manual)

All scripts are idempotent (safe to re-run).

## Paths

- Dotfiles: `~/dotfiles`
- Config: `~/.config/`
- Templates: `~/.config/templates/`
- Homebrew: `/opt/homebrew`

## Dual-Shell Sync

**CRITICAL**: zsh and fish configs must stay synchronized.

| Change Type | Zsh Location | Fish Location |
|-------------|--------------|---------------|
| Alias | `.zshrc` | `config.fish` |
| Function | `.zshrc` | `functions/*.fish` |
| Environment | `.zshrc` | `config.fish` |

When modifying shell config, update BOTH shells.
