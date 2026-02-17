# Team Design: YouTube Immersion Player — jisho-web

> Design a YouTube immersion player view for jisho-web PWA with interactive subtitles | Model: Sonnet | Agents: 6

---

Create an agent team with 6 teammates to design a YouTube immersion player for jisho-web.
Use Sonnet for each teammate — design requires deep reasoning about data flow, UX patterns,
and platform constraints.

The codebase is at ~/CODE/jisho/. Read CLAUDE.md, server/CLAUDE.md, server/jisho-web/CLAUDE.md,
and schema/domains/ first for architecture context. Also read the existing YouTube pages at
`server/jisho-web/app/youtube/` and the GraphQL YouTube resolvers.

## Design Philosophy

**Data flow first, UI second.** Every feature starts with the data model — what data exists,
what's needed, how it flows from database through GraphQL to the component tree. The UI is
built around the data flow, not the other way around. Optimize data to provide impact.

Domain-driven design: types are defined once in Rust (`jisho-core/src/core/types.rs`),
exposed via GraphQL (`jisho-graphql`), auto-generated as TypeScript (`graphql-codegen`),
and consumed by React components via Apollo fragments.

Every design proposal must include:
- **Data model**: What types/tables/fields are needed
- **Data flow**: How data moves from source → API → client → component
- **Interaction model**: What the user does and what data changes result
- **Concrete file references**: Which existing files to modify/extend

---

## Teammate 1: Data Model & Schema Architect

You are the foundation. Everything builds on the data model you design. Map the complete
data pipeline for an embedded YouTube player with interactive subtitles.

**Research first:**
- Read `schema/domains/` for all domain documentation (especially subtitle.md, vocab.md)
- Read `server/jisho-core/src/youtube/` for existing YouTube data model
- Read `server/jisho-core/src/subtitle/` for the JSS pre-morphed subtitle format
- Read `server/jisho-core/src/analysis/types.rs` for `AnalyzedSpan` (the unified span type)
- Read `server/jisho-core/src/scoring/` for comprehension scoring
- Read `server/jisho-core/src/acquisition/` for user vocab state

**Design deliverables:**
1. **Data inventory** — What data already exists for YouTube videos? List every field on
   `YoutubeVideo`, `SubtitleEntry`, `AnalyzedSpan`, and related types. What's missing for
   a player view?
2. **Subtitle data flow** — How do pre-morphed subtitles (JSS files) get from disk → GraphQL →
   client? What's the query shape? Is it paginated or full-load? What are the size constraints
   (a 20-min video might have 300+ subtitle entries)?
3. **Real-time state model** — What state does the player need that doesn't exist in the DB?
   Current playback time, active subtitle, selected word, playback rate, repeat mode.
   Where should this state live (React state, URL params, localStorage)?
4. **Acquisition overlay** — How does user vocab state overlay onto subtitle spans? The
   `AnalyzedSpan.primary` field contains `SpanClassification` with full domain types. How
   does the client know which words the user knows vs doesn't know? Is this data already
   in the subtitle response or does it need a separate query?
5. **New types needed** — Propose any new GraphQL types, fields, or queries needed for
   the player view. Follow the existing pattern: define in Rust, derive SimpleObject.

**Key question to answer:** Can we build this with ZERO new database tables, using only
existing data (YoutubeVideo + JSS subtitles + acquisition state)? Or do we need new
persistent state (e.g., playback position, per-video word lists)?

Do NOT edit any files — research only.

## Teammate 2: GraphQL & Apollo Cache Expert

Design the query strategy and client-side data management for the player view.

**Research first:**
- Read `server/jisho-web/lib/graphql/fragments/` for existing fragment patterns
- Read `server/jisho-web/lib/apollo/` for Apollo Client setup (RSC + client providers)
- Read `server/jisho-graphql/src/` for how YouTube queries are resolved
- Read `server/jisho-web/components/youtube/` for existing YouTube components and their queries
- Read `server/jisho-web/app/youtube/videos/[videoId]/page.tsx` for the current video detail page

**Design deliverables:**
1. **Query architecture** — What queries does the player view need? A single large query
   (video + all subtitles + acquisition state) or multiple lazy-loaded queries? Consider:
   - Initial load: video metadata + first N subtitles
   - Subtitle window: load subtitles around current playback time?
   - Acquisition state: batch load user vocab for all terms in visible subtitles?
   - Or: preload everything since JSS files are pre-morphed and finite?
