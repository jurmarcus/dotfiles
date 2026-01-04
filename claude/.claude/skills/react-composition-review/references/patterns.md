# Compositional React Patterns

Detailed patterns for building maintainable React applications.

## Pattern 1: Fragment Colocation

### Concept

Components define their own data requirements via GraphQL fragments. Parent queries compose these fragments automatically.

### Implementation

```tsx
// lib/graphql/fragments/vocab.ts
import { gql } from "@apollo/client";
import { DEFINITION_FRAGMENT } from "./definition";

export const VOCAB_DETAIL_FRAGMENT = gql`
  ${DEFINITION_FRAGMENT}

  fragment VocabDetail on MergedVocab {
    term
    reading
    frequency
    definitions {
      ...DefinitionData
    }
  }
`;
```

```tsx
// components/dictionary/DefinitionList.tsx
import { DEFINITION_FRAGMENT } from "@/lib/graphql/fragments";
import type { SourcedDefinition } from "@/lib/types";

// Re-export fragment for parent queries
export { DEFINITION_FRAGMENT };

export function DefinitionList({ definitions }: { definitions: SourcedDefinition[] }) {
  // Component implementation
}
```

### Benefits

- Change component data needs → only update fragment
- Parent queries automatically include nested fragments
- No query duplication across pages
- Type safety from matching interfaces

---

## Pattern 2: Centralized Constants

### Concept

All magic values, color mappings, and labels live in `lib/constants/`.

### Structure

```
lib/constants/
├── index.ts      # Re-exports all constants
├── colors.ts     # Color mappings (LAYER_COLORS, etc.)
├── labels.ts     # Display labels (NAME_TYPE_LABELS, etc.)
└── validation.ts # Validation constants (JLPT_LEVELS, etc.)
```

### Implementation

```tsx
// lib/constants/colors.ts
export const LAYER_COLORS: Record<string, string> = {
  vocab: "bg-blue-100 dark:bg-blue-900/30",
  grammar: "bg-green-100 dark:bg-green-900/30",
  name: "bg-purple-100 dark:bg-purple-900/30",
  particle: "bg-gray-100 dark:bg-gray-800",
  unresolved: "bg-red-100 dark:bg-red-900/30",
};
```

```tsx
// lib/constants/labels.ts
export const NAME_TYPE_LABELS: Record<string, string> = {
  surname: "Surname",
  given: "Given name",
  place: "Place",
  person: "Person",
};
```

```tsx
// lib/constants/validation.ts
export const JLPT_LEVELS = [1, 2, 3, 4, 5] as const;
export type JlptLevel = (typeof JLPT_LEVELS)[number];

export function isValidJlptLevel(level: number): level is JlptLevel {
  return JLPT_LEVELS.includes(level as JlptLevel);
}
```

### Usage

```tsx
import { LAYER_COLORS, NAME_TYPE_LABELS, isValidJlptLevel } from "@/lib/constants";
```

---

## Pattern 3: Domain-Driven Types

### Concept

Type organization mirrors backend resources. Each domain has its own type file.

### Structure

```
lib/types/
├── index.ts     # Re-exports all types
├── common.ts    # Shared types (SourcedDefinition, etc.)
├── vocab.ts     # VocabEntry, VocabDetail, VocabSearchResult
├── grammar.ts   # GrammarEntry, GrammarDetail
├── kanji.ts     # KanjiSearchResult, KanjiDetail
├── names.ts     # NameEntry, NameSearchResult
└── analyze.ts   # Token, ResolvedTerm, Layer types
```

### Implementation

```tsx
// lib/types/vocab.ts
export interface VocabEntry {
  __typename: "VocabEntry";
  term: string;
  vocabReading: string | null;
  definition: string | null;
  frequency: number | null;
}

export interface VocabDetail {
  japaneseText: JapaneseText;
  definitions: SourcedDefinition[];
  forms: Forms | null;
  sentences: Sentence[];
  pitchAccents: PitchAccent[];
  frequency: number | null;
}
```

### Never Redefine Types Locally

```tsx
// BAD: Types in page file
interface VocabEntry {
  term: string;
  reading: string;
}

// GOOD: Import from centralized types
import type { VocabEntry } from "@/lib/types";
```

---

## Pattern 4: Component Composition

### Concept

Build pages from small, reusable components. No component should do everything.

### Layout Components

```tsx
// components/layout/ContentLayout.tsx
export function ContentLayout({ children, showBackLink = true }) {
  return (
    <main className="min-h-screen p-6 bg-background">
      <div className="max-w-5xl mx-auto">
        {showBackLink && <BackLink />}
        {children}
      </div>
    </main>
  );
}
```

```tsx
// components/layout/DetailSection.tsx
export function DetailSection({ title, children }) {
  return (
    <section className="mb-8">
      <h2 className="text-2xl font-semibold mb-4">{title}</h2>
      <Card><CardContent className="pt-6">{children}</CardContent></Card>
    </section>
  );
}
```

### Page Composition

