# Team UX Audit — Jisho PWA

> Full mobile-first UX audit of jisho-web, CLI, TUI, and MCP surfaces | Model: Sonnet | Agents: 6

---

Create an agent team with 6 teammates to audit jisho for mobile-first UX quality,
focused on iPhone PWA usage. Use Sonnet for each teammate — UX analysis requires
strong reasoning about interaction patterns and visual hierarchy.

The codebase is at ~/CODE/jisho/. Read CLAUDE.md, server/CLAUDE.md, and
server/jisho-web/CLAUDE.md first for architecture context.

Every finding must include:
- **File path + line number** (e.g., `components/layout/AppSidebar.tsx:42`)
- **Severity**: Critical (breaks usability), Major (degrades experience), Minor (polish)
- **Screenshot description**: What the user would see on a 390px iPhone viewport
- **Recommendation**: Concrete fix with code direction (not vague "improve this")

## Teammate 1: Mobile Layout & Interaction Auditor

Audit every page and component for mobile viewport correctness (iPhone 15, 390×844px).
Check the following across ALL pages in `server/jisho-web/app/`:

- **Touch targets**: Every interactive element must be >= 44×44px. Check buttons, links,
  tabs, badges, list items, kanji cards, radical cards. Flag anything smaller.
- **Safe areas**: Verify `env(safe-area-inset-bottom)` usage on fixed/sticky elements.
  Check the review session controls, floating analyze panel, bottom navigation.
- **Scroll behavior**: No horizontal overflow. No content hidden behind fixed headers.
  Check wide tables (conjugation grids, definition lists), long kanji readings, code blocks.
- **Viewport meta**: Verify `maximum-scale=1` and `viewport-fit=cover` in layout.tsx.
- **PWA manifest**: Check `app/manifest.ts` for correct display mode, icons, theme color,
  start URL, orientation settings.
- **Responsive breakpoints**: Verify every `md:`, `lg:`, `xl:` class has a sensible
  mobile-first default. Check for desktop-only layouts that collapse poorly.
- **Input handling**: Search bar, analyze textarea — do they work well with iOS keyboard?
  Does the viewport shift correctly? Is there `inputMode` set appropriately?
- **Gestures**: Can the user swipe back in Safari/PWA without conflicting with UI gestures?
  Check the sidebar, sheets, dialogs for gesture conflicts.

Focus files: `app/layout.tsx`, `components/layout/*`, `components/ui/*`,
`app/decks/review/`, `app/analyze/`, all `page.tsx` files.

Do NOT edit any files — research only.

## Teammate 2: Visual Design & Typography Auditor

Audit the design system and visual presentation for mobile readability and consistency.

- **Typography scale**: Check every Japanese text class (`.jp-title`, `.jp-heading`,
  `.jp-body`, `.jp-sentence`, `.jp-small`) at 390px width. Are they readable without
  zooming? Is the hierarchy clear? Check `globals.css` and all components using these.
- **Furigana sizing**: Verify ruby text is readable on small screens. Check font-size
  ratios (currently 0.5em). Test with long readings (e.g., 承る=うけたまわる).
- **Color contrast**: Check all foreground/background combinations in the warm dark theme
  against WCAG AA (4.5:1 for text, 3:1 for large text). Pay special attention to:
  muted text on dark backgrounds, badge text, chart colors, tier badge colors.
- **Spacing rhythm**: Check padding/margin consistency. Are cards cramped on mobile?
  Is there enough breathing room between sections? Check `ContentLayout`, `DetailSection`,
  `ListHeader`, `DetailsHeader` padding at mobile widths.
- **Visual hierarchy**: On detail pages (vocab, grammar, kanji), is the most important
  information (the word, its reading, primary meaning) visually dominant? Or does it
  compete with badges, metadata, and secondary info?
- **Icon sizing**: Check Lucide icons at mobile sizes. Are they legible? Properly aligned
  with text? Check sidebar icons in collapsed state.
- **Card density**: Check result cards, video cards, kanji cards, deck cards at mobile
  width. Is there too much or too little information per card?
- **Dark mode consistency**: Every component should use CSS variable colors, not hardcoded
  values. Flag any hardcoded colors that would break theming.

Focus files: `app/globals.css`, `tailwind.config.ts`, `components/ui/*`,
`components/dictionary/*`, `components/layout/*`, all detail page components.

Do NOT edit any files — research only.

## Teammate 3: Japanese Language Learning Flow Auditor

Audit the learning-specific UX flows from a Japanese language learner's perspective.
You are a Japanese linguistics and SRS methodology expert.

