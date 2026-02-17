---
description: Load a plan and execute it in batches with review checkpoints and parallel agents
---

Load, review, and execute an implementation plan in batched phases with verification checkpoints.

Combines plan discovery, batch execution, parallel dispatch for independent tasks, and review gates into a single workflow.

## Step 1: Find and Load Plan

Search two locations (in order):
1. `./plans/` — project-local plans (in current repo)
2. `~/Notes/plans/planned/` — global plans

**If no argument provided**, list available plans from both locations:
```bash
echo "=== Project plans ===" && ls ./plans/PLAN_*.md 2>/dev/null || echo "(none)"
echo "=== Global plans ===" && ls ~/Notes/plans/planned/PLAN_*.md 2>/dev/null || echo "(none)"
```
Then ask which plan to implement.

**If argument provided** ($ARGUMENTS), find the matching plan:
- Search for files matching `*$ARGUMENTS*` in `./plans/` first, then `~/Notes/plans/planned/`
- If multiple matches, show them and ask which one
- If single match, read it

## Step 2: Review Plan Critically

After reading the plan, present a brief summary:
- **Goal**: What the plan achieves (1-2 sentences)
- **Phases**: List each phase with task count
- **Total tasks**: How many steps total
- **Estimated batches**: ceil(total_tasks / 3)
- **Parallelization opportunities**: Identify tasks within each phase that are independent (no shared files, no import dependencies) and could run as parallel agents

If the plan has gaps, unclear steps, or concerns — raise them before starting.

Then ask: "Ready to start Phase A?" (or whichever phase is first).

## Step 3: Create Task List

Convert plan tasks into TodoWrite items. Mark all as pending. Group by phase.

## Step 4: Execute in Batches

**Default batch size: 3 tasks** (adjustable per user preference).

For each batch:

1. **Identify parallelizable tasks** in the batch:
   - Independent tasks (no shared files, no import dependencies between them) → dispatch as parallel agents using the `dispatching-parallel-agents` pattern
   - Dependent tasks → execute sequentially
   - When in doubt, execute sequentially

2. **For each task**:
   - Mark as in_progress
   - Execute the step exactly as written in the plan
   - Run any verification specified (tests, type checks, build)
   - Mark as completed

3. **After batch completes**, report:
   ```
   ## Batch N Complete (tasks X-Y of Z)

   **Completed:**
   - [x] Task description — result/notes
   - [x] Task description — result/notes
   - [x] Task description — result/notes

   **Verification:** [pass/fail + output summary]

   **Next batch:** [preview of next 3 tasks]

   Ready for feedback before continuing.
   ```

4. **Wait for user feedback** before starting next batch. Apply any changes requested.

## Step 5: Phase Transitions

When a phase completes (e.g., Phase A → Phase B):
- Summarize what Phase A accomplished
- Run full verification (build, tests, type check as appropriate)
- Preview Phase B scope
- Ask: "Phase A complete. Ready for Phase B?"

This is a natural checkpoint for the user to review, adjust the plan, or pause.

## Step 6: Completion

After all tasks complete:
- Run final verification (full build + test suite)
- Summarize what was implemented
- Use the `superpowers:finishing-a-development-branch` skill to present options (commit, PR, merge)

## Parallel Agent Dispatch

When 2+ tasks in a batch are independent, dispatch them as parallel agents:

```
Task 1: Create useYouTubePlayer hook (no imports from task 2)
Task 2: Create useActiveSubtitle hook (no imports from task 1)
→ PARALLEL: Both are new hooks with no shared code

Task 3: Create PlayerView component (imports hooks from tasks 1+2)
→ SEQUENTIAL: Depends on tasks 1+2
```

**Rules for parallel dispatch:**
- Tasks create different files → likely parallel
- Tasks edit the same file → sequential
- Task B imports from task A's output → sequential
- Tasks are in different domains (hook vs component vs CSS) → likely parallel

**Agent prompt structure** for parallel tasks:
- Specific scope (one task only)
- Self-contained context (what files to read, what to create)
- Clear output expectations (summary of what was created/changed)
- Constraints (don't touch other files)

## When to Stop

**STOP and ask for guidance when:**
- A task fails verification
- The plan has unclear instructions for the current step
- A dependency is missing or broken
- Two tasks conflict (parallel dispatch failed)
- Build or tests break unexpectedly

Do not guess or force through blockers. Report what happened and ask.

## Example Usage

```
/implement-plan youtube_player    # loads PLAN_youtube_player.md and starts execution
/implement-plan                   # lists all available plans
/implement-plan catppuccin        # fuzzy-matches catppuccin plan
```
