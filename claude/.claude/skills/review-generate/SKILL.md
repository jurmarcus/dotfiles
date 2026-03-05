---
name: review-generate
description: "Generate i+1 review sentences from Anki due cards. Use when the user says /review-generate, 'generate review sentences', 'make review cards', 'pull due cards', or wants to create sentences.json entries from their Anki due queue for jisho-review TUI practice. Requires: anki-mcp, jisho-acquisition, jisho-voice MCP servers."
user_invocable: true
argument: "optional deck name and count (e.g., 'Tango N3 20')"
---

# Review Generate Skill

Pull due cards from Anki, generate i+1 sentences, and save to sentences.json for jisho-review TUI practice with Anki grading support.

Follow **sentence-core** conventions for formatting, audio synthesis, voice selection, and illustration search.

## Arguments

- **Optional deck**: filter to a specific deck (e.g., `"Tango N3"`)
- **Optional count**: number of cards to process (default: **20**)

Parse from `$ARGUMENTS`: e.g., `/review-generate Tango N3 20` → deck="Tango N3", count=20

## Workflow

### Step 1: Sync Anki

Call `mcp__anki-mcp__sync` to ensure latest data.

### Step 2: Get due cards

Use `mcp__anki-mcp__get_due_cards` to get cards due for review:

```
mcp__anki-mcp__get_due_cards(deck_name: "<deck>", limit: <count>)
```

If no deck specified, omit `deck_name` to get due cards from all decks.

Then call `mcp__anki-mcp__notesInfo` on the returned card IDs to get full details (Word, WordMeaning fields).

- If **no due cards**: tell the user and stop.
- If **fewer than count**: process all of them, tell the user how many were found.

### Step 3: Show what we're processing

Display a brief list:

```
Generating **N** review sentences from due cards:
1. <Word> — <WordMeaning>
2. <Word> — <WordMeaning>
...
```

### Step 4: Generate i+1 context

Call `mcp__jisho-acquisition__generate_sentences` with:
- `topic_count: 5`

This returns a prompt with vocabulary lists. Use this context for all sentence generation.

### Step 5: Generate sentences

For each card, generate **one** i+1 sentence where:
- The target word (`<Word>`) is the +1 learning word
- All other words come from the user's acquired/mature vocabulary
- Sentences are natural, everyday Japanese

Distribute topics from Step 4 evenly across the batch.

### Step 6: Save each sentence

For each card, call `mcp__jisho-acquisition__save_sentence` with:
- `sentence`: the plain sentence
- `furigana`: the kanji[reading] furigana
- `learning_word`: the Word value
- `word_meaning`: the WordMeaning value
- `translation`: the English translation
- `topic`: the assigned topic
- `anki_card_id`: the **card ID** (not note ID!) from Step 2

**Do NOT call `format_sentence`** — that tool is for Anki card HTML fields. `save_sentence` writes raw text to sentences.json.

### Step 7: Summary

```
Saved **N** review sentences to sentences.json.

| # | Word | Sentence | Topic |
|---|------|----------|-------|
| 1 | ... | ... | ... |

Run `just review` to start reviewing. Press `j` to grade cards as "Good" in Anki.
```

## Important Notes

- Use the **card ID** (from `get_due_cards`), not the note ID, for `anki_card_id`
- `save_sentence` handles audio synthesis automatically — do NOT call synthesize separately
- Do NOT update any Anki card fields — this skill only writes to sentences.json
- Grading happens in jisho-review TUI via the `j` key (sends "Good" grade back to Anki)
