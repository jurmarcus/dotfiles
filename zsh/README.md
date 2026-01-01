# Zsh Configuration

Flat `.zshrc` configuration with plugins from Homebrew.

## Files

```
zsh/
├── .zshrc       # Main config (all-in-one)
├── .zshenv      # PATH for non-interactive shells (SSH, scripts)
└── .zprofile    # Login shell (Homebrew init)
```

## Structure of .zshrc

1. **Environment** - PATH, EDITOR, MANPAGER, Homebrew, BUN_INSTALL, UV_PYTHON_PREFERENCE
2. **Completions** - Cached compinit (rebuilds once/day), `regen-completions` function
3. **Tool init** - fzf, zoxide, atuin, starship
4. **History** - 50k entries, dedup, shared
5. **SSH** - Auto-attach Zellij for SSH sessions
6. **Zellij** - Session management functions
7. **Aliases** - Modern CLI replacements
8. **Functions** - Claude workflow, dotfiles, Python/TS, MCP
9. **Plugins** - zsh-autosuggestions, zsh-syntax-highlighting

## Aliases (synced with fish)

| Category | Aliases |
|----------|---------|
| Files | `ls/ll/la/lt`→eza, `cat`→bat, `grep`→rg, `find`→fd |
| System | `top/htop`→btop, `ps`→procs, `du`→dust, `df`→duf, `help`→tldr |
| Editors | `vim/vi/v/nano`→nvim, `code`→codium |
| Sapling | `ss`, `sa`, `sc`, `sp`, `spl`, `sar` |
| GitHub | `pr`, `issue`, `repo` |
| Navigation | `..`, `...`, `....`, `.....` |

## Functions

| Function | Description |
|----------|-------------|
| `context` | Project tree + sapling status |
| `yank <file>` | Copy file to clipboard |
| `yankdir [dir] [depth]` | Copy tree to clipboard |
| `watch <cmd> [ext]` | watchexec wrapper |
| `restow` | Re-stow all packages |
| `brewsync [clean]` | Sync Homebrew |
| `regen-completions` | Rebuild completion cache |

### Dev Functions
| Function | Description |
|----------|-------------|
| `py-init [name]` | Create uv Python project |
| `ts-init [name]` | Create bun TypeScript project |
| `rs-init [name]` | Create cargo Rust project |
| `py-init-mcp [name]` | Create Python MCP server |
| `ts-init-mcp [name]` | Create TypeScript MCP server |
| `pyr`, `pyt`, `pya`, `pyx`, `pyb` | uv run/pytest/add/uvx/build |
| `pyl`, `pyf` | ruff check/format (via uvx) |
| `tsr`, `tst`, `tsa`, `tsx`, `tsb` | bun run/test/add/x/build |
| `tsl`, `tsf` | biome lint/format (via bunx) |
| `rsr`, `rst`, `rsa`, `rsb` | cargo run/test/add/build |
| `rsl`, `rsf` | cargo clippy/fmt |

### Zellij Functions
| Function | Description |
|----------|-------------|
| `zls` | List sessions |
| `zcd <session>` | Attach to session |
| `zrm <session>` | Delete session |
| `zclaude` | New numbered claude session |
| `zopencode` | New numbered opencode session |

## Plugins

From Homebrew (must be last in .zshrc):
- `zsh-autosuggestions` - Fish-like suggestions
- `zsh-syntax-highlighting` - Command highlighting

## Key Bindings

- `Ctrl+R` - fzf history (via atuin)
- `Ctrl+T` - fzf file search
- `Alt+C` - fzf cd