```tsx
// app/vocab/[term]/page.tsx
export default async function VocabPage({ params }) {
  const { data } = await getClient().query({ ... });

  return (
    <ContentLayout>
      <DetailsHeader
        title={vocab.term}
        reading={vocab.reading}
        badges={<FrequencyBadge frequency={vocab.frequency} />}
      />

      <DetailSection title="Definitions">
        <DefinitionList definitions={vocab.definitions} />
      </DetailSection>

      {vocab.forms && (
        <DetailSection title="Conjugations">
          <ConjugationGrid forms={vocab.forms} />
        </DetailSection>
      )}
    </ContentLayout>
  );
}
```

---

## Pattern 5: Shared Loading/Error States

### Concept

Extract common UI states into reusable components.

### Implementation

```tsx
// components/ui/QueryLoading.tsx
export function QueryLoading({ message = "Loading..." }) {
  return (
    <Card>
      <CardContent className="pt-6">
        <Skeleton className="h-32 w-full" />
        <p className="text-muted-foreground mt-2">{message}</p>
      </CardContent>
    </Card>
  );
}
```

```tsx
// components/ui/QueryError.tsx
export function QueryError({ message = "Failed to load data." }) {
  return (
    <Card>
      <CardContent className="pt-6">
        <p className="text-destructive">{message}</p>
      </CardContent>
    </Card>
  );
}
```

### Usage

```tsx
function VocabEntryDetail({ entry }) {
  const { loading, error, data } = useQuery(VOCAB_QUERY);

  if (loading) return <QueryLoading />;
  if (error) return <QueryError message="Failed to load vocab details." />;

  return <VocabContent data={data} />;
}
```

---

## Pattern 6: Result Card Abstraction

### Concept

Search results share a common structure. Extract into a base component.

### Base Component

```tsx
// components/search-results/ResultCard.tsx
export interface ResultCardProps {
  href: string;
  title: string;
  reading?: string | null;
  subtitle?: string | null;
  badges?: ReactNode;
  description?: string | null;
}

export function ResultCard({
  href, title, reading, subtitle, badges, description
}: ResultCardProps) {
  return (
    <Link href={href} className="block p-5 rounded-lg border hover:shadow-md">
      <header className="flex items-baseline gap-3 mb-2">
        <h3 className="text-xl font-semibold">{title}</h3>
        {reading && <span className="text-muted-foreground">{reading}</span>}
        {subtitle && <span className="text-muted-foreground italic">{subtitle}</span>}
        {badges && <div className="ml-auto">{badges}</div>}
      </header>
      {description && <p className="text-muted-foreground">{description}</p>}
    </Link>
  );
}
```

### Domain-Specific Cards

```tsx
// components/search-results/VocabResultCard.tsx
export function VocabResultCard({ result }: { result: VocabSearchResult }) {
  return (
    <ResultCard
      href={`/vocab/${encodeURIComponent(result.term)}`}
      title={result.term}
      reading={result.reading}
      badges={result.frequency && <FrequencyBadge frequency={result.frequency} />}
      description={result.definitionText}
    />
  );
}
```

---

## Pattern 7: Tab Navigation Component

### Concept

Extract linked tab navigation into reusable component.

### Implementation

```tsx
// components/layout/TabNavigation.tsx
interface TabItem {
  value: string;
  label: string;
  href: string;
}

export function TabNavigation({ tabs, currentValue }: {
  tabs: TabItem[];
  currentValue: string;
}) {
  return (
    <Tabs value={currentValue} className="mb-6">
      <TabsList className="flex-wrap h-auto gap-1">
        {tabs.map((tab) => (
          <Link key={tab.value} href={tab.href}>
            <TabsTrigger value={tab.value}>{tab.label}</TabsTrigger>
          </Link>
        ))}
      </TabsList>
    </Tabs>
  );
}
```

### Usage

```tsx
const JLPT_TABS = JLPT_LEVELS.map((l) => ({
  value: `${l}`,
  label: `N${l}`,
  href: `/kanji/jlpt/${l}`,
}));

<TabNavigation tabs={JLPT_TABS} currentValue={`${level}`} />
```

---

## Pattern 8: Dispatcher Pattern

### Concept

When rendering different content based on type, use a dispatcher component.

### Implementation

```tsx
// components/analyze/TermDetail.tsx
export function TermDetail({ term }: { term: ResolvedTerm }) {
  if (!term.entry) {
    return <EmptyState message="No dictionary entry found." />;
  }

  switch (term.entry.__typename) {
    case "VocabEntry":
      return <VocabEntryDetail entry={term.entry} />;
    case "GrammarEntry":
      return <GrammarEntryDetail entry={term.entry} />;
    case "NameEntry":
      return <NameEntryDetail entry={term.entry} />;
    default:
      return null;
  }
}
```

### Benefits

- Dispatcher is tiny (~50 lines)
- Each entry detail is focused and testable
- Easy to add new entry types
- TypeScript ensures exhaustive handling
