---
name: sentence-core
description: "Shared conventions for sentence generation, formatting, audio synthesis, and illustration search. Referenced by batch-sentences, update-sentence, and review-generate skills. Not directly invocable."
user_invocable: false
---

# Sentence Core

Shared building blocks for all sentence skills. This skill is **not directly invocable** — it's referenced by orchestrator skills.

## Sentence Generation

Call `mcp__jisho-acquisition__generate_sentences` with:
- `topic_count`: number of topics to sample from practice profile
- `count`: number of sentences (optional, default 10)

This returns a prompt with the user's vocabulary lists. Use it to write i+1 sentences where:
- The target word is the **+1 learning word** (the only unknown word)
- All other content words come from the user's acquired/mature vocabulary
- Sentences are natural, everyday Japanese — not textbook-stilted

## Sentence Quality

Good sentences are **memorable**. Follow these guidelines:

### Vivid and concrete
Paint a scene the learner can picture. Bad: "友達がボールを打った" (generic). Good: "写真の大会で優勝した友達のスピーチに心を打たれた" (a specific, vivid moment).

### Personal relevance
Use the user's profile from `jisho.toml` `[meta]` — their location, interests, and daily life. A runner in Tokyo remembers "マラソンの後、膝を打って一週間走れなかった" better than "ボールを打った".

### Emotional hooks
Sentences with surprise, embarrassment, frustration, warmth, or humor stick. "彼女とラーメン屋で食べ放題の勝負をして、お腹が痛くなった" is funny and relatable.

### Match the card's meaning
The sentence must reinforce the **WordMeaning on the card**. If the card teaches 打つ as "to hit, to strike", use it literally — don't use 心を打つ (to be moved) or 手を打つ (to take action), which are effectively different vocabulary. Figurative/idiomatic uses belong on their own cards, not as examples for the base meaning.

### Vivid context, not a different word
Make the *context* interesting, not the word usage exotic. "マラソンの後、転んで膝を強く打ってしまった" uses 打つ literally (hit your knee) but the running/marathon context makes it memorable and personal.

### Natural flow
Sentences should sound like something a real person would say or think — not a textbook exercise. Avoid stiff constructions.

## Field Formatting

Call `mcp__jisho-acquisition__format_sentence` with:
- `sentence`: plain Japanese text with kanji
- `furigana`: text with kanji[reading] format
- `word`: the target/+1 learning word
- `word_meaning`: English meaning of the word (optional)
- `translation`: English translation of the sentence (optional)

Returns formatted fields ready for Anki or sentences.json:
- `sentence_html`: sentence with `<b>` around target word
- `furigana_html`: Anki furigana with proper spacing + `<b>` tags
- `audio_tag`: `[sound:<word>-sentence.ogg]`

If `format_sentence` is unavailable, format manually following the rules below.

### SentenceFurigana Format Rules

Anki's furigana parser requires a **space before each kanji[reading] group** to identify where ruby text starts. The consistent rule:

1. **Space before every `kanji[reading]`** that follows kana — e.g., `していた 鍵[かぎ]が 見[み]つかった`
2. **No space at the start** of the string — e.g., `鞄[かばん]の...`
3. **Bold target word**: put the space **inside** the `<b>` tag — e.g., `の<b> 底[そこ]</b>`

This ensures the `<b>` tag never breaks the furigana delimiter. Build the ` kanji[reading]` groups first, then wrap the target word's group(s) in `<b>...</b>` with the leading space inside.

**Examples:**
```
鞄[かばん]の<b> 底[そこ]</b>にずっと 探[さが]していた 鍵[かぎ]が 見[み]つかった。
祖母[そぼ]が<b> 先祖[せんぞ]</b>の 話[はなし]をよくしてくれた。
雨[あめ]の 中[なか]で 知[し]らない 人[ひと]が 傘[かさ]を<b> 差[さ]し 出[だ]して</b>くれて、 本当[ほんとう]に 助[たす]かった。
```

## Audio Synthesis

Call `mcp__jisho-voice__synthesize` (single) or `mcp__jisho-voice__synthesize_batch` (batch) with:
- `text`: the plain sentence (no HTML tags, no furigana brackets)
- `voice`: `"bitesize"` — always specify this voice
- `instruct`: **omit for most sentences**. Only provide a single English feeling word when the sentence has clear, strong emotional content.

| Emotion | instruct |
|---------|----------|
| Happy/excited | `"cheerfully"` |
| Sad | `"sadly"` |
| Frustrated | `"frustratedly"` |
| Surprised | `"surprised"` |
| Worried | `"worriedly"` |
| Gentle/warm | `"warmly"` |

**Do NOT** write long Japanese voice-acting directions.

### Audio Output Paths

- **For Anki cards**: `/Users/methylene/Library/Application Support/Anki2/<profile>/collection.media/<Word>-sentence.ogg`
- **For sentences.json**: handled by `save_sentence` automatically (writes to `<output_dir>/audio/<Word>.ogg`)

Read `~/.config/jisho/jisho.toml` `[anki].profile` for the Anki profile name.

**Important**: All paths must be absolute — never use `~` tilde.

### Audio Post-Processing

After synthesis, **always** run ffmpeg to boost volume and re-encode with optimal Opus settings:

```bash
ffmpeg -y -i "<output_path>" -filter:a "volume=2.0" -c:a libopus -b:a 48k -application voip "<output_path>-tmp.ogg" && mv "<output_path>-tmp.ogg" "<output_path>"
```

Settings rationale:
- `volume=2.0` — 200% volume boost (TTS output is too quiet by default)
- `-c:a libopus -b:a 48k` — Opus at 48kbps is transparent for mono speech
- `-application voip` — optimized for speech, smaller files

For batch operations, run ffmpeg on each file after `synthesize_batch` completes. Use a single Bash call with a for-loop:

```bash
for f in "<file1>" "<file2>" ...; do
  ffmpeg -y -i "$f" -filter:a "volume=2.0" -c:a libopus -b:a 48k -application voip "${f}-tmp.ogg" && mv "${f}-tmp.ogg" "$f"
done
```

## Illustration Search

Search for an irasutoya illustration that matches the **sentence's scene**, not just the word. Extract 1-2 key visual nouns or the situation from the sentence and use those as the search query.

Examples:
- Word: 打つ, Sentence about 心を打たれた → search `感動` or `スピーチ 感動`
- Word: 勝負, Sentence about ラーメン食べ放題 → search `大食い ラーメン`
- Word: 暴れる, Sentence about 犬が暴れた → search `犬 暴れる`
- Word: 空, Sentence about 空が暗くなって雨 → search `雨雲 空`

```
mcp__jisho-irasutoya__search_images(query: <scene_keywords>, limit: 1)
```

If a result is found, store the image in Anki's media folder:

```
mcp__anki-mcp__mediaActions(action: "storeMediaFile", url: <image_url>, filename: "<Word>.webp")
```

Then set the Picture field: `<img src="<Word>.webp">`

If no image is found, leave the Picture field unchanged.

## Anki Field Names

When updating Anki cards, use these exact field names:
- `Sentence` — HTML with `<b>` target word
- `SentenceFurigana` — Anki furigana format with `<b>` and spacing
- `SentenceMeaning` — English translation
- `SentenceAudio` — `[sound:<word>-sentence.ogg]`
- `Picture` — `<img src="<Word>.webp">` (only if illustration found)

## Important Rules

- The `Word` field value is the dictionary form — use it exactly as-is for filenames
- Do NOT modify any fields other than the 5 sentence/picture fields
- Always add the `refreshed` tag to processed notes
