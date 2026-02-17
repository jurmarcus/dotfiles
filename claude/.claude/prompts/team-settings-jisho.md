# Team Design: Settings System — jisho-web

> Audit every app surface for user preferences, design a unified settings system with client storage, and build the settings page | Model: Sonnet | Agents: 6

---

Create an agent team with 6 teammates to design and plan a settings system for jisho-web.
Use Sonnet for each teammate — settings design requires deep understanding of every app surface,
storage patterns, and UX architecture.

The codebase is at ~/CODE/jisho/. Read CLAUDE.md, server/CLAUDE.md, server/jisho-web/CLAUDE.md
first for architecture context.

## Design Philosophy

**Settings should be discoverable, not buried.** The app currently has ~8 user preferences scattered
across localStorage with no unified UI to view or change them. A learner using the PWA daily should
be able to customize their experience from a single settings page accessible from the admin tab.

**Client-first storage.** This is a PWA — settings live in the browser (localStorage or IndexedDB),
not on the server. No GraphQL mutations for preferences. Settings follow the existing
`useSyncExternalStore` pattern used by `usePlayerPreferences` and `useFurigana`.

**Current scattered preferences (audit these):**
```
jisho:playbackRate        → hooks/use-player-preferences.ts (number, default: 1)
jisho:pauseOnLookup       → hooks/use-player-preferences.ts (boolean, default: true)
jisho:showFurigana        → hooks/use-furigana.ts (boolean, default: true)
jisho:autoScroll          → hooks/use-auto-scroll.ts (boolean, default: true)
jisho:comprehensionFilter → hooks/use-comprehension-filter.ts ('all'|'i1'|'unknown')
jisho:lastDeckId          → 3 files (duplicated constant, number)
analyze-legend-seen       → app/analyze/page.tsx (boolean, one-time flag)
review-session-*          → hooks/use-review-session.ts (session state, not a preference)
```

Every design proposal must include:
- **File paths** — existing files to modify and new files to create
- **Data shape** — TypeScript types for the settings schema
- **Migration** — how existing scattered localStorage keys become part of the unified system
- **Concrete code direction** — not vague "add a setting for X", but the actual hook/component shape

---

## Teammate 1: Player & Media Settings Auditor

You are a media player UX expert and Japanese immersion learning specialist. Audit every
player-related feature and identify what should be user-configurable.

**Research first:**
- Read `server/jisho-web/components/youtube/player/PlayerView.tsx` — the player orchestrator
- Read `server/jisho-web/components/youtube/player/PlayerControls.tsx` — playback controls
- Read `server/jisho-web/components/youtube/player/ActiveSubtitleDisplay.tsx` — subtitle display
- Read `server/jisho-web/components/youtube/player/WordDetailInline.tsx` — word detail panel
- Read `server/jisho-web/components/youtube/player/SubtitleTimeline.tsx` — timeline component
- Read `server/jisho-web/components/youtube/player/VideoEmbed.tsx` — YouTube embed
- Read `server/jisho-web/components/youtube/player/MobileSubtitleSheet.tsx` — mobile sheet
- Read `server/jisho-web/hooks/use-player-preferences.ts` — existing player prefs
- Read `server/jisho-web/hooks/use-auto-scroll.ts` — auto-scroll preference
- Read `server/jisho-web/hooks/use-watch-progress.ts` — watch progress tracking
- Read `server/jisho-web/hooks/use-wake-lock.ts` — screen wake lock
- Read `server/jisho-web/components/youtube/explorer/` — subtitle explorer components

**Deliverables:**

1. **Existing player preferences inventory** — Document every current preference:
   - Where it's stored (localStorage key)
   - Where it's consumed (which components)
   - Current default value and valid range
   - Whether it's exposed in UI or hidden

