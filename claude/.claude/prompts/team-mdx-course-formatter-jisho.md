# Team Design: MDX Course Formatter — Bunpro & Migaku

> Design a general MDX formatter for converting Bunpro grammar and Migaku course data into rich MDX content | Model: Sonnet | Agents: 8

---

Create an agent team with 8 teammates to design a general MDX course content formatter for jisho.
Use Sonnet for each teammate — this requires reasoning about data shapes, MDX component APIs,
HTML-to-MDX conversion rules, and pipeline architecture.

The codebase is at ~/CODE/jisho/. Read CLAUDE.md, server/CLAUDE.md, server/jisho-web/CLAUDE.md
first for architecture context.

## Design Philosophy

**Two sources, one output format.** Bunpro has scraped grammar explanations (938 JSON files at
`~/.local/share/jisho/scraped/bunpro/grammar/`). Migaku has pre-compiled MDX lesson content and
card notes. Both need to produce MDX that renders through the existing Migaku component registry
(`MdxLessonContent` / `MdxContent` with 35+ Ui* components).

**Reuse the component registry, don't reinvent.** The Migaku components (UiCard, UiExample,
UiFormation, UiCardTypo, UiParsedTypo, UiTargetWord, etc.) already handle Japanese text with
furigana, example sentences with audio and translation, formation patterns, and grammar boxes.
The formatter converts source content into JSX that uses these components.

**Research first, format spec second.** Before designing the formatter, we need to deeply
understand: (a) what the source data looks like across ALL entries, (b) what MDX the Migaku
components expect, and (c) what gaps exist between source data and component capabilities.

Every design proposal must include:
- **Data shape**: What fields exist, their types, edge cases, completeness
- **MDX target**: What JSX the formatter should produce, using which components
- **Conversion rules**: How source content maps to MDX components
- **Edge cases**: What happens with missing data, malformed HTML, special characters
- **Concrete examples**: Before/after for at least 3 representative entries

## Current State

### Bunpro scraped data (`~/.local/share/jisho/scraped/bunpro/grammar/*.json`)
- 938 grammar points as individual JSON files (numbered 1-999 with gaps)
- Fields: `title`, `title_japanese`, `bunpro_id`, `meaning`, `structure`, `jlpt_level`,
  `register`, `explanation` (long text), `caution`, `examples[]` (with `japanese_highlighted`
  HTML + `audio_url`), `synonyms[]`, `antonyms[]`, `related_grammar[]`, `online_resources[]`,
  `book_references[]`
- Rust types: `server/jisho-core/src/grammar/bunpro_types.rs` (BunproGrammar, BunproExample, etc.)

### What's already in the database (grammar_senses.metadata)
- `BunproSenseMetadata`: bunpro_id, structure, caution, register, part_of_speech, word_type,
  lesson_number, online_resources[], book_references[]
- **NOT in DB**: `explanation`, `examples[]`, `synonyms[]`, `antonyms[]`, `related_grammar[]`

### MDX rendering infrastructure
- **MdxCardContent** (`components/cards/MdxCardContent.tsx`): Uses `evaluateSync()` for raw JSX.
  Components: CardMeaning, CardPitch, CardFrequency, CardKanji, CardNotes, CardImage
- **MdxLessonContent / MdxContent** (`components/courses/MdxLessonContent.tsx`): Uses `runSync()`
  for pre-compiled function-body MDX. 35+ Migaku Ui* components including:
  - **Layout**: UiCard, UiCardItem, UiCardAlign, UiCardTypo (heading levels)
  - **Grammar**: UiFormation (orange box), UiGrammarBox, UiGrammarItem
  - **Examples**: UiExample (sentence + translation + audio), UiTargetWord (vocab with furigana + audio)
  - **Text**: UiParsedTypo (Japanese with furigana from Migaku syntax), UiTranslation, UiTranslationQuoted
  - **Media**: UiImage, UiSvg, UiAudioTap
  - **Structure**: UiList, UiListItem, UiNumberedHeading, UiMigachuToggle (collapsible)
  - **Table**: UiTable, UiTableRow, UiTableCell, UiTableRowGroup, UiTableColumnHeader, UiTableRowHeader
  - **Misc**: UiHiragana, UiKatakana, UiLessonLink, UiPronunciationIpa, UiPronunciationRomanized