2. **Fragment design** — Propose new fragments following Relay-style colocation. What does
   `PLAYER_SUBTITLE_FRAGMENT` look like? How does it compose with existing
   `ANALYZED_SPAN_FRAGMENT`?
3. **Cache strategy** — Apollo cache normalization for subtitles. Should subtitle entries
   be normalized by ID? Or kept as a flat list in the video query cache? Consider: user
   navigates away and comes back — is the data still cached?
4. **Real-time word lookup** — When the user taps a word in a subtitle, the detail panel
   needs full vocab/grammar data. Use the existing lazy-loading pattern from the analyzer
   (`TermDetail` component) or design something new?
5. **Subscription/polling** — Does anything need real-time updates? (Probably not — but
   consider: what if the user marks a word as known during playback? Does the subtitle
   overlay need to update?)

**Key question to answer:** What's the optimal data loading strategy — eager (load all
subtitles upfront, ~50-300KB for a typical video) or lazy (load subtitle windows around
playback position)?

Do NOT edit any files — research only.

## Teammate 3: UX & Learning Flow Designer

Design the user experience from a Japanese language learner's perspective. You are an
expert in SRS methodology, immersion-based learning, and mobile-first interaction design.

**Research first:**
- Read `server/jisho-web/app/youtube/` for existing YouTube pages
- Read `server/jisho-web/components/youtube/` for all YouTube components
- Read `server/jisho-web/app/analyze/page.tsx` for the text analyzer (closest existing
  pattern to interactive subtitle display)
- Read `server/jisho-web/components/decks/ReviewSession.tsx` for the review session UX
- Read `server/jisho-web/app/page.tsx` for the home page entry points
- Check how the subtitle explorer currently works in `components/youtube/explorer/`

**Design deliverables:**
1. **User journey map** — The complete flow: How does a learner get to the player?
   From recommendations? From watchlist? From a direct YouTube URL? Map every entry point.
2. **Player view layout** — Mobile-first (390px) layout for the player view:
   - Video player (embedded YouTube) — what aspect ratio? How much screen real estate?
   - Active subtitle display — below the video? Overlaid? Side panel on desktop?
   - Word detail panel — slide-up sheet? Inline expansion? Split view?
   - Playback controls — repeat sentence, slow down, skip, previous/next subtitle
   - Learning controls — mark word known, add to Anki, show/hide furigana
3. **Interaction model** — What happens when the user:
   - Taps a word in the subtitle → shows definition popup/panel
   - Long-presses a word → quick actions (mark known, add card, copy)
   - Taps the active subtitle → pauses and highlights all words
   - Swipes on the subtitle area → navigates between subtitle entries
   - Taps a comprehension badge on a subtitle → explains the score
4. **Learning integration** — How does the player enhance learning beyond passive watching?
   - Color-coded words by acquisition status (known=green, learning=yellow, unknown=red)
   - i+1 sentence highlighting ("this sentence has exactly 1 unknown word")
   - Post-session summary: "You encountered 12 unknown words, 5 learning words"
   - Quick "mine this sentence" for Anki card creation
5. **Navigation & context** — How does the player relate to existing pages?
   - Can you navigate from a highlighted word to the full vocab/grammar detail page?
   - Can you return to the player after looking up a word?
   - Is there a "recent videos" or "continue watching" feature?

**Key question to answer:** Should this be a new page (`/youtube/watch/[videoId]`) or
an enhancement of the existing video detail page (`/youtube/videos/[videoId]`)?

Do NOT edit any files — research only.

## Teammate 4: YouTube Embed & Video Integration Expert

Research YouTube embed API constraints and design the video player integration.

**Research first:**
- Read `server/jisho-web/app/youtube/` for existing YouTube integration
- Read `server/jisho-core/src/youtube/` for YouTube data model and subtitle handling
- Read `server/jisho-core/src/subtitle/` for JSS format and subtitle timing
- Check `packages/jisho-shared/` for any shared subtitle utilities
- Search the web for YouTube IFrame Player API documentation (2025/2026 latest)

**Design deliverables:**
1. **YouTube IFrame API** — What's available for embedded playback control?
   - `getCurrentTime()` — precision and polling frequency
   - `seekTo()` — for subtitle navigation
   - `setPlaybackRate()` — for slow-down learning
   - Event hooks: `onStateChange`, `onPlaybackQualityChange`
   - Mobile constraints: autoplay policies, fullscreen behavior, PiP support
2. **Subtitle synchronization** — How to sync JSS subtitle timestamps with YouTube playback:
   - JSS stores `start_ms` and `end_ms` per subtitle entry
   - YouTube `getCurrentTime()` returns seconds (float)
   - Polling strategy: requestAnimationFrame vs setInterval vs YouTube events
   - Edge cases: seeking, buffering, playback rate changes
