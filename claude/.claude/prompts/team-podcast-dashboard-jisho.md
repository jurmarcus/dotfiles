# Team Design: Podcast Dashboard — jisho-web

> Design a full podcast learning dashboard for jisho-web mirroring YouTube's functionality | Model: Sonnet | Agents: 6

---

Create an agent team with 6 teammates to design a podcast learning dashboard for jisho-web.
Use Sonnet for each teammate — design requires reasoning about data flow, UX patterns,
backend gaps, and feature parity with the existing YouTube dashboard.

The codebase is at ~/CODE/jisho/. Read CLAUDE.md, server/CLAUDE.md, server/jisho-web/CLAUDE.md,
and schema/domains/ first for architecture context.

## Design Philosophy

**Mirror YouTube, don't reinvent.** The YouTube dashboard is the template. Every podcast page
should be the structural equivalent of its YouTube counterpart, adapted for audio content.
Users who know the YouTube section should feel immediately at home in podcasts.

**Data flow first, UI second.** Every feature starts with the data model — what data exists,
what's needed, how it flows from database through GraphQL to the component tree.

Domain-driven design: types are defined once in Rust (`jisho-core/src/podcast/types.rs`),
exposed via GraphQL (`jisho-graphql/src/schema/podcast/`), auto-generated as TypeScript
(`graphql-codegen`), and consumed by React components via Apollo fragments.

Every design proposal must include:
- **Data model**: What types/tables/fields exist vs what's needed
- **Data flow**: How data moves from source -> API -> client -> component
- **YouTube equivalent**: Which YouTube page/component this mirrors
- **Backend gap**: What backend work is needed (new queries, filters, types)
- **Concrete file references**: Which existing files to modify/extend

## Current State

### What exists (podcast)
- `/podcasts` — Grid of podcast cards with basic stats (podcast count, episode count, scored count)
- `/podcasts/[podcastId]` — Episode list for a single podcast
- `/podcasts/[podcastId]/[episodeId]` — Episode player with audio, transcript explorer
- Components: `PodcastCard`, `EpisodeListItem`, `AudioPlayer`, `TranscriptExplorer`, `PodcastPlayerView`
- Backend: `Podcast`, `PodcastEpisode`, `PodcastEpisodeState`, `PodcastStats`, `PodcastEpisodeFilter`
- GraphQL: `searchPodcast`, `fetchPodcast`, `listPodcastEpisode`, `fetchPodcastEpisode`, `podcastStats`
- Scoring: `comprehensionScore`, `reinforcementValue`, `learningValue`, `knownSpanCount`, `totalSpanCount`, `scoredAt` on episodes
- Fragments: `PODCAST_SUMMARY_FRAGMENT`, `PODCAST_DETAIL_FRAGMENT`, `PODCAST_EPISODE_SUMMARY_FRAGMENT`, `PODCAST_EPISODE_DETAIL_FRAGMENT`

### What exists (YouTube — the template)
- `/youtube` — Dashboard with stats grid, quick links (For You, Watchlist), continue watching, best for study, recent videos, channel avatars
- `/youtube/videos` — All videos with score bracket filters (Easy/Optimal/Challenging/Hard), sort (Newest/Best for Study), duration filter
- `/youtube/channels` — Channel list with thumbnails, last fetched
- `/youtube/channels/[channelId]` — Videos filtered by channel
- `/youtube/stats` — Overview stats, score distribution bars, comprehension growth chart (snapshots), processing progress
- `/youtube/recommendations` — i+1 tiers: Perfect Match (70-75%), Slightly Challenging (60-70%), Easy Review (75-85%)
- `/youtube/watchlist` — Bookmarked videos with inline removal
- `/youtube/[videoId]` — Video detail with thumbnail, metadata, ExplorerDashboard (6 stat cards: Score, i+1 Sentences, Unknown Words, Unacquired Vocab, SRS Reinforcement, Learning Value)
- `/youtube/[videoId]/watch` — Immersion player with subtitle sync

