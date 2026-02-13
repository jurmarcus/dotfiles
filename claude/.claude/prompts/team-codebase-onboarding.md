# Team Codebase Onboarding

> Rapidly understand an unfamiliar codebase with parallel exploration agents | Model: Haiku | Agents: 3

---

Create an agent team with 3 teammates to explore and document [REPO_PATH].
Use Haiku for each teammate. No editing — research only.

## Teammate 1: Architecture Mapper

Map the high-level architecture of this codebase. Produce:

1. **Directory tree** — top 3 levels with purpose annotations
2. **Entry points** — where execution starts (main files, route handlers, CLI entry)
3. **Layer diagram** — how the major modules/packages relate to each other
4. **Tech stack** — languages, frameworks, build tools, databases, external services
5. **Config files** — what each config file does (justfile, pyproject.toml, Cargo.toml, tsconfig, etc.)

Look at CLAUDE.md, README.md, and any docs/ directory first — they often describe architecture.
If it's a monorepo, map each package/workspace separately.

Do NOT edit any files — research only.

## Teammate 2: Pattern Analyst

Identify the coding patterns and conventions used in this codebase:

1. **Error handling** — how errors are created, propagated, and reported
2. **Data flow** — how data moves between layers (DTOs, domain models, API contracts)
3. **Testing patterns** — test framework, fixtures, mocks, naming conventions
4. **Dependency injection** — how services/dependencies are wired together
5. **Naming conventions** — file naming, function naming, module organization

For each pattern, cite 2-3 concrete examples with file:line references.
Flag any inconsistencies where different parts of the codebase use different patterns.

Do NOT edit any files — research only.

## Teammate 3: Rough Edges Scout

Find the pain points and improvement opportunities:

1. **TODOs/FIXMEs/HACKs** — collect all with file:line and surrounding context
2. **Dead code** — unused imports, unreachable functions, commented-out blocks
3. **Missing tests** — source files with no corresponding test file
4. **Dependency health** — outdated deps, deprecated packages, security advisories
5. **Documentation gaps** — public APIs without docs, outdated README sections

Prioritize findings by impact: what would hurt a new contributor most?

Do NOT edit any files — research only.

## Coordination

After all teammates report, synthesize into a single onboarding document with:
- **Quick start** — how to build and run (extracted from teammate 1's findings)
- **Architecture overview** — the layer diagram and key entry points
- **Conventions to follow** — the patterns a new contributor must know
- **Known issues** — prioritized list of rough edges
Save this to docs/ONBOARDING.md if the user approves.

---

## Notes

- **[REPO_PATH]**: Replace with the actual repo path before using
- **Three orthogonal angles**: Architecture (what), patterns (how), rough edges (what's broken) — gives complete coverage without overlap
- **"Look at CLAUDE.md first"**: Many repos already have context docs; reading them first avoids agents rediscovering known information
- **Concrete examples required**: "This repo uses Result types" is useless; "see src/api/handler.rs:42 for error propagation pattern" is actionable
- **Synthesis into onboarding doc**: The real value is the combined output, not three separate reports
