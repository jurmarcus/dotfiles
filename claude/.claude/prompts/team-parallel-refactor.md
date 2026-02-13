# Team Parallel Refactor

> Coordinate a large refactor across non-overlapping file boundaries | Model: Sonnet | Agents: 2-4

---

Create an agent team to refactor [DESCRIBE_REFACTOR] across this codebase.
Use Sonnet for each teammate (they need to write correct code).
Require plan approval for every teammate.

## Lead responsibilities

Before spawning teammates:
1. Identify ALL files that need changes
2. Partition files into non-overlapping groups — no two teammates touch the same file
3. Define the shared interface/contract that all teammates must conform to
4. Create a task per teammate with explicit file lists

## Teammate template

Each teammate gets:

### Teammate N: [Area Name]

Refactor [specific aspect] in these files ONLY:
- `path/to/file1.ts`
- `path/to/file2.ts`
- `path/to/file3.ts`

**What to change**:
[Specific transformation — e.g., "rename FooService to BarService", "convert callbacks to async/await",
"replace manual SQL with query builder"]

**Contract to follow**:
[The shared interface that all teammates must match — e.g., "all handlers must return Result<Response, AppError>",
"all services must implement the new trait"]

**Validation**:
After making changes, run:
- `just check` (type checking)
- `just test` (verify nothing broke)

Report: files changed, tests passing/failing, any issues found.

## Coordination

1. Wait for ALL teammates to finish and report
2. Run full test suite: `just test`
3. If any cross-boundary issues, fix them yourself (teammates can't see each other's changes)
4. Commit with: `sl commit -m "refactor(scope): [description]"`

---

## Notes

- **Sonnet, not Haiku**: Refactoring requires understanding context and writing correct code; Haiku tends to make subtle mistakes in non-trivial edits
- **Plan approval required**: Critical for refactors — you must verify each teammate's plan won't conflict with others
- **Non-overlapping file lists**: The single most important constraint. Two agents editing the same file causes merge hell. Partition strictly.
- **Shared contract**: Without this, teammates will make incompatible changes. Define the target interface/type/API shape explicitly.
- **Lead fixes cross-boundary issues**: Teammates can't see each other's changes within a session. The lead handles integration.
- **Template, not prescription**: Adjust teammate count (2-4) based on how cleanly the files partition
