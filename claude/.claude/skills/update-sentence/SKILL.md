---
name: update-sentence
description: "Replace an Anki card's example sentence with an i+1 sentence. Use when the user says /update-sentence <word>, 'update sentence for <word>', 'replace sentence', 'fix sentence', or wants to change the example sentence on a Japanese vocabulary card. Requires: anki-mcp, jisho-acquisition, jisho-voice MCP servers."
user_invocable: true
argument: word to update (e.g., "一応")
---

# Update Sentence Skill

Replace an Anki vocabulary card's example sentence with a comprehensible i+1 sentence, synthesize audio, and update the card.

## Prerequisite

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

Display the current card fields clearly:

```
Current sentence for **<Word>** (<WordMeaning>):
  Sentence: <Sentence>
  Meaning:  <SentenceMeaning>
  Furigana: <SentenceFurigana>
```

### Step 4: Generate i+1 sentences

Call `mcp__jisho-acquisition__generate_sentences` with:
- `count: 5`
- `topic_count: 1`

This returns a prompt with vocabulary lists. Use that prompt to generate **5 example sentences** where:
- The target word (`<Word>`) is the **+1 learning word** (the only unknown word)
- All other words come from the user's acquired/mature vocabulary
- Sentences are natural, everyday Japanese appropriate for the topic

**Present 3 sentences** to the user using `AskUserQuestion`. Keep 2 in reserve.

Use `AskUserQuestion` with:
- `header`: "Sentence"
- `question`: "Which sentence for **<Word>**?"
- Each sentence as an option:
  - `label`: the Japanese sentence (truncate to fit if needed)
  - `description`: the English translation
- Add a **"More options"** option with description "Show 2 more sentences"
- `multiSelect`: false

If the user picks **"More options"**, present the 2 reserve sentences plus a "Custom" option using another `AskUserQuestion`.

If the user picks **"Custom"** (via the Other free-text input), ask them to provide their own sentence.

### Step 5: Confirm translation

After the user picks a sentence, confirm the English translation using `AskUserQuestion`:

Use `AskUserQuestion` with:
- `header`: "Translation"
- `question`: "Translation: \"<English translation>\" — Does this look right?"
- Options:
  - `label`: "Looks good", `description`: "Use this translation as-is"
  - `label`: "Suggest a change", `description`: "Provide a different translation"
- `multiSelect`: false

### Step 6: Build the fields

Construct the 4 fields to update:

#### Sentence
Wrap the target word in `<b>` tags within the sentence:
```
<b>一応</b>食べられるけど、あまり美味しくない。
```

#### SentenceFurigana
Apply Anki furigana format with `<b>` tags around the target word. Follow these spacing rules:

- A **space must appear before any kanji that has a `[reading]`** so Anki knows where the furigana target starts
- **Exception**: no leading space at the very start of the sentence
- The target word (with its reading) gets wrapped in `<b>...</b>`

Example: `<b>一応[いちおう]</b> 食[た]べられるけど、あまり 美味[おい]しくない。`

Breakdown:
- `一応[いちおう]` — no leading space (start of sentence)
- ` 食[た]べられるけど` — space before 食
- ` 美味[おい]しくない` — space before 美味

Verify the furigana spacing is correct before proceeding.

#### SentenceMeaning
The confirmed English translation.

#### SentenceAudio
Format: `[sound:<Word>.mp3]`

### Step 7: Synthesize audio

Call `mcp__jisho-voice__synthesize` with:
- `text`: the plain sentence (no HTML tags, no furigana brackets)
- `output`: `/Users/methylene/Library/Application Support/Anki2/<profile>/collection.media/<Word>.mp3`
- `instruct`: **ALWAYS provide** a natural language instruction describing how to speak the sentence (see below)
- Do NOT specify `voice` — the default (`ono_anna`) is correct

**Crafting the instruct**: Qwen3-TTS accepts rich, descriptive natural language instructions — not just single words. ALWAYS provide an `instruct` value. Write it in **Japanese** since we're synthesizing Japanese speech. The instruction should describe the speaker's emotion, pace, and context as if directing a voice actor.

**How to write good instructions**:
1. Read the sentence and imagine the real-world context
2. Describe the speaker's emotion, energy level, and speaking style
3. Write it in Japanese as a natural direction (1-2 sentences, max 200 chars)

**Examples by sentence type**:

| Sentence context | instruct example |
|------------------|------------------|
| Everyday factual statement | `"落ち着いた口調で、自然に話してください。"` |
| Happy/excited news | `"嬉しそうに、明るい声で元気よく話してください。"` |
| Sad/disappointed | `"少し寂しそうに、静かな声でゆっくり話してください。"` |
| Angry/frustrated | `"怒りを込めて、強い口調で話してください。"` |
| Gentle explanation | `"優しく丁寧に、友達に教えるように話してください。"` |
| Casual chat with friend | `"リラックスした雰囲気で、友達に話しかけるように。"` |
| Surprised reaction | `"驚いた様子で、少し声を高くして話してください。"` |
| Polite/formal | `"丁寧で礼儀正しい口調で、はっきりと話してください。"` |
| Nostalgic/reflective | `"懐かしそうに、穏やかにゆっくり語ってください。"` |
| Worried/anxious | `"心配そうに、少し不安な声で話してください。"` |

**Key principles**:
- NEVER omit instruct — every sentence gets a direction
- Write in Japanese for best results with Japanese speech
- Be descriptive: "優しく丁寧に、友達に教えるように" beats "warmly"
- Match the instruction to the sentence's emotional content, punctuation, and vocabulary
- For neutral sentences, use `"落ち着いた口調で、自然に話してください。"` — this is better than no instruction because it actively directs natural, calm delivery

**Important**: The output path must be absolute (no `~` tilde). Always use `/Users/methylene/...`.

### Step 8: Update the card

Call `mcp__anki-mcp__updateNoteFields` with the note ID and the 4 fields:
- `Sentence`
- `SentenceMeaning`
- `SentenceFurigana`
- `SentenceAudio`

### Step 9: Confirm

Show the final result:

```
Updated **<Word>** card:
  Sentence:  <new Sentence>
  Meaning:   <new SentenceMeaning>
  Furigana:  <new SentenceFurigana>
  Audio:     <new SentenceAudio>
```

## Important Notes

- The `Word` field value is the dictionary form — use it exactly as-is for the audio filename and `[sound:]` tag
- Do NOT specify `voice` in synthesize — the default is correct
- The sentence should sound natural — not textbook-stilted
- Do NOT modify any fields other than the 4 sentence-related fields
- Furigana spacing is critical: Anki will render incorrectly without proper spaces before kanji with readings
- All file paths must be absolute — never use `~` tilde
