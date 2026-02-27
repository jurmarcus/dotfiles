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

**Emotion analysis process** — follow these steps for EVERY sentence before writing the instruct:

1. **Identify the situation**: What's happening? (e.g., typhoon cancels trains, fever keeps someone home, a date goes well)
2. **Identify emotional signals** in the sentence:
   - Vocabulary: 大変 (serious), 嬉しい (happy), 残念 (disappointed), 頑張る (determined)
   - Sentence-ending particles: よ (assertive), ね (seeking agreement), な (reflective), ぞ (emphatic)
   - Grammar patterns: ～てしまった (regret), ～たい (desire), ～てよかった (relief), ～なければならない (obligation)
   - Punctuation: ！(excitement/emphasis), ？(questioning), 。(neutral)
   - Negative constructions: ～ない, ～できない (frustration, limitation)
3. **Determine the speaker's role**: Who would naturally say this? (friend chatting, parent scolding, student explaining, worker complaining)
4. **Set pace**: Short urgent sentences → fast. Reflective/nostalgic → slow. Explanatory → moderate.
5. **Write the instruct** in Japanese, combining emotion + pace + speaker context (1-2 sentences, max 200 chars)

**Example analysis**:

| Sentence | Situation | Signals | instruct |
|----------|-----------|---------|----------|
| 台風で電車が止まって、大変な事態になった。 | Typhoon disruption | 大変, negative event, reporting past crisis | `"緊迫感を持って、困った状況を報告するように話してください。"` |
| 今日のデートはうまくいく予感がする。 | Pre-date excitement | うまくいく, 予感, positive anticipation | `"ワクワクした気持ちで、期待を込めて明るく話してください。"` |
| 日本語がまだ上手じゃないのが現状だけど、毎日勉強している。 | Self-reflection + resolve | まだ～ない (limitation), けど (contrast), 毎日 (determination) | `"少し悔しさを感じつつも、前向きな決意を込めてしっかり話してください。"` |
| 写真を撮るのは、旅の思い出を残す一番いい手段だ。 | Sharing a belief | 一番いい, declarative, about a hobby | `"自信を持って、好きなことについて語るように穏やかに話してください。"` |
| 先週は三十八度の熱が出て、仕事を休んだ。 | Reporting illness | 熱, 休んだ, past hardship | `"少しだるそうに、体調が悪かった経験を振り返るように話してください。"` |
| 毎朝走っている友達を見て、本当に感心した。 | Admiring someone | 本当に, 感心, positive observation | `"感心した気持ちを込めて、尊敬するように温かく話してください。"` |
| 彼女の料理は、いつも私のお腹を満たしてくれる。 | Grateful contentment | いつも, くれる (receiving kindness), warmth | `"幸せそうに、感謝の気持ちを込めて柔らかく話してください。"` |

**Key principles**:
- NEVER omit instruct — every sentence gets a direction
- ALWAYS analyze the sentence first — do NOT pick from a static list of templates
- Write in Japanese for best results with Japanese speech
- Be specific to THIS sentence: "緊迫感を持って、困った状況を報告するように" beats generic "心配そうに"
- Combine multiple dimensions: emotion + pace + speaker context + physical state when relevant
- For genuinely neutral sentences (rare), use `"落ち着いた口調で、自然に話してください。"` as fallback

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
