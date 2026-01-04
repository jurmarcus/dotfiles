Generate changelog from commits: $ARGUMENTS

## What This Command Does

Generates a structured changelog from git commit history, grouped by type and formatted for release notes.

## Usage

- `/changelog` - Generate changelog since last tag
- `/changelog v1.2.0` - Generate changelog since v1.2.0
- `/changelog v1.2.0..v1.3.0` - Generate changelog between versions
- `/changelog --unreleased` - Show all unreleased changes

## Process

### 1. Get Commits

```bash
# Since last tag
git log $(git describe --tags --abbrev=0 2>/dev/null || echo "")..HEAD --pretty=format:"%h|%s|%an|%ad" --date=short

# Or between specific versions
git log v1.2.0..v1.3.0 --pretty=format:"%h|%s|%an|%ad" --date=short
```

### 2. Parse Conventional Commits

Group commits by type prefix:
- `feat:` → Features
- `fix:` → Bug Fixes
- `perf:` → Performance
- `refactor:` → Refactoring
- `docs:` → Documentation
- `test:` → Tests
- `chore:` → Maintenance
- `build:` → Build System
- `ci:` → CI/CD

Extract scope if present: `feat(api):` → Features (api)

### 3. Generate Changelog

```markdown
# Changelog

## [Unreleased] - YYYY-MM-DD

### Features
- **api**: Add user authentication endpoint (#123)
- **ui**: Implement dark mode toggle (#125)

### Bug Fixes
- **parser**: Fix off-by-one error in tokenizer (#127)
- **api**: Handle null response from external service (#128)

### Performance
- **db**: Add index for user lookup queries (#130)

### Breaking Changes
- **api**: Remove deprecated `/v1/users` endpoint (#126)
  - Migration: Use `/v2/users` instead

### Dependencies
- Bump `axios` from 1.4.0 to 1.5.0
- Add `zod` for runtime validation

### Contributors
- @alice (5 commits)
- @bob (3 commits)
```

## Output Options

### For CHANGELOG.md

Prepend new section to existing CHANGELOG.md, preserving history.

### For GitHub Release

Generate markdown suitable for GitHub release notes:
- Include PR links where available
- Mention contributors
- Highlight breaking changes

### For Terminal

Show condensed summary:
```
Since v1.2.0: 15 commits
  Features: 5
  Bug Fixes: 7
  Other: 3
Breaking changes: 1
```

## Special Handling

### Breaking Changes
Look for:
- `BREAKING CHANGE:` in commit body
- `!` after type: `feat!:` or `feat(api)!:`
- Commits that remove/rename public API

### Scope Grouping
Group related changes:
- `feat(auth):` and `fix(auth):` under "Authentication"
- Map common scopes to readable names

### Non-Conventional Commits
Commits without type prefix:
- Try to infer from keywords (fix, add, update, remove)
- Fall back to "Other Changes" section

## Integration

After generating:
1. Review and edit for clarity
2. Add to CHANGELOG.md (if not already)
3. Consider for release notes
