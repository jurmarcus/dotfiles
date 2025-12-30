# Fish Configuration

Modular fish config with auto-loading functions.

## Files

```
fish/
└── .config/fish/
    ├── config.fish           # Main config (env, aliases, abbreviations)
    └── functions/            # Auto-loaded functions
        ├── claude.fish       # context, yank, yankdir, watch
        ├── dotfiles.fish     # restow, brewsync
        ├── mcp.fish          # template, py-init-mcp, ts-init-mcp
        ├── python.fish       # py-init
        ├── typescript.fish   # ts-init
        └── zellij.fish       # _znew, zclaude, zopencode, zservice
```

## Structure of config.fish

1. **Environment** - PATH, EDITOR, VISUAL, MANPAGER, FZF_*, Homebrew, BUN_INSTALL
2. **Tool init** - fzf, zoxide, atuin, starship (interactive only)
3. **SSH auto-attach** - Zellij for SSH sessions
4. **Abbreviations** - Sapling (ss, sa, sc), GitHub (pr, issue), Zellij (zls, zcd), Navigation (..)
5. **Aliases** - Modern CLI replacements, Python/TS shortcuts

## Aliases (synced with zsh)

| Category | Aliases |
|----------|---------|
| Files | `ls/ll/la/lt`→eza, `cat`→bat, `grep`→rg, `find`→fd |
| System | `top/htop`→btop, `ps`→procs, `du`→dust, `df`→duf, `help`→tldr |
| Editors | `vim/vi/v/nano`→nvim, `code`→codium |
| Python | `python/py`→`uv run python`, `pyr`, `pyt`, `pya`, `pyx` |
| TypeScript | `tsr`, `tst`, `tsa`, `tsx` |

## Functions

| Function | File | Description |
|----------|------|-------------|
| `context` | claude.fish | Project tree + sapling status |
| `yank <file>` | claude.fish | Copy file to clipboard |
| `yankdir [dir] [depth]` | claude.fish | Copy tree to clipboard |
| `watch <cmd> [ext]` | claude.fish | watchexec wrapper |
| `restow` | dotfiles.fish | Re-stow all packages |
| `brewsync [clean]` | dotfiles.fish | Sync Homebrew |
| `py-init [name]` | python.fish | Create uv Python project |
| `ts-init [name]` | typescript.fish | Create bun TS project |
| `py-init-mcp [name]` | mcp.fish | Create Python MCP server |
| `ts-init-mcp [name]` | mcp.fish | Create TypeScript MCP server |
| `zclaude` | zellij.fish | New numbered claude session |
| `zopencode` | zellij.fish | New numbered opencode session |

## Abbreviations vs Aliases

- **Abbreviations** (`abbr`): Expand inline, visible in history
- **Aliases** (`alias`): Execute directly, show alias in history

Fish uses abbreviations for Sapling/GitHub/Zellij commands so you see the expanded command.

## Key Bindings

- `Ctrl+R` - fzf history (via atuin)
- `Ctrl+T` - fzf file search
- `Alt+C` - fzf cd

## Differences from Zsh

| Feature | Fish | Zsh |
|---------|------|-----|
| Autosuggestions | Built-in | Plugin required |
| Syntax highlighting | Built-in | Plugin required |
| Functions | Separate files (auto-load) | In .zshrc |
| History | Built-in + atuin | Configured + atuin |
