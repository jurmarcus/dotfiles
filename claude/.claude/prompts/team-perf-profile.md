# Team Performance Profile

> Comprehensive Rust performance profiling suite: CPU, allocation, benchmarks, and static analysis | Model: Sonnet | Agents: 7

---

Create an agent team with 7 teammates to profile and analyze performance of the [TARGET]
binary stack. Use Sonnet for all teammates (they need to understand Rust ownership, lifetimes,
and memory semantics). No plan approval needed.

## Targets

The target determines which binary to profile and which crates are in scope:

| Target | Binary | Crate Stack |
|--------|--------|-------------|
| `graphql` | `jisho-graphql` | graphql → core → fsrs |
| `cli` | `jisho` (CLI) | cli → core → fsrs |
| `tui` | `jisho-tui` | tui → core → fsrs |
| `mcp` | all MCP binaries | dictionary-mcp, youtube-mcp, etc. |

All server targets share `jisho-core` as the heavy dependency. Profiling any server binary
effectively profiles core's analysis pipeline, database queries, and type serialization
in the context of that binary's runtime behavior.

---

## Phase 1: Parallel Profiling (6 teammates)

All Phase 1 teammates run in parallel. No dependencies between them.

### Teammate 1: CPU Profiler

Profile CPU usage of the [TARGET] binary using `samply`.

**Setup:**
```bash
# Install samply if not present
cargo install samply
# On Apple Silicon, run setup once:
samply setup
```

**Workload:**
Create a representative workload script that exercises the binary's hot paths.
For `graphql`: send a batch of GraphQL queries (analysis, search, lookup) via curl.
For `cli`: run an import or extract operation on test data.
For `tui`: not applicable (interactive), profile core benchmarks instead.

**Run:**
```bash
samply record --save-only -o target/profile/cpu.json -- target/release/[BINARY] [WORKLOAD_ARGS]
```

**Extract hotspots** from the samply JSON. Parse the profile data and produce:

```json
// target/profile/cpu-hotspots.json
{
  "target": "[TARGET]",
  "total_samples": 50000,
  "hotspots": [
    {
      "function": "jisho_core::analysis::analyze::analyze_text",
      "file": "server/jisho-core/src/analysis/analyze.rs",
      "line": 45,
      "samples": 8500,
      "percent": 17.0,
      "callers": ["jisho_graphql::schema::analysis::resolve_analyze"]
    }
  ]
}
```

If samply fails or isn't available, fall back to `cargo-instruments` on macOS and
manually extract timing data from the trace.

Report: top-20 CPU hotspots with caller context.

### Teammate 2: Allocation Profiler

Instrument the [TARGET] binary with `dhat-rs` for heap allocation profiling.

**Setup — add dhat behind a feature flag:**

In the target crate's `Cargo.toml`:
```toml
[features]
profile-alloc = ["dhat"]

[dependencies]
dhat = { version = "0.3", optional = true }
```

In the target crate's `main.rs` (or create `examples/profile_alloc.rs`):
```rust
#[cfg(feature = "profile-alloc")]
#[global_allocator]
static ALLOC: dhat::Alloc = dhat::Alloc;

fn main() {
    #[cfg(feature = "profile-alloc")]
    let _profiler = dhat::Profiler::builder().file_name("target/profile/dhat-heap.json").build();

    // ... existing main logic or representative workload
}
```

**Run:**
```bash
cargo run --release --features profile-alloc -- [WORKLOAD_ARGS]
```

**Parse dhat output** and produce a simplified summary:

```json
// target/profile/alloc-hotspots.json
{
  "target": "[TARGET]",
  "total_allocations": 142000,
  "total_bytes_allocated": 28400000,
  "peak_bytes_live": 8192000,
  "hotspots": [
    {
      "location": "server/jisho-core/src/analysis/analyze.rs:87",
      "function": "analyze_text",
      "allocations": 4500,
      "total_bytes": 1200000,
      "avg_size": 267,
      "max_size": 4096,
      "description": "Vec<AnalyzedSpan> growth during 6-layer resolution"
    }
  ]
}
```

**Important**: Keep the feature flag — don't commit dhat as a non-optional dependency.
The `profile-alloc` feature should be off by default.

Report: top-20 allocation hotspots with byte counts and call context.

