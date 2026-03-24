---
name: panel
description: "Assemble an expert panel to analyze an architectural question or system component. Auto-discovers agents from both global (~/.claude/agents/) and project (.claude/agents/) directories, selects the most relevant experts for the question, and runs them as a coordinated Agent Team. Use when the user says /panel <question>, 'assemble a panel', 'get expert review', 'spin up experts', or wants multi-expert analysis of any topic."
user_invocable: true
argument: "the question or topic for the expert panel to analyze"
---

# Expert Panel — Auto-Assembled Agent Team

Discovers available agent profiles, selects the right experts for the question, and runs them as a coordinated Agent Team.

## Step 1: Discover Available Agents

Read agent profiles from BOTH locations:

```
~/.claude/agents/*.md          (global — how you program)
.claude/agents/*.md            (project — domain-specific)
```

For each `.md` file (skip README.md), read the frontmatter to extract:
- `name` — agent identifier
- `description` — when to use this agent
- `model` — opus or sonnet

Build a roster of all available agents with their descriptions.

## Step 2: Read Context

1. Read `~/.claude/agents/_preamble.md` — the shared philosophy (FAC model)
2. Read the project's root `CLAUDE.md` — project context
3. Read the user's question/topic from the skill argument

## Step 3: Select Experts

Based on the question, select 5-8 agents whose descriptions are most relevant. Always include:
- **`devils-advocate`** (global) — for balance, always invited
- At least 1 technical agent relevant to the implementation
- At least 1 domain agent relevant to the subject matter

Announce the selected panel to the user before proceeding:
```
Assembling panel for: "<question>"
Experts: postgresql, scoring-engine, japanese-pedagogy, acquisition-architect, devils-advocate, performance-profiler
```

## Step 4: Create Team

```
TeamCreate(team_name: "panel-<short-slug>", description: "Expert panel: <question>")
```

## Step 5: Create Tasks

Create one task per expert:

```
TaskCreate(subject: "<agent-name>: Analyze <specific-aspect>")
```

Plus a synthesis task blocked by all expert tasks:
```
TaskCreate(subject: "Synthesize findings into prioritized report", blockedBy: [all expert task IDs])
```

## Step 6: Spawn Expert Teammates

For each selected expert, read their full profile file and spawn:

```
Agent(
  name: "<agent-name>",
  team_name: "panel-<slug>",
  model: <from profile frontmatter>,
  prompt: """
  <contents of _preamble.md>

  <contents of project CLAUDE.md (first 200 lines)>

  <contents of agent profile .md (the system prompt section)>

  YOUR TASK:
  <the user's question, scoped to this expert's domain>

  Report your findings as: STRENGTHS, WEAKNESSES, CRITICAL ISSUES, and RECOMMENDED CHANGES (prioritized).
  Do NOT write any code. Research only.
  When done, mark your task as completed via TaskUpdate.
  """
)
```

Use `model: sonnet` for agents whose profile says sonnet, `model: opus` for opus.
Spawn ALL expert agents in a single message (parallel launch).

## Step 7: Wait and Synthesize

After all expert tasks complete, the team lead (you) synthesizes:

1. **Cross-expert consensus** — findings where 3+ experts agree
2. **Disagreements** — where experts contradict, with your resolution
3. **Critical bugs** — anything broken found by any expert
4. **Prioritized action plan** — ordered by impact/effort ratio
5. **Summary table** — one row per expert with their key finding

Write the synthesis to `plans/panel-<slug>.md` in the project.

## Step 8: Cleanup

1. Present the synthesis to the user
2. Ask if they want to act on any findings
3. Shutdown all teammates via SendMessage shutdown_request
4. TeamDelete after all teammates confirm shutdown

## Important Notes

- **Agent discovery is dynamic** — the panel works for ANY project, picking from whatever agents exist in both global and project directories
- **The preamble is always injected** — every expert thinks in FAC terms
- **Project CLAUDE.md is always injected** — every expert has project context
- **Devils advocate is always invited** — prevents groupthink
- **Minimum 5, maximum 10 experts** — fewer is too narrow, more is diminishing returns
- **All experts are research-only** — they read code, they don't write it
- **The synthesis is the deliverable** — individual expert reports are intermediate artifacts
