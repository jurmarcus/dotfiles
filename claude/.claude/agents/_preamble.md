# Agent Preamble — Read This First

Every agent in this roster operates under a shared worldview. Internalize this before analyzing anything.

## Problem Space → Solution Space

All software starts from nothingness. Then problems are identified, and solutions are designed.

- **Every feature solves a problem.** If it solves no problem, it is not needed.
- **Every domain groups related solutions.** Domains follow patterns of trackable logical consistency.
- **Every record has a source.** If there is no source, there is no meaning. If there is no meaning, there is no record.

## The Three Layers

Every program that solves a problem has three layers:

### 1. Foundational Data (the world model)

Reference knowledge the problem space requires as input. Imported, not produced by the user. The bedrock everything else is built on.

In jisho: vocab, grammar, kanji, proper nouns, radicals, frequency data. The user didn't create 食べる — the dictionary did. But without knowing what "words" are, you can't answer "what words does the user know?"

**This is why jisho started with the dictionary domain and worked backwards.**

### 2. Aggregates (accumulated user state)

State that builds up over time from user actions. The system's memory of what the user has done, seen, learned, and produced. Every record traces back to a user event.

In jisho: user_vocab, user_grammar, cards, morphemes, passage_spans, watch history, acquisition snapshots.

### 3. Computations (derived solutions)

Pure functions that take **user input + foundations + aggregates** and produce a solution. Computations don't own state — they read from (1) and (2), derive an answer, and either return it or produce a side effect that updates (2).

In jisho: analysis pipeline, scoring engine, recommendation engine, search, TTS, morph pipeline.

```
solution = compute(user_input, foundations, aggregates)
```

### The Universal Pattern

Every program follows this if it solves a problem:
- **Foundations** provide the vocabulary of the domain (what exists in the world)
- **Aggregates** capture what the user has done (accumulated state)
- **Computations** derive answers by mapping user intent against both

When designing anything — a new feature, a new table, a new API — ask: "Is this a foundation, an aggregate, or a computation?" If it's none of the three, it probably doesn't belong.

## Data Model as DNA

The data model IS the application. PG schema → GraphQL → MCP → CLI → UI are all projections of the same truth. Design the data right, and everything downstream falls out naturally.

## Paradigms

- **FP**: pure functions, immutable data, composition
- **FRP**: reactive data dependencies, changes propagate through declarative pipelines
- **DDD**: aggregates, bounded contexts, projections, events

## For Agents

When analyzing or recommending:
1. Name the **problem** being solved
2. Classify: foundational data, aggregate state, or tool?
3. Map it to the **domain** it belongs to
4. Trace the **data flow** (event → state → projection → consumer)
5. If your suggestion doesn't solve a stated problem, don't make it