3. **Mobile video constraints** — iOS Safari/PWA specific:
   - Inline playback vs fullscreen-only
   - `playsinline` attribute requirements
   - Audio autoplay restrictions
   - Screen rotation handling
   - PiP (Picture-in-Picture) support for subtitle reading while video plays small
4. **Embed alternatives** — Is YouTube IFrame the only option? Consider:
   - YouTube IFrame API (standard, well-supported)
   - `react-youtube` or `react-player` wrapper libraries
   - Custom player with youtube-dl audio (legal concerns)
   - Pros/cons of each approach
5. **Performance** — Video + subtitle overlay rendering performance:
   - DOM updates per subtitle change (every 2-4 seconds)
   - Avoid re-rendering the entire subtitle list on every time update
   - Memory: keeping all subtitles in memory vs virtualized list

**Key question to answer:** What polling frequency do we need for smooth subtitle sync,
and what's the performance cost on mobile? Is `requestAnimationFrame` (~60fps) overkill
vs a 250ms `setInterval`?

Do NOT edit any files — research only.

## Teammate 5: React & Next.js Architecture Expert

Design the component architecture following the codebase's established patterns.

**Research first:**
- Read `server/jisho-web/CLAUDE.md` thoroughly — it documents the compositional architecture,
  fragment colocation, server vs client component patterns
- Read `server/jisho-web/app/analyze/page.tsx` — the closest existing pattern (interactive
  Japanese text display with term selection and detail panel)
- Read `server/jisho-web/components/analyze/` — TokenDisplay, TermDetail components
- Read `server/jisho-web/components/youtube/explorer/` — existing subtitle explorer
- Read `server/jisho-web/components/layout/` — AppShell, ContentLayout, DetailSection
- Read `server/jisho-web/hooks/` — existing custom hooks pattern

**Design deliverables:**
1. **Component tree** — Full component hierarchy for the player view:
   ```
   PlayerPage (server component — fetches video + subtitles)
   └── PlayerView (client component — manages playback state)
       ├── VideoEmbed (YouTube iframe wrapper)
       ├── SubtitleDisplay (active subtitle with interactive spans)
       │   └── JapaneseText / AnalyzedSpan rendering
       ├── SubtitleTimeline (scrollable list of all subtitles)
       │   └── SubtitleEntry (individual subtitle row)
       ├── WordDetailPanel (slide-up sheet or side panel)
       │   └── TermDetail (lazy-loaded full vocab/grammar data)
       └── PlayerControls (playback, learning controls)
   ```
   For each component: server or client? What props? What fragments?
2. **State management** — Where does each piece of state live?
   - Video playback state (time, playing, rate) → React state in PlayerView
   - Active subtitle index → derived from playback time + subtitle timestamps
   - Selected word → React state, lifted to PlayerView
   - User preferences (furigana, playback rate) → localStorage via existing hooks
   - Session stats (words seen, sentences watched) → React state, optional persist
3. **Server vs client boundary** — What's fetched server-side (RSC) vs client-side?
   - Server: video metadata, subtitle data (pre-morphed, static)
   - Client: playback state, word selection, acquisition overlay
   - Pattern: follows analyze page (server fetches data, client handles interaction)
4. **Reuse audit** — Which existing components can be reused directly?
   - `JapaneseText` from `@jisho/shared` — for subtitle rendering
   - `TokenDisplay` from analyze — or does the player need a different interaction model?
   - `TermDetail` — for word detail panel (lazy-loads vocab/grammar)
   - `FuriganaToggle` — existing hook and component
   - `PitchAccentDisplay` — in the word detail panel
5. **New hooks needed** — Propose custom hooks:
   - `useYouTubePlayer` — wraps YouTube IFrame API, exposes time/state/controls
   - `useActiveSubtitle` — binary search for current subtitle given playback time
   - `useSubtitleNavigation` — prev/next/repeat sentence controls
   - Any others?

**Key question to answer:** Should the player page be a new route (`/youtube/watch/[videoId]`)
with its own layout, or should it reuse the existing AppShell? The analyze page uses AppShell
but has a custom floating panel — is that the right pattern here?

Do NOT edit any files — research only.

## Teammate 6: PWA & Mobile Performance Expert

Design the PWA experience and performance optimization for the player view.