2. **New player settings to propose** — For each, explain WHY a learner would want it:
   - Default playback rate (currently always starts at stored rate — should there be per-video?)
   - Subtitle font size (currently hardcoded)
   - Show/hide subtitle translation (if available)
   - Auto-advance to next video
   - Default comprehension filter mode
   - Wake lock behavior (always on during playback, or optional?)
   - Auto-repeat current subtitle N times
   - Subtitle display style (overlay vs standalone)
   - Word detail panel behavior (auto-close on next subtitle? keep open?)

3. **Settings that should NOT be settings** — Things that might seem configurable but shouldn't be:
   - Settings with only one good value
   - Things that would confuse learners
   - Things that should be per-session rather than persistent

Do NOT edit any files — research only.

## Teammate 2: Dictionary & Learning Settings Auditor

You are a Japanese language learning methodology expert. Audit dictionary pages, acquisition
tracking, deck review, and learning-specific features for settings opportunities.

**Research first:**
- Read `server/jisho-web/hooks/use-furigana.ts` — furigana toggle
- Read `server/jisho-web/hooks/use-comprehension-filter.ts` — comprehension filter
- Read `server/jisho-web/hooks/use-review-session.ts` — review session state
- Read `server/jisho-web/components/decks/ReviewSession.tsx` — SRS review UI
- Read `server/jisho-web/components/dictionary/QuickActions.tsx` — word quick actions
- Read `server/jisho-web/components/dictionary/PassageCard.tsx` — passage display
- Read `server/jisho-web/app/acquisition/` — acquisition dashboard pages
- Read `server/jisho-web/app/decks/` — deck management pages
- Read `server/jisho-web/app/analyze/page.tsx` — text analyzer
- Read `server/jisho-web/app/vocab/` — vocab detail page
- Read `server/jisho-web/app/grammar/` — grammar detail page
- Read `server/jisho-web/app/kanji/` — kanji pages
- Read `server/jisho-web/app/search/` — unified search

**Deliverables:**

1. **Existing learning preferences inventory** — Same format as Teammate 1:
   - Where stored, where consumed, default, UI exposure

2. **New learning settings to propose** — For each, explain the learning benefit:
   - Default furigana mode (on/off/auto-by-acquisition-tier)
   - Default deck for "Add to Deck" actions (currently `jisho:lastDeckId`, duplicated in 3 files)
   - Number of review cards per session
   - Review session style (front→back, back→front, random)
   - Dictionary display language (English definitions vs Japanese definitions)
   - Show/hide frequency rank on vocab pages
   - Show/hide pitch accent by default
   - Acquisition tier color scheme (current CSS variables are hardcoded)
   - Search result ordering preference
   - Sentence difficulty preference for the analyzer

3. **Cross-cutting learning settings:**
   - JLPT target level (filter content by N5-N1)
   - "Focus mode" — only show unknown/learning words highlighted
   - Daily study goal (cards reviewed, words encountered)
   - Learning notifications (cards due, streak reminders)

Do NOT edit any files — research only.

## Teammate 3: Display, Theme & Accessibility Settings Auditor

You are a UI/UX accessibility expert specializing in PWA design systems and Japanese typography.
Audit visual presentation, theming, and accessibility settings.

**Research first:**
- Read `server/jisho-web/app/globals.css` — theme variables, tier colors, typography
- Read `server/jisho-web/tailwind.config.ts` — Tailwind configuration
- Read `server/jisho-web/app/layout.tsx` — root layout, viewport config
- Read `server/jisho-web/app/manifest.ts` — PWA manifest
- Read `server/jisho-web/components/layout/AppShell.tsx` — app shell
- Read `server/jisho-web/components/layout/BottomTabBar.tsx` — mobile bottom nav
- Read `server/jisho-web/components/layout/MobileShell.tsx` — mobile shell
- Read `server/jisho-web/hooks/use-is-desktop.ts` — responsive detection
- Read `server/jisho-web/hooks/use-mobile.ts` — mobile detection
- Read `packages/jisho-shared/text/` — shared Japanese text rendering

**Deliverables:**

