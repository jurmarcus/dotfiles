---
name: sapling-workflow
description: Use when working in a sapling (sl) repository — especially anything under ~/code/ which is native .sl mode with no git. Covers the daily sapling command surface (smartlog, ssl, absorb, amend+auto-restack, pr submit --stack), the parallel-work pattern with sl share + sl follow + sl adopt (the sapling replacement for git worktree), ISL (sl web) for drag-and-drop rebase, and the bookmark model. Trigger when the user mentions sapling, sl, smartlog, sl share, parallel work, stacked PRs, absorb, ISL, or when working in any directory under ~/code/.
---

# Sapling Workflow

You are working in a sapling-first environment. All repos under `~/code/` are **native sapling (`.sl` mode)** — they have no `.git/` directory at all. `git` commands physically cannot work in these repos; they will fail with `fatal: not a git repository`. Reach for `sl` commands directly.

Outside `~/code/` (e.g., `~/dotfiles/`, `~/notes/`), repos are git-interop sapling (both `.git/` and sapling state). The user's global CLAUDE.md mandates `sl` commands there too, but the physical enforcement only applies to `~/code/`.

## The one translation that actually matters

| git | sapling |
|---|---|
| `git worktree add <path>` | **`sl share . <path>`** |

This is the load-bearing translation. `sl share` is what unlocks the parallel-work pattern the user adopted sapling for. It's **fundamentally different from git worktree**: two sapling shares can sit on the same commit simultaneously with independent working directories, whereas git refuses two worktrees on the same branch. This is the enabling property for multi-agent / multi-task workflows on one repo.

Other `git X → sl Y` mappings are mostly mechanical (`git status → sl status`, `git log → sl log`, etc.) and you can derive them from context. If stuck, the sapling docs at https://sapling-scm.com/docs/ are authoritative.

## The parallel-work pattern (the reason sapling is worth the migration)

From ezyang's blog post (https://blog.ezyang.com/2026/03/parallel-agents-heart-sapling/):

```
     <one sapling repo>
            │
            ├── sl share . ../repo-work-a    # worktree A: top of stack, feature work
            ├── sl share . ../repo-work-b    # worktree B: mid-stack, review fixes
            └── sl share . ../repo-work-c    # worktree C: E2E tests
```

All three shares read/write the same store. Each has its own `.` (current commit) and working directory. Edits in A don't affect B's working copy. When one share amends a commit, the obsmarker propagates to the store; other shares whose `.` is now pointing at an obsoleted commit can catch up via `sl follow`.

**The two aliases baked into the user's sapling.conf:**

```ini
[alias]
follow = goto last(successors(.))
adopt = rebase -s 'children(parents(.)) - .' -d .
```

- **`sl follow`** — chase the obsmarker chain to the live successor of `.`. Use this in share B after share A amended a commit that B was sitting on.
- **`sl adopt`** — rebase any newly-inserted children of our parent onto `.`. Use when share A inserted a new commit mid-stack and share B needs to rebase its work on top.

**Canonical multi-agent flow:**

1. Agent A, working in share-a, amends the schema commit. Sapling auto-restacks downstream work in share-a.
2. Agent B, working in share-b, was parked on the old schema commit. Agent B runs `sl follow` to chase the obsmarker chain to the new schema commit.
3. Agent B commits a new change on top; that change is now in the store.
4. Agent C, working in share-c (E2E tests), runs `sl follow` to catch up to the full new state.

**When recommending parallel work**, suggest `sl share` explicitly. Do not suggest `git worktree add` under any circumstances in `~/code/` — it will fail and the user has explicitly chosen sapling-only.

## S-tier daily commands

### `sl smartlog` / `sl ssl` / bare `sl`

The user has aliased bare `sl` → `sl ssl` (Super Smartlog). A plain `sl` shows:
- Your current position `@`
- Your local draft commits
- Obsoleted commits as `x` (with "Landed as YYY" messages)
- The main branch as a dashed line eliding thousands of irrelevant commits
- GitHub PR status + CI state + review state inline (once `gh auth` is set up)

**Replaces**: `git log --graph --all --oneline` + `git branch` + `gh pr status` + squinting.

Use this as the default status check. Much more informative than `sl status`.

### `sl absorb` (`sl ab`)

Edit lines anywhere in the working copy, then `sl absorb`. Sapling figures out which commit in the current stack introduced each line and amends them in place. Unambiguous changes are absorbed; ambiguous ones stay in the working copy for manual resolution.

```bash
sl absorb --dry-run   # preview without applying
sl absorb -a          # skip confirmation
```

**This replaces** `git commit --fixup=<sha>` followed by `git rebase -i --autosquash`. It's strictly better because you don't have to identify which commit gets the fixup — absorb does it.

