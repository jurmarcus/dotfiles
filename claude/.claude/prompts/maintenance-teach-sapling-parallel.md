# Teach Claude to use Sapling for parallel agent work

You are starting **cold**. Read this whole prompt before doing anything. The user will not be steering you turn-by-turn — act thoughtfully, stop and ask before irreversible changes, and finish with a clear hand-off.

## Who you are working for

`methylene` / `jurmarcusallen@gmail.com`. Develops from `methylene-studio` (macOS server) over a Tailscale mesh, lives in tmux panes, uses **Sapling (`sl`) exclusively** — never `git`. Primary project: `~/CODE/jisho`. Full environment rules are in `~/.claude/CLAUDE.md` and `~/.claude/memory/MEMORY.md` — read those first.

## Why this task exists

Earlier this week the user asked me to clean up a stray git worktree under `~/CODE/jisho/.claude/worktrees/pocketcasts-sync`. It was orphaned — created by a superpowers skill, invisible to `sl`, leftover for weeks. I saved a feedback memory telling future-Claude to **never let superpowers skills create git worktrees**. Then the user pointed me at two resources that prove the rule was overbroad:

1. **Sapling issue #153** — <https://github.com/facebook/sapling/issues/153>  
   Sapling inherits Mercurial's `share` extension. It creates multiple working directories that share **one backing store** — one commit graph, one smartlog, bookmarks visible from every checkout. Setup:
   ```bash
   sl config -u                                      # opens ~/.config/sapling/sapling.conf
   # add under [extensions]:
   #   share=
   sl share -B /path/to/repo /path/to/other-checkout # -B shares bookmarks too
   ```
   This is the sl-native equivalent of `git worktree add`. Commenters on the issue confirmed it works, with the caveat that the extension "should" work in sapling but hadn't been fully verified by them.

2. **ezyang's post** — <https://blog.ezyang.com/2026/03/parallel-agents-heart-sapling/>  
   Describes running multiple Claude agents in parallel over a **single sapling stack**, with one worktree per stack layer. Key commands: `sl smartlog` for situational awareness, `sl follow` to move a worktree from a stale commit to its successor while carrying uncommitted changes, `sl adopt` to rebase orphaned children onto a newly inserted commit, and `sl prev/next/top/bottom` for stack navigation. Sapling's obsolescence / successor-tracking is what makes mid-stack amends safe when other agents are working the same stack — something git literally cannot do.

The old feedback memory has been deleted. Your job is to replace it with the **right** behavior: make Claude prefer `sl share` + sapling stack commands when orchestrating parallel work in a sapling repo, and only fall back to git worktrees in git-only repos.

## Tasks

### 1. Discovery (read-only — no writes yet)

- Grep `~/.claude/` for every reference to worktrees: `worktree`, `git worktree`, `EnterWorktree`, `isolation.*worktree`, `using-git-worktrees`, `sl share`. Use `rg` via the Grep tool.
- Locate and read the full text of the `superpowers:using-git-worktrees` skill. It lives under a plugin directory — find it with Glob (`**/using-git-worktrees*.md`).
- Read `superpowers:executing-plans`, `superpowers:subagent-driven-development`, and `superpowers:dispatching-parallel-agents`. These are the skills most likely to invoke worktree creation.
- Check for any existing `using-sapling-*` skill.
- Grep `~/.claude/hooks/` and `~/.claude/settings*.json` for worktree references.
- Report the inventory in ≤20 lines before making any changes.

### 2. Verify `sl share` actually works on this machine

- Check if the share extension is already enabled: `sl config extensions.share`.
- If not: locate the config file (`sl config -u --no-editor` prints the path, or check `~/.config/sapling/sapling.conf`). **Ask the user before adding `share=` to `[extensions]`** — this is the first irreversible change.
- Smoke test in a **throwaway** location, not in `~/CODE/jisho`:
  ```bash
  sl share -B ~/CODE/jisho /tmp/jisho-share-test
  cd /tmp/jisho-share-test && sl smartlog | head -20
  cd - && rm -rf /tmp/jisho-share-test
  ```
  Verify the share sees the same commits as the main checkout.
- Report whether share works and note the sapling version (`sl version`) in case there are known rough edges.

### 3. Propose a plan, then ask the user before executing

Based on discovery, lay out these three options in 5-10 lines each with tradeoffs, and let the user pick:

**A. Minimal edit.** Add a short "if the repo uses sapling, use `sl share` instead" section to the existing `using-git-worktrees` skill. Cheap, reversible, low-friction.

**B. New dedicated skill.** Create `using-sapling-shares` (or similar) that covers `sl share` setup, the ezyang stack-based parallel-agents workflow, `sl follow` / `sl adopt` / `sl smartlog`, and when to collapse back to a single checkout. Update `executing-plans` and `dispatching-parallel-agents` to prefer it for sapling repos. More work, proper fit.

**C. Skill + hook.** Option B plus a PreToolUse hook on the `Agent` tool that blocks `isolation: "worktree"` in sapling-managed directories and nudges toward `sl share`. Strongest guardrail.

### 4. Implement the chosen path

- Skill content should describe the ezyang pattern concretely: one worktree per stack layer (e.g. `worktree-e2e` / `worktree-feature` / `worktree-review`), one tmux pane each, `sl smartlog` as the shared dashboard, `sl follow` to promote stale worktrees, `sl adopt` to rebase orphans.
- Every non-trivial edit gets verified by reading the file back after writing.
- **Do NOT modify any files inside `~/CODE/*`** — this work is scoped to `~/.claude/` and (with approval) `~/.config/sapling/` only.
- **Do NOT delete existing skills** — only add or edit.

### 5. Replace the feedback memory

Write a new memory at `~/.claude/memory/feedback_sapling_parallel_work.md`:

- **Rule:** Prefer `sl share` + sapling stack commands over `git worktree` / `Agent isolation: "worktree"` / `EnterWorktree` for parallel agent work in sapling-managed repos. Fall back to git worktrees only in git-only repos.
- **Why:** Cite ezyang's post and sapling issue #153. Explain that `sl share` gives one commit graph and one smartlog, and sapling's successor-tracking makes mid-stack amends safe across agents. Note that the 2026-04-15 cleanup removed a stray git worktree under `.claude/worktrees/` — the lesson was *tool mismatch*, not that parallel working trees are bad.
- **How to apply:** Concrete command snippets for `sl share -B`, `sl follow`, `sl adopt`, `sl smartlog`, plus the "tmux pane per worktree" layout from ezyang.

Then add a one-line pointer to `~/.claude/memory/MEMORY.md` under the `## Feedback` section.

### 6. Hand-off

Finish with a short report: what changed, which files to review, and any follow-up. Flag anything the user should do themselves — for example:
- Whether to run `sl share` against `~/CODE/jisho` (don't do it yourself; it's a directory-layout decision)
- Whether the sapling version has known rough edges with the share extension
- Whether option C's hook requires additional `permissions` config

## Scope boundaries (hard limits)

- Do **not** touch project code in `~/CODE/*`.
- Do **not** modify the sapling config without explicit approval.
- Do **not** run `sl share` against `~/CODE/jisho` itself in this session.
- Do **not** delete existing skills.
- Keep the ezyang stack workflow as the inspiration — you don't need to automate full `sl follow` / `sl adopt` orchestration, just make sure the skills describe these commands clearly enough that Claude reaches for them.
