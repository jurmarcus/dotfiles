---
name: yt-summary
description: "Get a summary of a YouTube video via its subtitles. Use when the user says /yt-summary <url>, 'summarize this video', 'what's this video about', or pastes a YouTube URL and asks for context/summary."
user_invocable: true
argument: "YouTube video URL"
---

# YouTube Video Summary

Download subtitles from a YouTube video and summarize the content.

## Step 1: Download Subtitles

```bash
yt-dlp --skip-download --write-subs --write-auto-subs --sub-lang en,ja --sub-format srt --convert-subs srt -o "/tmp/yt-summary/%(id)s" "<URL>"
```

If English subs exist, prefer those for summary. If only Japanese, use those.

Check which subtitle file was downloaded:
```bash
ls /tmp/yt-summary/*.srt
```

## Step 2: Read and Clean

Read the .srt file with the Read tool. Strip SRT formatting (timestamps, sequence numbers) to get plain text. Deduplicate repeated lines (auto-subs often repeat).

## Step 3: Summarize

Provide:
1. **Title**: Video title (from yt-dlp output or subtitle context)
2. **Summary**: 3-5 sentence overview of what the video covers
3. **Key Points**: Bullet list of the main topics/arguments/takeaways
4. **Quotes**: 2-3 notable direct quotes if relevant

## Step 4: Keep Context

After summarizing, the subtitle text is now in context. The user can ask follow-up questions about the video content, reference specific points, or use it as context for other work.

## Cleanup

```bash
rm -rf /tmp/yt-summary/
```

## Notes

- Prefers manual subs over auto-generated (higher quality)
- Falls back to auto-subs if manual aren't available
- For Japanese videos, can summarize in English or analyze the Japanese content
- The full transcript stays in context for follow-up questions