- **Dictionary lookup flow**: Search → results → detail page. Is the flow intuitive?
  Can a learner quickly find what they need? Is the result ranking sensible
  (grammar > kanji > vocab priority)? Are readings always shown? Can you get from
  a kanji detail back to the vocab that uses it?
- **SRS review session** (`app/decks/review/`, `components/decks/ReviewSession.tsx`):
  Is the card display clear? Are rating buttons (Again/Hard/Good/Easy) large enough
  for one-handed thumb use? Is the front/back transition smooth? Can you accidentally
  rate a card? Is there undo? Does it show progress (cards remaining, accuracy)?
- **Acquisition dashboard** (`app/acquisition/`): Does the tier system (New/Young/
  Mature/Mastered) make sense to a learner? Are the stats actionable? Can you quickly
  see what to study next? Is the frequency gaps page useful?
- **Text analyzer** (`app/analyze/`): Is the token display intuitive? Does the color
  coding make sense without reading the legend? Is the floating sentence panel useful
  or distracting on mobile? Can you tap tokens to see details easily?
- **Kanji study flow**: Kanji hub → kanji detail → components → related words.
  Is the radical breakdown useful? Can you navigate from a word's kanji to study
  each character? Is the stroke information present and useful?
- **Sentence examples**: Are example sentences useful for learning context?
  Is furigana toggleable? Are translations accessible? Is the sentence length
  appropriate for the display width?
- **Pitch accent display**: Is the pitch accent visualization readable on mobile?
  Does it convey the pattern clearly to a learner?
- **Grammar patterns**: Are Bunpro grammar explanations well-structured? Are the
  examples progressive (simple → complex)? Is JLPT level always visible?

Check: Does the app support a coherent "study session" workflow, or is it just
a reference tool? What workflow gaps exist for daily Japanese study on mobile?

Do NOT edit any files — research only.

## Teammate 4: Search, Navigation & Information Architecture Auditor

Audit the navigation patterns, search UX, and information architecture for mobile.

- **Global search**: How does the search bar behave on mobile? Does it have autocomplete?
  Does it handle Japanese IME input well (composing vs committed text)? Are search
  results grouped sensibly? Is the tab interface (Grammar/Vocab/Kanji/etc.) usable
  on a narrow screen with 6 tabs?
- **Sidebar navigation**: Is the sidebar discoverable on mobile? When collapsed to
  icon-only, are the kanji icons recognizable? Can you navigate to any section in
  ≤ 2 taps from anywhere? Is the current location always clear?
- **Breadcrumbs**: Are they present on all detail pages? Do they provide useful
  context for "where am I"? Do they truncate gracefully on mobile?
- **Back navigation**: Does browser/PWA back button always work correctly?
  Are there dead ends where you can't go back? Check after: search → result → detail,
  kanji → words → vocab detail, deck → card → review.
- **Deep linking**: Can you share a URL to any page? Do URLs contain meaningful
  slugs (e.g., `/vocab/食べる` not `/vocab/12345`)?
- **Empty states**: What happens when there are no results? No acquisition data?
  No YouTube videos? Check every list/grid page for empty state handling.
- **Error states**: What happens when GraphQL fails? When the server is down?
  Check error boundaries, loading failures, network errors.
- **Loading states**: Are skeleton loaders present for all async content?
  Do they match the layout of the loaded content? Check every page that fetches data.
- **Progressive disclosure**: On dense pages (vocab detail, video detail), is
  information layered appropriately? Or is everything dumped at once?
- **Cross-domain navigation**: Can you seamlessly move between vocab → kanji →
  radical → back? Between YouTube video → sentence → vocab detail? Are these
  connections discoverable?

Focus files: `components/search/*`, `components/layout/AppSidebar.tsx`,
`components/layout/ContentLayout.tsx`, all `page.tsx`, all `loading.tsx`,
all `error.tsx`, all `not-found.tsx`.

Do NOT edit any files — research only.

## Teammate 5: YouTube & Media Experience Auditor

Audit the YouTube learning integration and all media-related UX.

- **Video card design** (`components/youtube/VideoCard.tsx`): Is the thumbnail
  readable at mobile width? Is the comprehension score badge prominent enough?
  Can you distinguish 60% (sweet spot) from 40% (too hard) at a glance?
- **Recommendation flow**: Search → recommendations → video detail → watchlist.
  Is the i+1 concept explained? Can a learner understand why a video is recommended?
  Is the 60-80% sweet spot visually highlighted?
- **Subtitle explorer** (`components/youtube/SubtitleExplorer.tsx`): This is the
  most complex mobile view. Check: Can you scroll through subtitles smoothly?
  Are color-coded spans readable? Can you tap a sentence to expand it? Does the
  morphological breakdown fit on screen? Are the filter controls accessible?
