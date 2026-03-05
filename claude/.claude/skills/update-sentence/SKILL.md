---
name: update-sentence
description: "Replace an Anki card's example sentence with an i+1 sentence. Use when the user says /update-sentence <word>, 'update sentence for <word>', 'replace sentence', 'fix sentence', or wants to change the example sentence on a Japanese vocabulary card. Requires: anki-mcp, jisho-acquisition, jisho-voice MCP servers."
user_invocable: true
argument: word to update (e.g., "一応")
---

# Update Sentence Skill

Replace an Anki vocabulary card's example sentence with a comprehensible i+1 sentence, synthesize audio, and update the card.

Follow **sentence-core** conventions for formatting, audio synthesis, voice selection, and illustration search.

## Prerequisites

Read `~/.config/jisho/jisho.toml` to get:
- `[anki].profile` — Anki profile name (for the audio file path)

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

### Step 3: Show current state

```
Current sentence for **<Word>** (<WordMeaning>):
  Sentence: <Sentence>
  Meaning:  <SentenceMeaning>
  Furigana: <SentenceFurigana>
```

### Step 4: Generate i+1 sentences

Call `mcp__jisho-acquisition__generate_sentences` with `count: 5`, `topic_count: 1`.

Generate **5 example sentences** using the returned context.

**Present 3 sentences** to the user using `AskUserQuestion`:
- `header`: "Sentence"
- `question`: "Which sentence for **<Word>**?"
- Each sentence as an option with the Japanese as label, English as description
- Add a **"More options"** option with description "Show 2 more sentences"

If "More options" selected, present 2 reserve sentences plus "Custom" option.

### Step 5: Confirm translation

After sentence selection, confirm translation via `AskUserQuestion`:
- `header`: "Translation"
- Options: "Looks good" or "Suggest a change"

### Step 6: Format fields

Call `mcp__jisho-acquisition__format_sentence` with the chosen sentence, furigana, word, meaning, and confirmed translation. This returns all formatted fields.

### Step 7: Find illustration

Follow sentence-core illustration search conventions.

### Step 8: Synthesize audio

Call `mcp__jisho-voice__synthesize` with the plain sentence. Follow sentence-core audio conventions.

Output path: `/Users/methylene/Library/Application Support/Anki2/<profile>/collection.media/<Word>-sentence.ogg`

### Step 9: Update the card

Call `mcp__anki-mcp__updateNoteFields` with the note ID and formatted fields from Step 6 (use sentence-core field names).

### Step 10: Tag the card

Add the `refreshed` tag:

```
mcp__anki-mcp__tagActions(action: "addTags", notes: [<noteId>], tags: "refreshed")
```

### Step 11: Confirm

```
Updated **<Word>** card:
  Sentence:  <sentence_html>
  Meaning:   <translation>
  Furigana:  <furigana_html>
  Audio:     <audio_tag>
  Picture:   <Picture or "—">
```
