# dotfiles

macOS development environment managed with GNU Stow. Dual-shell setup (zsh + fish).

## Quick Start

```bash
git clone https://github.com/jurmarcus/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap/bootstrap.sh
exec zsh  # or: exec fish
```

## Structure

```
dotfiles/
├── bootstrap/     # Setup scripts
├── brew/          # Modular Homebrew (host-based)
├── zsh/           # Zsh config
├── fish/          # Fish config
├── templates/     # Shared MCP templates
├── nvim/          # Neovim (NvChad)
├── ghostty/       # Terminal
├── tmux/          # Multiplexer
├── starship/      # Prompt
├── git/           # Git + delta
├── karabiner/     # Keyboard remaps
├── ssh/           # SSH config
├── claude/        # Claude Code commands
└── stow/          # Stow settings
```

## Shells

Both zsh and fish are configured identically with modern CLI replacements:

| Original | Replacement | Original | Replacement |
|----------|-------------|----------|-------------|
| ls | eza | cd | zoxide |
| cat | bat | top | btop |
| grep | rg | diff | delta |
| find | fd | vim | nvim |

**Zsh**: Flat `.zshrc` with plugins from Homebrew
**Fish**: Modular `config.fish` + `functions/` directory

## Development

| Language | Runtime | Commands |
|----------|---------|----------|
| Python | uv | `py`, `py-init`, `pyr`, `pyt`, `pya` |
| TypeScript | bun | `ts-init`, `tsr`, `tst`, `tsa` |
| MCP | both | `py-init-mcp`, `ts-init-mcp` |

## Tools

- **Editor**: Neovim (NvChad) + VSCodium
- **Terminal**: Ghostty
- **Multiplexer**: Tmux
- **Prompt**: Starship (Catppuccin Frappe)
- **VCS**: Sapling (`sl`) + Git + Lazygit
- **History**: Atuin

## Usage

```bash
restow              # Re-stow all packages
brewsync            # Sync Homebrew packages
brewsync clean      # Sync + remove orphans
stow -R <pkg>       # Re-stow single package
```

## Customization

1. Fork repo
2. Create host profile: `brew/.config/brew/hosts/$(hostname).brew`
3. Enable modules in host file
4. Run `./bootstrap/bootstrap.sh`

## Files

All configs live in `~/dotfiles/` and are symlinked via Stow. **Never edit files in `~/` directly.**