### Teammate 3: Benchmark Engineer

Extend the existing criterion benchmarks and add allocation counting.

**Audit existing benchmarks:**
```bash
# Find all benchmark files
find server/ mcp/ -name "*.rs" -path "*/benches/*"
```

The existing `server/jisho-core/benches/analyzer.rs` benchmarks the analysis pipeline.
Identify which hot paths are NOT yet benchmarked.

**Add new benchmarks** for uncovered paths. Prioritize:
1. Database lookup functions (`vocab::lookup_vocab`, `grammar::lookup_grammar`, etc.)
2. Search functions (`vocab::search_vocab`, `kanji::search_kanji`)
3. Import/extract operations if profiling `cli`
4. GraphQL resolver overhead if profiling `graphql`
5. Any function that appeared in Teammate 1 or 2's hotspots (if available)

Follow the existing benchmark style:
```rust
fn bench_lookup_vocab(c: &mut Criterion) {
    let conn = open_db();
    c.bench_function("lookup_vocab", |b| {
        b.iter(|| vocab::lookup_vocab(&conn, "食べる", None, 10).unwrap())
    });
}
```

**Add allocation-counting wrapper** using a simple GlobalAlloc:
```rust
use std::sync::atomic::{AtomicUsize, Ordering};

static ALLOC_COUNT: AtomicUsize = AtomicUsize::new(0);
static ALLOC_BYTES: AtomicUsize = AtomicUsize::new(0);

struct CountingAlloc;
unsafe impl std::alloc::GlobalAlloc for CountingAlloc {
    unsafe fn alloc(&self, layout: std::alloc::Layout) -> *mut u8 {
        ALLOC_COUNT.fetch_add(1, Ordering::Relaxed);
        ALLOC_BYTES.fetch_add(layout.size(), Ordering::Relaxed);
        unsafe { std::alloc::System.alloc(layout) }
    }
    unsafe fn dealloc(&self, ptr: *mut u8, layout: std::alloc::Layout) {
        unsafe { std::alloc::System.dealloc(ptr, layout) }
    }
}

fn count_allocations<F: FnOnce() -> R, R>(f: F) -> (R, usize, usize) {
    ALLOC_COUNT.store(0, Ordering::Relaxed);
    ALLOC_BYTES.store(0, Ordering::Relaxed);
    let result = f();
    (result, ALLOC_COUNT.load(Ordering::Relaxed), ALLOC_BYTES.load(Ordering::Relaxed))
}
```

**Run all benchmarks** and produce:

```json
// target/profile/benchmarks.json
{
  "target": "[TARGET]",
  "benchmarks": [
    {
      "name": "analyze_short",
      "mean_ns": 1200000,
      "std_dev_ns": 100000,
      "throughput_ops_sec": 833,
      "allocations_per_iter": 142,
      "bytes_per_iter": 28400,
      "status": "existing"
    },
    {
      "name": "lookup_vocab",
      "mean_ns": 50000,
      "std_dev_ns": 3000,
      "throughput_ops_sec": 20000,
      "allocations_per_iter": 35,
      "bytes_per_iter": 8200,
      "status": "new"
    }
  ]
}
```

Report: full benchmark table with timing + allocation counts. Flag high-variance benchmarks.

### Teammate 4: Allocation Pattern Scanner

Static code review of the [TARGET] crate stack for allocation anti-patterns.
Do NOT edit any files — research only.

**Scope**: Read all `.rs` files in the crate stack for [TARGET].

**Search for these patterns:**

1. **Unnecessary heap allocations**:
   - `format!()` where `write!()` or `&str` would suffice
   - `.to_string()` or `.to_owned()` in hot paths (loops, iterators, row mappers)
   - `collect::<Vec<_>>()` immediately followed by `.iter()` or `.into_iter()`
   - `clone()` on large structs (`Vocab`, `Grammar`, `AnalyzedSpan`) when borrowing is possible
   - `String` concatenation in loops instead of `String::with_capacity()` + `push_str()`
   - Repeated temporary `String` allocation in match arms

2. **Collection pre-allocation**:
   - `Vec::new()` where size is known or estimable → `Vec::with_capacity()`
   - `HashMap::new()` in functions that always insert N items → `HashMap::with_capacity()`
   - `String::new()` followed by multiple `push_str()` → `String::with_capacity()`