1. **Theme settings:**
   - Dark/light mode toggle (currently warm dark only)
   - Theme variants (Catppuccin Frappe is planned — see plans/ directory)
   - Accent color customization
   - Tier badge colors (currently CSS variables — should they be customizable?)

2. **Typography settings:**
   - Japanese font family preference (system default, Noto Sans JP, custom)
   - Base font size adjustment (accessibility)
   - Furigana font size ratio (currently 0.5em)
   - Line height for Japanese text

3. **Accessibility settings:**
   - Reduced motion preference (currently auto-detected, should it be overridable?)
   - High contrast mode
   - Color vision deficiency accommodations (tier colors)
   - Screen reader optimization toggles

4. **Mobile-specific display settings:**
   - Bottom tab bar labels (show/hide)
   - Status bar style
   - Compact vs comfortable spacing mode

5. **Settings that are NOT display settings** — things that seem visual but belong elsewhere
   (e.g., furigana is a learning setting, not a display setting)

Do NOT edit any files — research only.

## Teammate 4: Storage Architecture Expert

You are a client-side storage architect. Design the unified storage system for all settings,
with migration from the current scattered localStorage approach.

**Research first:**
- Read `server/jisho-web/hooks/use-player-preferences.ts` — the BEST current pattern
  (`useSyncExternalStore` with shared listeners, SSR-safe snapshots)
- Read `server/jisho-web/hooks/use-furigana.ts` — simpler single-value pattern
- Read `server/jisho-web/hooks/use-auto-scroll.ts` — same simple pattern
- Read `server/jisho-web/hooks/use-comprehension-filter.ts` — enum-based pattern
- Read `server/jisho-web/lib/streak.ts` — complex object storage pattern
- Read all files that reference `localStorage` in the web app
- Search web for: "React useSyncExternalStore settings pattern 2025 2026",
  "localStorage vs IndexedDB preferences", "client-side settings migration",
  "zustand vs jotai vs useSyncExternalStore for preferences"

**Deliverables:**

1. **Storage approach recommendation** — Pick ONE and justify:
   - Option A: Keep individual localStorage keys, add a unified `useSettings()` hook that
     composes them (minimal change, preserves existing hooks)
   - Option B: Single `jisho:settings` localStorage key with a JSON blob, one
     `useSettings()` hook with typed selectors (clean, but requires migration)
   - Option C: Zustand/Jotai store with localStorage persistence (adds dependency,
     but battle-tested reactivity)
   - Option D: Something else
   - Consider: SSR safety, cross-tab sync, migration complexity, bundle size, DX

