# Team Jisho Irasutoya

> Design a semantic image search service for Japanese flashcards: irasutoya vector DB + Google fallback | Model: Sonnet | Agents: 5

---

Create an agent team with 5 teammates to research and design `jisho-irasutoya`, a semantic image
search service for the jisho ecosystem. Use Sonnet for all teammates (they need to understand
embedding models, Rust architecture, and Japanese NLP). No editing — research only.

## Context

### Existing System (~/CODE/morpho)

The morpho project already has a **working irasutoya module** at `src/morpho/lookup/irasutoya/`:

| Component | File | What It Does |
|-----------|------|-------------|
| Client | `client.py` | Blogger JSON Feed API client (not scraping), pagination, rate limiting |
| Database | `database.py` | SQLite cache: `images`, `keywords`, `image_categories`, `metadata` tables |
| Models | `models.py` | `IrasutoyaImage` dataclass (post_id, title, categories, image_url, etc.) |
| Tokenizer | `tokenize.py` | Sudachi-based keyword extraction from Japanese titles |
| Fetcher | `fetch.py` | CLI for incremental/full DB population (~500 pages, ~10,000+ images) |
| API | `__init__.py` | `get_images_for_morpheme()` — searches by lemma, inflection, AND reading |

**Key patterns**: Uses public Blogger API (`/feeds/posts/default`), extracts keywords via Sudachi
morphemization, stores in SQLite with indexed keyword/category tables. Search is keyword-based
(exact + LIKE), no semantic/vector search.

### Target Architecture (jisho ecosystem)

The jisho monorepo uses:
- **Rust** for all server/MCP components
- **SQLite** for all databases (jisho.db ~500MB, acquisition.db ~10MB)
- **Sudachi** for Japanese tokenization (via sudachi-rs or HTTP API)
- **GraphQL** (Axum) for API layer
- **MCP servers** (rmcp) for Claude integration

### User Vision

1. **Vector database** with embeddings of irasutoya image metadata (titles, categories, descriptions)
2. **Semantic search** — find images by meaning, not just keyword match
3. **On-device storage** — the vector DB lives locally, no cloud dependency
4. **irasutoya-first, Google fallback** — prefer irasutoya's clean illustration style
5. **Integration** — usable from MCP servers, GraphQL, and Anki card generation

### Reference: KikuImageFetcher (GitHub gist)

A simpler Python approach: searches Google Images with query + "いらすとや" suffix. Uses
BeautifulSoup to scrape Google results. Has throttling to avoid bans. This is the fallback
strategy — when irasutoya's own DB has no match.

---

## Phase 1: Parallel Research (4 teammates)

All Phase 1 teammates run in parallel. No dependencies between them.

### Teammate 1: Morpho Archaeologist

Deep-dive into the existing morpho irasutoya code to extract everything we need for the Rust port.

**Read these files in ~/CODE/morpho:**
- `src/morpho/lookup/irasutoya/client.py` — API endpoints, pagination, parsing logic
- `src/morpho/lookup/irasutoya/database.py` — schema, indexes, search queries
- `src/morpho/lookup/irasutoya/tokenize.py` — keyword extraction, Sudachi integration
- `src/morpho/lookup/irasutoya/models.py` — data model
- `src/morpho/lookup/irasutoya/__init__.py` — public API, morpheme search strategy
- `src/morpho/lookup/irasutoya/fetch.py` — incremental update logic
- `tests/lookup/test_irasutoya.py` — test patterns, edge cases
- `src/morpho_server/rest/routers/v1/cards.py` — how images integrate with card generation

**Produce:**

1. **Complete API contract** — every Blogger API endpoint, parameters, response format
2. **Database schema** — exact SQL CREATE statements, all indexes
3. **Search algorithm** — step-by-step: how `get_images_for_morpheme()` resolves a word to images
4. **Keyword extraction pipeline** — how titles are tokenized, which POS are kept, suffix stripping
5. **Incremental update strategy** — how `fetch.py` handles delta updates
6. **Pain points** — what works poorly? What's the recall like? Known failure modes?
7. **Image count estimate** — how many images are in the current DB? How many have useful keywords?

Report everything needed for a faithful Rust port, plus improvements.

### Teammate 2: Embedding & Vector Search Researcher

Research the best approach for semantic search over Japanese image metadata.

**Research questions:**

