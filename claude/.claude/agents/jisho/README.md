# jisho Project Agents

20 agents specific to the jisho Japanese learning platform — the **why** and **who for**.

These carry domain expertise in Japanese linguistics, language acquisition, and jisho-specific pipelines. They pair with the 28 global agents at `~/.claude/agents/` which carry the **how** (programming philosophy, technology patterns).

## Japanese Linguistics (12 agents)

| Agent | Focus |
|-------|-------|
| `japanese-morphology` | Sudachi, tokenization, conjugation, morpheme model |
| `japanese-grammar` | Bunpro/DOJG, pattern matching, formality registers |
| `japanese-kanji` | Radicals, components, readings, furigana |
| `japanese-pedagogy` | SLA research, i+1, JLPT, comprehensible input |
| `japanese-srs` | FSRS, Anki algorithms, retention modeling |
| `japanese-search` | BM25+Sudachi, analysis pipeline |
| `japanese-content` | Recommendations, scoring, learning paths |
| `japanese-voice` | TTS, pitch accent, voice cloning |
| `japanese-subtitle` | Morph pipeline, SRT/ASS, encoding |
| `japanese-proper-nouns` | NER, name readings, exposure tracking |
| `japanese-keigo` | Honorifics, register detection, formality |
| `japanese-collocations` | Multi-word expressions, set phrases, idioms |

## jisho Pipelines & Domains (8 agents)

| Agent | Focus |
|-------|-------|
| `acquisition-architect` | Anki→matview pipeline, cache refresh, scoring consistency |
| `scoring-engine` | Comprehension formulas, weight calibration, dual paths |
| `dictionary-import` | Yomitan format, structured content, import pipeline |
| `corpus-linguistics` | JPDB, Innocent Corpus, frequency, coverage models |
| `anki-integration` | jisho-specific Anki sync, card model |
| `youtube-pipeline` | YouTube API, yt-dlp, morph, batch |
| `podcast-pipeline` | RSS, transcription, audio content |
| `devops-infra` | hanekawa-nas, Docker, Tailscale, pg_cron |