### Backend gaps (podcast vs YouTube)
1. **No snapshot system** — YouTube has `YoutubeSnapshot` for growth tracking; podcasts need `PodcastSnapshot`
2. **No sort options** — `listPodcastEpisode` doesn't support `sortBy: LEARNING_VALUE` like YouTube
3. **No score bracket filtering** — `PodcastEpisodeFilter` has basic `duration` and `listened` but no `score`, `hasScore`, `maxDuration`
4. **No watchlist/bookmark filter** — Filter exists for `bookmarked` but no dedicated query path
5. **No episode state mutations** — YouTube has `addToWatchlist`/`removeFromWatchlist`; podcasts need `bookmarkEpisode`/`unbookmarkEpisode`
6. **No `hasScore` filter** — Can't query "episodes with scores" vs "unscored"
7. **Missing `listenedCount` in PodcastStats** — Only has `podcast_count`, `episode_count`, `listened_count`, `scored_count`
8. **No per-podcast episode count** — YouTube channels show video count

---

## Teammate 1: Backend Data Model & Gap Analysis Architect

You are the foundation. Map every backend gap between podcast and YouTube, and design the
exact Rust types, SQL migrations, and GraphQL schema changes needed.

**Research first:**
- Read `server/jisho-core/src/podcast/` — all files (types.rs, db.rs, mod.rs, README.md)
- Read `server/jisho-core/src/youtube/` — all files for comparison
- Read `server/jisho-graphql/src/schema/podcast/` — query.rs, mutation.rs
- Read `server/jisho-graphql/src/schema/youtube/` — query.rs, mutation.rs for filter/sort patterns
- Read `server/jisho-core/src/database/schema.rs` — migration patterns
- Read `server/jisho-core/src/scoring/` — scoring pipeline

**Design deliverables:**
1. **Gap inventory** — Complete list of backend features YouTube has that podcast lacks.
   For each gap: what YouTube has (file + line), what podcast needs, difficulty estimate.

2. **PodcastEpisodeFilter enhancement** — Design new filter fields mirroring `YoutubeVideoFilter`:
   - `hasScore: BoolFilter` — filter scored vs unscored
   - `score: IntFilter` — filter by comprehension score range (gte/lte)
   - `maxDuration: i32` — max duration in seconds
   - `sortBy: PodcastEpisodeSortBy` — enum: `NEWEST`, `LEARNING_VALUE`, `REINFORCEMENT_VALUE`
   - `unwatched: BoolFilter` — episodes with partial listen progress
   Include exact Rust code for the filter type and SQL WHERE clause generation.

3. **PodcastSnapshot type** — Design snapshot system for comprehension growth tracking:
   - Table schema: `podcast_snapshots (id, date, tier_hard, tier_challenging, tier_optimal, tier_easy, episode_count, scored_count, listened_count, avg_comprehension, avg_learning_value, avg_reinforcement)`
   - Rust type with `#[derive(SimpleObject)]`
   - `take_podcast_snapshot()` and `fetch_podcast_snapshots()` DB functions
   - CLI command to take snapshots (integrate into `jisho cron`)

4. **Bookmark mutations** — GraphQL mutations for episode bookmarking:
   - `bookmarkPodcastEpisode(episodeId: Int!): PodcastEpisode`
   - `unbookmarkPodcastEpisode(episodeId: Int!): PodcastEpisode`
   Map to existing `PodcastEpisodeState.bookmarked` field.

5. **Per-podcast stats** — Episode count per podcast for the podcasts list:
   - Either a `ComplexObject` resolver on `Podcast` or a batch loader
   - `episodeCount`, `scoredEpisodeCount`, `avgComprehension`

6. **PodcastStats enhancement** — Add fields to match YouTube:
   - `morphedCount` (episodes with source_id)
   - Verify `listenedCount` exists and works

**Key question to answer:** Can we reuse YouTube's `YoutubeVideoFilter` pattern (Prisma-style
composable filters) for podcast episodes? Or does the existing `PodcastEpisodeFilter` need a
different approach?

Do NOT edit any files — research only.

## Teammate 2: Dashboard & Navigation Page Designer

