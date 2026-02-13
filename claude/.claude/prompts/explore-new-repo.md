# Explore New Repo

> Systematic solo deep-dive into an unfamiliar codebase — layered discovery | Model: default | Agents: 0

---

I need to understand [REPO_PATH] well enough to contribute. Walk me through it
using a layered discovery approach — don't dump everything at once.

## Phase 1: Orientation (do this first, then pause for my questions)

1. Read CLAUDE.md, README.md, and any docs/ directory
2. Show me the top-level directory tree (3 levels deep) with brief annotations
3. Identify the build system and how to run/test/lint (justfile, package.json, Cargo.toml, etc.)
4. What's the tech stack? Languages, frameworks, databases, external services.
5. Is this a monorepo? If so, what are the packages and how do they relate?

Pause here. Let me ask questions before going deeper.

## Phase 2: Architecture (after I say "continue")

1. Trace the main entry points — where does execution start?
2. Draw a data flow diagram — how does a request/event flow through the system?
3. What are the major abstractions? (base classes, traits, interfaces, middleware)
4. How are dependencies wired? (DI container, manual construction, module imports)
5. Where does state live? (databases, caches, in-memory stores, config files)

Pause again.

## Phase 3: Conventions (after I say "continue")

1. Error handling — how are errors created, propagated, reported?
2. Testing — framework, patterns, fixture setup, naming conventions
3. Naming — file naming, function naming, module organization
4. What patterns should I follow when adding new code?
5. Any anti-patterns I should avoid? (check TODOs, FIXMEs, known issues)

## Phase 4: Where to start

Based on everything above, suggest:
1. The best first file to read to understand the core logic
2. The simplest module to modify as a warmup task
3. The riskiest area to touch (where bugs are most likely)

---

## Notes

- **Layered with pauses**: Prevents information overload. Each phase builds on the previous and you can steer the exploration.
- **No agents needed**: Solo exploration works better here because you want to interactively ask follow-up questions between phases.
- **"Read CLAUDE.md first"**: This is the highest-signal file in any well-maintained repo. Many questions are already answered there.
- **Phase 4 is the payoff**: Phases 1-3 build understanding, phase 4 gives you a concrete starting point. Skip phases if you're already familiar with part of the codebase.
- **Works for any size repo**: The layered approach scales — for a small repo you might blast through all phases in one go, for a large monorepo each phase could take a full session
