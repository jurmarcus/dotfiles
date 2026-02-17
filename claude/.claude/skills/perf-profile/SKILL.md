---
name: perf-profile
description: "Comprehensive Rust performance profiling with 7 parallel agents. Use when the user says /perf-profile <target>, 'profile performance', 'find bottlenecks', 'make it faster', 'profile allocations', 'profile CPU', or wants comprehensive Rust performance analysis. Targets: graphql, cli, tui, mcp."
user_invocable: true
argument: "target binary to profile (graphql, cli, tui, mcp)"
---

# Rust Performance Profiling Suite

Comprehensive profiling with 7 agents: 3 dynamic profilers + 3 static analysts + 1 synthesizer.

## Target Resolution

Resolve the argument to a binary and crate stack:

| Argument | Binary | Crate Stack | Workload Strategy |
|----------|--------|-------------|-------------------|
| `graphql` | `jisho-graphql` | graphql → core → fsrs | Send GraphQL queries via curl |
| `cli` | `jisho` | cli → core → fsrs | Run import/extract on test data |
| `tui` | `jisho-tui` | tui → core → fsrs | Benchmark-only (interactive binary) |
| `mcp` | all MCP binaries | dictionary-mcp, etc. | Profile each MCP binary separately |

If no argument provided, ask the user which target to profile using `AskUserQuestion`.

## Prerequisites

Before spawning the team, verify:

```bash
# Check samply is installed
which samply || echo "MISSING: cargo install samply"

# Check dhat is available
cargo search dhat --limit 1

# Check criterion benchmarks exist
ls server/jisho-core/benches/*.rs

# Create output directory
mkdir -p target/profile
```

If samply is not installed, warn the user and offer to install it. Proceed with remaining
agents even if samply is unavailable (CPU profiler will be skipped).

## Team Creation

Create a team named `perf-profile-[TARGET]`:

```
TeamCreate(team_name: "perf-profile-[TARGET]", description: "Performance profiling [TARGET]")
```

## Task Creation

Create 7 tasks, then set dependencies:

### Phase 1 Tasks (no dependencies — all run in parallel)

1. **CPU Profiler** — Run samply on [TARGET] binary, extract top-20 CPU hotspots to `target/profile/cpu-hotspots.json`
2. **Allocation Profiler** — Add dhat-rs with `profile-alloc` feature flag, run profiling, extract top-20 allocation hotspots to `target/profile/alloc-hotspots.json`
3. **Benchmark Engineer** — Audit + extend criterion benchmarks with allocation counting, run all, save results to `target/profile/benchmarks.json`
4. **Allocation Pattern Scanner** — Static analysis: clone/format!/collect/to_string patterns in [TARGET] crate stack, save to `target/profile/static-alloc.json`
5. **SQL & Query Analyst** — Static analysis: query efficiency, row mapping, connection pooling in all db.rs files, save to `target/profile/static-sql.json`
6. **Struct Layout Analyst** — Static analysis: struct sizing, enum variants, heap vs stack, type overhead in all types.rs files, save to `target/profile/static-layout.json`

### Phase 2 Task (blocked by all Phase 1 tasks)

7. **Report Synthesizer** — Cross-reference all JSON outputs, produce prioritized `target/profile/report.md`

Set task 7 as `blockedBy: [1, 2, 3, 4, 5, 6]`.

## Spawning Teammates

### Dynamic Profilers (Sonnet, general-purpose, write code)

Spawn teammates 1-3 as `general-purpose` agents with `model: sonnet`. They need to:
- Write profiling infrastructure code
- Run binaries and benchmarks
- Parse output into structured JSON

Each teammate prompt MUST include:
- The target binary name and path
- The crate stack (which source directories to look at)
- The exact output file path and JSON schema
- Instructions to read the team prompt at `~/.claude/prompts/team-perf-profile.md` for their teammate section

### Static Analysts (Sonnet, Explore agents, read-only)

Spawn teammates 4-6 as `Explore` agents with `model: sonnet`. They:
- Read source code only
- Produce JSON findings files
- Do NOT edit any code

Each teammate prompt MUST include:
- The crate stack directories to analyze
- The specific patterns to search for (from team prompt)
- The exact output JSON schema
- "Do NOT edit any files — research only"

### Report Synthesizer (Sonnet, general-purpose)

Spawn teammate 7 as `general-purpose` with `model: sonnet` ONLY after all Phase 1 tasks
are complete. Its prompt MUST include:
- Paths to all 6 JSON output files
- Instructions to cross-reference measured vs static findings
- The report.md template from the team prompt

## After Completion

When the synthesizer finishes:

1. Read `target/profile/report.md`
2. Present the **Executive Summary** and **P0/P1 actions** to the user
3. Ask if they want to:
   - Start fixing P0 issues now
   - Save the report and come back later
   - Re-run with a different target

## Important Notes

- **Build release first**: Before any dynamic profiling, ensure `just build` has run (release mode)
- **Database required**: CPU and allocation profiling need the jisho database. Verify `JISHO_DB_PATH` is set.
- **Feature flag cleanup**: The `profile-alloc` feature flag added by Teammate 2 should remain in Cargo.toml (it's opt-in and useful for future profiling runs)
- **Output is ephemeral**: `target/profile/` is in `.gitignore` (it's under `target/`). Only Cargo.toml feature flag changes persist.
- **Re-runnable**: The skill can be invoked multiple times. Each run overwrites `target/profile/` with fresh data.
- **Concurrent safety**: Phase 1 agents don't touch the same files. Dynamic profilers create new files, static analysts only read.