Design the podcast dashboard (`/podcasts` replacement) and navigation structure mirroring YouTube.

**Research first:**
- Read `server/jisho-web/app/youtube/page.tsx` — the YouTube dashboard (template)
- Read `server/jisho-web/app/podcasts/page.tsx` — current podcast grid page
- Read `server/jisho-web/components/youtube/video-card.tsx` — VideoCard component
- Read `server/jisho-web/components/podcast/PodcastCard.tsx` — existing PodcastCard
- Read `server/jisho-web/components/podcast/EpisodeListItem.tsx` — existing episode list item
- Read `server/jisho-web/lib/routes.ts` — route/breadcrumb definitions
- Read `server/jisho-web/components/layout/AppSidebar.tsx` — sidebar navigation

**Design deliverables:**
1. **Route structure** — Map YouTube routes to podcast equivalents:
   | YouTube | Podcast | Purpose |
   |---------|---------|---------|
   | `/youtube` | `/podcasts` | Dashboard |
   | `/youtube/videos` | `/podcasts/episodes` | All episodes (filtered) |
   | `/youtube/channels` | `/podcasts/list` | All podcasts |
   | `/youtube/stats` | `/podcasts/stats` | Learning stats |
   | `/youtube/recommendations` | `/podcasts/recommendations` | i+1 recs |
   | `/youtube/watchlist` | `/podcasts/bookmarks` | Bookmarked episodes |
   | `/youtube/[videoId]` | `/podcasts/episodes/[episodeId]` | Episode detail |
   | `/youtube/[videoId]/watch` | `/podcasts/[podcastId]/[episodeId]` | Player (exists) |

   For each route: exact file path, server vs client component, query name.

2. **Dashboard page design** (`/podcasts`) — Mirror YouTube dashboard exactly:
   - Stats grid: Podcasts (→ /podcasts/list), Episodes (→ /podcasts/episodes), Scored (→ /podcasts/stats)
   - Quick links: For You card (→ /podcasts/recommendations), Bookmarks card (→ /podcasts/bookmarks)
   - Continue Listening section: episodes with partial listen progress, sorted by recent
   - Best for Study section: episodes 60-80% comprehension, sorted by learning value
   - Recent Episodes section: newest episodes across all podcasts
   - Your Podcasts section: podcast artwork row (like channel avatar row)
   Include the full GraphQL query with all fragment references.

3. **EpisodeCard component** — Design a new card component (like VideoCard) for episode grids:
   - Podcast artwork as thumbnail (or episode artwork if available)
   - Episode title, podcast name, published date, duration
   - Comprehension score badge, reinforcement value, learning value
   - Listen progress bar (if partially listened)
   - Link to episode detail page
   Include the fragment definition.

4. **Sidebar navigation** — Update AppSidebar for new podcast routes:
   - Podcast section with sub-items matching YouTube's structure
   - Icon choices (kanji for each section header)

5. **Breadcrumb updates** — Add all new routes to `lib/routes.ts`

**Key question to answer:** Should `/podcasts` be the dashboard (replacing the current grid)
or should the current grid become `/podcasts/list` and `/podcasts` becomes the new dashboard?

Do NOT edit any files — research only.

## Teammate 3: Episodes List & Filtering Page Designer

Design the "All Episodes" page mirroring YouTube's "All Videos" with score brackets and sorting.

**Research first:**
- Read `server/jisho-web/app/youtube/videos/page.tsx` — the template
- Read `server/jisho-web/app/podcasts/[podcastId]/page.tsx` — current episode list
- Read `server/jisho-web/lib/youtube.ts` — `SCORE_BRACKETS`, `getScoreColor`, `formatDuration`
- Read `server/jisho-web/components/youtube/score-badge.tsx` — ScoreBadge component
- Read `server/jisho-core/src/podcast/types.rs` — `PodcastEpisodeFilter`
- Read `server/jisho-core/src/podcast/db.rs` — `search_podcast_episodes` and filter logic