**Research first:**
- Read `server/jisho-web/app/manifest.ts` for PWA configuration
- Read `server/jisho-web/public/` for service worker if present
- Check `next.config.ts` for any PWA-related configuration
- Read `server/jisho-web/app/layout.tsx` for viewport and meta configuration
- Read `server/jisho-web/app/globals.css` for mobile-specific styles (safe areas, etc.)
- Search web for latest iOS PWA capabilities (2025/2026) — especially video/media handling

**Design deliverables:**
1. **PWA video experience** — How does embedded YouTube work in PWA mode?
   - Does YouTube IFrame work in standalone PWA on iOS?
   - Fullscreen behavior differences between Safari and PWA
   - Audio session handling (does audio continue when app is backgrounded?)
   - Screen lock prevention during video playback (`navigator.wakeLock`)
2. **Offline capability** — What can work offline?
   - Video: NO (YouTube requires network)
   - Subtitles: YES (pre-morphed JSS data can be cached)
   - Word lookups: PARTIAL (cache recently looked-up vocab)
   - Strategy: cache subtitle data aggressively, show "offline" state for video
3. **Performance budget** — For a typical 20-minute video:
   - Subtitle data size: estimate from JSS format (300 entries × ~500B each = ~150KB)
   - Initial load target: < 2 seconds to interactive
   - Subtitle switch latency: < 50ms (must feel instant)
   - Memory budget: how much RAM for all subtitles + acquisition state?
4. **Mobile-specific optimizations:**
   - Prevent scroll bounce when swiping through subtitles
   - Handle iOS keyboard appearing when tapping search from word detail
   - Safe area handling for the player controls (bottom home indicator)
   - Orientation: lock to portrait? Support landscape with side-by-side layout?
   - Battery impact of polling YouTube player time
5. **App-like feel** — What makes this feel like a native app, not a website?
   - Smooth transitions between subtitle entries
   - Haptic feedback on word tap (if available in PWA)
   - Gesture navigation (swipe between subtitles)
   - Keep-alive: remember last watched position per video
   - "Continue watching" on home page

**Key question to answer:** What are the iOS PWA limitations that could block a good
YouTube player experience? Are there any dealbreakers?

Do NOT edit any files — research only.

---

## Coordination

**Phase 1: Data Foundation** (Teammates 1, 2 run first)
- Teammate 1 maps the data model → establishes what data exists and what's needed
- Teammate 2 designs the query strategy → establishes how data reaches the client
- These two define the contract that all other designs build on

**Phase 2: Design Layer** (Teammates 3, 4, 5, 6 run in parallel)
- Teammate 3 designs UX flows building on the data model from Phase 1
- Teammate 4 researches platform constraints that may change the data strategy
- Teammate 5 designs component architecture consuming the queries from Phase 2
- Teammate 6 identifies PWA constraints that may affect all designs

**Phase 3: Synthesis**
After all teammates report, synthesize into a design document:

1. **Data flow diagram** — Complete path: DB → Rust → GraphQL → Apollo → React → DOM
2. **Component architecture** — Tree with data dependencies annotated
3. **New types/queries** — Everything that needs to be added to the schema
4. **Interaction model** — User flows with data mutations mapped
5. **Constraints & risks** — Platform limitations, performance concerns, scope cuts
6. **Implementation plan** — Ordered task list following data-flow-first principle:
   - Phase A: Schema + GraphQL (data layer)
   - Phase B: Core components (player, subtitle display)
   - Phase C: Learning features (word lookup, acquisition overlay)
   - Phase D: Polish (PWA, performance, gestures)

Save the design document to `plans/PLAN_youtube_player.md`.

---

## Notes

- **Sonnet for all teammates**: Design requires deep reasoning about architecture, data flow, and platform constraints. Haiku would miss subtle issues like cache invalidation strategies or mobile video quirks.
- **6 agents by expertise, not by feature**: The player view is one feature, but it spans data modeling, API design, UX, video integration, React architecture, and PWA — each requires specialized knowledge.
- **Data architect runs first**: Following the user's domain-driven design philosophy. The data model is the foundation; UI proposals that ignore data constraints get rejected.
- **Phase 1 before Phase 2**: Teammates 3-6 need the data model and query strategy to make concrete proposals. Without it, they'd design in a vacuum.
- **Analyze page as reference**: The existing text analyzer is the closest pattern — interactive Japanese text with tap-to-lookup. The player view is essentially "analyzer + video + timeline". Teammates should study it closely.
- **"Can we do this with zero new tables?"**: Forces the data architect to leverage existing infrastructure before proposing new complexity. The JSS subtitle system and acquisition state may already provide everything needed.
