# Claude Code Automation Guide

Complete guide to hooks, skills, and commands for faster development with Claude.

---

## 🎣 Hooks (Automatic Event-Driven Actions)

Hooks run automatically on events. No need to remember to run checks!

### PostToolUse Hooks (Run After Tool Execution)

| Hook | Trigger | Languages | Purpose |
|------|---------|-----------|---------|
| **lsp-check-after-edit.sh** | After Edit/Write | TS, Python, Rust | Type checking (tsc, ty, cargo check) |
| **format-on-edit.sh** | After Edit/Write | TS, Python, Rust | Auto-format (prettier, ruff, rustfmt) |
| **test-after-edit.sh** | After Edit/Write | TS, Python, Rust | Run targeted tests for modified file |
| **layer-validation.sh** | After Edit/Write | TS/GraphQL/Rust | Cross-layer boundary validation (see below) |

### Cross-Layer Boundary Validation (layer-validation.sh)

For projects with multiple technology layers, validates that interfaces between layers match:

```
┌─────────────────────────────────────────────────────────────────┐
│  TypeScript (jisho-web)          ← tsc (within-layer)          │
├─────────────────────────── TS ↔ Apollo ─────────────────────────┤
│  Apollo Client (lib/graphql)     ← codegen (cross-layer)       │
├─────────────────────────── Apollo ↔ GraphQL ────────────────────┤
│  GraphQL Schema                  ← validates BOTH directions   │
├─────────────────────────── GraphQL ↔ Rust ──────────────────────┤
│  Rust Resolvers (jisho-graphql)  ← cargo check (cross-layer)   │
├─────────────────────────── Rust ↔ SQLite ───────────────────────┤
│  SQLite Database (jisho-core)    ← cargo check (within-layer)  │
└─────────────────────────────────────────────────────────────────┘
```

**Key insight**: Within-layer validation (tsc, cargo check) is handled by `lsp-check-after-edit.sh`. The `layer-validation.sh` hook focuses on **cross-layer boundaries** where interfaces must match:

| Edit Location | Cross-Layer Validation |
|---------------|------------------------|
| `lib/graphql/**/*.ts` | Run graphql-codegen → validate against schema |
| `lib/apollo/**/*.ts` | Run graphql-codegen → validate against schema |
| `*.graphql` (schema) | Validate BOTH directions (Apollo + Rust) |
| `jisho-graphql/**/*.rs` | Run cargo check → validate resolvers match schema |
| Pages with `gql\`` | Run graphql-codegen → validate inline queries |

### PreToolUse Hooks (Run Before Tool Execution)

| Hook | Trigger | Purpose |
|------|---------|---------|
| **enforce-justfile.sh** | Before Bash | Block raw build commands → use `just` recipes |
| **enforce-package-managers.sh** | Before Bash | Block npm/yarn/pip/poetry → use bun/uv |
| **pre-commit-checks.sh** | Before `git commit` | Format, LSP, tests, **dead code**, clippy, TODO scan |

### Justfile Enforcement (enforce-justfile.sh)

Enforces use of `just` task runner for all build infrastructure:

```
Commands blocked:
├── cargo build/test/fmt/clippy/check
├── npm/pnpm/bun build/test/lint
├── uv run pytest, uvx ruff/ty
├── wasm-pack build
├── cargo pgrx install/test
└── make

If justfile exists:
  → Block with "Use `just <recipe>` instead"

If no justfile:
  → Block with "Create justfile first"
  → Spawn agent to analyze project and create justfile
```

### SessionStart Hooks (Run When Session Begins)

| Hook | Purpose |
|------|---------|
| **session-start-context.sh** | Load project CLAUDE.md, find relevant plans |

### SessionEnd Hooks (Run When Session Ends)

| Hook | Purpose |
|------|---------|
| **session-summary.sh** | Summarize changes, TODOs, uncommitted files |

---

## 🎯 Commands - Guided Workflows

Detailed task templates invoked with `/command-name`. All stored in `~/.claude/commands/`.

| Name | Invocation | Purpose | Languages |
|------|------------|---------|-----------|
| **test** | `/test <file>` | Generate comprehensive tests | Python, TS, Rust |
| **review** | `/review <file>` | Code review for bugs/security/performance | All |
| **doc** | `/doc [file]` | Update CLAUDE.md, README, docstrings | All |
| **commit** | `/commit [msg]` | Smart conventional commits | Git |
| **refactor** | `/refactor <target>` | Guided refactoring with safety checks | All |
| **perf** | `/perf <file>` | Performance analysis and optimization | All |
| **debug** | `/debug <issue>` | Investigate issue without fixing | All |
| **design** | `/design <feature>` | Create detailed implementation plan | All |
| **migrate** | `/migrate <from> <to>` | Migrate code patterns/libraries | All |
| **deadcode** | `/deadcode [path]` | Full codebase dead code scan | Python, TS, Rust |
| **changelog** | `/changelog [version]` | Generate changelog from commits | Git |

