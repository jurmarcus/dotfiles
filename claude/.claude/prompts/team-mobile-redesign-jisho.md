# Team Design: Mobile-First Navigation Redesign — jisho-web

> Rethink the mobile app experience from the ground up: bottom nav, swipe gestures, full viewport clamping | Model: Sonnet | Agents: 6

---

Create an agent team with 6 teammates to design a complete mobile navigation overhaul for jisho-web.
Use Sonnet for each teammate — mobile UX architecture requires deep reasoning about interaction
patterns, platform constraints, and responsive design strategy.

The codebase is at ~/CODE/jisho/. Read CLAUDE.md, server/jisho-web/CLAUDE.md, and the files listed
in each teammate's section for full context.

## Design Philosophy

**Native app feel on mobile, power-user desktop on desktop.** The mobile experience should feel like
a dedicated iOS/Android app — bottom tab navigation, swipe gestures, full viewport clamping, no
browser chrome waste. The desktop experience stays exactly as-is with the sidebar and header.

This is NOT a responsive tweak — it's a fundamental rethinking of mobile navigation architecture.
The two experiences (mobile vs desktop) should share components and data flow but have completely
different navigation shells.

**Current state (what we're replacing on mobile):**
- `AppShell` wraps everything: sidebar (`AppSidebar`) + header with search + content area
- Sidebar uses shadcn `Sidebar` with collapsible icon mode and `SidebarTrigger` hamburger
- Header is a sticky 64px bar with search and breadcrumbs
- Navigation groups: Dictionary (5 items), Learning (3), Tools (2), Admin (1)
- Defined in `lib/constants/navigation.ts` — 4 groups with kanji icons
- No bottom navigation exists today
- Breadcrumbs exist on some pages (recently added, hidden on mobile in some places)
- No swipe gesture support

**What must change on mobile (< 768px):**
1. **Kill the header entirely** — no top bar, no hamburger, no breadcrumbs
2. **Kill the sidebar entirely** — never rendered on mobile
3. **Add 4-tab bottom navigation** — Dictionary, Learning, Tools, Admin
4. **Each tab opens a hub page** listing its section's tools/features
5. **Swipe right/left for back/forward** — like a native app
6. **Clamp viewport to 100dvh** — no scroll bounce, no address bar shifting
7. **Search becomes a floating action or embedded in hub pages** — not a persistent header element

**What stays the same on desktop (>= 768px):**
- Sidebar navigation with collapsible icons (AppSidebar)
- Sticky header with search bar (AppHeader)
- Breadcrumbs where present
- All current navigation UX

Every design proposal must include:
- **File paths** — which existing files to modify and which new files to create
- **Component hierarchy** — how new components compose with existing ones
- **Responsive boundary** — exactly how the mobile/desktop split works (media query, hook, etc.)
- **Data flow** — how navigation state, route transitions, and gestures are managed

---

## Teammate 1: Mobile Navigation Architecture Expert

You are a mobile app UX architect. Design the bottom tab navigation system and the
mobile/desktop shell split.

**Research first:**
- Read `server/jisho-web/components/layout/AppShell.tsx` — current shell wrapper
- Read `server/jisho-web/components/layout/AppSidebar.tsx` — current sidebar nav
- Read `server/jisho-web/app/layout.tsx` — root layout with providers
- Read `server/jisho-web/lib/constants/navigation.ts` — navigation config (4 groups, 11 items)
- Read `server/jisho-web/components/ui/sidebar.tsx` — shadcn sidebar primitives
- Read `server/jisho-web/components/layout/ContentLayout.tsx` — content wrapper
- Search web for iOS bottom tab bar design guidelines (HIG 2025/2026), Material 3 bottom
  navigation patterns, and modern PWA bottom nav implementations

**Design deliverables:**

1. **Shell architecture** — How to split mobile vs desktop at the layout level:
   - Option A: Single AppShell with responsive conditionals (CSS `hidden md:block`)
   - Option B: Two separate shells selected by a hook/provider at layout.tsx level
   - Option C: CSS-only approach where both shells exist in DOM but only one is visible
   - Recommend the best approach with tradeoffs (SSR implications, hydration, bundle size)
   - How does `SidebarProvider` from shadcn interact with this? Does it need to be
     conditionally rendered or can it be inert on mobile?

2. **Bottom tab bar design** — The 4-tab navigation component:
   - Tab items: Dictionary (辞書), Learning (学習), Tools (道具), Admin (管理)
   - Icon selection: Lucide icons? Kanji characters (matching sidebar)? Both?
   - Active state: how to indicate current tab (color, indicator bar, scale)
   - Badge support: notification dots for items needing attention (e.g., cards due for review)
   - Safe area: `env(safe-area-inset-bottom)` for iPhone home indicator
   - Height: iOS recommends 49pt tab bars, Material recommends 80dp — what's right for PWA?
   - z-index and stacking: tab bar must be above all content but below sheets/modals
   - How the tab bar relates to the existing navigation constants in `lib/constants/navigation.ts`

3. **Hub pages** — Each tab needs a landing page listing its section's features:
   - Dictionary hub: Vocab, Grammar, Proper Nouns, Kanji, Radicals (+ search prominent)
   - Learning hub: Acquisition, Decks, YouTube
   - Tools hub: Sentences, Analyzer (+ any future tools)
   - Admin hub: Dictionaries (+ any future admin tools)
   - Hub page layout: cards? list? grid? How dense?
   - Should hubs be new routes (`/m/dictionary`) or conditional renders on existing pages?
   - Do hubs replace the current home page on mobile, or does `/` redirect to a default tab?

4. **Search relocation** — Where does search live without the header?
   - Option A: Floating search button (FAB) that expands to full-screen search
   - Option B: Search bar embedded at the top of each hub page
   - Option C: Dedicated search tab replacing one of the 4 tabs
   - Option D: Search accessible via pull-down gesture on any page
   - Consider: search is currently the primary action (always visible in header).
     It must remain highly accessible on mobile.

5. **Route mapping** — How do existing routes map to tabs?
   - `/vocab/*`, `/grammar/*`, `/proper-nouns/*`, `/kanji/*`, `/radicals/*` → Dictionary tab
   - `/acquisition/*`, `/decks/*`, `/youtube/*` → Learning tab
   - `/sentences/*`, `/analyze/*` → Tools tab
   - `/admin/*` → Admin tab
   - `/search` → where does it live?
   - `/` (home page) → what happens on mobile?
   - How does the tab bar know which tab is active for nested routes?

Do NOT edit any files — research only.

## Teammate 2: Gesture & Interaction Design Expert

You are a mobile interaction designer specializing in gesture-based navigation for PWAs and
native-feel web apps.

**Research first:**
- Read `server/jisho-web/components/layout/AppShell.tsx` — current nav wrapper
- Read `server/jisho-web/app/youtube/[videoId]/watch/page.tsx` — most interactive mobile page
- Read `server/jisho-web/components/youtube/player/` — player components with gestures
- Read `server/jisho-web/components/decks/ReviewSession.tsx` — review with swipe potential
- Read `server/jisho-web/components/analyze/` — analyzer with token tapping
- Search web for: "swipe navigation PWA React 2025", "native-like gesture navigation web app",
  "iOS Safari swipe back conflict PWA", "framer-motion gesture navigation",
  "react swipeable navigation", Next.js App Router page transitions

**Design deliverables:**

1. **Swipe back/forward navigation** — Replace breadcrumbs with gesture nav:
   - Implementation approach: touch event handlers vs library (react-swipeable, framer-motion,
     use-gesture)?
   - Swipe threshold: how far before committing to navigation? (iOS uses ~50% screen width)
   - Visual feedback during swipe: page peek? Parallax? Opacity fade? iOS-style page stack?
   - Animation: what does the transition look like? Duration? Easing curve?
   - How to handle swipe on pages with horizontal scroll (conjugation tables, subtitle timelines)?
   - Conflict with iOS Safari's native swipe-back gesture in PWA standalone mode
   - History management: does this use `router.back()`/`router.forward()` or custom history?

2. **Page transitions** — Mobile pages should transition like app screens:
   - Forward navigation (tap link): slide in from right
   - Back navigation (swipe right or back button): slide out to right
   - Tab switch: cross-fade or no animation (tabs are peers, not hierarchical)
   - Modal/sheet: slide up from bottom
   - How to implement with Next.js App Router (no built-in page transitions)?
   - Libraries to consider: framer-motion `AnimatePresence`, view-transitions API,
     next-view-transitions, custom CSS transitions
   - Performance: will page transitions cause layout shift or FOUC?

3. **Touch target sizing** — All interactive elements on mobile:
   - Minimum 44x44px touch targets (Apple HIG requirement)
   - Bottom tab bar buttons: at least 48x48px active area
   - List items in hub pages: full-width tap targets
   - Back gesture area: left edge of screen (how wide?)
   - How to ensure touch targets don't conflict (e.g., swipe area vs scrollable content)

4. **Pull-to-refresh** — Should mobile pages support pull-to-refresh?
   - Native feel for data-heavy pages (acquisition stats, YouTube recommendations)
   - Implementation: CSS overscroll-behavior + custom handler vs browser default?
   - Which pages benefit from PTR vs which should disable it?

5. **Haptic feedback** — Can the PWA provide haptic feedback?
   - `navigator.vibrate()` availability on iOS Safari/PWA
   - Where haptics add value: tab switch, card flip in review, word tap
   - Fallback for devices without haptic support

6. **Gesture conflict resolution** — Map out all gesture conflicts:
   - Horizontal swipe: page navigation vs horizontal scroll (tables, timelines)
   - Vertical swipe: scroll vs pull-to-refresh vs sheet dismiss
   - Long press: context menu vs text selection vs custom actions
   - How to prioritize gestures per page/component context

Do NOT edit any files — research only.

## Teammate 3: Viewport & Layout Clamping Expert

You are a CSS architecture expert specializing in mobile viewport behavior, safe areas,
and full-screen PWA layouts.

**Research first:**
- Read `server/jisho-web/app/layout.tsx` — viewport meta and root layout
- Read `server/jisho-web/app/globals.css` — global styles, safe area handling
- Read `server/jisho-web/app/manifest.ts` — PWA manifest (display mode, theme)
- Read `server/jisho-web/components/layout/AppShell.tsx` — current shell structure
- Read `server/jisho-web/components/layout/ContentLayout.tsx` — content wrapper
- Read `server/jisho-web/tailwind.config.ts` — Tailwind configuration
- Search web for: "100dvh mobile viewport clamping 2025", "iOS PWA safe area insets",
  "mobile viewport units dvh svh lvh", "prevent iOS address bar resize",
  "CSS viewport clamping techniques", "overscroll-behavior contain"

**Design deliverables:**

1. **Viewport clamping strategy** — Lock mobile to exact 100dvh:
   - `height: 100dvh` vs `height: 100svh` vs `height: 100lvh` — which is correct?
   - `dvh` (dynamic viewport height) changes as address bar shows/hides — is this what we want?
   - Or do we want `svh` (small viewport height) = always fits, even with address bar?
   - Should we use `overflow: hidden` on body or `overscroll-behavior: contain`?
   - How does this interact with scrollable content areas within the clamped viewport?
   - The layout stack: `[viewport 100dvh] > [content area] > [bottom nav]` — sizing math
   - What about landscape orientation? Same clamping?

2. **Content area sizing** — With header gone and bottom nav added:
   - Content area = `100dvh - bottom_nav_height - safe_area_bottom`
   - How to make content area scroll independently (not the page body)
   - `flex-1` with `overflow-y: auto` vs `calc(100dvh - X)` vs CSS Grid approach
   - Should the content area have its own `overscroll-behavior: contain`?
   - Per-page scroll position preservation (scroll restoration on back navigation)

3. **Safe area insets** — Complete safe area handling:
   - Top: `env(safe-area-inset-top)` — status bar on iPhone (notch/dynamic island)
   - Bottom: `env(safe-area-inset-bottom)` — home indicator bar
   - Left/Right: `env(safe-area-inset-left/right)` — landscape mode
   - Where each inset is applied: bottom nav gets bottom inset, content gets top inset
   - Does removing the header mean content could render behind the status bar?
   - PWA standalone mode vs Safari — different safe area behavior?

4. **Scroll behavior** — No rubber-banding, no overscroll:
   - `overscroll-behavior: none` on the clamped container
   - `-webkit-overflow-scrolling: touch` — still needed in 2025/2026?
   - Scroll snap for certain pages (hub page cards, review cards)?
   - Scroll anchoring for subtitle timelines and long lists
   - How does `position: sticky` behave inside the clamped viewport? (e.g., section headers)

5. **Keyboard handling** — When iOS keyboard appears:
   - Does the viewport resize or does the keyboard overlay?
   - `viewport-fit: cover` + `interactive-widget: resizes-content` vs `overlays-content`
   - How does the bottom nav behave when keyboard is open? Hide it? Keep it?
   - Search input, analyzer textarea, any other inputs — keyboard interaction
   - Visual viewport API (`window.visualViewport`) for keyboard-aware layout

6. **Dark mode & theme** — Viewport-level styling:
   - `theme-color` meta tag for status bar coloring on mobile
   - Dynamic theme-color per page/tab?
   - PWA title bar area customization
   - How does the current warm dark theme (`globals.css`) interact with mobile chrome?

Do NOT edit any files — research only.

## Teammate 4: PWA & iOS Platform Expert

You are an iOS PWA specialist who understands the latest Safari/WebKit capabilities and
limitations for installed web apps.

**Research first:**
- Read `server/jisho-web/app/manifest.ts` — current PWA manifest
- Read `server/jisho-web/components/PWARegistration.tsx` — service worker registration
- Read `server/jisho-web/public/` — check for service worker, icons, splash screens
- Read `server/jisho-web/next.config.ts` — Next.js config, any PWA plugins
- Read `server/jisho-web/app/layout.tsx` — meta tags, viewport config
- Search web for: "iOS 18 PWA capabilities 2025 2026", "Safari standalone mode features",
  "PWA bottom navigation iOS", "iOS PWA navigation gestures",
  "next-pwa vs serwist 2025", "PWA app-like navigation patterns",
  "iOS PWA address bar behavior standalone", "web app manifest display modes"

**Design deliverables:**

1. **PWA manifest optimization** — Configure for maximum app-like feel:
   - `display: "standalone"` vs `"fullscreen"` — which is better for our use case?
   - `orientation`: lock to portrait? Allow landscape?
   - `scope` and `start_url`: should `/` open the default tab hub?
   - `display_override`: modern display modes (`window-controls-overlay`, `tabbed`)?
   - `handle_links`: how should external links behave?
   - iOS-specific: `apple-mobile-web-app-capable`, `apple-mobile-web-app-status-bar-style`
   - Splash screens: do we need them? Apple touch startup images?

2. **iOS Safari/PWA constraints** — What can and can't we do:
   - Navigation gestures: does iOS allow custom swipe-back in standalone PWA or does
     the system gesture always win?
   - Bottom bar: is there a system bottom bar in PWA standalone that conflicts with ours?
   - Status bar: can we control its color/visibility per page?
   - Keyboard: does the virtual keyboard behavior differ in PWA vs Safari?
   - Audio/video: any restrictions on media playback in PWA mode?
   - Storage: IndexedDB/Cache API limits in PWA mode?
   - Push notifications: available on iOS 16.4+, do we want them?
   - Badge API: can we badge the app icon (e.g., cards due for review)?
   - Screen wake lock: does `navigator.wakeLock` work in iOS PWA?

3. **Service worker strategy** — Caching for app-like speed:
   - App shell caching: cache the navigation shell (bottom nav, layout) for instant load
   - Route prefetching: preload hub pages on install?
   - Stale-while-revalidate for dictionary data
   - Cache-first for static assets (fonts, icons)
   - Network-first for dynamic data (acquisition state, YouTube recommendations)
   - What service worker library? `serwist`? `next-pwa`? `workbox`? Custom?

4. **Install experience** — Making the app installable:
   - Install prompt: when and how to suggest "Add to Home Screen"?
   - First-launch experience: what happens when user opens PWA for the first time?
   - Should the first launch show a brief onboarding explaining the tab navigation?
   - Update flow: how does the user get new versions?

5. **Performance benchmarks** — What should we target?
   - First Contentful Paint: < 1s
   - Largest Contentful Paint: < 2s
   - Time to Interactive: < 2s
   - Navigation between tabs: < 100ms (must feel instant)
   - CLS (Cumulative Layout Shift): 0 (no layout shift from shell loading)
   - What's the current Lighthouse PWA score? What should we target?

6. **Cross-platform** — Beyond iOS:
   - Android Chrome: any differences in bottom nav behavior, gestures?
   - Desktop PWA: should the bottom nav appear in desktop PWA window mode?
   - Does the mobile shell make sense for tablets (iPad, Android tablets)?
   - Breakpoint strategy: mobile (< 768px), tablet (768-1024px), desktop (> 1024px)?

Do NOT edit any files — research only.

## Teammate 5: Component Architecture & Next.js Expert

You are a React/Next.js architecture expert. Design the concrete component hierarchy and
file structure for the mobile navigation system.

**Research first:**
- Read `server/jisho-web/components/layout/AppShell.tsx` — current shell
- Read `server/jisho-web/components/layout/AppSidebar.tsx` — sidebar component
- Read `server/jisho-web/components/layout/ContentLayout.tsx` — content wrapper
- Read `server/jisho-web/components/layout/HeaderSlotContext.tsx` — header slot system
- Read `server/jisho-web/components/layout/index.ts` — layout exports
- Read `server/jisho-web/app/layout.tsx` — root layout
- Read `server/jisho-web/app/page.tsx` — home page
- Read `server/jisho-web/lib/constants/navigation.ts` — navigation config
- Read `server/jisho-web/hooks/` — existing custom hooks
- Read `server/jisho-web/components/ui/sidebar.tsx` — shadcn sidebar

**Design deliverables:**

1. **Component tree** — Full hierarchy for the dual-shell system:
   ```
   RootLayout (app/layout.tsx)
   └── ApolloWrapper
       └── ResponsiveShell (new — chooses mobile vs desktop)
           ├── DesktopShell (existing AppShell, unchanged)
           │   ├── AppSidebar
           │   ├── AppHeader (search + breadcrumbs)
           │   └── AppContent
           │
           └── MobileShell (new)
               ├── MobileContent (scrollable area, full viewport)
               │   └── {children} (page content)
               └── BottomTabBar (fixed bottom)
                   ├── TabItem (Dictionary)
                   ├── TabItem (Learning)
                   ├── TabItem (Tools)
                   └── TabItem (Admin)
   ```
   For each component: server or client? What props? What context?

2. **Responsive detection** — How to choose mobile vs desktop:
   - CSS-only (`hidden md:block` / `md:hidden`) vs JavaScript hook (`useIsMobile`)
   - If JS hook: `window.matchMedia` vs `ResizeObserver` vs existing pattern
   - SSR implications: what renders on the server before hydration?
   - Should we use a `<MobileOnly>` / `<DesktopOnly>` wrapper component?
   - What about the SidebarProvider — does it need to wrap both or just desktop?

3. **New files to create:**
   ```
   components/layout/MobileShell.tsx        — Mobile app shell
   components/layout/BottomTabBar.tsx       — Bottom tab navigation
   components/layout/ResponsiveShell.tsx    — Mobile/desktop switcher
   components/layout/MobileContent.tsx      — Viewport-clamped content area
   app/(mobile)/dictionary/page.tsx         — Dictionary hub page (mobile)
   app/(mobile)/learning/page.tsx           — Learning hub page (mobile)
   app/(mobile)/tools/page.tsx              — Tools hub page (mobile)
   app/(mobile)/admin/page.tsx              — Admin hub page (mobile)
   hooks/useIsMobile.ts                     — Mobile detection hook
   ```
   For each: server or client? Purpose? Key implementation details?
   Should hub pages use Next.js route groups `(mobile)` or regular routes?

4. **Existing files to modify:**
   - `app/layout.tsx` — Replace `SidebarProvider > AppShell` with `ResponsiveShell`
   - `components/layout/AppShell.tsx` — Rename to `DesktopShell` or wrap conditionally
   - `lib/constants/navigation.ts` — Extend with mobile tab config (icons, badges, hub routes)
   - `components/layout/index.ts` — Export new components
   - Any page that uses `HeaderSlotContext` — mobile equivalent?

5. **State management for navigation:**
   - Active tab state: derived from pathname (like sidebar's `isActive`)
   - Tab badge counts: where does "cards due" data come from?
   - Navigation history: how does the mobile shell track back/forward for swipe?
   - Scroll position per tab: preserve scroll when switching tabs?
   - Should each tab maintain its own navigation stack (like iOS UITabBarController)?

6. **Hub page design** — Component structure for tab landing pages:
   ```tsx
   // app/(mobile)/dictionary/page.tsx
   <MobileHub title="Dictionary">
     <HubSearch placeholder="Search vocab, grammar, kanji..." />
     <HubGrid>
       <HubCard href="/vocab" icon="単語" title="Vocab" description="Browse vocabulary" />
       <HubCard href="/grammar" icon="文法" title="Grammar" description="Grammar patterns" />
       <HubCard href="/kanji" icon="漢字" title="Kanji" description="Kanji lookup" />
       ...
     </HubGrid>
   </MobileHub>
   ```
   Should HubCard show recent items or stats? How much info per card?

Do NOT edit any files — research only.

## Teammate 6: Performance & Modern UX Patterns Expert

You are a web performance engineer and modern UX pattern expert. Research the best
implementations of mobile navigation in modern web apps and PWAs.

**Research first:**
- Read `server/jisho-web/next.config.ts` — current Next.js config
- Read `server/jisho-web/app/globals.css` — current CSS architecture
- Read `server/jisho-web/tailwind.config.ts` — Tailwind config
- Read `server/jisho-web/components/layout/AppShell.tsx` — current shell performance
- Search web for: "best mobile web app bottom navigation 2025 2026",
  "Discord mobile PWA navigation", "Telegram web app navigation pattern",
  "Notion mobile web bottom nav", "Instagram PWA navigation",
  "shadcn mobile navigation", "radix bottom navigation",
  "Next.js 15 mobile navigation pattern", "view transitions API mobile nav",
  "react native web bottom tabs"

**Design deliverables:**

1. **Reference implementations** — Study 5+ production apps with excellent mobile nav:
   - For each app: screenshot description, navigation pattern, gesture support,
     transition animations, tab behavior
   - What makes each feel "native"? What are the common patterns?
   - Which patterns are achievable in a PWA vs native-only?
   - Rank them by applicability to our use case (dictionary/learning app)

2. **Animation & transitions** — Modern mobile transitions:
   - View Transitions API: browser support, Next.js integration, polyfills
   - Framer Motion: `AnimatePresence` for page transitions, gesture-based animations
   - CSS-only transitions: `@starting-style`, `view-transition-name`
   - Performance budget: transitions must be 60fps, no jank on older iPhones
   - Reduced motion: respect `prefers-reduced-motion`

3. **Bundle impact** — Adding mobile navigation shouldn't bloat the desktop experience:
   - Code splitting: mobile shell components only loaded on mobile
   - Dynamic imports for gesture libraries (`react-swipeable`, `framer-motion`)
   - Tree shaking: sidebar code not included in mobile bundle
   - Target: < 20KB additional JS for mobile navigation system
   - Measure: how much does the current sidebar + header contribute to bundle size?

4. **Rendering strategy** — SSR vs CSR for mobile shell:
   - The shell must render instantly (no flash of desktop layout on mobile)
   - Server-side responsive detection: `User-Agent` vs CSS-only vs hybrid?
   - Avoiding layout shift: mobile shell must be the first paint, not desktop-then-switch
   - Streaming SSR implications: can the shell stream before page content?

5. **Accessibility on mobile** — Mobile-specific a11y concerns:
   - Bottom nav: proper `role="tablist"` + `role="tab"` + `aria-selected`
   - Swipe gestures: provide visible back button alternative for motor impairment
   - Screen reader: how does VoiceOver interact with bottom tab bar?
   - Focus management: when switching tabs, where does focus go?
   - Reduced motion: disable swipe animations for `prefers-reduced-motion`

6. **Modern patterns to adopt** — What should we consider beyond the basics?
   - **Shared element transitions**: hero animations between list → detail pages
   - **Progressive disclosure**: mobile hub pages show summary, expand on tap
   - **Skeleton screens**: instant shell + skeleton content while loading
   - **Optimistic navigation**: show page skeleton before data loads
   - **Tab memory**: each tab remembers scroll position and sub-navigation state
   - **Contextual bottom bar**: morph bottom nav into contextual actions on certain pages
     (e.g., in review session: Again/Hard/Good/Easy instead of tab bar)
   - **Pull-to-action**: pull-down on hub page for quick search
   - **Edge swipe indicators**: subtle visual hint that swipe-back is available

---

## Coordination

**All 6 teammates run in parallel** — each explores a different dimension of the same problem.
There are no phase dependencies since this is a research/design task, not implementation.

After all teammates report, synthesize findings into a design document covering:

1. **Architecture decision** — The recommended shell split approach (responsive CSS vs JS vs hybrid)
2. **Component blueprint** — Complete component tree with file paths, server/client designation
3. **Navigation model** — Tab bar spec, hub page designs, route mapping
4. **Gesture system** — Swipe navigation spec, conflict resolution matrix, animation curves
5. **Viewport strategy** — CSS clamping approach, safe areas, keyboard handling
6. **PWA configuration** — Manifest changes, service worker strategy, iOS-specific settings
7. **Performance budget** — Bundle size targets, render timing targets, animation frame budgets
8. **Accessibility checklist** — Mobile-specific a11y requirements
9. **Implementation plan** — Ordered task list:
   - Phase A: Shell architecture (ResponsiveShell, MobileShell, BottomTabBar)
   - Phase B: Viewport clamping (CSS, safe areas, scroll containment)
   - Phase C: Hub pages (4 tab landing pages with navigation cards)
   - Phase D: Gesture navigation (swipe back/forward, page transitions)
   - Phase E: Polish (animations, haptics, PWA manifest, service worker)
   - Phase F: Migration (remove breadcrumbs on mobile, hide header/sidebar, search relocation)
10. **Risk register** — iOS PWA limitations, gesture conflicts, performance risks

Save the design document to `plans/PLAN_mobile_navigation_redesign.md`.

---

## Notes

- **Sonnet for all teammates**: Mobile UX architecture requires reasoning about spatial layout, gesture physics, CSS interactions, and platform-specific quirks. Haiku would miss critical details like safe area stacking or gesture conflict resolution.
- **6 agents by expertise, not by feature**: Bottom tab navigation spans architecture, gestures, CSS, platform constraints, component design, and performance. Each angle requires different domain knowledge.
- **Parallel execution**: Unlike the YouTube player design (which had data dependencies), this is a research/design task where all dimensions can be explored simultaneously. No phasing needed.
- **"Kill the header" is the key insight**: This isn't just "add a bottom nav" — it's a complete rethinking of the mobile shell. The header, sidebar, breadcrumbs, and search bar all need new homes. Each teammate should consider the implications for their domain.
- **Desktop stays untouched**: Critical constraint. The sidebar navigation and header are well-liked on desktop. This redesign only affects viewport widths below the mobile breakpoint.
- **Navigation constants as contract**: The existing `NAVIGATION` array in `lib/constants/navigation.ts` already groups items into Dictionary/Learning/Tools/Admin — exactly matching the proposed 4-tab bottom nav. The data model is already right; we're changing the presentation layer.
- **Swipe navigation is the hardest part**: Getting native-feel swipe-back in a PWA is notoriously difficult due to iOS Safari's own swipe gesture. The gesture expert (Teammate 2) should focus heavily on this.
