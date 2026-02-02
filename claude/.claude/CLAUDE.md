# Development Environment

macOS development environment managed with GNU Stow.

## Critical Rules

These rules MUST be followed without exception:

- **Always use `sl` (Sapling), never `git`** - `sl status`, `sl commit`, `sl push`
- **Always use Claude Code tasks** - Every task = 1 commit for clean diff stacks
- **Never edit files in `~/`** - Modify in `~/dotfiles/`, run `stow -R <pkg>`
- **Always use `just`** - Never raw `cargo build`, `bun run`, `uv run`
- **When working on a component, read its README.md first**

## Version Control: Sapling

Use `sl` for everything. Git is only for compatibility.

| Alias | Command | Purpose |
|-------|---------|---------|
| `ss` | `sl status` | Show status |
| `sa` | `sl add` | Stage files |
| `sc` | `sl commit` | Commit |
| `sp` | `sl push` | Push |
| `spl` | `sl pull --rebase` | Pull with rebase |
| `sar` | `sl addremove` | Add new, remove deleted |

### Diff Stacks Workflow

When working on a plan/project with multiple tasks:

1. **Create a task per logical unit** using Claude Code tasks
2. **Each task = one `sl commit`** with the task purpose as message
3. This creates a reviewable diff stack
4. Use `sl push` to push the stack for review

## Language Tooling

### Python: Always `uv`

Never use pip, venv, or virtualenv directly.

| Alias | Command | Purpose |
|-------|---------|---------|
| `py` | `uv run python` | Run Python |
| `pya` | `uv add` | Add dependency |
| `pyt` | `uv run pytest` | Run tests |
| `pyf` | `uvx ruff format` | Format |
| `pyl` | `uvx ruff check` | Lint |
| - | `py-init <name>` | New project (uv init + ruff + pytest) |

### TypeScript: Always `bun`

Never use npm, yarn, or pnpm.

| Alias | Command | Purpose |
|-------|---------|---------|
| `tsr` | `bun run` | Run script |
| `tsa` | `bun add` | Add dependency |
| `tst` | `bun test` | Run tests |
| `tsf` | `bunx biome format` | Format |
| `tsl` | `bunx biome lint` | Lint |
| - | `ts-init <name>` | New project (bun init + typescript) |

### Rust: `cargo` with edition 2024

| Alias | Command | Purpose |
|-------|---------|---------|
| `rsr` | `cargo run` | Run |
| `rsa` | `cargo add` | Add dependency |
| `rst` | `cargo test` | Test |
| `rsf` | `cargo fmt` | Format |
| `rsl` | `cargo clippy` | Lint |
| - | `rs-init <name>` | New project |

Use `edition = "2024"` in Cargo.toml (valid since Rust 1.85, Jan 2025).

## Task Runner: `just`

Always use `just` (justfile) over Makefiles or npm scripts.

```bash
just              # List available tasks
just <task>       # Run task
just <module> <task>  # Monorepo pattern
```

## CLI Tool Preferences

Always use these modern alternatives:

| Instead of | Use | Aliases |
|------------|-----|---------|
| git | sl (Sapling) | `ss`, `sa`, `sc`, `sp`, `spl`, `sar` |
| ls | eza | `ls`, `ll`, `la`, `lt` |
| cat | bat | `cat` |
| grep | rg (ripgrep) | `grep` |
| find | fd | `find` |
| cd | zoxide | `cd` |
| diff | delta | - |
| top/htop | btop | `top`, `htop` |
| du | dust | `du` |
| df | duf | `df` |
| ps | procs | `ps` |
| man | bat (as pager) | - |
| help | tldr | `help` |
| vim/vi/nano | nvim | `vim`, `vi`, `v`, `nano` |
| vscode | codium | `code` |
| npm/yarn/pnpm | bun | See TypeScript section |
| pip/venv | uv | See Python section |

## Environment

- **direnv** for per-directory env vars (`.envrc` files)
- **starship** prompt
- **atuin** for shell history
- **fzf** for fuzzy finding
- **tmux** for terminal multiplexing

## Multi-Machine Development

Development happens across Tailscale network:

| Machine | Role |
|---------|------|
| `methylene-studio` | Server (databases, APIs, Sudachi) |
| `methylene-macbook` | Laptop (client, MCP, apps) |

Environment variables via direnv:
- `cd server/` → localhost URLs, DB paths
- `cd mcp/` or `cd app/` → remote URLs via Tailscale

Use `JISHO_REMOTE_HOST` and similar env vars for cross-machine URLs.

## Commit Messages

Always use conventional commits with optional scope:

```
feat(web): add user authentication
fix(api): handle null response
refactor(core): simplify error handling
docs: update README
```

## Project Structure

### Monorepos

Use layered CLAUDE.md files:

```
project/
├── CLAUDE.md           # Root: architecture, commands
├── server/CLAUDE.md    # Layer: server-specific
├── mcp/CLAUDE.md       # Layer: MCP-specific
└── app/CLAUDE.md       # Layer: app-specific
```

### Dotfiles

```
~/dotfiles/           # Source (edit here)
├── zsh/              # Shell config
├── fish/             # Shell config (keep in sync!)
├── brew/             # Modular Homebrew
│   └── .config/brew/modules/  # *.brew files
└── ...
```

**Brew Modules**: Add packages to appropriate `.brew` file, run `brewsync`.

## MCP Development

Scaffold new MCP servers:

```bash
py-init-mcp <name>    # Python MCP with mcp SDK
ts-init-mcp <name>    # TypeScript MCP with @modelcontextprotocol/sdk
```

Templates in `~/.config/templates/`.

## Dual-Shell Sync

**CRITICAL**: zsh and fish configs must stay synchronized.

| Change Type | Zsh Location | Fish Location |
|-------------|--------------|---------------|
| Alias | `.zshrc` | `config.fish` |
| Function | `.zshrc` | `functions/*.fish` |
| Environment | `.zshrc` | `config.fish` |

## Claude Code Automation

Full automation docs: `~/.claude/AUTOMATION.md`

**Hooks** (automatic):

| Hook | Trigger | Purpose |
|------|---------|---------|
| lsp-check | After Edit | Type checking (tsc, ty, cargo check) |
| format-on-edit | After Edit | Auto-format (prettier, ruff, rustfmt) |
| test-after-edit | After Edit | Run targeted tests |
| pre-commit-checks | Before commit | Format, lint, test, dead code scan |
| session-summary | Session end | Generate session summary |

**Commands** (invoke with `/command`):

| Command | Purpose |
|---------|---------|
| `/test <file>` | Generate tests |
| `/review <file>` | Code review |
| `/commit [msg]` | Smart commit (uses `sl`) |
| `/refactor <target>` | Guided refactoring |
| `/design <feature>` | Implementation plan |
| `/doc [file]` | Update docs |

**Skills** (auto-triggered):

| Skill | Purpose |
|-------|---------|
| `dotfiles-stow` | Apply dotfiles with Stow |
| `homebrew-modular` | Add packages to brew modules |