Constraints:
- Will not touch public commits or merges
- Leaves ambiguous changes in the working copy (safe failure mode)

**When you see "I need to fix a bug that was introduced 3 commits ago" style problems, reach for `sl absorb` first.**

### `sl amend` (with automatic restack)

Navigate to any commit in the stack via `sl goto <sha>` or `sl prev`/`sl next`. Edit files. Run `sl amend`. Sapling auto-rebases every downstream commit onto the amended version. Conflict-free in the overwhelming majority of cases because changes are localized.

**This replaces** `git rebase -i HEAD~N` + manual `edit` actions + conflict resolution. The auto-restack is the killer feature — you never have to think about rebasing after amending.

```bash
sl prev              # go back one commit
# edit files
sl amend             # amend and auto-restack descendants
sl next              # return to the top
```

### `sl pr submit --stack` (`sl pr s -s`)

Creates one GitHub PR per commit in the current stack. Each PR is automatically linked to the next. Re-submitting updates them in place.

Caveat: PRs on github.com show "overlapping commits" (each PR includes the target commit plus all ancestors below it). For **solo work**, github's PR UI is fine — just merge them in order. For **external review**, use [reviewstack.dev](https://reviewstack.dev) — replace `github.com` with `reviewstack.dev` in any PR URL and you get a clean per-commit view.

**This replaces** multiple `git push` + `gh pr create` invocations. One command, one PR per commit, linked automatically.

### `sl undo` / `sl undo -i`

Operates on the commit graph, not refs. Undo a rebase, undo an amend, undo a goto, undo a hide. `sl undo -i` opens an interactive graph-at-time-T browser navigable with arrow keys.

**This replaces** `git reflog` + manual `git reset --hard ORIG_HEAD` archaeology. Reach for `sl undo` any time the user says "I just broke something" — it's almost always reversible.

## Commit philosophy: atomic units of work

The user's rule is short: **"we add things atomically, at units of work."** Each commit should represent exactly one unit of work, and the commit log is a journal of what was done — not a curated narrative or a story to be polished after the fact.

This rule is NOT "never rewrite commits." It's "each commit should be atomic by the time it's finished." Those two are very different:

- **Iteration noise is not a unit of work.** If I just committed "add feature X", realized 30 seconds later I wanted to tweak X, and committed "fix oversight in X" — those two commits are **not** two units of work. They're one unit of work (add X) with a retry. **Fold them into one** using `sl fold --from <first>` or `sl amend` the first commit directly. This is correct sapling usage and the user wants it done.
- **Real distinct decisions ARE different units of work.** If I committed "add feature X" and then later committed "refactor feature X for clarity because of feedback from review" — those are two units. Leave them alone.
- **The distinction is the decision count, not the file overlap.** Two commits touching the same file can still be two real units. Two commits that together represent one coherent change should be one commit.

**When to reach for which rewriting primitive:**

| Situation | Primitive |
|---|---|
| I just committed and realized I want to adjust the commit | `sl amend` — edits the most recent commit (or navigate to it via `sl goto`, edit files, `sl amend`) |
| I have 2+ commits at the tip that are really one unit | `sl fold --from <first-to-fold>` — collapses linearly from the given commit through `.` |
| Edits in my working copy should flow back into specific earlier commits in my stack | `sl absorb` — sapling figures out which commit each line belongs to |
| I need to pick specific non-contiguous commits to fold | `sl fold --exact <rev1> <rev2>` (they must be linearly chained) |

**Do not:**

- Narrate commits into a story they weren't when they happened
- Squash commits that represent distinct decisions just to reduce line count
- Treat "messy-looking" history as a problem — if each commit is a real unit, the history is correct even when it includes a retry
- **Never describe a committed sequence as "noisy," "flip-flop," or "would be cleaner collapsed"** unless you're specifically asking "was this really one unit of work?" and the answer is yes. The user's framing is "no one gives a fuck about commit history" — your job is to make each commit atomic at the moment of commit, not to tidy it afterward.

**In practice**: when you realize mid-session "these last two commits should have been one," `sl fold` them. When you realize mid-session "that commit I made an hour ago is missing a line," `sl goto <sha> && sl amend`. When the user tells you history looks fine, leave it fine.

Sapling's auto-restack makes all of this cheap: amending a commit in the middle of your stack automatically rebases everything above it. No conflict dance unless the edit actually conflicts with downstream code.

## ISL — the GUI rebase (`sl web`)

```bash
sl web
```

Launches a local web server and opens a browser UI. Shows the commit tree with drag-and-drop rebase, click-to-goto, inline PR badges, conflict resolution. Watchman (installed via brew) makes it auto-refresh on filesystem changes.