2. **Settings schema** — TypeScript interface for ALL settings:
   ```typescript
   interface JishoSettings {
     player: { ... }
     learning: { ... }
     display: { ... }
     // ...
   }
   ```
   Include defaults for every field. Make it extensible (new settings don't break old stored data).

3. **Migration strategy** — How to move from scattered keys to unified system:
   - Read old keys on first load
   - Write to new format
   - Clean up old keys (or keep for backward compat?)
   - Version field for future migrations

4. **Hook API design** — How components consume settings:
   ```typescript
   // Option: granular selectors
   const playbackRate = useSettings(s => s.player.playbackRate)
   const setPlaybackRate = useSetSetting('player.playbackRate')

   // Option: section hooks
   const { playbackRate, pauseOnLookup } = usePlayerSettings()

   // Option: one big hook with stable references
   const settings = useSettings()
   ```
   Recommend the best API considering re-render performance and DX.

5. **Cross-tab synchronization** — Settings changed in one tab should reflect in others:
   - `storage` event listener pattern
   - BroadcastChannel API
   - Or: don't sync (settings pages are rarely open in multiple tabs)

6. **Export/import** — Should users be able to export settings as JSON?
   - Useful for backup, device transfer, sharing configs
   - Simple JSON download/upload vs more complex sync

Do NOT edit any files — research only.

## Teammate 5: Settings Page UI & Component Architect

You are a React component architect specializing in settings interfaces and admin dashboards.
Design the settings page and its integration into the app navigation.

**Research first:**
- Read `server/jisho-web/app/admin/` — existing admin pages
- Read `server/jisho-web/app/(mobile)/admin/page.tsx` — mobile admin hub
- Read `server/jisho-web/components/layout/` — all layout components
- Read `server/jisho-web/components/ui/` — available shadcn components (switch, slider, select, etc.)
- Read `server/jisho-web/lib/constants/navigation.ts` — navigation config
- Read `server/jisho-web/app/globals.css` — existing CSS variables and theme
- Search web for: "best settings page design mobile 2025 2026", "iOS Settings app UX patterns",
  "shadcn settings page", "React settings form patterns"

**Deliverables:**

1. **Settings page location** — Where does it live?
   - Option A: `/admin/settings` — under admin section
   - Option B: `/settings` — top-level route, accessible from mobile admin hub
   - Option C: Bottom sheet / drawer accessible from any page
   - Recommendation with justification

2. **Settings page layout** — Sectioned form design:
   ```
   Settings
   ├── Player
   │   ├── Default playback rate [slider]
   │   ├── Pause on word lookup [switch]
   │   ├── Auto-scroll subtitles [switch]
   │   └── ...
   ├── Learning
   │   ├── Default furigana [switch]
   │   ├── Default deck [select]
   │   └── ...
   ├── Display
   │   ├── Theme [select]
   │   ├── Japanese font size [slider]
   │   └── ...
   └── About
       ├── Version info
       ├── Export settings [button]
       └── Reset to defaults [button]
   ```
   Mock the component structure (not pixel-perfect, but component hierarchy and props)

3. **Component hierarchy:**
   ```
   SettingsPage
   ├── SettingsSection (title, description)
   │   ├── SettingsItem (label, description, control)
   │   │   ├── SettingsSwitch (boolean settings)
   │   │   ├── SettingsSlider (range settings)
   │   │   ├── SettingsSelect (enum settings)
   │   │   └── SettingsInput (text/number settings)
   │   └── SettingsItem ...
   └── SettingsSection ...
   ```
   For each component: what shadcn primitives does it use?

4. **Navigation integration:**
   - How to access settings from the admin hub on mobile
   - How to access settings from the sidebar on desktop
   - Should there be a settings icon/gear in the header?
   - Breadcrumb: Admin > Settings or just Settings?

5. **Inline settings vs settings page** — Some settings are better edited in-context:
   - Playback rate: keep the inline control in PlayerControls AND show in settings page?
   - Furigana toggle: keep inline AND in settings?
   - Or: settings page is the ONLY place to change persistent preferences, inline controls
     are session-only overrides?
   - Recommendation on the inline vs centralized tension

6. **Mobile responsiveness** — Settings page on 390px viewport:
   - Full-width sections with clear spacing
   - Switches/sliders thumb-friendly (44px touch targets)
   - Sections collapsible? Or all visible with scrolling?
   - Back navigation from settings page

Do NOT edit any files — research only.

## Teammate 6: Integration & Implementation Planning Expert

You are a systems integration architect. Plan how the settings system connects to every
existing hook and component, and create the implementation roadmap.

**Research first:**
- Read ALL hooks in `server/jisho-web/hooks/` — understand every existing preference hook
- Read `server/jisho-web/components/youtube/player/PlayerView.tsx` — how prefs are consumed
- Read `server/jisho-web/components/decks/ReviewSession.tsx` — how review prefs work
- Read `server/jisho-web/app/analyze/page.tsx` — how analyzer prefs work
- Read `server/jisho-web/components/dictionary/QuickActions.tsx` — lastDeckId usage
- Read `server/jisho-web/components/dictionary/PassageCard.tsx` — lastDeckId usage (duplicate)
- Read `server/jisho-web/components/youtube/player/WordDetailInline.tsx` — lastDeckId usage
- Read `server/jisho-web/app/layout.tsx` — provider hierarchy
- Read `server/jisho-web/lib/constants/navigation.ts` — nav config for settings entry point

**Deliverables:**

1. **Dependency map** — For every existing preference, map:
   ```
   jisho:playbackRate
     ├── Written by: use-player-preferences.ts, PlayerControls (via handleSetPlaybackRate)
     ├── Read by: use-player-preferences.ts → PlayerView (prefs.playbackRate)
     └── Migration: keep key, wrap in unified hook
   ```
   Do this for ALL 8+ existing localStorage preferences.

2. **Deduplication opportunities:**
   - `jisho:lastDeckId` is defined in 3 files — extract to one shared hook
   - `analyze-legend-seen` uses a non-namespaced key — migrate to `jisho:` prefix
   - Any other duplicated state?

3. **Backward compatibility plan:**
   - Existing hooks (`useFurigana`, `useAutoScroll`, etc.) should keep working
   - Settings migration should not lose user's current preferences
   - Can we wrap existing hooks with the new settings system without breaking consumers?

4. **Provider hierarchy:**
   - Where does the settings provider sit in the component tree?
   - Does it need to wrap the entire app or just specific subtrees?
   - How does it interact with ApolloProvider, SidebarProvider, etc.?

5. **Implementation phases:**
   - Phase A: Storage layer (settings schema, migration, hook API)
   - Phase B: Settings page (UI, navigation entry point)
   - Phase C: Integration (connect existing hooks to unified system)
   - Phase D: New settings (add proposed settings from teammates 1-3)
   - Phase E: Polish (export/import, cross-tab sync, about section)
   For each phase: estimated tasks, dependencies, files touched

6. **Testing strategy:**
   - How to verify migration doesn't lose preferences
   - How to test settings persistence across page reloads
   - How to test cross-tab sync
   - How to test SSR safety (no hydration mismatch)

Do NOT edit any files — research only.

---

## Coordination

**All 6 teammates run in parallel** — each explores a different dimension. Auditors (1-3) discover
what settings should exist. Architects (4-6) design how the system works.

After all teammates report, synthesize findings into a design document covering:

1. **Settings inventory** — Complete categorized list of all settings (existing + proposed)
2. **Storage architecture** — Chosen approach with schema and migration plan
3. **Component blueprint** — Settings page component tree with file paths
4. **Integration plan** — How each existing hook migrates to the unified system
5. **Implementation plan** — Ordered tasks following the phased approach:
   - Phase A: Storage layer + settings hook
   - Phase B: Settings page in admin
   - Phase C: Migrate existing scattered preferences
   - Phase D: Add new settings identified by auditors
   - Phase E: Polish (export/import, about, reset)
6. **Settings not included** — Explicitly document what was considered and rejected, with reasoning

Save the design document to `docs/plans/YYYY-MM-DD-settings-system-design.md`.

---

## Notes

- **Sonnet for all teammates**: Settings design requires understanding every app surface deeply — player UX, learning methodology, accessibility standards, storage patterns, component architecture. Haiku would miss important cross-cutting concerns.
- **3 auditors + 3 architects**: The audit phase discovers WHAT settings should exist (domain expertise). The architecture phase designs HOW the system works (technical expertise). Both run in parallel since auditors inform the final settings list, while architects design the infrastructure that's independent of the specific settings.
- **Client-first, not server-first**: This is a PWA. Settings live in the browser. No database migrations, no GraphQL mutations for preferences. The `useSyncExternalStore` pattern already works perfectly — we're scaling it up, not replacing it.
- **"Default deck" deduplication is a quick win**: `jisho:lastDeckId` is copy-pasted into 3 files. The settings system should extract this into one hook, validating the architecture works for real cases.
- **Settings page lives in admin**: The mobile admin hub already exists at `app/(mobile)/admin/page.tsx`. Settings is a natural addition there — it's not a frequently-accessed page, so it shouldn't take a bottom tab slot.
- **Inline controls remain**: The furigana toggle in the player, the playback rate slider — these stay. The settings page shows the persistent default; inline controls override for the current session. This is how iOS apps work (Music app has a global EQ setting, but you can adjust volume per-song).