1. **Embedding models for Japanese text**:
   - Compare: `multilingual-e5-small`, `intfloat/multilingual-e5-base`, `sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2`, `cl-tohoku/bert-base-japanese-v3`
   - What dimension, what model size, what inference speed?
   - Can we run inference locally (ONNX runtime) or need a server?
   - Which handles short Japanese phrases best? (irasutoya titles are 5-15 chars)

2. **Vector database options for on-device SQLite integration**:
   - `sqlite-vec` (SQLite extension for vector search) — how mature? Rust bindings?
   - `hnswlib` — standalone HNSW index, Rust crate available?
   - `usearch` — compact, Rust-native, HNSW
   - `faiss` — overkill? Hard to compile for macOS?
   - Can we store vectors IN the same SQLite DB as image metadata?

3. **Hybrid search strategy**:
   - How to combine keyword search (high precision) with vector search (high recall)?
   - Reciprocal Rank Fusion (RRF) vs linear combination of scores?
   - When to fall through to Google Images?

4. **Storage requirements**:
   - 10,000 images × embedding dimension × 4 bytes = how much?
   - Pre-compute all embeddings at fetch time vs on-demand?
   - Index build time and update strategy?

5. **Offline embedding generation**:
   - Can we embed all 10,000 titles during the fetch/import step?
   - Use ONNX runtime in Rust (`ort` crate) for local inference?
   - Or pre-compute embeddings in Python and import the vectors?

**Produce:** A recommendation with concrete model, vector DB, and hybrid search strategy.
Include storage estimates and performance expectations.

### Teammate 3: Google Images Fallback Researcher

Research reliable approaches for Google Images as a fallback source.

**Research questions:**

1. **Google Custom Search API**:
   - Free tier limits (100 queries/day)
   - Pricing for paid tier
   - Image search parameters (size, type, safe search)
   - Can we filter to illustration/clipart style?

2. **Alternative APIs**:
   - Bing Image Search API — pricing, quality for Japanese queries
   - SerpAPI — Google Images scraping service, pricing
   - Brave Search API — free tier?
   - DuckDuckGo — any API?

3. **Direct scraping approach** (like the gist):
   - Google Images HTML scraping — reliability, rate limiting, ban risk
   - The "いらすとや" suffix trick — does it consistently find irasutoya images on Google?
   - BeautifulSoup → Rust equivalent (scraper crate)?

4. **Image format considerations**:
   - irasutoya images are PNG, transparent background
   - Google results are mixed format
   - Do we need to convert/resize for Anki cards?
   - WebP conversion for smaller file size?

5. **Caching strategy**:
   - Cache Google results locally to avoid repeated API calls?
   - How long to cache? Per-word or per-query?
   - Store in same SQLite DB?

**Produce:** Recommended fallback strategy with cost analysis, reliability assessment,
and implementation approach.

### Teammate 4: Jisho Integration Architect

Design how jisho-irasutoya fits into the jisho ecosystem.

**Read these files first:**
- `~/CODE/jisho/CLAUDE.md` — overall architecture
- `~/CODE/jisho/server/CLAUDE.md` — server components
- `~/CODE/jisho/mcp/CLAUDE.md` — MCP server patterns
- `~/CODE/jisho/Cargo.toml` — workspace members
- `~/CODE/jisho/justfile` — build commands

**Design questions:**

1. **Where does it live?**
   - New crate `server/jisho-irasutoya/` (standalone service)?
   - Module in `server/jisho-core/` (library)?
   - New MCP server `mcp/jisho-irasutoya-mcp/`?
   - Or split: core logic in jisho-core, exposed via GraphQL + MCP?

2. **Database location**:
   - Separate `irasutoya.db` file? Or tables in `jisho.db`?
   - Vector index: same DB (sqlite-vec) or sidecar file?
   - Where: server-only (`~/.local/share/jisho/db/`) or also on clients?

3. **API surface**:
   - GraphQL: `imageSearch(word: String, limit: Int): [ImageResult!]!`
   - MCP resource: `jisho://images/{word}` or tool: `search_images`
   - CLI: `jisho image search <word>`, `jisho image fetch --full`

4. **Data pipeline**:
   - How to populate the DB? CLI command? Cron job? On-demand?
   - Incremental updates — how often? Triggered how?
   - Embedding generation — during fetch or post-import step?

5. **Anki card integration**:
   - Current cards have `Picture` field with `<img src="filename.webp">`
   - Images live in Anki's `collection.media/` folder
   - How does the image get from irasutoya URL → Anki media folder?
   - MCP tool: `update_card_image(noteId, word)` that searches + downloads + updates?