**When to suggest it**: complex rebase/restack work, visual branch surgery, the user wants to "see" the stack. The terminal smartlog is great for daily use; ISL is great for "I need to rearrange things and want to see what I'm doing."

Works over SSH port forwarding too — you can run `sl web` on a remote host and access it from your local browser.

## The bookmark model (why there's no detached HEAD here)

In sapling, **a commit doesn't need a name to exist**. The smartlog shows it whether a bookmark points at it or not. There is no detached HEAD concept — you're always at a commit, end of story.

- Local bookmarks: `sl bookmark <name>` creates a name-pointer at `.`. Safe to delete (deletion doesn't hide the commit). Bookmarks follow their commit automatically when you amend/rebase.
- Remote bookmarks: prefixed `remote/`, read-only locally, updated by `sl pull`/`sl push`. The github "branch" you see visiting a PR is a remote bookmark.

**Key implication**: when the user talks about "the branch I was on," in sapling that's usually "the commits I was stacking" — no branch name needed. When something DOES need a name (to push to a specific github branch), it's a bookmark, not a branch.

**There is no `git checkout -b feature` equivalent.** `sl bookmark feature` just tags the current commit; you don't "switch to" it because you're already there.

## Recovery patterns

- **"I broke my stack"** → `sl undo` (or `sl undo -i` for visual)
- **"I accidentally hid a commit"** → `sl unhide <sha>` (hash still shows in smartlog history)
- **"I'm on an obsoleted commit"** → `sl follow` (walks to the live successor)
- **"I want to start over from main"** → `sl goto remote/main` (auto-pulls if needed)
- **"I need to recover work from yesterday"** → `sl debugmutation` shows the full mutation history, or `sl undo -i` navigates it visually

Sapling keeps a full mutation history — commits that appear "gone" are almost always still recoverable via `sl unhide`, `sl undo`, or by direct SHA lookup (commits aren't deleted just because nothing currently references them).

## Common confusions to avoid

| Don't reach for | Reach for |
|---|---|
| `git rebase -i HEAD~5` | `sl absorb` (line-level) or `sl goto X && sl amend` (commit-level) |
| `git worktree add` | **`sl share .`** (works, and you can have two shares on the same commit) |
| `git stash` | `sl shelve` |
| `git stash pop` | `sl unshelve` |
| `git reflog` | `sl undo -i` |
| `git checkout -b feature` | `sl bookmark feature` (you stay put; bookmark tags `.`) |
| `git push origin feature` | `sl push --to remote/feature` |
| `git cherry-pick <sha>` | `sl graft <sha>` |
| `git revert <sha>` | `sl backout <sha>` |
| `git fetch` | `sl pull --update=false` |
| `git rebase main` | `sl rebase -d main` |

## Things sapling `.sl` mode does NOT support

- Git LFS (use `.git` mode if you need LFS — but none of the user's `~/code/` repos do)
- Git submodules in `.git` mode (work in `.sl` mode though — all `~/code/` repos are `.sl`)
- Git hooks (sapling has its own hooks system; `.git/hooks/` doesn't exist)
- Local-only tags (use bookmarks instead)

If the user asks for any of these in a `~/code/` repo, point out that the repo is `.sl` mode and the feature isn't supported. Do NOT suggest converting back to `.git` mode without explicit user authorization — the native-sapling choice was deliberate.

## Reference

- ezyang's parallel-agents post: https://blog.ezyang.com/2026/03/parallel-agents-heart-sapling/
- Sapling docs: https://sapling-scm.com/docs/
- ReviewStack (for stacked PR review): https://reviewstack.dev (replace github.com in any PR URL)
- User's sapling.conf: `~/dotfiles/sapling/Library/Preferences/sapling/sapling.conf`
- Migration design doc: `~/notes/projects/sapling-migration/2026-04-15-sapling-native-migration-and-upstream-fixes-design.md`

## Quick decision tree for "what sl command do I need?"

1. **"Where am I, what's my stack state?"** → `sl` (aliased to `sl ssl`)
2. **"I need to fix something in an earlier commit"** → `sl absorb` (line-level) or `sl goto <sha> && sl amend` (commit-level)
3. **"I want parallel working dirs on the same repo"** → `sl share . <target>`
4. **"I want to submit PRs for this stack"** → `sl pr submit --stack`
5. **"I just broke my stack"** → `sl undo`
6. **"I want a GUI"** → `sl web`
7. **"I'm on an obsoleted commit after someone else amended"** → `sl follow`
8. **"I want to rebase children onto my new commit"** → `sl adopt`
9. **"I want to shelve WIP"** → `sl shelve` / `sl unshelve`
10. **"I want the smartlog without the PR status overhead"** → `\sl` (bypass the function) or `command sl smartlog`
