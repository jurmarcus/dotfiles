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
| tmux | `tmux/README.md` | Multiplexer |
| git | `git/README.md` | Git + delta |
| karabiner | `karabiner/README.md` | Keyboard |
| opencode | `opencode/README.md` | AI coding assistant |
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

## Claude Code Automation

**COMPLETE DEVELOPMENT WORKFLOW AUTOMATION**: Hooks, skills, and commands for Python, TypeScript, and Rust projects.

📖 **Full Guide**: See `~/.claude/AUTOMATION.md` for comprehensive documentation.

### Quick Reference

**Hooks** (run automatically):
- ✅ Type checking after edits (Python, TypeScript, Rust)
- ✅ Auto-formatting after edits (prettier, rustfmt, ruff)
- ✅ Tests after edits (pytest, jest, cargo test)
- ✅ Pre-commit checks (format, LSP, tests, lint, TODO scan)
- ✅ Session summary on exit

**Commands** (invoke with `/command`):
- `/test <file>` - Generate comprehensive tests
- `/review <file>` - Code review for bugs/security/performance
- `/doc [file]` - Update CLAUDE.md, README.md, docstrings
- `/commit [msg]` - Smart conventional commits
- `/refactor <target>` - Guided refactoring with safety checks
- `/perf <file>` - Performance analysis and optimization
- `/debug <issue>` - Investigate without fixing
- `/design <feature>` - Create implementation plan
- `/migrate <from> <to>` - Safe pattern/library migration

**Skills** (auto-triggered):
- `homebrew-modular` - Add brew packages to dotfiles modules
- `dotfiles-stow` - Stow changes after editing dotfiles

### Supported Languages

All hooks and commands support:
- 🐍 **Python**: ty, pytest, ruff format (via uv/uvx)
- 📘 **TypeScript**: tsc, bun test, prettier (via bun/bunx)
- 🦀 **Rust**: cargo check, cargo test, rustfmt

### Configuration

**Location**: `~/.claude/hooks/`

**Disable a hook**:
```bash
mv ~/.claude/hooks/hook-name.sh{,.disabled}
```

**Enable a hook**:
```bash
mv ~/.claude/hooks/hook-name.sh{.disabled,}
```

### Workflow

```
1. Code changes → Auto: type check, format, test
2. /review → Code review
3. /doc → Update documentation
4. /commit → Smart commit with pre-commit checks
5. Session end → Summary of changes
```

All automation is **invisible**, **fast** (<5s), and **helpful** (catches errors early).
