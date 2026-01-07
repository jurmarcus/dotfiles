# AGENTS.md

macOS dotfiles via GNU Stow. Dual-shell (zsh + fish) with shared configs.

## STRUCTURE

```
dotfiles/
├── bootstrap/     # Setup scripts (run once)
├── brew/          # Modular Homebrew (host-based)
├── zsh/           # Zsh config (flat .zshrc)
├── fish/          # Fish config (modular functions/)
├── templates/     # Shared MCP templates (both shells)
├── nvim/          # Neovim (NvChad)
├── ghostty/       # Terminal
├── tmux/          # Multiplexer
├── starship/      # Prompt
├── git/           # Git + delta
├── karabiner/     # Keyboard remaps
├── ssh/           # SSH config
├── claude/        # Claude Code commands
└── stow/          # Stow ignore rules
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add CLI tool | `brew/.config/brew/modules/developer.brew` | Then `brewsync` |
| Add shell alias | `zsh/.zshrc` AND `fish/.config/fish/config.fish` | Keep synced |
| Add shell function | `zsh/.zshrc` AND `fish/.config/fish/functions/*.fish` | fish is modular |
| Add MCP template | `templates/.config/templates/` | Shared by both shells |
| Add macOS setting | `bootstrap/macos.sh` | Grouped by category |
| Add default app | `bootstrap/duti.sh` | By file extension |
| Change editor keys | `nvim/.config/nvim/lua/mappings.lua` | |
| Change tmux config | `tmux/.config/tmux/tmux.conf` | |

## BOOTSTRAP

New machine setup: `./bootstrap/bootstrap.sh`

| Flag | Effect |
|------|--------|
| `--help` | Show usage |
| `--dry-run` | Preview without changes |
| `--verbose` | Debug output |

### Scripts

| Script | Purpose | Idempotent |
|--------|---------|------------|
| `bootstrap.sh` | Main orchestrator | ✓ |
| `macos.sh` | System preferences | ✓ |
| `git.sh` | VCS identity (reads ~/Documents/keys/git_info or prompts) | ✓ |
| `duti.sh` | File associations | ✓ |
| `vscodium.sh` | Editor extensions | ✓ |
| `tailscale.sh` | Generate /etc/hosts from Tailscale peers (manual) | ✓ |

### Adding macOS Settings

1. Find the setting: Change in GUI, then `defaults read > after.txt`, diff with before
2. Add to appropriate section in `bootstrap/macos.sh`
3. Add `killall` for affected app if needed (Dock, Finder, SystemUIServer)

## CONVENTIONS

- **Never edit ~/**: Modify in `~/dotfiles/`, then `stow -R <pkg>`
- **Dual-shell sync**: zsh and fish MUST have identical aliases/functions
- **Templates shared**: Both shells use `~/.config/templates/`
- **Bootstrap idempotent**: All scripts safe to re-run

## SHELL PARITY (zsh ↔ fish)

| Feature | Zsh | Fish |
|---------|-----|------|
| Main config | `.zshrc` (monolithic) | `config.fish` + `functions/*.fish` |
| Aliases | In `.zshrc` | In `config.fish` |
| Functions | In `.zshrc` | Separate files in `functions/` |
| Abbreviations | N/A (use aliases) | `abbr` in `config.fish` |
| Plugins | External (homebrew) | Built-in |

### Synced Features
- Environment: EDITOR, VISUAL, MANPAGER, FZF_*, BUN_INSTALL, UV_PYTHON_PREFERENCE
- Tool init: fzf, zoxide, atuin, starship
- Aliases: ls→eza, cat→bat, grep→rg, find→fd, vim→nvim, etc.
- Dev aliases: pyr, pyt, pya, tsr, tst, tsa
- Functions: py-init, ts-init, py-init-mcp, ts-init-mcp, restow, brewsync
- Tmux: tls, tcd, tk, tka, tssh, tclaude, topencode, tservice

## ANTI-PATTERNS

- **Shell-specific templates**: Use shared `templates/` package
- **Editing ~/ directly**: Stow will overwrite; edit source in dotfiles/
- **Forgetting dual-shell**: Adding feature to one shell but not the other
- **Host-specific in modules**: Put machine-specific in `brew/.config/brew/hosts/`
- **Hardcoded identity**: Use env vars or prompts in bootstrap scripts

## COMMANDS

```bash
restow              # Re-stow all packages
brewsync            # Install from Brewfile (skips if current)
brewsync clean      # Install + remove orphans
stow -R <pkg>       # Re-stow single package
```

## NOTES

- Fish functions auto-load from `functions/` dir (no source needed)
- Zsh plugins from homebrew: zsh-autosuggestions, zsh-syntax-highlighting
- Fish has these built-in
- Atuin handles history for both shells
- Karabiner handles Caps Lock→Control (persistent across reboots)
