---
name: memory-sync
description: "Audit, organize, and sync memories across global and project scopes. Use when the user says /memory-sync, 'sync memories', 'organize memories', 'audit memory', 'check memories', or wants to promote project memories to global, deduplicate, or clean up stale entries. Also use proactively at session end if you saved memories that might be global."
user_invocable: true
---

# Memory Sync — Global/Project Memory Organizer

## Step 1: Discover All Memory Scopes

Scan for all memory directories:

```bash
# Global memory
ls ~/.claude/memory/*.md 2>/dev/null

# All project memories
find ~/.claude/projects/*/memory -name "*.md" 2>/dev/null
```

Read every `MEMORY.md` index file and every individual memory file found.

## Step 2: Classify Each Memory

For each memory file, determine its scope based on `type` frontmatter and content:

| Classification | Criteria | Destination |
|----------------|----------|-------------|
| **Global** | `type: user` — identity, preferences, philosophy | `~/.claude/memory/` |
| **Global** | `type: feedback` about coding style that applies everywhere | `~/.claude/memory/` |
| **Global** | `type: reference` for infrastructure used across projects | `~/.claude/memory/` |
| **Project** | `type: project` about a specific codebase | Stay in project scope |
| **Project** | `type: feedback` about a specific project's patterns | Stay in project scope |

**The rule: if a memory would be useful in a DIFFERENT project, it's global.**

## Step 3: Detect Issues

Check for:

### Duplicates
Same information in multiple scopes (e.g., homelab info in both `~/CODE/` and `~/CODE/docker-compose/`). Keep the most complete version in the highest-appropriate scope, delete the rest.

### Misplaced Memories
- `type: user` memories in project scopes → should be global
- Project-specific memories in `~/CODE/` (parent) when they belong in `~/CODE/jisho/` (child)
- Global memories that reference specific file paths (paths change, memory goes stale)

### Stale Memories
- Memories referencing files that no longer exist
- `type: project` memories about completed/abandoned work
- Memories whose description no longer matches their content

### Missing Index Entries
- Memory files that exist but aren't listed in their scope's `MEMORY.md`
- `MEMORY.md` entries pointing to files that don't exist

## Step 4: Propose Changes

Present a table of proposed actions:

```
| Action | File | From | To | Reason |
|--------|------|------|----|--------|
| PROMOTE | user_philosophy.md | ~/CODE/ | ~/.claude/memory/ | type:user, cross-project |
| DELETE | nas_hardware.md | arr-stack/ | — | duplicated in user_homelab.md |
| MOVE | jisho_migration.md | ~/CODE/ | ~/CODE/jisho/ | project-specific |
| UPDATE | project_infra.md | ~/CODE/ | — | stale port numbers |
| INDEX | feedback_typing.md | jisho/ | — | missing from MEMORY.md |
```

Ask the user to confirm before executing.

## Step 5: Execute

For each confirmed action:

### PROMOTE (project → global)
1. Copy file to `~/.claude/memory/`
2. Add entry to `~/.claude/memory/MEMORY.md`
3. Remove from old project scope
4. Update old project's `MEMORY.md`

### DELETE
1. Remove the file
2. Remove from its `MEMORY.md`

### MOVE
1. Copy to new scope
2. Add to new scope's `MEMORY.md`
3. Remove from old scope
4. Update old scope's `MEMORY.md`

### UPDATE
1. Edit the memory file with corrected content
2. Update description in frontmatter if needed

### INDEX
1. Add missing entry to the scope's `MEMORY.md`

## Step 6: Report

```
Memory Sync Complete
  Global: N memories (N new, N updated)
  Projects: N scopes, M total memories
  Actions: N promotions, N deletions, N moves, N updates
```

## Important Notes

- **Never delete without confirmation** — memories represent accumulated knowledge
- **Global memories should be path-free** — no specific file paths that change per project
- **Keep MEMORY.md indexes concise** — one line per memory, description only
- **Frontmatter must stay accurate** — name, description, type should match content
- **The 200-line limit on MEMORY.md** — Claude Code truncates after 200 lines, keep indexes tight
