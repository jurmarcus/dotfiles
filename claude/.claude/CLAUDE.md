# Dotfiles - Claude Context

## Repository Structure

```
dotfiles/
├── brew/           # Homebrew (modular with host profiles)
│   ├── .Brewfile   # Main loader
│   └── .config/brew/
│       ├── hosts/  # Host-specific configs
│       └── modules/# Category-based packages
├── claude/         # Claude Code config & slash commands
├── git/            # Git configuration (delta pager)
├── ghostty/        # Ghostty terminal
├── nvim/           # Neovim editor
├── starship/       # Shell prompt
├── vscodium/       # VSCodium editor
├── zellij/         # Terminal multiplexer
├── zsh/            # Shell configuration
│   ├── .zprofile   # Login shell (homebrew init)
│   └── .zshrc      # Main config (flat file)
├── macos/          # macOS settings script
├── stow/           # Stow configuration
└── bootstrap.sh    # Setup script
```

## Key Information

### Symlink Management
- Uses **GNU Stow** - never edit files in `~/` directly
- Always modify source files in `~/dotfiles/`
- Run `stow <package>` to create symlinks

### Shell
- **Zsh** with flat `.zshrc` (not modular)
- **Starship** prompt
- **Atuin** for shell history (SQLite + sync)
- **Zoxide** replaces `cd` command

### Editors
- **Neovim** is primary (`$EDITOR`)
- **VSCodium** for GUI editing
- Aliases: `vim`, `vi`, `v`, `nano` -> `nvim`, `code` -> `codium`

### Version Control
- **Sapling** (`sl`) preferred over git for daily use
- **Git** for compatibility
- **Delta** as git pager (side-by-side, line numbers)
- **Lazygit** for TUI

### Modern CLI Replacements

| Alias | Tool | Replaces |
|-------|------|----------|
| `ls`, `ll`, `la`, `lt` | eza | ls |
| `cat` | bat | cat |
| `grep` | ripgrep | grep |
| `find` | fd | find |
| `top`, `htop` | btop | top/htop |
| `diff` | delta | diff |
| `du` | dust | du |
| `df` | duf | df |
| `ps` | procs | ps |
| `curl` | xh | curl |
| `help` | tldr | man |
| `cd` | zoxide | cd |
| `hg` | sapling | hg |

### Claude Workflow Functions

- `context` - Show project structure and git status
- `yank <file>` - Copy file contents to clipboard
- `yankdir [dir] [depth]` - Copy directory tree to clipboard
- `watch <cmd> [ext]` - Run command on file changes
- `dft` - Syntax-aware diff (difftastic)

### Python / uv Workflow

| Command | Description |
|---------|-------------|
| `py` | python3 |
| `ipy` | IPython via uvx |
| `pip` | uv pip |
| `pyinit [name]` | Create Python project with ruff+pytest |
| `pyr <file>` | Run Python with uv |
| `pyt` | Run pytest |
| `pya <pkg>` | Add dependency |
| `uvr <tool>` | Run any tool via uvx |

### TypeScript / bun Workflow

| Command | Description |
|---------|-------------|
| `ts` | bun run |
| `tsx` | Run TS directly |
| `tsinit [name]` | Create TS project |
| `tsr <file>` | Run with bun |
| `tst` | Run tests |

### MCP Development

| Command | Description |
|---------|-------------|
| `mcp-init-py [name]` | Create Python MCP server |
| `mcp-init-ts [name]` | Create TypeScript MCP server |

### Brew Modules

Enabled via host file (`hosts/methylene-macbook.brew`):
- ai, browsers, communication, developer, editors
- entertainment, hardware, learning, photography, security, utils

### Code Formatting

- **ruff** - Python linting/formatting (Rust-based, fast)
- **biome** - JS/TS/CSS/JSON formatting & linting (Rust-based, replaces prettier+eslint)

## Common Tasks

```bash
# Install new brew package
# 1. Add to appropriate module in brew/.config/brew/modules/
# 2. Run: brew bundle --global

# Update dotfiles
cd ~/dotfiles && sl commit -m "message" && sl push

# Re-stow a package
cd ~/dotfiles && stow -R zsh

# Update tldr pages
tldr --update
```

## Paths

- Dotfiles: `~/dotfiles` (this repo)
- Homebrew: `/opt/homebrew`
- Config: `~/.config/`
- Local bin: `~/.local/bin`