- **Migaku syntax**: `学生[がくせい]` → furigana ruby, `<strong class="emphasis-grammar">だ</strong>` → orange bold

### MDX compilation pipeline
- Rust `compile_card_mdx()` in `server/jisho-core/src/card/mdx.rs` generates raw JSX for card backs
- HTML-to-MDX conversion via `html_to_mdx()`: preserves strong/em/br, strips unsafe tags, escapes `{}`
- For pre-compiled MDX (Migaku lessons): already compiled by Migaku's tooling, stored as function-body strings

### Grammar page frontend
- `GrammarDefinitionList.tsx` — currently shows glosses + parsed metadata (structure, caution, register, resources)
- Grammar detail page: `server/jisho-web/app/grammar/[pattern]/page.tsx`

---

## Teammate 1: Bunpro Data Shape Auditor

Analyze ALL 938 Bunpro grammar JSON files to produce a comprehensive field inventory with
completeness statistics and edge cases.

**Research first:**
- Read `server/jisho-core/src/grammar/bunpro_types.rs` — BunproGrammar struct and helpers
- Sample at least 20 files across JLPT levels: N5 (1-50), N4 (51-200), N3 (200-500), N2 (500-800), N1 (800+)
- Read at least 5 files with long explanations (>2000 chars) and 5 with short ones

**Deliverables:**
1. **Field completeness matrix** — For each field, what percentage of entries have it:
   | Field | Present (%) | Avg Length | Min/Max Length | Example |
   Count how many entries have `explanation`, `caution`, `examples`, etc.

2. **Explanation text patterns** — Analyze the `explanation` field across entries:
   - How is it structured? (Paragraphs? Inline examples? Section headers?)
   - Does it contain inline Japanese with furigana notation like `(reading)`?
   - Does it contain inline example sentences? How are they formatted?
   - Are there "Caution", "Fun Fact", or other sub-section markers?
   - How does it differ between N5 (simple) and N1 (complex)?

3. **Example sentence patterns** — Analyze `examples[]`:
   - What HTML tags appear in `japanese_highlighted`? (ruby, span, data-gp-id, etc.)
   - What `source` values exist? ("examples_tab", "about", "caution" — any others?)
   - How many examples per entry (min, max, avg, distribution)?
   - Are audio URLs consistently present?
   - Are English translations always present?

4. **Relationship data patterns** — Analyze `synonyms[]`, `antonyms[]`, `related_grammar[]`:
   - How many entries have each type?
   - Do the URLs consistently point to valid bunpro grammar_points?
   - Is the `description` field useful (comparison between patterns)?

5. **Edge cases catalog** — Find and document:
   - Entries with empty/null explanation
   - Entries with very long explanation (>5000 chars)
   - Entries with HTML in explanation text
   - Entries with unusual structure formatting (multi-line, brackets, etc.)
   - Entries with duplicate examples (same sentence appearing twice)
   - Entries where examples have no English translation

Do NOT edit any files — research only.

## Teammate 2: Migaku Notes MDX Auditor

Extract and analyze real Migaku `notes_mdx` content from the database to understand what
well-formed Migaku MDX looks like in practice.

**Research first:**
- Read `server/jisho-web/components/courses/MdxLessonContent.tsx` — full component registry
- Read `server/jisho-migaku/src/types.rs` — MigakuCardFull and field layout
- Read `server/jisho-migaku/src/import.rs` — how notes_mdx is extracted from field[5]

**Deliverables (research via database query):**

Use `sqlite3 ~/.local/share/jisho/db/jisho.db` to query actual card data.

