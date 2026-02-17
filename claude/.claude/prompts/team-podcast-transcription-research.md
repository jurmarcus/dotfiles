# Team Research: Podcast Transcription Pipeline

> Research local Japanese podcast transcription for the jisho ecosystem | Model: Sonnet | Agents: 6

---

Create an agent team with 6 teammates to research how to transcribe Japanese podcast episodes
locally on a Mac Studio (M-series, 512GB unified memory) and integrate transcripts into the
existing jisho podcast system.

The codebase is at ~/CODE/jisho/. Read CLAUDE.md, server/CLAUDE.md, schema/domains/podcast.md,
and server/jisho-core/src/podcast/README.md first for architecture context. Also read
schema/domains/passage.md and schema/domains/subtitle.md for how subtitles/passages already work.

All teammates: research only, do NOT edit any files.

---

## Teammate 1: Japanese Speech-to-Text Model Survey

Survey the current landscape of speech-to-text models that work well for Japanese,
with emphasis on models that can run locally on Apple Silicon with 512GB unified memory.

**Research deliverables:**

1. **Model comparison** — Compare these models for Japanese transcription accuracy:
   - OpenAI Whisper (large-v3, turbo) — the baseline
   - Whisper.cpp / whisper-rs — C++/Rust ports optimized for Apple Silicon
   - mlx-whisper / lightning-whisper-mlx — Apple MLX framework ports
   - Kotoba-Whisper (ReazonSpeech-based, fine-tuned for Japanese)
   - ReazonSpeech models (specifically trained on Japanese broadcast audio)
   - Nue-ASR / other Japanese-specific ASR models
   - Any newer models from 2025-2026 worth considering

   For each: accuracy on Japanese (CER/WER if available), speed (real-time factor),
   memory usage, and Apple Silicon support.

2. **Word-level timestamps** — Which models support word-level or segment-level timestamps?
   This is critical for syncing transcripts to audio playback (like subtitles).
   Compare timestamp granularity and accuracy across models.

3. **Punctuation and formatting** — Japanese transcription challenges:
   - Does the model output proper punctuation (。、！？)?
   - Does it handle kanji correctly or default to hiragana?
   - Mixed Japanese/English handling (common in learning podcasts)
   - Speaker diarization (multiple speakers) — any models support this?

4. **Hardware fit** — With 512GB unified memory on Mac Studio:
   - Which models can run entirely in memory?
   - What's the largest model size that fits comfortably?
   - MLX vs GGUF vs PyTorch — which backend is fastest on Apple Silicon?
   - Can we batch-transcribe an entire podcast library overnight?

5. **Recommendation** — Top 2-3 models ranked by: accuracy on conversational Japanese,
   speed on Apple Silicon, ease of integration, timestamp support.

**Search the web** for recent benchmarks (2025-2026) comparing these models on Japanese audio.

Do NOT edit any files — research only.

## Teammate 2: Existing jisho Pipeline Analyst

Analyze how the existing jisho codebase handles subtitles and passages, and map out
exactly how podcast transcripts could plug into the same system.

**Research first:**
- Read `schema/domains/passage.md` — the unified passage system (sources + passages)
- Read `schema/domains/subtitle.md` — the JSS pre-morphed subtitle format
- Read `server/jisho-core/src/subtitle/` — subtitle parsing and morphing pipeline
- Read `server/jisho-core/src/passage/` — passage types, storage, and queries
- Read `server/jisho-core/src/podcast/` — current podcast types and database schema
- Read `server/jisho-core/src/analysis/types.rs` — AnalyzedSpan (unified span type)
- Read `server/jisho-core/src/scoring/` — comprehension scoring
- Read `server/jisho-core/src/youtube/` — how YouTube subtitles flow through the system
- Read `server/jisho-web/app/youtube/` — how the web player renders subtitles

**Design deliverables:**

1. **Data flow map** — How YouTube subtitles currently flow:
   ```
   SRT/ASS file → morph pipeline → JSS → passages table → GraphQL → web player
   ```
   Document each step with code references and types involved.