---

## 📋 Commands - Quick Prompts

Simple templates for common tasks.

| Command | Purpose |
|---------|---------|
| `/agent <desc>` | Build an AI agent |
| `/explain <code>` | Deep code explanation |
| `/fix <issue>` | Debug and fix issues |
| `/improve` | Review recent changes |
| `/polish <code>` | Quick wins cleanup |
| `/sweep` | Full codebase cleanup |
| `/mcp-tool <name>` | Add MCP tool |
| `/mcp-resource <name>` | Add MCP resource |
| `/mcp-prompt <name>` | Add MCP prompt |

---

## 📋 Complete Workflow Example

```
User: "Add fuzzy search to the vocab API"

Claude: [Implements feature using Edit tool]
  ↓
Hook: lsp-check-after-edit.sh ✅ TypeScript passed
  ↓
Hook: format-on-edit.sh ✅ Formatted with prettier
  ↓
Hook: test-after-edit.sh ✅ Related tests passed

User: "/review src/search.ts"
  ↓
Claude: [Reviews code]
  → 🟢 No critical issues
  → 🟡 Suggestion: Add input validation

User: "/doc"
  ↓
Claude: [Updates CLAUDE.md and README.md]

User: "/commit"
  ↓
Hook: pre-commit-checks.sh ✅ All checks passed
  → Dead code scan, clippy (Rust), TODO scan
  ↓
Claude: [Creates conventional commit]
  → feat(search): add fuzzy matching for vocab

Session End:
Hook: session-summary.sh
  → 📊 Summary: 3 files modified, all tests passing
```

---

## 🔧 Configuration

### Enabling/Disabling Hooks

**Disable a hook**:
```bash
mv ~/.claude/hooks/test-after-edit.sh{,.disabled}
```

**Re-enable a hook**:
```bash
mv ~/.claude/hooks/test-after-edit.sh{.disabled,}
```

### Environment Variables

Hooks receive these from Claude:
- `CLAUDE_HOOK_TOOL_NAME` - Tool that triggered hook
- `CLAUDE_HOOK_TOOL_ARGS_*` - Tool arguments (e.g., `CLAUDE_HOOK_TOOL_ARGS_file_path`)

---

## 🚀 Quick Reference

### Development Workflow
```bash
# 1. Make changes (hooks run automatically on Edit/Write)
#    → LSP checks, formatting, targeted tests all automatic

# 2. Investigate issues
/debug <issue>

# 3. Review code
/review src/module.ts

# 4. Update documentation
/doc

# 5. Commit changes
/commit
#    → Pre-commit checks run automatically (includes clippy for Rust)
```

### Manual Checks (if needed)
```bash
# TypeScript
bunx tsc --noEmit

# Rust
cargo check && cargo clippy && cargo test

# Python
uvx ty check && uv run pytest
```

---

## 📊 Hook Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│ Session Start                                           │
└───────────────────────┬─────────────────────────────────┘
                        ▼
          ┌─────────────────────────────┐
          │ session-start-context.sh    │
          │ → Load CLAUDE.md            │
          │ → Find relevant plans       │
          └─────────────┬───────────────┘
                        ▼
┌─────────────────────────────────────────────────────────┐
│ User: "Fix the parser bug"                              │
└───────────────────────┬─────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Claude: [Uses Edit tool on src/parser.ts]               │
└───────────────────────┬─────────────────────────────────┘
                        ▼
          ┌─────────────────────────────┐
          │ PostToolUse Hooks (parallel) │
          └─────────────┬───────────────┘
                        │
      ┌─────────────────┼─────────────────┐
      ▼                 ▼                 ▼
┌──────────┐   ┌──────────────┐   ┌──────────┐
│ LSP Check│   │ Format Code  │   │ Run Tests│
│    ✅     │   │      ✅       │   │    ✅     │
└──────────┘   └──────────────┘   └──────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Claude: "Bug fixed! All checks passed."                 │
└─────────────────────────────────────────────────────────┘
```

---

## 📚 Resources

- Hooks: `~/.claude/hooks/`
- Commands: `~/.claude/commands/` → `~/dotfiles/claude/.claude/commands/`
- Skills: `~/.claude/skills/` → `~/dotfiles/claude/.claude/skills/`
- Plans: `~/plans/` and `~/.claude/plans/`
- Config: `~/.claude/CLAUDE.md`

---

**Philosophy**: Automation should be **invisible** (runs automatically), **fast** (<5s), and **helpful** (catches errors early).
