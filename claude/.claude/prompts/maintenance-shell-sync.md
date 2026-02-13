# Maintenance: Shell Sync Audit

> Verify zsh and fish configs are in parity | Model: default | Agents: 0

---

Audit the zsh and fish shell configurations for sync drift. Both shells must have
identical behavior — same aliases, environment, functions, and tool integrations.

## Files to compare

| Category | Zsh Source | Fish Source |
|----------|-----------|-------------|
| Main config | `~/dotfiles/zsh/.zshrc` | `~/dotfiles/fish/.config/fish/config.fish` |
| Functions | Inline in `.zshrc` | `~/dotfiles/fish/.config/fish/functions/*.fish` |
| Completions | Inline or plugins | `~/dotfiles/fish/.config/fish/completions/*.fish` |

## Check each category

### 1. Aliases / Abbreviations

Extract all aliases from zsh (alias name=value) and all abbreviations from fish.
Present as a comparison table:

| Alias | Zsh | Fish | Status |
|-------|-----|------|--------|
| `ss` | `sl status` | `sl status` | synced |
| `foo` | `bar` | — | **missing in fish** |

### 2. Environment Variables

Compare all exported variables. Pay special attention to:
- PATH modifications (tool-specific paths like cargo, bun, uv)
- EDITOR, VISUAL, PAGER
- Tool configs (FZF_DEFAULT_OPTS, ATUIN_*, STARSHIP_*)
- Custom vars (JISHO_*, project-specific)

### 3. Functions

Map zsh functions to their fish equivalents:
- Zsh: defined inline in .zshrc or as shell functions
- Fish: separate files in functions/*.fish

### 4. Tool Integrations

Verify both shells initialize these identically:
- **starship** (prompt)
- **atuin** (history)
- **fzf** (fuzzy finder)
- **zoxide** (cd replacement)
- **direnv** (env management)

### 5. Conditional Logic

Check that platform/machine-specific conditionals exist in both:
- macOS vs Linux checks
- methylene-macbook vs methylene-studio checks
- Tool availability checks (command -v / type -q)

## Output

Produce a single table of all discrepancies sorted by severity:
1. **Missing entirely** — exists in one shell, absent in other
2. **Different value** — same alias/var name, different value
3. **Different initialization** — same tool, different init approach

Do NOT edit any files until I review the findings.

---

## Notes

- **This is your most common maintenance task**: Zsh/fish drift is inevitable because they use different syntax for the same concepts. Run this monthly.
- **Aliases vs abbreviations**: Zsh uses `alias`, fish uses `abbr` (which expands inline). Functionally equivalent but syntactically different.
- **Functions are the trickiest**: Zsh puts them inline in .zshrc, fish requires separate files in functions/. Easy to add to one and forget the other.
- **"Do NOT edit until review"**: Some discrepancies are intentional (fish-specific features, zsh-specific plugins). You need to judge which to sync.