3. **Ownership inefficiency**:
   - Functions taking `String` parameter but only reading it → should take `&str`
   - Functions returning `Vec<T>` that callers immediately iterate → could return `impl Iterator`
   - Struct fields that are `String` but immutable after construction → consider `Arc<str>` or `Cow<str>`

4. **Hot-path amplification**:
   - Allocations inside `query_map()` closures (called per-row)
   - Allocations inside analysis pipeline loops (called per-token)
   - Allocations inside FTS5 match processing

For each finding, produce:
```json
// target/profile/static-alloc.json
{
  "findings": [
    {
      "file": "server/jisho-core/src/vocab/db.rs",
      "line": 42,
      "pattern": "clone_in_hot_path",
      "severity": "high",
      "code": "let vocab = row_to_vocab(row)?.clone();",
      "suggestion": "Remove .clone() — row_to_vocab already returns owned Vocab",
      "estimated_savings": "1 Vocab clone (~200 bytes) per result row"
    }
  ]
}
```

### Teammate 5: SQL & Query Analyst

Static analysis of database query patterns in the [TARGET] crate stack.
Do NOT edit any files — research only.

**Scope**: All `db.rs` files, `database/` module, and any file with SQL queries.

**Analyze:**

1. **Query efficiency**:
   - SELECT * or selecting unused columns → select only needed columns
   - Missing LIMIT on queries that could return unbounded results
   - Missing indexes (check schema.rs for CREATE INDEX vs query WHERE clauses)
   - Suboptimal JOIN patterns or correlated subqueries
   - FTS5 queries that could use column filters for narrower matching

2. **Row mapping overhead**:
   - Row mappers that allocate per-field when batch strategies exist
   - `row.get::<_, String>()` for columns that could stay as `&str` (SQLite text)
   - Mappers that build nested structures per-row instead of batching

3. **Connection & pooling**:
   - Connection pool sizing (`JISHO_POOL_SIZE` default = 4)
   - Prepared statement reuse vs re-preparation
   - Transaction boundaries (too broad = lock contention, too narrow = overhead)

4. **DataLoader patterns** (if graphql target):
   - N+1 query patterns not covered by existing DataLoaders
   - DataLoader batch sizes and caching behavior
   - Resolver chains that trigger multiple sequential queries

For each finding, produce:
```json
// target/profile/static-sql.json
{
  "findings": [
    {
      "file": "server/jisho-core/src/vocab/db.rs",
      "line": 78,
      "pattern": "missing_limit",
      "severity": "medium",
      "query": "SELECT * FROM vocab WHERE term = ?1",
      "suggestion": "Add LIMIT clause — term is not unique, could return many rows",
      "estimated_impact": "Prevents unbounded allocation on ambiguous terms"
    }
  ]
}
```

### Teammate 6: Struct Layout & Memory Analyst

Static analysis of type definitions and memory layout in the [TARGET] crate stack.
Do NOT edit any files — research only.

**Scope**: `core/types.rs`, all `types.rs` files, and `analysis/types.rs`.

**Analyze:**

1. **Struct sizing**:
   - Large structs (>128 bytes) that are frequently cloned or moved
   - Structs with many `Option<String>` fields (each Option<String> = 24 bytes even when None)
   - Enum variants with very different sizes (largest variant determines enum size)

2. **Cache efficiency**:
   - Field ordering that causes padding waste (Rust doesn't reorder by default with `repr(Rust)`,
    but `repr(C)` does not — check for explicit `repr` attrs)
   - Actually, Rust's default repr DOES reorder fields. Check if any `#[repr(C)]` prevents this.
   - Hot structs that exceed 64-byte cache line

3. **Heap vs stack decisions**:
   - `Box<dyn Trait>` where an enum would avoid heap allocation
   - `Vec<T>` for small fixed-size collections → `[T; N]` or `SmallVec`
   - `String` fields that are always short → `SmallString` or `CompactString`
   - `HashMap` for small maps (< 10 entries) → `Vec<(K, V)>` with linear search

4. **Type flow overhead**:
   - Types that derive `Clone` but contain large vecs/strings → expensive implicit clones
   - `SimpleObject` derive adding GraphQL overhead to types used in non-GraphQL contexts
   - Serialization derives (`Serialize`/`Deserialize`) on types that don't need them

