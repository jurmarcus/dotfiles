Create a smart conventional commit with proper message: $ARGUMENTS

## 1. Analyze Staged Changes

- Run `git status` to see staged files
- Run `git diff --cached` to see exact changes
- Categorize changes by type and scope

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
- TypeScript: `npx tsc --noEmit`
- Rust: `cargo check && cargo test`
- Python: `uvx pyright && uv run pytest`

## 5. Commit Command

Generate the commit using heredoc format:
```bash
git commit -m "$(cat <<'EOF'
feat(scope): subject line

Body explaining what and why.

EOF
)"
```

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
