---
name: batch-sentences
description: "Add i+1 sentences to a batch of Anki cards that have empty sentences. Use when the user says /batch-sentences <deck>, 'add sentences to deck', 'batch sentences', 'fill empty cards', 'do the next N cards', or wants to populate suspended vocabulary cards with example sentences and audio. Requires: anki-mcp, jisho-acquisition, jisho-voice MCP servers."
user_invocable: true
argument: deck name (e.g., "Tango N3")
---

# Batch Sentences Skill

Automatically generate i+1 sentences, synthesize audio, and update a batch of Anki cards that have empty Sentence fields. Fully automatic with a summary at the end.

Follow **sentence-core** conventions for formatting, audio synthesis, voice selection, and illustration search.

## Prerequisites

Read `~/.config/jisho/jisho.toml` to get:
- `[anki].profile` — Anki profile name (for the audio file path)

## Arguments

- **Required**: deck name (the `$ARGUMENTS` value, e.g., `"Tango N3"`)
- **Optional count**: if the user specifies a number (e.g., `/batch-sentences Tango N3 5`), use that as the batch size. Default: **10**.

## Workflow

### Step 1: Sync Anki

Call `mcp__anki-mcp__sync` to ensure latest data.

### Step 2: Find cards needing sentences

Use `mcp__anki-mcp__get_cards` to get suspended cards in deck order (by position):

```
mcp__anki-mcp__get_cards(deck_name: "<deck>", card_state: "suspended", limit: 50)
```

Then call `mcp__anki-mcp__notesInfo` on the returned card IDs to get full details.

Filter to only cards where `SentenceAudio` is empty — this catches both truly empty Sentence fields and cards where the Sentence field just contains the word as a placeholder.

- If **no cards need sentences**: tell the user and stop.
- If **fewer than batch size**: process all of them, tell the user how many were found.
- Cards are already in deck position order from `get_cards` — do NOT re-sort by note ID.
- Take the first N cards (batch size).

### Step 3: Show what we're processing

```
Processing **N** cards from **<deck>**:
1. <Word> — <WordMeaning>
2. <Word> — <WordMeaning>
...
```

### Step 4: Generate i+1 context

Call `mcp__jisho-acquisition__generate_sentences` with `topic_count: 5`.

### Step 5: Generate sentences

For each card, generate **one** i+1 sentence. Distribute topics evenly across the batch.

### Step 6: Format fields

For each card, call `mcp__jisho-acquisition__format_sentence` with the sentence, furigana, word, meaning, and translation. This returns `sentence_html`, `furigana_html`, `audio_tag`, etc.

### Step 7: Find illustrations

Follow sentence-core illustration search conventions for each card.

### Step 8: Synthesize audio (batch)

Call `mcp__jisho-voice__synthesize_batch` with all items at once. Follow sentence-core audio conventions.

Output path: `/Users/methylene/Library/Application Support/Anki2/<profile>/collection.media/<Word>-sentence.ogg`

### Step 9: Update all cards

For each card, call `mcp__anki-mcp__updateNoteFields` with the note ID and the formatted fields from Step 6 (use sentence-core field names: Sentence, SentenceFurigana, SentenceMeaning, SentenceAudio, Picture).

Update all cards in parallel for speed.

### Step 10: Tag all cards

Add the `refreshed` tag to all processed notes:

```
mcp__anki-mcp__tagActions(action: "addTags", notes: [<all noteIds>], tags: "refreshed")
```

### Step 11: Summary

```
Updated **N** cards in **<deck>**:

| # | Word | Sentence | Meaning | Picture | Topic |
|---|------|----------|---------|---------|-------|
| 1 | ... | ... | ... | ✓ / — | ... |

Remaining suspended empty cards: ~<count>
```

## Important Notes

- No user interaction during processing — this skill is fully automatic
- If synthesis fails for a card, skip it, report the error, and continue with the rest
