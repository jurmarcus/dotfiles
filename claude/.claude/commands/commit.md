Create a smart conventional commit with proper message: $ARGUMENTS

## 1. Analyze Changes

Determine if using Sapling (sl) or Git:
```bash
# Check VCS type
if sl root &>/dev/null; then
  VCS="sl"
elif git rev-parse --git-dir &>/dev/null; then
  VCS="git"
fi
```

**For Sapling (sl):**
- Run `sl status` to see modified/added/removed files
- Run `sl diff` to see exact changes (Sapling has no staging - shows all uncommitted changes)
- Categorize changes by type and scope

**For Git (fallback):**
- Run `git status` to see staged files
- Run `git diff --cached` to see exact changes

## 2. Determine Commit Type

Use conventional commit format: `<type>(<scope>): <description>`

**Commit Types**:
- `feat`: New feature (user-facing)
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, no logic change)
- `refactor`: Code restructure (no behavior change)
- `perf`: Performance improvement
- `test`: Add/update tests
- `chore`: Maintenance (deps, tooling, config)
- `ci`: CI/CD changes
- `build`: Build system changes

**Scope** (optional):
- Component/module name (e.g., `api`, `parser`, `ui`)
- Language-specific (e.g., `rust`, `ts`, `py`)
- Feature area (e.g., `auth`, `search`, `cache`)

## 3. Write Commit Message

**Subject** (first line):
- Use imperative mood ("add", not "added" or "adds")
- No period at the end
- Max 72 characters
- Lowercase after colon

**Body** (optional):
- Explain *what* and *why* (not *how*)
- Wrap at 72 characters

**Footer** (optional):
- Breaking changes: `BREAKING CHANGE: <description>`
- Issue references: `Closes #123`

## 4. Pre-Commit Checks

Before committing, run checks:
- TypeScript: `bunx tsc --noEmit`
- Rust: `cargo check && cargo test`
- Python: `uvx ty check && uv run pytest`

## 5. Commit Command

### Sapling (preferred)

**Commit all changes:**
```bash
sl commit -m "$(cat <<'EOF'
feat(scope): subject line

Body explaining what and why.

EOF
)"
```

**Commit specific files only:**
```bash
# Include only certain patterns
sl commit -I '*.rs' -m "feat: message"

# Exclude certain patterns
sl commit -X 'tests/*' -m "feat: message"

# Interactive selection
sl commit -i -m "feat: message"
```

**Amend last commit:**
```bash
sl amend -m "feat(scope): updated message"
```

### Git (fallback)

```bash
git commit -m "$(cat <<'EOF'
feat(scope): subject line

Body explaining what and why.

EOF
)"
```

## 6. Push Changes

### Sapling
```bash
# Push to remote (default bookmark/branch)
sl push

# Push to specific destination
sl push --to main
```

### Git
```bash
git push
```

## Sapling Advantages

- **No staging area**: All tracked changes commit together (use `-I`/`-X` for selectivity)
- **No detached HEAD**: Bookmarks always point somewhere valid
- **Easy amend**: `sl amend` to update last commit
- **Stack workflow**: Build commits incrementally with `sl next`/`sl prev`
- **Smart log**: `sl ssl` for interactive stack view

## Guidelines

**Good commits**:
- Single logical change
- All tests pass
- Type checks pass
- Descriptive message

**Bad commits**:
- "WIP", "fixes", "updates"
- Multiple unrelated changes
- Broken tests
- Large commits (>20 files)