6. **Existing patterns to follow**:
   - How does jisho-core handle other SQLite databases?
   - How do other MCP servers expose search functionality?
   - What's the convention for CLI subcommands?

**Produce:** Architecture decision record with:
- Component diagram showing where jisho-irasutoya fits
- Database schema proposal
- API surface design (GraphQL + MCP + CLI)
- Data flow: fetch → store → embed → search → serve

---

## Phase 2: Synthesis (1 teammate)

### Teammate 5: Design Synthesizer

Wait for ALL Phase 1 teammates to finish, then produce the implementation plan.

**Read all teammate reports and cross-reference:**

1. **From Teammate 1** (Morpho Archaeologist):
   - What to port directly vs what to redesign
   - Known pain points to fix in the Rust version

2. **From Teammate 2** (Embedding Researcher):
   - Chosen embedding model + vector DB
   - Hybrid search algorithm

3. **From Teammate 3** (Google Fallback):
   - Chosen fallback strategy + cost model

4. **From Teammate 4** (Integration Architect):
   - Where components live, API surface, data flow

**Produce implementation plan** covering:

### Plan Structure

```markdown
# jisho-irasutoya Implementation Plan

## Overview
[1-paragraph summary of what we're building]

## Architecture
[Component diagram, data flow, dependencies]

## Phase 1: Core Database (Port from morpho)
- [ ] Create crate structure
- [ ] Port Blogger API client to Rust (reqwest)
- [ ] Port SQLite schema + queries (rusqlite)
- [ ] Port Sudachi tokenization for keyword extraction
- [ ] CLI: `jisho image fetch` command
- [ ] Verify: fetch all images, keyword search works

## Phase 2: Vector Search
- [ ] Add embedding model (ONNX runtime via `ort` crate)
- [ ] Generate embeddings for all image titles
- [ ] Set up vector index (sqlite-vec or alternative)
- [ ] Implement hybrid search (keyword + vector + RRF)
- [ ] Verify: semantic queries return better results than keyword-only

## Phase 3: Google Fallback
- [ ] Implement chosen fallback strategy
- [ ] Add fallback logic: irasutoya → Google → empty
- [ ] Cache Google results
- [ ] Verify: fallback triggers correctly, results are usable

## Phase 4: Integration
- [ ] Expose via GraphQL (imageSearch query)
- [ ] Expose via MCP (search_images tool or jisho://images/ resource)
- [ ] CLI: `jisho image search <word>`
- [ ] Anki integration: download + update card Picture field

## Crate Dependencies
[Exact crate versions for reqwest, rusqlite, ort, sqlite-vec, etc.]

## Database Schema
[Final SQL CREATE statements]

## API Contracts
[GraphQL schema, MCP tool/resource definitions]

## Open Questions
[Anything unresolved that needs user input]
```

Save the plan to `~/CODE/jisho/docs/plans/jisho-irasutoya.md`.

---

## Coordination

1. Spawn Teammates 1-4 in parallel (all research, no editing)
2. Wait for ALL to complete
3. Spawn Teammate 5 (synthesizer) with all reports
4. Present the architecture summary and key decisions to the user
5. Save full plan to `docs/plans/jisho-irasutoya.md`

---

## Notes

- **Sonnet for all teammates**: Japanese NLP, embedding model selection, and Rust architecture require deep reasoning — Haiku would produce shallow analysis
- **No editing in Phase 1**: This is a design sprint. Implementation comes after the user approves the plan.
- **morpho is the foundation**: Don't reinvent — port. The Blogger API client, keyword extraction, and search strategy are battle-tested.
- **sqlite-vec is the likely winner**: It stores vectors in the same SQLite DB as metadata, avoiding a second data store. But Teammate 2 should verify maturity and Rust bindings.
- **Google fallback is insurance**: irasutoya has ~10,000+ images covering most common words. Google fills the long tail.
- **Hybrid search is key**: Pure keyword search misses semantic matches (morpho's known weakness). Pure vector search hallucinates on short queries. Combine both with RRF.
- **On-device storage**: 10,000 images × 384-dim × 4 bytes = ~15MB for vectors. Trivial. The SQLite DB with metadata + keywords is ~50-100MB. All fits on any device.
- **Embedding at fetch time**: Pre-compute embeddings during the `jisho image fetch` command, not at query time. This keeps search latency under 10ms.
- **ONNX runtime in Rust**: The `ort` crate wraps ONNX runtime and supports macOS ARM64. Model weights are ~90MB for multilingual-e5-small. One-time download.