1. **Sample extraction** — Find 10 cards that have non-null `notes_mdx`:
   ```sql
   SELECT id, target, notes_mdx FROM cards WHERE notes_mdx IS NOT NULL LIMIT 10;
   ```
   For each, show the raw MDX string and identify which Ui* components it uses.

2. **Component usage frequency** — Across all notes_mdx content, which components appear most?
   ```sql
   SELECT COUNT(*) FROM cards WHERE notes_mdx LIKE '%UiCardItem%';
   SELECT COUNT(*) FROM cards WHERE notes_mdx LIKE '%UiExample%';
   -- etc. for each component
   ```

3. **MDX structure patterns** — What's the typical nesting pattern?
   - Do all notes start with UiCard?
   - What's inside UiCardItem typically?
   - How are examples structured (UiExample vs UiTargetWord)?
   - How is furigana encoded (Migaku bracket syntax)?

4. **Component prop patterns** — For each commonly-used component, what props are used?
   - UiExample: `translation`, `syntaxProps`, `audio` — what values?
   - UiTargetWord: `translation`, `syntaxProps`, `audioProps` — what values?
   - UiParsedTypo: `syntax`, `lang`, `flags` — what values?
   - UiFormation: `formation`, `syntaxProps` — what values?

5. **Sample MDX → rendered output mapping** — For 3 representative cards, show:
   - The raw MDX source
   - What each component renders to (describe the visual output)
   - How this maps to the component registry in MdxLessonContent.tsx

Do NOT edit any files — research only.

## Teammate 3: Migaku Lesson Content Auditor

Analyze existing Migaku course lesson content to understand how full lessons (not just card notes)
are structured in MDX.

**Research first:**
- Read `server/jisho-core/src/course/` — all files (types, db, mod)
- Read `server/jisho-migaku/src/import.rs` — how lessons are imported
- Read `server/jisho-web/app/courses/[courseId]/lessons/[lessonId]/page.tsx` — lesson rendering

**Deliverables (research via database query):**

Use `sqlite3 ~/.local/share/jisho/db/jisho.db` to query lesson data.

1. **Lesson content sample** — Find 5 lessons with content:
   ```sql
   SELECT id, title, chapter, content_mdx FROM lessons WHERE content_mdx IS NOT NULL LIMIT 5;
   ```
   For each: show the first 500 chars of MDX, identify top-level structure.

2. **Lesson structure patterns** — How are lessons organized?
   - Do they start with an introduction section?
   - How are vocabulary items presented within lessons?
   - How are grammar explanations structured?
   - Are there exercise/practice sections?
   - How do lessons reference their associated cards?

3. **Component usage in lessons vs card notes** — Compare:
   - Which components are used in lessons but not card notes?
   - Which are used in both?
   - What's the typical lesson length (in MDX chars)?

4. **Lesson metadata** — What metadata accompanies lessons?
   - `chapter`, `position`, `lesson_number`
   - How do lessons relate to cards (via `lesson_id` FK)?

5. **Quality assessment** — For the Migaku lesson content:
   - Is the MDX well-formed?
   - Are there rendering issues with any components?
   - What would need to change to match Bunpro's explanation depth?

Do NOT edit any files — research only.

## Teammate 4: MDX Component API Expert

Create a comprehensive API reference for every Migaku Ui* component, documenting exactly what
JSX to generate for each content type.

**Research first:**
- Read `server/jisho-web/components/courses/MdxLessonContent.tsx` — the FULL file, every component
- Read `server/jisho-web/components/courses/AudioButton.tsx` — audio playback component
- Read `server/jisho-web/components/courses/parseSyntax.ts` or similar — Migaku syntax parser
- Search for `UiFormation`, `UiExample`, `UiTargetWord` usage in any test files or examples

**Deliverables:**

