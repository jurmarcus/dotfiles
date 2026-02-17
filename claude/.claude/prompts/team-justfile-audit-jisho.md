# Team Justfile Audit — Jisho Monorepo

> DevX & ops audit of all 23 justfiles for consistency, bloat, and ergonomics | Model: Sonnet | Agents: 5

---

Create an agent team with 5 teammates to audit and improve every justfile in the jisho
monorepo. Use Sonnet for each teammate — they need to understand build systems,
monorepo patterns, and propose concrete recipe changes.

The codebase is at ~/CODE/jisho/. Read CLAUDE.md first for architecture context.
There are 23 justfiles across 4 layers:

- **Root**: `justfile` (orchestrator)
- **Server** (7): `server/justfile`, `server/jisho-{web,graphql,voice,scraper,transcribe,core,cli}/justfile`
- **MCP** (6): `mcp/justfile`, `mcp/jisho-{dictionary,acquisition,voice,scraper,youtube}-mcp/justfile`
- **App** (6): `app/justfile`, `app/jisho-{mobile,tv,browser,iina,anki}/justfile`
- **Packages** (2): `packages/justfile`, `packages/jisho-shared-ts/justfile`

Every finding must include:
- **File path** (e.g., `server/jisho-voice/justfile`)
- **Current recipe** (the recipe name or code snippet)
- **Issue** (what's wrong: inconsistency, redundancy, missing, confusing)
- **Recommendation** (concrete fix with recipe code)

## Teammate 1: Consistency Auditor

Read ALL 23 justfiles and audit for naming/structural consistency across the monorepo.

Check for:

- **Recipe naming inconsistencies**: Do all modules use the same recipe names for the
  same operation? (e.g., `dev` vs `start`, `build` vs `build-dev`, `run` vs `dev`,
  `typecheck` vs `check`, `lint` vs `clippy`)
- **Missing standard recipes**: Every module should have a consistent set of standard
  recipes. Identify which modules are missing which standard recipes.
- **Section header inconsistency**: Compare the section comment styles (`# ===` blocks,
  spacing, ordering of sections)
- **Default recipe**: Does every justfile have `default: @just --list`?
- **Comment style**: Are recipe descriptions consistent? (`# Comment` above recipe
  vs inline `# comment` after recipe name)
- **Variable naming**: Are constants defined consistently across files?

Produce a consistency matrix: rows = modules, columns = standard recipe names,
cells = present/missing/differently-named.

Do NOT edit any files — research only.

## Teammate 2: Redundancy & Bloat Hunter

Read ALL justfiles and find recipes that are redundant, dead, or unnecessarily complex.

Check for:

- **Dead recipes**: Recipes that reference commands, paths, or services that no longer
  exist or were removed. Check against actual project structure.
- **Duplicate recipes**: Same recipe defined at multiple levels (e.g., root delegates to
  server which delegates to module — is the chain too deep?)
- **Unnecessary shell blocks**: Recipes using `#!/usr/bin/env bash` with `set -euo pipefail`
  when a simple one-liner would work (just has built-in error handling)
- **Verbose echo blocks**: Excessive emoji logging, banner printing, or status messages
  that add noise. Identify where `just` quiet mode (`@`) or simpler output would work.
- **Redundant dependencies**: Recipe chains that rebuild things unnecessarily
- **Copy-paste recipes**: Nearly identical recipes across modules that could be generalized
- **Stale port/URL references**: Hardcoded hostnames or ports that may be out of date

Produce a list of recipes to remove, merge, or simplify, with estimated line savings.

Do NOT edit any files — research only.

## Teammate 3: Ergonomics & DX Reviewer

Read ALL justfiles from a developer experience perspective. Imagine you're a new
contributor trying to work on the project.

Check for:

- **Discoverability**: If you run `just` at any level, do you get a clear picture of
  what's available? Are recipe descriptions helpful or cryptic?
- **Common workflows undocumented**: Are there workflows developers need that aren't
  captured as recipes? (e.g., "I changed a Rust type, now what?" should be a recipe)
- **Too many top-level recipes**: Does the root justfile have too many recipes? Should
  some be moved to sub-justfiles?
- **Missing delegation**: Does the root justfile properly delegate to layer justfiles,
  or does it duplicate logic?
- **Confusing names**: Recipes whose names don't clearly indicate what they do
  (e.g., `fix` vs `fix-all` — what's the difference?)
- **Missing `--help` equivalents**: Are there `info` or `help` recipes where needed?
- **Dev workflow gaps**: Is there a recipe for every common development task? Missing
  recipes for: running a single module, rebuilding after type changes, checking what
  services are running, stopping all services, viewing logs?
- **Parameter ergonomics**: Are recipe parameters intuitive? Do they have good defaults?

Propose a "golden path" recipe set that every module-level justfile should have.

Do NOT edit any files — research only.

## Teammate 4: Server & Service Orchestration Reviewer

Focus specifically on the server layer's service orchestration (the `dev`, `prod`,
`dev-minimal`, `dev-sql` recipes and per-service justfiles).

Check for:

- **Service sprawl**: 5 services in `just dev` — are all necessary? Which are truly
  required for core development vs optional?
- **Process management**: The current approach uses `trap 'kill 0' EXIT` with
  background processes. Is this robust? Does it handle failures gracefully?
  What happens when one service crashes?
- **Port conflicts**: Are ports defined in one place or scattered? Could a developer
  accidentally start two copies?
- **Health checks**: Is there a way to verify all services are running and healthy?
  Should there be a `just status` recipe?
- **Startup ordering**: Do services need to start in a specific order? (e.g., GraphQL
  before Web for codegen). Is this enforced?
- **Log management**: When 5 services output simultaneously, can you tell which log
  line is from which service? Should there be colored prefixes?
- **Environment handling**: Are environment variables for services defined consistently?
  Compare direnv `.envrc` vs justfile `export` vs hardcoded values.
- **Production mode**: Compare `dev` vs `prod` — what's different and is it correct?
  Is there a `prod` for every service that needs one?
- **Transcribe service**: The jisho-transcribe service uses a Python + TypeScript bridge
  pattern. Is this well-integrated into the justfile system? Is its justfile consistent
  with the other TypeScript services (voice, scraper)?

Do NOT edit any files — research only.

## Teammate 5: Cross-cutting Quality & CI Reviewer

Review the quality-related recipes (test, lint, format, typecheck, quality) across
the entire monorepo.

Check for:

- **Quality recipe completeness**: Map which quality tools run at which level.
  Is anything missed? (e.g., does `just quality` cover all languages and all modules?)
- **Tool consistency**: Are the same tools used everywhere? (e.g., `biome` vs `eslint`,
  `ruff` vs `flake8`, `bunx tsc` vs `bun tsc`)
- **Test coverage gaps**: Which modules have test recipes? Which don't? Are tests
  actually runnable or do they require specific setup?
- **CI readiness**: Could `just quality` + `just test-all` be run in CI as-is?
  What would break? Are there missing environment setup steps?
- **Incremental checking**: Can you check/test just the module you're working on,
  or do you have to run everything? Are per-module recipes available?
- **Pre-commit integration**: Is there a pre-commit recipe? Does it run the right
  subset of checks (fast ones only)?
- **Build recipe hierarchy**: `build` vs `build-dev` vs `build-all` vs
  `build-component` — is this hierarchy clear and consistent?
- **Clean recipe coverage**: Does every module that produces build artifacts have
  a `clean` recipe? Does `clean-all` actually clean everything?

Produce a quality matrix: rows = modules, columns = test/lint/format/typecheck/clean,
cells = recipe name or missing.

Do NOT edit any files — research only.

## Coordination

After all 5 teammates report, synthesize findings into a single actionable plan:

1. **Executive summary**: Overall justfile health score and key findings
2. **Standard recipe template**: The canonical set of recipes every module justfile
   should have (with exact names and descriptions)
3. **Critical fixes**: Broken or misleading recipes — fix immediately
4. **Consolidation opportunities**: Recipes to merge, remove, or simplify
5. **Ergonomic improvements**: New recipes or renames that improve DX
6. **Service orchestration improvements**: Better process management for dev/prod

Save the full report to `plans/PLAN_justfile_audit.md` formatted as an actionable plan
with checkboxes per fix. Wait for ALL teammates to finish before synthesizing.

---

## Notes

- **Sonnet for teammates**: Build system analysis requires understanding monorepo patterns, process management, and developer workflows — Haiku would miss architectural issues
- **5 agents by concern, not by layer**: Each agent looks across ALL layers for their specific concern (consistency, bloat, DX, orchestration, quality). This catches cross-cutting patterns that per-layer agents would miss.
- **"Do NOT edit" per teammate**: This is a research-first audit. Edits come after the plan is approved.
- **Why 5 not 6**: The orchestration reviewer (teammate 4) is server-focused because that's where the complexity lives. MCP and app layers are simpler and covered by the cross-cutting agents.
- **Concrete recipe code**: Every recommendation must include actual recipe code, not vague "improve this". The output should be copy-pasteable.
