# Dotfiles

macOS development environment managed with GNU Stow.

## Rules

- **Never edit files in `~/`** - modify in `~/dotfiles/`, run `stow -R <pkg>`
- Brew packages go in `brew/.config/brew/modules/`
- **When working on a component, read its README.md first** (e.g., `zsh/README.md` for shell changes)

## Components

| Package | README | Purpose |
|---------|--------|---------|
| brew | `brew/README.md` | Modular Homebrew |
| zsh | `zsh/README.md` | Shell config |
| nvim | `nvim/README.md` | Neovim (NvChad) |
| ghostty | `ghostty/README.md` | Terminal |
| starship | `starship/README.md` | Prompt |
| zellij | `zellij/README.md` | Multiplexer |
| git | `git/README.md` | Git + delta |
| karabiner | `karabiner/README.md` | Keyboard |
| bootstrap | `bootstrap/README.md` | Setup scripts |
| stow | `stow/README.md` | Symlink config |

## Quick Reference

### CLI Aliases
`ls`->eza, `cat`->bat, `grep`->rg, `find`->fd, `cd`->zoxide, `diff`->delta, `top`->btop, `vim`->nvim, `code`->codium

### Development
- Python: `py`, `pyinit`, `pyr`, `pyt`, `pya`
- TypeScript: `ts`, `tsinit`, `tsr`, `tst`
- MCP: `mcp-init-py`, `mcp-init-ts`

### Functions
- `restow` - Re-stow all packages
- `brewsync` - Sync Homebrew

## Paths

- Dotfiles: `~/dotfiles`
- Config: `~/.config/`
- Homebrew: `/opt/homebrew`