For each finding, produce:
```json
// target/profile/static-layout.json
{
  "findings": [
    {
      "type": "Vocab",
      "file": "server/jisho-core/src/core/types.rs",
      "line": 15,
      "pattern": "large_struct_frequently_cloned",
      "estimated_size_bytes": 256,
      "severity": "medium",
      "suggestion": "Wrap in Arc for shared ownership instead of cloning",
      "fields_contributing_most": ["senses: Vec<VocabSense>", "forms: Vec<VocabForm>"]
    }
  ]
}
```

---

## Phase 2: Synthesis (1 teammate)

### Teammate 7: Report Synthesizer

Wait for ALL Phase 1 teammates to finish, then synthesize findings.

**Read all output files:**
- `target/profile/cpu-hotspots.json`
- `target/profile/alloc-hotspots.json`
- `target/profile/benchmarks.json`
- `target/profile/static-alloc.json`
- `target/profile/static-sql.json`
- `target/profile/static-layout.json`

**Cross-reference:**
1. Match measured CPU hotspots with static findings — high-CPU functions that also
   have allocation anti-patterns are the highest-priority fixes
2. Match measured allocation hotspots with static findings — validates that the
   static analysis found real issues, not theoretical ones
3. Identify hotspots that only appear in dynamic profiling (runtime-only patterns
   like cache thrashing, pool contention)
4. Identify static findings in cold paths (low priority — correct but not impactful)

**Produce prioritized report** at `target/profile/report.md`:

```markdown
# Performance Profile: [TARGET]

## Executive Summary
- Total CPU hotspots identified: N
- Total allocation hotspots identified: N
- Static findings confirmed by measurement: N
- Estimated total allocation reduction: N%

## Priority Actions

| # | Location | Issue | Evidence | Est. Impact |
|---|----------|-------|----------|-------------|
| P0 | analysis/analyze.rs:87 | Vec reallocation in loop | dhat: 4500 allocs, samply: 17% CPU | -30% allocs in analysis |
| P1 | vocab/db.rs:42 | clone() in row mapper | dhat: 200KB/query | -200KB per search |
| ... | | | | |

## Detailed Findings
[Organized by category: CPU, Allocation, SQL, Layout]

## Benchmark Baseline
[Table from Teammate 3]

## Methodology
[Tools used, workload description, limitations]
```

Report the executive summary to the user. Save full report to file.

---

## Coordination

1. Spawn Teammates 1-6 in parallel
2. Wait for ALL to complete
3. Spawn Teammate 7 (synthesizer) with access to all output files
4. Present the executive summary and P0/P1 actions to the user
5. Save full report to `target/profile/report.md`

---

## Notes

- **Sonnet for all teammates**: Allocation analysis requires understanding Rust ownership semantics, lifetimes, and memory layout — Haiku makes mistakes on borrow checker reasoning
- **Feature flag for dhat**: `profile-alloc` feature keeps dhat out of normal builds. This is the ONLY code change that persists — everything else is ephemeral profiling output.
- **samply on macOS**: Requires one-time `samply setup` for Apple Silicon self-signing. Works natively after that. Falls back gracefully if unavailable.
- **Non-overlapping file boundaries**: Dynamic profilers (1-3) create new files in `target/profile/`. Static analysts (4-6) are read-only. No conflicts.
- **JSON everywhere**: All intermediate outputs are structured JSON so the synthesizer (and future Claude sessions) can parse them programmatically.
- **Why 3 static analysts instead of 1**: Allocation patterns, SQL efficiency, and struct layout are distinct expertise areas. A single agent trying to cover all three produces shallow findings. Specialized agents go deeper.
- **`core` is always in scope**: Every server target includes jisho-core transitively. The target just determines which binary entry point and runtime context to profile.
- **Criterion already exists**: `server/jisho-core/benches/analyzer.rs` has benchmarks. Teammate 3 extends this, not replaces it.
- **dhat over cargo-instruments**: dhat produces JSON that Claude can analyze. cargo-instruments produces `.trace` bundles requiring Xcode — useless for automated analysis.
- **samply over perf**: samply works on macOS natively, produces Firefox Profiler JSON. perf is Linux-only.
