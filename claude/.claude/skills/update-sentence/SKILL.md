---
name: update-sentence
description: "Replace an Anki card's example sentence with an i+1 sentence. Use when the user says /update-sentence <word>, 'update sentence for <word>', 'replace sentence', 'fix sentence', or wants to change the example sentence on a Japanese vocabulary card. Requires: anki-mcp, jisho-acquisition, jisho-voice MCP servers."
user_invocable: true
argument: word to update (e.g., "一応")
---

# Update Sentence Skill

Replace an Anki vocabulary card's example sentence with a memorable i+1 sentence, synthesize audio, find an illustration, and update the card. Fully automatic — no user interaction needed.

Follow **sentence-core** conventions for sentence quality, formatting, audio synthesis, voice selection, and illustration search.

## Prerequisites

Read `~/.config/jisho/jisho.toml` to get:
- `[anki].profile` — Anki profile name (for the audio file path)
- `[meta]` — user profile (location, interests) for sentence personalization

## Workflow

### Step 1: Sync Anki

Call `mcp__anki-mcp__sync` to ensure latest data.

### Step 2: Find the card

Search with just the word field — do NOT add `note:` or other filters:

```
mcp__anki-mcp__findNotes(query: "word:<word>")
```

Then call `mcp__anki-mcp__notesInfo` on the returned note IDs.

- If **no cards found**: tell the user and stop.
- If **multiple cards found**: show each card's Word, Sentence, and deck. Ask the user to pick one using `AskUserQuestion`.
- If **one card found**: proceed.

### Step 3: Generate i+1 context

Call `mcp__jisho-acquisition__generate_sentences` with `count: 5`, `topic_count: 1`.

### Step 4: Generate the best sentence

Using the vocabulary context and sentence-core quality guidelines, generate **one** i+1 sentence — the best one. Make it vivid, personally relevant, and memorable. Prefer interesting collocations over basic literal usage.

Also generate:
- Furigana in `kanji[reading]` format
- English translation

### Step 5: Format fields

Call `mcp__jisho-acquisition__format_sentence` with the sentence, furigana, word, meaning, and translation. This returns all formatted fields.

### Step 6: Find illustration and synthesize audio (parallel)

Do both in parallel:

1. **Illustration**: Follow sentence-core illustration search conventions — search by the sentence's scene, not just the word.

2. **Audio**: Call `mcp__jisho-voice__synthesize` with the plain sentence. Follow sentence-core audio conventions.
   Output path: `/Users/methylene/Library/Application Support/Anki2/<profile>/collection.media/<Word>-sentence.ogg`

### Step 7: Update the card

Call `mcp__anki-mcp__updateNoteFields` with the note ID and formatted fields from Step 5 (use sentence-core field names).

### Step 8: Tag the card

Add the `refreshed` tag:

```
mcp__anki-mcp__tagActions(action: "addTags", notes: [<noteId>], tags: "refreshed")
```

### Step 9: Confirm

```
Updated **<Word>** (<WordMeaning>):
  <sentence_html>
  <translation>
  Picture: <✓ or —>
```