1. **Complete component API reference** — For EVERY Ui* component:
   ```
   ### UiExample
   Props: { translation?: string, syntaxProps?: { syntax: string, lang?: string }, audio?: string }
   Purpose: Renders an example sentence with furigana, translation, and optional audio
   JSX example:
     <UiExample
       translation="It is a cat."
       syntaxProps={{ syntax: "猫[ねこ]だ。", lang: "ja" }}
       audio="https://example.com/audio.mp3"
     />
   Renders: Japanese sentence with ruby furigana, italic English translation below, audio button
   ```

2. **Composition patterns** — How components nest together:
   - `UiCard > UiCardItem > UiParsedTypo` — standard text card
   - `UiCard > UiCardItem > UiExample` — example within card
   - `UiFormation` — standalone formation box
   - `UiGrammarBox > UiGrammarItem` — grammar container
   - `UiNumberedHeading + UiCard` — numbered section

3. **Migaku syntax specification** — Document the bracket notation:
   - `学生[がくせい]` → ruby furigana
   - `学生[!がくせい]` → forced display
   - `きれい[,綺麗*きれい]` → alternative kanji form
   - `<strong class="emphasis-grammar">だ</strong>` → orange grammar highlight
   - How to encode inline Japanese text for UiParsedTypo's `syntax` prop

4. **Content type → component mapping** — For each content type a grammar lesson might have:
   | Content Type | Best Component | Props Pattern |
   |---|---|---|
   | Explanation paragraph | UiCardTypo | `{ type: 1 }` for heading, else default |
   | Example sentence with translation | UiExample | `{ translation, syntaxProps, audio }` |
   | Formation/structure pattern | UiFormation | `{ formation, syntaxProps }` |
   | Caution/warning block | UiCard type=2 | `{ type: 2 }` (orange accent) |
   | Vocabulary target word | UiTargetWord | `{ translation, syntaxProps, audioProps }` |
   | Inline Japanese text | UiParsedTypo | `{ syntax, lang: "ja" }` |
   | English translation | UiTranslation | `{ translation }` |
   | Collapsible section | UiMigachuToggle | children |
   | Numbered list | UiNumberedHeading + content | `{ number }` |

Do NOT edit any files — research only.

## Teammate 5: Bunpro Explanation → MDX Converter Designer

Design the conversion rules for turning Bunpro `explanation` text into MDX using the Migaku
component registry.

**Research first:**
- Read at least 10 Bunpro JSON files across JLPT levels (N5: 1.json, 5.json; N4: 100.json, 150.json;
  N3: 300.json, 400.json; N2: 600.json, 700.json; N1: 850.json, 900.json)
- Focus on the `explanation` field structure in each
- Read `server/jisho-web/components/courses/MdxLessonContent.tsx` for component API

**Deliverables:**

1. **Explanation text anatomy** — Dissect the explanation format:
   - Paragraph breaks (double newline)
   - Inline example sentences (Japanese + English on separate lines within the explanation)
   - Furigana notation: `漢字(かんじ)` — parenthesized readings after kanji
   - Sub-sections: "Caution", "Fun Fact", "Note" markers
   - Inline bold/emphasis (are there any?)
   - Cross-references to other grammar points

2. **Parsing rules** — Design a parser that converts explanation text to structured blocks:
   ```
   Input: "For the most part, だ is the equivalent of 'is' in English.\n\nアイスクリームだ。It is ice cream.\n\nCaution\nAlthough です..."

   Output:
   [
     { type: "paragraph", text: "For the most part, だ is the equivalent of 'is' in English." },
     { type: "example", japanese: "アイスクリームだ。", english: "It is ice cream." },
     { type: "caution_header" },
     { type: "paragraph", text: "Although です..." }
   ]
   ```

3. **Block → MDX conversion** — For each block type, the exact JSX output:
   ```
   paragraph → <UiCardTypo>For the most part, だ is the equivalent of 'is' in English.</UiCardTypo>
   example → <UiExample translation="It is ice cream." syntaxProps={{ syntax: "アイスクリームだ。" }} />
   caution → <UiCard type={2}><UiCardItem><UiCardTypo type={3}>Caution</UiCardTypo></UiCardItem>...</UiCard>
   ```