2. **Podcast parallel** — Map the equivalent flow for podcast transcripts:
   ```
   Audio file → transcription → ??? → passages table → GraphQL → web player
   ```
   What's the transcript intermediate format? Can we reuse JSS, or do we need
   something new? What about the morphing step (Sudachi analysis of transcript text)?

3. **Source integration** — The `sources` table is the unified entry point for passages.
   How do YouTube videos connect to sources? How would podcast episodes connect?
   - Does the `podcast_episodes.source_id` FK already exist? (Check the schema)
   - What source_type should podcast transcripts use?

4. **Reuse audit** — What existing infrastructure can be reused directly?
   - Morphing pipeline (Sudachi tokenization + span resolution)
   - Passage storage and querying
   - Comprehension scoring
   - Web player components (subtitle display, word lookup)
   - Audio player component (already exists for podcasts)

5. **Gap analysis** — What's missing that would need to be built?
   - Transcript import (new format → passage pipeline)
   - Timestamp alignment (transcript timestamps → passage start/end)
   - Audio player + subtitle sync (YouTube player equivalent for podcasts)
   - Any new CLI commands needed (e.g., `jisho podcast transcribe`)

Do NOT edit any files — research only.

## Teammate 3: Transcription Tooling & Integration Patterns

Research practical integration patterns for running transcription as part of the jisho
toolchain. Focus on how to invoke transcription, store results, and handle the pipeline.

**Research first:**
- Read the existing jisho CLI structure: `server/jisho-cli/src/`
- Read how YouTube morphing works: `server/jisho-cli/src/commands/` (youtube commands)
- Read the podcast CLI: `server/jisho-cli/src/commands/podcast.rs`
- Read how the voice server works: `server/jisho-voice/` (it already uses MLX for TTS)
- Check `justfile` at the root for existing task patterns

**Research deliverables:**

1. **CLI integration** — How should transcription be invoked?
   - `jisho podcast transcribe <episode_id>` — single episode
   - `jisho podcast transcribe --all` — batch all untranscribed
   - `jisho podcast transcribe --feed <url>` — all episodes from a feed
   - Should this be a CLI command (Rust, calls whisper-rs/subprocess) or a separate
     server (like jisho-voice, which wraps mlx-audio)?

2. **Whisper integration options** — Compare approaches:
   - **whisper-rs** (Rust bindings to whisper.cpp) — native Rust, no subprocess
   - **mlx-whisper via subprocess** — Python, best Apple Silicon performance
   - **Dedicated server** (like jisho-voice) — HTTP API, can queue jobs
   - **Shell script pipeline** — `whisper-cli` → JSON → jisho import
   - Pros/cons of each for: developer experience, performance, error handling,
     progress reporting, batch processing

3. **Transcript format** — What format should transcription output?
   - Whisper outputs JSON with segments (start, end, text) or SRT/VTT
   - SRT is already parseable by jisho-core's subtitle module
   - Should we store raw transcripts (before morphing) or only morphed passages?
   - Where to store transcript files on disk? (Alongside JSS files?)

