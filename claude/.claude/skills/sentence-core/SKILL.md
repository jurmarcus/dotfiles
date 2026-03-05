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

**Do NOT manually format furigana or bold tags.** Always use `format_sentence`.

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

## Illustration Search

For each word, search for an irasutoya illustration:

```
mcp__jisho-irasutoya__search_images(query: <Word>, limit: 1)
```

If a result is found, store the image in Anki's media folder:

```
mcp__anki-mcp__mediaActions(action: "storeMediaFile", url: <image_url>, filename: "<Word>.webp")
```

Then set the Picture field: `<img src="<Word>.webp">`

If no image is found, skip — leave the Picture field unchanged.

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