4. **Furigana conversion** — Convert Bunpro's `漢字(かんじ)` notation to Migaku's `漢字[かんじ]` bracket syntax:
   - Rule: `(\w+)\(([ぁ-ん]+)\)` → `$1[$2]`
   - Edge cases: Nested parentheses, non-furigana parenthesized content
   - When to use UiParsedTypo (inline Japanese) vs plain text (English)

5. **Complete before/after examples** — Show full conversion for 3 grammar points:
   - A simple N5 entry (e.g., だ — ID 1)
   - A medium N4 entry (e.g., にくい — ID 100)
   - A complex N2/N1 entry with multiple caution blocks
   Show the raw explanation text → the parsed blocks → the final MDX output.

Do NOT edit any files — research only.

## Teammate 6: Example Sentence & Metadata MDX Designer

Design the conversion rules for Bunpro example sentences (with highlighted HTML), and
metadata (structure, synonyms, antonyms, resources) into MDX.

**Research first:**
- Read 5 Bunpro JSON files, focusing on `examples[]` and `japanese_highlighted` HTML
- Read `server/jisho-web/components/courses/MdxLessonContent.tsx` — UiExample, UiTargetWord
- Read `server/jisho-web/components/dictionary/GrammarDefinitionList.tsx` — current metadata rendering

**Deliverables:**

1. **japanese_highlighted HTML → MDX conversion** — Design rules for converting Bunpro's HTML:
   - `<ruby>漢字<rp>(</rp><rt>かんじ</rt><rp>)</rp></ruby>` → `漢字[かんじ]` (Migaku syntax)
   - `<span class="study-area-input"><span class="text-primary-accent">だ</span></span>` → `<strong class="emphasis-grammar">だ</strong>` (grammar highlight)
   - `<span data-gp-id="N" class="gp-popout cursor-pointer">...</span>` → plain text (strip popout wrapper)
   - `<span data-vocab-id="N" class="vocab-popout cursor-pointer">...</span>` → plain text (strip vocab wrapper)
   Show 3 complete conversion examples.

2. **Example sentence MDX format** — The target JSX for each example:
   ```jsx
   <UiExample
     translation="It is a cat."
     syntaxProps={{ syntax: "<strong class=\"emphasis-grammar\">猫[ねこ]だ</strong>。" }}
     audio="https://dk3kgylsgq3k1.cloudfront.net/audio/grammar/n5/..."
   />
   ```
   - Should we use examples from `source: "examples_tab"` only? Or also `source: "about"`/`"caution"`?
   - Deduplication strategy (Bunpro sometimes has duplicate examples)

3. **Structure/Formation MDX format** — Convert `structure` field:
   ```
   Input: "Verb[stem] + にくい"
   Output: <UiFormation formation="Verb[stem] + にくい" />
   ```
   Or should it use UiGrammarBox? Recommend the best component.

4. **Synonyms/Antonyms/Related grammar MDX** — Design the format:
   - Link cards that reference other grammar patterns
   - Should these use UiCard, or a custom section at the end?
   - How to link to jisho grammar pages (`/grammar/[pattern]`)

5. **Resources MDX format** — Online resources and book references:
   - UiLessonLink for URLs?
   - UiList + UiListItem for book references?

6. **Complete example** — Show the full MDX output for one grammar point combining:
   explanation + structure + caution + 5 examples + synonyms + resources

Do NOT edit any files — research only.

## Teammate 7: Pipeline & Storage Architect

Design where and how the formatter runs, how it stores output, and how it integrates with
the existing jisho CLI and import pipeline.

**Research first:**
- Read `server/jisho-cli/src/commands/` — existing CLI commands (especially import/scrape patterns)
- Read `server/jisho-core/src/grammar/import.rs` — current grammar import pipeline
- Read `server/jisho-core/src/card/mdx.rs` — existing card MDX compilation
- Read `server/jisho-core/src/database/schema/mod.rs` — current schema
- Read `server/jisho-core/src/course/` — course/lesson/card schema

