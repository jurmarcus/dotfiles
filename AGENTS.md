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
├── claude/        # Claude Code (commands, agents, skills, hooks)
├── sync/          # Claude memory sync via Syncthing (folders.conf + helpers)
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
| Add Claude memory sync target | `sync/.config/claude-sync/folders.conf` | Then `claude-sync-add-folder` (see `sync/README.md`) |
| Check Claude sync health | `claude-sync-status` | Or `ssh studio claude-sync-status` |

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
| `tailscale.sh` | Generate mesh SSH config + /etc/hosts from Tailscale (step 9, or manual) | ✓ |
| `syncthing.sh` | Per-machine Syncthing setup for Claude memory sync (step 10) | ✓ |
| `syncthing-mesh.sh` | One-shot mesh pairing across macOS peers (run after 2+ bootstrapped) | ✓ |

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

## CLAUDE MEMORY SYNC

Real-time bidirectional sync of `~/.claude/memory/` and `~/.claude/projects/*/memory/` across the macOS mesh (studio, macbook, mini) via Syncthing. Live since 2026-05-10. See `sync/README.md` for full details.

**TL;DR daily commands:**

```bash
claude-sync-status                            # health check (folders, peers, conflicts)
~/dotfiles/bootstrap/syncthing.sh             # idempotent re-bootstrap (e.g., after stignore changes)
~/dotfiles/bootstrap/syncthing-mesh.sh        # re-pair after a new peer comes online (idempotent)
```

**Two synced folders:**

| Folder ID | Path | Notes |
|---|---|---|
| `claude-mem-global` | `~/.claude/memory/` | global memories — sync everything |
| `claude-mem-projects` | `~/.claude/projects/` | re-include only `**/memory/**`; everything else (session jsonl, transcripts) ignored |

**Key files:**

- `sync/.config/claude-sync/folders.conf` — declarative folder list (single source of truth)
- `sync/.config/claude-sync/stignore/` — `.stignore` templates (deployed by `syncthing.sh` via `install -m 644`)
- `sync/.local/bin/claude-sync-status` — health check helper
- `sync/.local/bin/claude-sync-add-folder` — add new sync target (e.g., to extend to plans later)
- `bootstrap/syncthing.sh` — per-machine setup (idempotent; reads API key BEFORE waiting for daemon since Syncthing v2 requires auth on `/rest/system/ping`)
- `bootstrap/syncthing-mesh.sh` — mesh pairing via SSH-tunneled REST. Skips unreachable peers. Optional `--seed-from <host>` for canonical-overwrite seeding.

**Conflicts** become `<original>.sync-conflict-<ts>-<deviceID>.<ext>` files. Resolve via the `/memory-sync` skill (audit, dedupe, merge). Deleted files are kept in `<folder>/.stversions/` for 5 versions as insurance.

**Bootstrap on a new machine:** `bootstrap.sh` Step 10 handles the per-machine setup automatically. Then run `syncthing-mesh.sh` once from any peer to wire pairings.
