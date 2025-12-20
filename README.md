# dotfiles

Personal macOS development environment managed with GNU Stow and modular Homebrew.

## Quick Start

```bash
git clone https://github.com/jurmarcus/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap/bootstrap.sh
exec zsh
```

The bootstrap script installs Xcode CLI tools, Homebrew, stows all packages, installs brew bundles, sets up SSH/git, applies macOS defaults, and configures default apps.

## Structure

```
dotfiles/
├── bootstrap/          # Setup scripts
│   ├── bootstrap.sh    # Main orchestrator
│   ├── macos.sh        # System preferences
│   ├── git.sh          # Git identity setup
│   ├── ssh.sh          # SSH key generation
│   ├── duti.sh         # Default file associations
│   └── vscodium.sh     # VSCodium extensions
├── brew/               # Homebrew (modular)
│   ├── .Brewfile       # Main loader with host detection
│   └── .config/brew/
│       ├── hosts/      # Per-machine profiles
│       └── modules/    # Category-based packages
├── zsh/                # Shell (flat .zshrc)
│   ├── .zshrc          # Main config
│   ├── .zprofile       # Login shell
│   └── .config/zsh/templates/  # MCP server templates
├── nvim/               # Neovim (NvChad-based)
├── ghostty/            # Terminal emulator
├── starship/           # Prompt
├── zellij/             # Terminal multiplexer
├── git/                # Git config (delta pager)
├── karabiner/          # Keyboard remapping
├── claude/             # Claude Code config & commands
└── stow/               # Stow settings
```

## Components

### Homebrew

Modular system with automatic host detection.

**Modules:** ai, browsers, communication, developer, editors, entertainment, hardware, learning, photography, security, utils

**Host profiles** in `brew/.config/brew/hosts/` define which modules each machine uses.

```bash
# Add package to a module
echo 'brew "newtool"' >> brew/.config/brew/modules/developer.brew
brew bundle --global
```

### Shell

Flat `.zshrc` with modern CLI tools:

| Original | Replacement |
|----------|-------------|
| ls | eza |
| cat | bat |
| grep | ripgrep |
| find | fd |
| cd | zoxide |
| top | btop |
| diff | delta |

**Plugins:** zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search

### Development

**Python (uv):** `py`, `pyinit`, `pyr`, `pyt`, `pya`

**TypeScript (bun):** `ts`, `tsinit`, `tsr`, `tst`

**MCP servers:** `mcp-init-py`, `mcp-init-ts`

### Editors

- **Neovim** - Primary editor (NvChad framework, onedark theme)
- **VSCodium** - GUI editor (`code` alias)

### Terminal

- **Ghostty** - GPU-accelerated terminal
- **Zellij** - Tmux replacement with vim-style navigation
- **Starship** - Customized prompt (Catppuccin Frappe)

### Version Control

- **Sapling** (`sl`) - Preferred for daily use
- **Git** - With delta pager (side-by-side diffs)
- **Lazygit** - TUI interface

## Usage

```bash
# Re-stow all packages
restow

# Sync brew packages
brewsync

# Re-stow single package
cd ~/dotfiles && stow -R zsh
```

## Customization

1. Fork this repo
2. Create host profile: `brew/.config/brew/hosts/your-hostname.brew`
3. Enable desired modules in your host file
4. Modify configs as needed
5. Run `./bootstrap/bootstrap.sh`

## Files

All configs live in `~/dotfiles/` and are symlinked via Stow. Never edit files in `~/` directly.