**Deliverables:**

1. **Storage design** — Where does the formatted MDX live?
   Option A: New column on `grammar_senses` table: `explanation_mdx TEXT`
   Option B: Separate table: `grammar_explanations (grammar_id, mdx_compiled TEXT, scraped_json TEXT)`
   Option C: Store in course/lessons system (grammar as a "course" with lessons per JLPT level)
   Recommend with reasoning. Consider: query patterns, update frequency, relationship to existing grammar data.

2. **CLI command design** — How to run the formatter:
   ```bash
   jisho format bunpro          # Format all Bunpro grammar into MDX
   jisho format bunpro --id 100  # Format a single entry
   jisho format bunpro --dry-run # Show MDX without storing
   jisho format migaku           # (Future) Format Migaku content
   ```
   Integrate into existing CLI pattern in `server/jisho-cli/`.

3. **Compilation approach** — Should the MDX be:
   - Raw JSX (like `content_mdx` for cards) → `evaluateSync()` at render time
   - Pre-compiled function-body (like Migaku `notes_mdx`) → `runSync()` at render time
   - Pre-compiled at format time (more complex but faster rendering)
   Recommend with reasoning about bundle size, render performance, and developer experience.

4. **GraphQL exposure** — How to serve the MDX to the frontend:
   - New field on Grammar type: `explanationMdx: String`?
   - New resolver: `grammarExplanation(pattern: String!) { mdx, examples, ... }`?
   - How to handle the relationship between grammar_senses (multiple per pattern) and explanation (one per Bunpro ID)?

5. **Update pipeline** — When Bunpro data is re-scraped:
   - How to detect changes and re-format only updated entries
   - Versioning/cache invalidation strategy
   - Should formatting happen as part of `jisho scrape bunpro` or as a separate step?

6. **Migaku extension** — How would this generalize for Migaku:
   - Migaku already has `notes_mdx` — does it need reformatting?
   - What about Migaku lesson `content_mdx` — is it already good enough?
   - Identify what Migaku-specific formatting would look like

Do NOT edit any files — research only.

## Teammate 8: Frontend Rendering & Grammar Page Integration Designer

Design how the formatted MDX renders in jisho-web grammar pages and other surfaces.

**Research first:**
- Read `server/jisho-web/app/grammar/[pattern]/page.tsx` — current grammar detail page
- Read `server/jisho-web/components/dictionary/GrammarDefinitionList.tsx` — current definition rendering
- Read `server/jisho-web/components/courses/MdxLessonContent.tsx` — MdxContent component
- Read `server/jisho-web/components/decks/CardBack.tsx` — how MDX is used for card backs
- Read `server/jisho-web/lib/graphql/fragments/grammar.ts` — current grammar fragments

**Deliverables:**

1. **Grammar page redesign** — How to integrate rich MDX explanation into the grammar detail page:
   - Current layout: GrammarDefinitionList (glosses + metadata) + SentenceList + related patterns
   - New layout: Where does the explanation MDX go? Before or after definitions?
   - Should the explanation replace or supplement the current metadata display?
   - Tabbed interface? (Definitions | Explanation | Examples | Related)?
   - Mobile considerations?

2. **New component design** — `GrammarExplanation.tsx`:
   - Props: `{ mdx: string }` (the formatted MDX)
   - Renders via `<MdxContent code={mdx} />` (reusing Migaku component registry)
   - Loading/error states
   - Server component or client component?

3. **Fragment updates** — What GraphQL changes are needed:
   - New fragment: `GRAMMAR_EXPLANATION_FRAGMENT`
   - Update existing query to include explanation MDX
   - Consider progressive loading: fetch metadata first (SSR), explanation second (client)?

4. **Example sentence display** — The formatted MDX includes UiExample components:
   - These render inline with the explanation
   - But the grammar page also has a separate SentenceList section
   - How to avoid duplication? Should the standalone examples section use different sentences?