**Design deliverables:**
1. **All Episodes page** (`/podcasts/episodes`) — Full episode browser:
   - Score bracket filter chips: All, Easy Review (80-100%), i+1 Sweet Spot (60-79%), Challenging (40-59%), Difficult (0-39%)
   - Sort toggle: Newest / Best for Study (learning value)
   - Duration filter: Include 2h+ toggle
   - Podcast filter: optional dropdown/chip to filter by specific podcast
   - Episode grid using new EpisodeCard component
   - URL params: `?score=optimal&sort=study&podcast=5&long=true`
   Include the full query with filter variable construction.

2. **Score utility module** — Create `lib/podcast.ts` mirroring `lib/youtube.ts`:
   - `SCORE_BRACKETS` (same values as YouTube)
   - `formatDuration()` (already exists in youtube.ts — propose shared util)
   - `getScoreColor()` (reuse from youtube.ts)
   - `formatRelativeTime()` (reuse from youtube.ts)

3. **Recommendations page** (`/podcasts/recommendations`) — i+1 episode discovery:
   - Three tiers mirroring YouTube: Perfect Match (70-75%), Slightly Challenging (60-70%), Easy Review (75-85%)
   - Sorted by learning value within each tier
   - i+1 explainer card
   - Uses enhanced `listPodcastEpisode` with score filters
   Include the full query.

4. **Bookmarks page** (`/podcasts/bookmarks`) — Bookmarked episodes:
   - Client component with `useQuery` and `useMutation`
   - Inline removal button (like YouTube watchlist)
   - `bookmarked: { eq: true }` filter on `listPodcastEpisode`
   Include the full query and mutation.

5. **Per-podcast episode list enhancement** — Update `/podcasts/[podcastId]`:
   - Add score bracket filter chips (same as All Episodes)
   - Add sort toggle
   - Show podcast stats (episode count, scored count, avg score)

**Key question to answer:** Should we extract shared scoring utilities (`SCORE_BRACKETS`,
`getScoreColor`, `formatDuration`) into a common module used by both YouTube and podcast pages?

Do NOT edit any files — research only.

## Teammate 4: Stats & Growth Tracking Page Designer

Design the podcast stats page mirroring YouTube's analytics with score distribution and growth charts.

**Research first:**
- Read `server/jisho-web/app/youtube/stats/page.tsx` — the template
- Read `server/jisho-web/components/youtube/YouTubeGrowthChart.tsx` — growth chart component
- Read `server/jisho-web/lib/graphql/fragments/youtube.ts` — `YOUTUBE_SNAPSHOT_FRAGMENT`, `YOUTUBE_STATS_FRAGMENT`
- Read `server/jisho-core/src/youtube/db.rs` — snapshot functions
- Read `server/jisho-core/src/podcast/types.rs` — `PodcastStats`
- Read `server/jisho-core/src/podcast/db.rs` — `get_podcast_stats`

**Design deliverables:**
1. **Stats page** (`/podcasts/stats`) — Learning analytics:
   - **Overview section**: Podcasts count, Episodes count, Scored count (with % processed)
   - **Score Distribution**: Horizontal bars for Hard/Challenging/Optimal/Easy with counts and percentages, clickable links to `/podcasts/episodes?score=<bracket>`
   - **Comprehension Growth chart**: Reuse/adapt `YouTubeGrowthChart` for podcast snapshots
   - **Processing Progress**: Progress bar showing scored/total with CLI command hint
   - **Score Guide**: 4-column explanation of score ranges
   Include the full query and interface types.

2. **PodcastGrowthChart component** — Either:
   - Generalize `YouTubeGrowthChart` to accept any snapshot data shape (rename to `GrowthChart`)
   - Or create a `PodcastGrowthChart` that mirrors the YouTube one
   Propose the better approach with reasoning.

3. **PodcastStats fragment** — GraphQL fragment for stats:
   ```graphql
   fragment PodcastStatsData on PodcastStats {
     podcastCount
     episodeCount
     listenedCount
     scoredCount
     morphedCount
   }
   ```

