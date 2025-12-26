# Zsh Configuration

Flat `.zshrc` configuration (not modular).

## Files

```
zsh/
├── .zshrc                      # Main config (all-in-one)
├── .zshenv                     # Non-interactive shell PATH (SSH, mosh)
├── .zprofile                   # Login shell (Homebrew init)
└── .config/zsh/
    └── templates/              # MCP server templates
        ├── mcp-server.py
        └── mcp-server.ts
```

## Structure of .zshrc

1. **Environment** - PATH, EDITOR, MANPAGER, Homebrew paths, Bun paths
2. **Caching** - compinit (rebuilds once/day), tool inits
3. **History** - 10k entries, ~/.zsh_history, SHARE_HISTORY
4. **Plugins** - fzf, zoxide, starship, completions
5. **SSH/Remote** - Auto-attach Zellij for SSH sessions
6. **Aliases** - Modern CLI replacements
7. **Functions** - Claude workflow, dotfiles, Python/TS, MCP
8. **Zsh plugins** - autosuggestions, syntax-highlighting, history-substring-search

## Aliases

| Category | Aliases |
|----------|---------|
| Files | `ls/ll/la/lt`->eza, `cat`->bat, `grep`->rg, `find`->fd, `diff`->delta |
| System | `top/htop`->btop, `ps`->procs, `du`->dust, `df`->duf, `help`->tldr |
| Editors | `vim/vi/v/nano`->nvim, `code`->codium |
| Git | `g`, `gs`, `ga`, `gc`, `gp`, `gl`, `gd`, `gds`, `lg`->lazygit |
| VCS | `hg`->sapling |

## Functions

| Function | Description |
|----------|-------------|
| `context` | Show project tree + git status |
| `yank <file>` | Copy file to clipboard |
| `yankdir [dir] [depth]` | Copy tree to clipboard |
| `watch <cmd> [ext]` | Run command on file changes |
| `restow` | Re-stow all packages |
| `brewsync [clean]` | Sync Homebrew packages |

### Python (uv)
`py`, `pyinit`, `pyr`, `pyt`, `pya`, `uvr`

### TypeScript (bun)
`ts`, `tsx`, `tsinit`, `tsr`, `tst`

### MCP
`mcp-init-py [name]`, `mcp-init-ts [name]`

## Plugins

1. zsh-autosuggestions - Fish-like suggestions
2. zsh-syntax-highlighting - Command highlighting
3. zsh-history-substring-search - Up/Down arrow search

## Key Bindings

- `Ctrl+R` - fzf history search
- `Up/Down` - history substring search
- `Ctrl+T` - fzf file search