4. **Batch processing pipeline** — For transcribing an entire podcast library:
   - Estimated time per episode (e.g., 30-min episode at 10x realtime = 3 min)
   - Queue management (process overnight, resume on failure)
   - Progress tracking (which episodes are transcribed, which aren't)
   - Storage requirements (audio download + transcript + morphed passages)

5. **Audio handling** — Podcast audio considerations:
   - Do we download MP3s locally for transcription? Where to store them?
   - Can we stream audio directly to the transcription model?
   - Should we delete audio after transcription to save disk space?
   - Audio preprocessing (normalize volume, remove silence) — worth it?

Do NOT edit any files — research only.

## Teammate 4: Apple Silicon & MLX Performance Expert

Deep-dive into running transcription models on Apple Silicon with MLX, benchmarking
options and optimizing for the Mac Studio's 512GB unified memory.

**Research deliverables:**

1. **MLX ecosystem for ASR** — What's available in the MLX ecosystem for speech recognition?
   - mlx-whisper: which Whisper variants are ported? Performance numbers?
   - lightning-whisper-mlx: how does it compare to standard mlx-whisper?
   - Any MLX-native Japanese ASR models (not Whisper-based)?
   - MLX vs whisper.cpp on Apple Silicon — benchmark comparisons
   - Search the web for recent MLX ASR benchmarks on M-series chips

2. **Memory and throughput analysis** — With 512GB unified memory:
   - Whisper large-v3 is ~3GB — what's the overhead during inference?
   - Can we run multiple transcription workers in parallel?
   - Memory-mapped model loading vs full load — which is faster for batch?
   - GPU utilization: does MLX fully utilize the Mac Studio's GPU cores?
   - Thermal throttling: sustained transcription over hours — any concerns?

3. **Comparison with jisho-voice** — The TTS server already uses MLX (mlx-audio/Qwen3-TTS):
   - How is the MLX model loaded and served in jisho-voice?
   - Can the same serving pattern work for ASR (load model once, process requests)?
   - Could ASR and TTS share a server process or do they need separate ones?
   - Read `server/jisho-voice/` for the existing MLX serving pattern

4. **Backend comparison on this hardware** — Practical comparison for Mac Studio:
   - MLX (Apple-native, best GPU utilization)
   - whisper.cpp / GGUF (CPU+GPU hybrid, mature ecosystem)
   - PyTorch with MPS backend (compatibility, slower)
   - CoreML (Apple's ML framework, less flexible)
   - Which gives the best real-time factor for Japanese podcast audio?

5. **Batch pipeline design** — Optimizing overnight batch transcription:
   - Estimated throughput: episodes per hour for a typical 20-30 min podcast
   - Parallel processing: can we run N episodes simultaneously?
   - Pipeline: download → preprocess → transcribe → morph → store
   - Failure handling: resume from last successful episode
   - Progress reporting: how to monitor a long-running batch job

**Search the web** for recent Apple Silicon ML benchmarks and MLX ASR performance data.

Do NOT edit any files — research only.

## Teammate 5: Speaker Diarization & Transcript Quality

Research how to produce high-quality, speaker-attributed transcripts for Japanese
conversation podcasts — critical for learning context.

**Research deliverables:**

1. **Speaker diarization models** — How to identify who is speaking:
   - pyannote-audio — the standard for diarization. Does it work with Japanese?
   - WhisperX — combines Whisper + diarization + word-level alignment
   - NeMo (NVIDIA) — speaker diarization toolkit
   - Any Japanese-specific diarization models?
   - Search the web for diarization accuracy on Japanese conversational audio

2. **WhisperX deep-dive** — WhisperX seems like the best all-in-one option:
   - Whisper transcription + forced alignment + diarization in one pipeline
   - Word-level timestamps via wav2vec2 forced alignment
   - Speaker labels per segment
   - Does it work on Apple Silicon / MLX? Or CPU-only?
   - Memory requirements and speed

3. **Transcript post-processing** — Improving raw Whisper output for Japanese:
   - Hallucination detection (Whisper can repeat phrases or generate nonsense)
   - Punctuation correction (adding proper 。、 if model misses them)
   - Kanji vs hiragana correction (when model outputs wrong script)
   - Segment merging/splitting (Whisper segments may not align with sentences)
   - Is there a Japanese-specific post-processing pipeline?

4. **Learning podcast considerations** — "Let's learn Japanese from small talk" format:
   - Host speaks Japanese with occasional English explanations
   - Vocabulary sections with word lists
   - Mixed difficulty levels within episodes
   - How should the transcript handle code-switching (Japanese ↔ English)?
   - Should we separate "teaching segments" from "conversation segments"?

5. **Quality validation** — How to know if transcription quality is good enough:
   - Manual spot-checking workflow (listen + compare transcript)
   - Automated quality metrics (confidence scores from Whisper)
   - Character error rate (CER) estimation without ground truth
   - When to flag an episode for manual review

Do NOT edit any files — research only.

## Teammate 6: Web Player & Learning Experience

Research how to present transcribed podcasts in the jisho web UI for language learning,
building on the existing YouTube player pattern.

**Research first:**
- Read `server/jisho-web/app/youtube/[videoId]/watch/` — the YouTube watch page
- Read `server/jisho-web/components/youtube/player/` — YouTube player components
- Read `server/jisho-web/components/youtube/explorer/` — subtitle explorer
- Read `server/jisho-web/components/podcast/` — existing podcast components
- Read `server/jisho-web/components/podcast/AudioPlayer.tsx` — current audio player
- Read `server/jisho-web/app/podcasts/[podcastId]/[episodeId]/page.tsx` — episode page

**Research deliverables:**

1. **Current state** — What does the podcast episode page look like today?
   Document the current UI, components used, and data displayed.
   What's the audio player capable of? (Play, pause, seek, progress tracking)

2. **YouTube player comparison** — How does the YouTube watch page work?
   - Video embed + subtitle timeline + word detail panel
   - How are subtitles synced to playback?
   - How does word lookup work during playback?
   - What components and hooks power the experience?

3. **Podcast player vision** — How would a podcast player with transcripts look?
   - Audio replaces video — more screen space for transcript
   - Active transcript line highlighted during playback
   - Tap-to-lookup on any word in the transcript
   - Comprehension scoring per sentence
   - i+1 sentence highlighting
   - Advantage over YouTube: no video means full-screen transcript focus

4. **Component reuse** — Which YouTube player components can be adapted?
   - Subtitle timeline → Transcript timeline
   - Word detail panel → Same (already works with AnalyzedSpan)
   - Playback controls → Adapt for audio (no video-specific controls)
   - Explorer view → Transcript explorer
   - What needs to be new vs adapted?

5. **Learning-specific features** — Unique opportunities for podcast learning:
   - Sentence repeat (loop a single transcript segment)
   - Speed control (slow down difficult passages)
   - Read-along mode (auto-scroll transcript with audio)
   - Transcript-only mode (read without audio for review)
   - Speaker labels — visually distinguish host from guest
   - Side-by-side with translation (if available in show notes)

Do NOT edit any files — research only.

---

## Coordination

**All 6 teammates run in parallel** — each researches an independent aspect.

After all teammates report, synthesize into a research document covering:

1. **Recommended model** — Which transcription model to use and why
2. **Diarization strategy** — Whether and how to identify speakers
3. **Architecture decision** — CLI command vs server vs hybrid
4. **Data flow** — Complete path: audio → transcript → morph → passages → web player
5. **Performance profile** — Throughput, memory, batch capacity on Mac Studio
6. **Reuse map** — What existing code handles each step
7. **Gap list** — What needs to be built, ordered by dependency
8. **Effort estimate** — Rough sizing (small/medium/large) per gap
9. **Open questions** — Unresolved decisions needing user input

Save the research document to `plans/PLAN_podcast_transcription.md`.

---

## Notes

- **Sonnet for all teammates**: Research requires deep reasoning about architecture tradeoffs, model comparisons, and integration patterns. Web search needed for model benchmarks.
- **512GB unified memory is key**: This unlocks running the largest Whisper models entirely in memory with room to spare. The model survey and hardware experts should emphasize what this enables — including parallel transcription workers.
- **jisho-voice as precedent**: The TTS server already uses MLX for Japanese speech synthesis. The transcription pipeline should follow similar patterns where applicable. Teammate 4 should study it closely.
- **JSS format reuse**: The existing pre-morphed subtitle format (JSS) might work directly for podcast transcripts — teammate 2 should investigate this thoroughly.
- **YouTube player as blueprint**: The YouTube watch page already solves subtitle sync + word lookup. The podcast player is "the same thing but with audio instead of video" — teammate 6 should map the parallels.
- **WhisperX as potential all-in-one**: Teammate 5 focuses on diarization + quality because learning podcasts are conversational — knowing who's speaking adds significant learning value (host explanations vs natural conversation).
- **Two new agents vs original 4**: Teammate 4 (Apple Silicon/MLX) goes deep on hardware optimization — critical given the Mac Studio's unique capabilities. Teammate 5 (diarization/quality) ensures transcripts are actually useful for learning, not just raw text dumps.
