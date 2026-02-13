# Maintenance: Full Repo Sweep

> Comprehensive repository health check — dead code, stale refs, config drift | Model: Haiku | Agents: 3

---

Create an agent team with 3 teammates to do a comprehensive health sweep of [REPO_PATH].
Use Haiku for each teammate. Research only — no edits.

## Teammate 1: Dead Code & Stale References

Scan the entire codebase for:

1. **Unused exports** — functions, types, constants exported but never imported elsewhere
2. **Unused imports** — imports that aren't referenced in the file
3. **Commented-out code** — blocks of code in comments (not documentation comments)
4. **Unreachable code** — code after return/throw, impossible branches
5. **Stale TODO/FIXME** — comments referencing completed work, closed issues, or old dates
6. **Orphan files** — files not imported/referenced by any other file

For each finding, report file:line and a brief explanation of why it's dead.
Do NOT edit any files — research only.

## Teammate 2: Configuration Drift

Check all configuration files for inconsistencies and staleness:

1. **CLAUDE.md accuracy** — do the described commands, paths, and patterns still match reality?
2. **justfile recipes** — do all recipes still work? Reference correct paths?
3. **CI/CD config** — if present, does it match the actual build/test process?
4. **Type config** — tsconfig.json, pyproject.toml [tool.ruff], Cargo.toml — are settings consistent?
5. **Environment files** — .envrc, .env.example — do they reference valid services/paths?
6. **Dependencies** — any deprecated packages? Major version bumps available?

For each finding, report the config file and what's drifted.
Do NOT edit any files — research only.

## Teammate 3: Test Health

Evaluate the test suite quality:

1. **Coverage gaps** — source files with no corresponding test file
2. **Broken tests** — tests that reference removed functions, wrong paths, stale fixtures
3. **Flaky indicators** — tests with sleep/timeout, network calls without mocks, date-dependent assertions
4. **Test organization** — are tests colocated or in a separate tree? Is it consistent?
5. **Missing edge cases** — for core business logic, are error paths and boundary conditions tested?

Report as a table: source file → test file → status (tested/untested/partial).
Do NOT edit any files — research only.

## Coordination

After all teammates report, produce:

### Priority 1: Breaking issues
Things that could cause bugs or CI failures right now.

### Priority 2: Maintenance debt
Things that slow down development but aren't breaking.

### Priority 3: Nice-to-have
Cleanup that improves code quality but isn't urgent.

For each issue, estimate effort: quick (< 5 min), medium (< 30 min), involved (> 30 min).
Wait for all teammates to finish before summarizing.

---

## Notes

- **Haiku for teammates**: Read-only analysis doesn't need expensive reasoning. Haiku handles pattern-matching tasks (finding dead code, checking configs) well.
- **Three orthogonal concerns**: Dead code (code quality), config drift (correctness), test health (reliability) — covers the full maintenance surface.
- **Priority + effort matrix**: The synthesized output should let you batch quick wins together and plan larger maintenance sessions.
- **[REPO_PATH]**: Replace with actual repo. For your dotfiles repo specifically, the config drift check is most valuable since configs reference each other extensively.
- **Run quarterly**: Monthly is too frequent (not enough drift), annually is too late (too much accumulated). Quarterly catches drift before it compounds.