- **Video detail page** (`app/youtube/videos/[videoId]/`): Is the stat card grid
  (i+1 sentences, unacquired vocab, unknown words, SRS reinforcement, learning value)
  readable? Do the cards stack properly on mobile? Is the most important metric
  (learning value) prominent?
- **Watchlist management**: Can you add/remove videos easily? Is there feedback
  when you add to watchlist? Can you access the watchlist from the video page?
- **Channel browsing**: Is the channel list useful? Can you filter videos by channel?
  Are channel avatars and names readable on mobile?
- **YouTube stats dashboard**: Are the charts/stats readable on mobile? Do they
  scroll horizontally or wrap properly?
- **Media playback**: Check the Anki media proxy (`app/api/anki-media/`). Does audio
  play smoothly in cards? Is there a visible audio player with accessible controls?
  Check `components/decks/AudioPlayer.tsx`.
- **Deck card display**: Check `components/decks/CardFront.tsx` and `CardBack.tsx`.
  Does HTML card content render well on mobile? Are images constrained? Is audio
  accessible?

Do NOT edit any files — research only.

## Teammate 6: CLI, TUI & MCP Discoverability Auditor

Audit the non-web interfaces for UX quality, consistency, and discoverability.

- **CLI UX** (`server/jisho-cli/`):
  - Is the help text clear and well-organized? Run `jisho --help` mentally.
  - Are subcommands logically grouped? Can a new user find what they need?
  - Are error messages actionable (not just "error occurred")?
  - Is there command discoverability (suggestions for typos, related commands)?
  - Are progress bars used for long operations? Are they informative?
  - Check destructive commands — do they require `--confirm`?
  - Is the `cron` command's flag naming intuitive?

- **TUI UX** (`server/jisho-tui/`):
  - Are keybindings discoverable? Is `?` help comprehensive?
  - Is the vim-style navigation (j/k/h/l) documented on first launch?
  - Does the YouTube browser's 3-level drill-down feel natural?
  - Are the dashboard stat cards readable in standard 80×24 terminals?
  - Is the color scheme accessible (colorblind-safe)?
  - Can you navigate entirely with arrow keys (not just vim keys)?
  - Is the command mode (`:`) discoverable?

- **MCP tool naming & descriptions** (`mcp/`):
  - Are tool names consistent across MCPs? (e.g., `search_vocab` vs `get_recommendations`)
  - Are tool descriptions clear enough for an LLM to choose the right tool?
  - Are parameter names self-documenting? Are defaults sensible?
  - Are resource URIs intuitive? (e.g., `jisho://vocab/食べる` — good)
  - Is there unnecessary overlap between tools? (e.g., `search_vocab` vs `batch_lookup_vocab`)
  - Are error messages from tools helpful for the LLM to retry or explain?
  - Check acquisition MCP: Is the tier naming consistent (New/Young/Mature/Mastered)
    across resources and the web UI?

Do NOT edit any files — research only.

## Coordination

After all 6 teammates report, synthesize findings into a single prioritized document:

1. **Executive summary**: Overall UX health score (1-10) per surface (web, CLI, TUI, MCP)
2. **Critical issues**: Anything that breaks usability on mobile — fix immediately
3. **Major issues**: Significant UX degradation — fix in next sprint
4. **Minor issues**: Polish items — fix when touching nearby code
5. **Pattern recommendations**: Recurring issues that suggest systemic fixes
   (e.g., "all grids need mobile column reduction", "all badges need size increase")
6. **Workflow gaps**: Missing features that would significantly improve the
   mobile learning experience

Save the full report to `plans/PLAN_ux_audit.md` formatted as an actionable plan
with checkboxes per fix. Wait for ALL teammates to finish before synthesizing.

---

## Notes

- **Sonnet for teammates**: UX analysis requires reasoning about spatial layout, user intent, and interaction sequences — Haiku would miss subtle issues like gesture conflicts or visual hierarchy problems
- **6 agents by audit dimension, not by page**: Every page needs layout, design, flow, and performance review. Splitting by page would miss cross-cutting patterns (e.g., "all detail pages have the same breadcrumb problem")
- **"Screenshot description" requirement**: Forces agents to think concretely about what the user sees, not abstractly about code structure
- **Japanese linguistics expert**: A dictionary app for language learners needs domain expertise to evaluate whether the UX actually serves learning, not just information display
- **CLI/TUI/MCP in one agent**: These are smaller surfaces than the web app; one agent can cover all three without being overwhelmed
- **Report as PLAN file**: The output feeds directly into the project's planning workflow (`plans/PLAN_*.md` convention) so fixes can be tracked as tasks