4. **PodcastSnapshot fragment** — GraphQL fragment for growth data:
   ```graphql
   fragment PodcastSnapshotData on PodcastSnapshot {
     date
     tierHard
     tierChallenging
     tierOptimal
     tierEasy
     episodeCount
     scoredCount
     listenedCount
     avgComprehension
     avgLearningValue
     avgReinforcement
   }
   ```

5. **Snapshot CLI integration** — How to wire snapshot taking into `jisho cron`:
   - `jisho podcast snapshot` — take a snapshot
   - Add to `cmd_cron()` alongside YouTube snapshot
   - Score distribution query approach (4 COUNT queries with WHERE clauses)

**Key question to answer:** Should the growth chart be a shared component between YouTube and
podcast, or separate components? Consider: same data shape? Same rendering? Same interaction?

Do NOT edit any files — research only.

## Teammate 5: Episode Detail & Explorer Dashboard Designer

Design the episode detail page with ExplorerDashboard mirroring YouTube's video detail page.

**Research first:**
- Read `server/jisho-web/app/youtube/[videoId]/page.tsx` — the template (video detail)
- Read `server/jisho-web/components/youtube/explorer/ExplorerDashboard.tsx` — 6-card dashboard
- Read `server/jisho-web/components/youtube/explorer/I1SentencesCard.tsx`
- Read `server/jisho-web/components/youtube/explorer/UnknownWordsCard.tsx`
- Read `server/jisho-web/components/youtube/explorer/UnacquiredVocabCard.tsx`
- Read `server/jisho-web/components/youtube/explorer/SrsReinforcementCard.tsx`
- Read `server/jisho-web/components/youtube/explorer/LearningValueCard.tsx`
- Read `server/jisho-web/components/youtube/explorer/SubtitleExplorer.tsx`
- Read `server/jisho-web/lib/graphql/fragments/subtitle.ts` — SOURCE_SCORING_QUERY
- Read `server/jisho-web/app/podcasts/[podcastId]/[episodeId]/page.tsx` — current episode player
- Read `server/jisho-web/components/podcast/PodcastPlayerView.tsx` — current player view

