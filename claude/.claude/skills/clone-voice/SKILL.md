---
name: clone-voice
description: "Clone a voice from a YouTube video for TTS synthesis. Use when the user says /clone-voice <video_or_channel>, 'clone voice from', 'create voice from youtube', 'add a voice', or wants to clone a speaker's voice from a YouTube video or channel. Requires: jisho-youtube, jisho-voice MCP servers."
user_invocable: true
argument: YouTube video ID, URL, or channel ID (e.g., "dQw4w9WgXcQ", "UCxxxxxx")
---

# Clone Voice Skill

Clone a speaker's voice from a YouTube video segment for use with Japanese TTS synthesis.

## Workflow

### Step 1: Parse input

Determine what the argument is:

- **YouTube URL** (contains `youtube.com` or `youtu.be`): extract the video ID from the URL
- **Channel ID** (starts with `UC`): use as `channel_id` for channel-wide search
- **Video ID** (anything else): use as `video_id` for single-video search

If no argument is provided, ask the user with `AskUserQuestion`:
- `header`: "Source"
- `question`: "Provide a YouTube video ID/URL or channel ID to search for voice segments."
- Options: "Paste a video URL", "Paste a channel ID"

### Step 2: Search for segments

Call `mcp__jisho-youtube__get_subtitle_segments` with:
- `video_id` or `channel_id` (from Step 1)
- `min_duration_ms`: 3000
- `max_duration_ms`: 10000
- `sort_by`: "duration_fitness"
- `limit`: 10

If **no segments found**:
- The video may not be morphed yet. Tell the user:
  ```
  No subtitle segments found. The video may not have morphed subtitles.
  Run: jisho youtube morph <video_id>
  Then try again.
  ```
- Stop.

### Step 3: Present segments to user

Present the **top 5 segments** using `AskUserQuestion`. Keep 5 in reserve.

Use `AskUserQuestion` with:
- `header`: "Segment"
- `question`: "Which segment to clone? Pick one with clear, single-speaker audio."
- Each segment as an option:
  - `label`: the Japanese text (truncate to ~40 chars if needed)
  - `description`: `[video_title] — Xs (start_ms → end_ms)`
- Add a **"More options"** option with description "Show 5 more segments"
- `multiSelect`: false

If the user picks **"More options"**, present the 5 reserve segments with another `AskUserQuestion`.

### Step 4: Ask for voice identity

Use `AskUserQuestion` with:
- `header`: "Voice ID"
- `question`: "What should this voice be called? The ID must be lowercase letters, numbers, hyphens, or underscores."
- Options:
  - `label`: Auto-suggest a reasonable ID from the video/channel context (e.g., the channel name lowercased)
  - `label`: "Custom"
  - `description`: "Enter a custom voice ID and display name"
- `multiSelect`: false

If the user picks "Custom" or provides free text via Other, parse it as the voice ID.

After getting the ID, determine a display name:
- If the user only gave an ID like `narrator`, use a capitalized version as the display name: `Narrator`
- If they gave something like `yuuka` keep it as-is for both

### Step 5: Clone the voice

Call `mcp__jisho-voice__clone_voice_from_youtube` with:
- `id`: the voice ID from Step 4 (lowercase, [a-z0-9_-]+)
- `name`: the display name from Step 4
- `video_url`: the video ID of the chosen segment (from the segment's `video_id` field)
- `start_ms`: from the chosen segment
- `end_ms`: from the chosen segment
- `transcript`: the segment's `text` field (the Japanese text spoken)

If cloning **fails**, show the error and stop.

### Step 6: Test the voice

Synthesize a test sentence to verify the voice works:

Call `mcp__jisho-voice__synthesize` with:
- `text`: "こんにちは、今日はいい天気ですね。"
- `voice`: the voice ID from Step 4
- `output`: "/tmp/<voice_id>_test.mp3"
- `instruct`: "落ち着いた口調で、自然に話してください。"

### Step 7: Report success

Display the result:

```
Voice cloned successfully!

  ID:       <voice_id>
  Name:     <display_name>
  Source:   <video_title> (<video_id>)
  Segment:  <start_ms>ms → <end_ms>ms (<duration>s)
  Text:     <transcript>

  Test audio: /tmp/<voice_id>_test.mp3

Use this voice with:
  synthesize(text: "...", voice: "<voice_id>", output: "/path/to/output.mp3")
```

## Important Notes

- The `id` must match `[a-z0-9_-]+` — no uppercase, spaces, or special characters
- Segments sorted by `duration_fitness` put 5-second segments first — the sweet spot for voice cloning
- Channel-wide search (`UC...` prefix) searches across ALL morphed videos for that channel — great for finding the best sample
- If the voice server is unreachable, tell the user to check that `jisho-voice` is running on the server
- The test synthesis verifies both that the voice was registered and that the TTS pipeline works end-to-end