5. **Cross-references** — Synonyms/antonyms/related grammar in the MDX:
   - Should link to jisho grammar pages (not Bunpro URLs)
   - Design the linking pattern: `<a href="/grammar/[pattern]">` or UiLessonLink?
   - How to resolve Bunpro URLs → jisho patterns (via bunpro_id lookup)

6. **Other rendering surfaces** — Where else might grammar MDX appear?
   - Card back rendering (when reviewing grammar cards)?
   - MCP resource responses (grammar explanations via MCP)?
   - Search result previews?

Do NOT edit any files — research only.

---

## Coordination

**Phase 1: Data Audit** (Teammates 1, 2, 3 run first)
- Teammate 1 audits ALL Bunpro scraped data → establishes source data shape and edge cases
- Teammate 2 audits Migaku notes_mdx → establishes target MDX format from real examples
- Teammate 3 audits Migaku lesson content → establishes lesson-level MDX patterns
- These three define what we're converting FROM and what good MDX looks like

**Phase 2: Format Design** (Teammates 4, 5, 6 run in parallel, after Phase 1)
- Teammate 4 creates complete component API reference → the "dictionary" for MDX generation
- Teammate 5 designs explanation text → MDX conversion → the core formatter logic
- Teammate 6 designs examples + metadata → MDX conversion → the supplementary content formatter
- All three build on the data shape from Phase 1 and MDX patterns from Phase 2

**Phase 3: Architecture** (Teammates 7, 8 run in parallel, after Phase 2)
- Teammate 7 designs pipeline, storage, and CLI → how to run and store
- Teammate 8 designs frontend rendering → how to display
- Both build on the format specification from Phase 2

**Phase 4: Synthesis**
After all teammates report, synthesize into a design document:

1. **MDX format specification** — The exact JSX output format for each Bunpro content type
2. **Conversion rules** — Text parsing rules, HTML-to-MDX rules, furigana notation conversion
3. **Component usage guide** — Which Migaku components to use and when
4. **Pipeline design** — CLI command, storage location, compilation approach
5. **Schema changes** — New tables/columns, GraphQL fields, fragments
6. **Frontend integration** — Grammar page layout, new components, progressive loading
7. **Edge cases** — How to handle missing data, malformed content, special patterns
8. **Implementation plan** — Ordered tasks:
   - Phase A: Rust formatter function (explanation parser + MDX generator)
   - Phase B: CLI command + storage
   - Phase C: GraphQL exposure
   - Phase D: Frontend rendering components
   - Phase E: Full pipeline run on all 938 entries
9. **Sample output** — Complete MDX for 3 representative grammar points (N5, N3, N1)

Save the design document to `docs/plans/YYYY-MM-DD-mdx-course-formatter-design.md`.

---

## Notes

- **Sonnet for all teammates**: Understanding MDX component APIs, HTML parsing rules, and data shape
  analysis requires solid reasoning. Haiku would miss nuances in the conversion rules.
- **8 agents by concern**: Data audit (3), format design (3), architecture (2). Clean separation
  ensures no overlap and each agent can go deep on their specific concern.
- **Migaku components as target**: We are NOT creating new components. The 35+ Ui* components
  already handle everything we need. The formatter's job is to produce JSX that uses them correctly.
- **Phase 1 before Phase 2**: Format designers need to know the actual data shape (not assumed).
  Bunpro's explanation text has many patterns that only emerge from reading many entries.
- **Bunpro explanation is the hard part**: The `explanation` field is free-text with inline examples,
  furigana notation, and section markers. Parsing this reliably is the key technical challenge.
- **Example sentence HTML conversion**: The `japanese_highlighted` HTML is complex (ruby, popout spans,
  grammar highlights). Converting this to Migaku bracket syntax requires careful regex/parser design.
- **Generalization for Migaku**: While this prompt focuses on Bunpro, the pipeline should be
  extensible for Migaku courses. Teammate 7 explicitly addresses this.