**Design deliverables:**
1. **Episode detail page** (`/podcasts/episodes/[episodeId]`) — New standalone page:
   - Episode artwork/podcast artwork as hero image
   - Episode title, podcast name (linked), published date, duration
   - Action buttons: Listen (→ player), Bookmark toggle
   - ExplorerDashboard with 6 stat cards (identical to YouTube's)
   - SubtitleExplorer below dashboard (reuse existing)
   Include SSR query (cheap metadata) and client query (expensive scoring).

2. **Podcast ExplorerDashboard** — Adapt or reuse YouTube's ExplorerDashboard:
   - **Score card**: Comprehension score badge + listen progress bar
   - **i+1 Sentences card**: Count of i+1 passages (from `passageStats.i1Count`)
   - **Unknown Words card**: Client-loaded from SOURCE_SCORING_QUERY
   - **Unacquired Vocab card**: Client-loaded
   - **SRS Reinforcement card**: Client-loaded
   - **Learning Value card**: Client-loaded
   Key decision: Can we reuse `ExplorerDashboard` directly by making it accept
   a generic `sourceId` instead of `videoId`? Both YouTube and podcast episodes
   have `source_id` pointing to the same `sources` table.

3. **SOURCE_SCORING_QUERY adaptation** — The existing query uses `fetchYoutubeVideo(videoId)`.
   For podcasts, we need `fetchPodcastEpisode(episodeId)` with the same source fields.
   Design the query and propose whether to:
   - Create a separate `PODCAST_SCORING_QUERY`
   - Or generalize the existing query to work with any source ID

4. **Progressive loading pattern** — Match YouTube's SSR/client split:
   - SSR: Episode metadata + `source.passageStats` (cheap SQL)
   - Client: `source.unknownVocab`, `source.reinforcementEntries`, `source.unknownWords` (expensive)
   Document which fields go in which phase.

5. **Navigation between player and detail** — Design the relationship:
   - Episode detail (`/podcasts/episodes/[episodeId]`) → stats, explorer
   - Episode player (`/podcasts/[podcastId]/[episodeId]`) → audio, transcript
   - "Listen" button on detail → player
   - "Details" link on player → detail
   - Breadcrumbs for both pages

**Key question to answer:** Can `ExplorerDashboard` be fully reused by accepting a
`sourceId: number` prop and a generic scoring query, or does it need podcast-specific
adaptation (e.g., listen progress instead of watch progress)?

Do NOT edit any files — research only.

## Teammate 6: Component Reuse & Shared Infrastructure Architect

Audit existing YouTube components for reusability and design the shared infrastructure
that both YouTube and podcast pages can use.

**Research first:**
- Read `server/jisho-web/components/youtube/` — all components
- Read `server/jisho-web/components/podcast/` — all components
- Read `server/jisho-web/lib/youtube.ts` — YouTube utilities
- Read `server/jisho-web/lib/graphql/fragments/youtube.ts` — YouTube fragments
- Read `server/jisho-web/lib/graphql/fragments/podcast.ts` — podcast fragments
- Read `server/jisho-web/components/layout/` — shared layout components
- Read `server/jisho-web/app/youtube/page.tsx` — dashboard patterns (StatCard, SectionHeader)
- Read `server/jisho-web/app/podcasts/page.tsx` — current podcast page (StatCard already exists)

**Design deliverables:**
1. **Component reuse audit** — For each YouTube component, can it be reused for podcasts?
   | YouTube Component | Reusable? | Adaptation needed |
   |-------------------|-----------|-------------------|
   | `VideoCard` | No — create `EpisodeCard` | Different shape (list vs thumbnail grid) |
   | `VideoGrid` | Yes — rename to `MediaGrid`? | Generic grid layout |
   | `ScoreBadge` | Yes — already domain-agnostic | No changes |
   | `ScoreDot` | Yes — already domain-agnostic | No changes |
   | `ExplorerDashboard` | Likely yes | Generalize `videoId` → `sourceId` |
   | `I1SentencesCard` | Likely yes | Generalize query |
   | `UnknownWordsCard` | Yes — data-driven | No changes |
   | `UnacquiredVocabCard` | Yes — data-driven | No changes |
   | `SrsReinforcementCard` | Yes — data-driven | No changes |
   | `LearningValueCard` | Yes — data-driven | No changes |
   | `SubtitleExplorer` | Yes — already used by podcasts | No changes |
   | `WatchlistButton` | No — create `BookmarkButton` | Different mutation |
   | `YouTubeGrowthChart` | Maybe — generalize? | Different snapshot type |
   | `ChannelListItem` | No — create `PodcastListItem` | Different data shape |
   | `ChannelAvatarRow` | No — create `PodcastAvatarRow` | Artwork instead of avatar |

2. **Shared utilities extraction** — Propose extracting from `lib/youtube.ts`:
   - `lib/media.ts` or `lib/scoring.ts` — shared scoring utilities:
     - `SCORE_BRACKETS` (used by both YouTube videos and podcast episodes)
     - `getScoreColor()` (same score colors for both)
     - `formatDuration()` (same duration formatting)
     - `formatRelativeTime()` (same relative time)
   - Keep `lib/youtube.ts` for YouTube-specific code
   - Create `lib/podcast.ts` for podcast-specific code (if any)

3. **Shared dashboard components** — Extract from YouTube pages:
   - `StatCard` — Currently inlined in both `/youtube/page.tsx` and `/podcasts/page.tsx`. Extract to `components/layout/StatCard.tsx`
   - `SectionHeader` — Currently inlined in `/youtube/page.tsx`. Extract to `components/layout/SectionHeader.tsx`
   - `FilterChip` — Currently inlined in `/youtube/videos/page.tsx`. Extract to `components/ui/FilterChip.tsx`
   - `EmptyState` — Multiple variants inlined. Create generic `components/layout/EmptyState.tsx`

4. **Fragment organization** — Propose new fragments needed:
   - `PODCAST_EPISODE_CARD_FRAGMENT` — for grid display (like `YOUTUBE_VIDEO_CARD_FRAGMENT`)
   - `PODCAST_STATS_FRAGMENT` — for stats pages
   - `PODCAST_SNAPSHOT_FRAGMENT` — for growth charts
   - `PODCAST_EPISODE_WITH_SOURCE_META_FRAGMENT` — for detail page SSR (like `VIDEO_WITH_SOURCE_META_FRAGMENT`)

5. **Implementation priority** — Order the work:
   - Phase A: Backend (filters, sort, snapshot, mutations) — unblocks everything
   - Phase B: Shared infrastructure (extract components, utilities) — enables reuse
   - Phase C: Dashboard + navigation (new routes, sidebar) — most visible
   - Phase D: Feature pages (episodes, stats, recommendations, bookmarks) — can parallelize
   - Phase E: Episode detail with ExplorerDashboard — most complex
   Estimate file count and complexity for each phase.

**Key question to answer:** What's the minimum backend work needed to unblock the
frontend pages? Can we build some pages (dashboard, podcasts list) with existing
backend queries and defer filter/sort enhancements?

Do NOT edit any files — research only.

---

## Coordination

**Phase 1: Foundation** (Teammates 1, 6 run first)
- Teammate 1 maps every backend gap → establishes what needs building
- Teammate 6 audits reusable components → establishes what's already built
- These two define the contract between backend and frontend

**Phase 2: Page Design** (Teammates 2, 3, 4, 5 run in parallel)
- Teammate 2 designs dashboard + navigation → the entry point
- Teammate 3 designs episode list + filters → the browse experience
- Teammate 4 designs stats + growth → the analytics view
- Teammate 5 designs episode detail + explorer → the deep dive
- All four build on the backend gap analysis from Phase 1 and component reuse from Phase 6

**Phase 3: Synthesis**
After all teammates report, synthesize into a design document:

1. **Route map** — Complete route structure with file paths
2. **Backend work list** — Ordered Rust/SQL changes (types, migrations, queries, mutations)
3. **Component inventory** — New vs reused components with fragment dependencies
4. **Shared extractions** — Components and utilities to extract before page work
5. **Page specifications** — For each page: query, interface, component tree, props
6. **Implementation plan** — Ordered task list:
   - Phase A: Schema migration + Rust types + filter/sort enhancements
   - Phase B: GraphQL mutations + snapshot system + CLI commands
   - Phase C: Extract shared components (StatCard, SectionHeader, FilterChip, scoring utils)
   - Phase D: Dashboard page + sidebar navigation + breadcrumbs
   - Phase E: Episodes list + recommendations + bookmarks pages
   - Phase F: Stats page + growth chart
   - Phase G: Episode detail page + ExplorerDashboard adaptation
7. **Risk assessment** — What could go wrong? What's the MVP vs nice-to-have?

Save the design document to `plans/PLAN_podcast_dashboard.md`.

---

## Notes

- **Sonnet for all teammates**: Design requires deep reasoning about data flow, component architecture, and feature parity. Need to trace data from SQLite → Rust → GraphQL → Apollo → React for every feature.
- **6 agents by concern, not by page**: Backend gaps, dashboard, episodes, stats, detail, and shared infrastructure each require specialized analysis. Splitting by page would miss cross-cutting concerns.
- **YouTube as explicit template**: Every teammate must reference the specific YouTube equivalent for their design. This ensures nothing is missed and the user gets exact feature parity.
- **Phase 1 before Phase 2**: Teammates 2-5 need to know what backend queries exist vs what needs building. Without the gap analysis, they'd propose features that can't be implemented.
- **ExplorerDashboard reuse is the key question**: If the 6-card explorer dashboard can be generalized to work with any `sourceId`, it eliminates the most complex piece of work. Teammate 5 must investigate this thoroughly.
- **Shared component extraction**: Both YouTube and podcast pages independently inline `StatCard`, `SectionHeader`, `FilterChip`, and `EmptyState`. Extracting these before building new pages prevents further duplication.
- **Snapshot system is net-new**: YouTube snapshots exist and power the growth chart. Podcasts need an equivalent system — this is the largest backend addition. Design it to be trivially integrated into `jisho cron`.
