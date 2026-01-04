# React Anti-Patterns Catalog

Extended catalog of anti-patterns to identify during component review.

## Anti-Pattern 1: God Component

### Description

A single component file that handles too many concerns: data fetching, state management, multiple rendering paths, and complex logic.

### Symptoms

- File exceeds 150-200 lines
- Multiple `useQuery` or `useEffect` calls
- Multiple inline component functions
- Complex conditional rendering logic
- Mixed server and client concerns

### Example

```tsx
// BAD: 350+ line component
export function TermDetail({ term }) {
  // Query 1
  const vocabQuery = useQuery(VOCAB_QUERY);
  // Query 2
  const grammarQuery = useQuery(GRAMMAR_QUERY);
  // Query 3
  const kanjiQuery = useQuery(KANJI_QUERY);

  // Inline component 1
  function VocabSection() { /* 80 lines */ }

  // Inline component 2
  function GrammarSection() { /* 80 lines */ }

  // Complex dispatch logic
  if (term.type === "vocab") return <VocabSection />;
  if (term.type === "grammar") return <GrammarSection />;
  // ... 5 more conditions
}
```

### Resolution

Split into separate files:
```
components/analyze/
├── TermDetail.tsx        # Dispatcher only (50 lines)
├── VocabEntryDetail.tsx  # Vocab with its query (90 lines)
├── GrammarEntryDetail.tsx
└── NameEntryDetail.tsx
```

---

## Anti-Pattern 2: Local Type Definitions

### Description

Defining interfaces and types inside component files instead of centralized type modules.

### Symptoms

```tsx
// BAD: In page.tsx or component file
interface VocabEntry {
  term: string;
  reading: string;
}

interface QueryData {
  vocab: VocabEntry[];
}
```

### Problems

- Type duplication across files
- Inconsistent definitions
- No single source of truth
- Hard to update when API changes

### Resolution

```tsx
// lib/types/vocab.ts
export interface VocabEntry {
  term: string;
  reading: string;
}

// In component
import type { VocabEntry } from "@/lib/types";
```

---

## Anti-Pattern 3: Magic Values

### Description

Hardcoded strings, colors, or configurations scattered throughout components.

### Symptoms

```tsx
// BAD: Magic values in component
function TokenDisplay({ token }) {
  const color = token.layer === "vocab"
    ? "bg-blue-100 dark:bg-blue-900/30"
    : token.layer === "grammar"
    ? "bg-green-100 dark:bg-green-900/30"
    : "bg-gray-100";

  return <div className={color}>{token.text}</div>;
}
```

### Problems

- Duplicated across components
- Inconsistent colors/labels
- Hard to update theme
- No type safety

### Resolution

```tsx
// lib/constants/colors.ts
export const LAYER_COLORS: Record<string, string> = {
  vocab: "bg-blue-100 dark:bg-blue-900/30",
  grammar: "bg-green-100 dark:bg-green-900/30",
};

// In component
import { LAYER_COLORS } from "@/lib/constants";
const color = LAYER_COLORS[token.layer] || "bg-gray-100";
```

---

## Anti-Pattern 4: Inline Field Selection

### Description

GraphQL queries with inline field lists instead of fragment references.

### Symptoms

```tsx
// BAD: Fields listed inline
const VOCAB_QUERY = gql`
  query GetVocab($term: String!) {
    vocab(term: $term) {
      term
      reading
      frequency
      definitions {
        dictName
        definitionText
        pos
        tags
      }
      sentences {
        japanese
        english
        source
      }
    }
  }
`;
```

### Problems

- Fields duplicated across queries
- Component data needs not colocated
- Hard to track what data components need
- Changes require updating multiple queries

### Resolution

```tsx
// lib/graphql/fragments/vocab.ts
export const VOCAB_DETAIL_FRAGMENT = gql`
  ${DEFINITION_FRAGMENT}
  ${SENTENCE_FRAGMENT}

  fragment VocabDetail on MergedVocab {
    term
    reading
    frequency
    definitions { ...DefinitionData }
    sentences { ...SentenceData }
  }
`;

// In page
const VOCAB_QUERY = gql`
  ${VOCAB_DETAIL_FRAGMENT}
  query GetVocab($term: String!) {
    vocab(term: $term) { ...VocabDetail }
  }
`;
```

---

## Anti-Pattern 5: Div Soup

### Description

Deeply nested `<div>` elements with inline Tailwind classes instead of semantic components.

### Symptoms

```tsx
// BAD: 6 levels of div nesting
<div className="min-h-screen p-8 bg-muted/20">
  <div className="max-w-5xl mx-auto">
    <div className="mb-8">
      <div className="flex items-baseline gap-4">
        <div className="text-5xl font-bold">{title}</div>
        <div className="text-3xl text-muted-foreground">{reading}</div>
      </div>
      <div className="mt-4 flex gap-3">{badges}</div>
    </div>
    <div className="space-y-6">
      {data.map(item => (
        <div className="p-4 border rounded-lg">
          <div className="text-lg font-medium">{item.title}</div>
          <div className="text-muted-foreground">{item.description}</div>
        </div>
      ))}
    </div>
  </div>
</div>
```

### Problems

- Hard to read and maintain
- No semantic meaning
- Duplicate layout patterns
- Inconsistent spacing/styling

### Resolution

```tsx
// GOOD: Semantic components
<ContentLayout>
  <DetailsHeader title={title} reading={reading} badges={badges} />
  <DetailSection title="Results">
    {data.map(item => (
      <ResultCard key={item.id} title={item.title} description={item.description} />
    ))}
  </DetailSection>
</ContentLayout>
```

---

## Anti-Pattern 6: Duplicated UI Patterns

### Description

Same visual pattern implemented multiple times across different components.

### Symptoms

```tsx
// In SearchPage.tsx
<Card className="hover:bg-accent transition-colors cursor-pointer">
  <CardHeader className="pb-2">
    <CardTitle className="text-2xl">{name}</CardTitle>
    <span className="text-muted-foreground">{reading}</span>
  </CardHeader>
  <CardContent>{description}</CardContent>
</Card>

// In AnalyzePage.tsx (nearly identical)
<Card className="hover:bg-accent transition-colors cursor-pointer">
  <CardHeader className="pb-2">
    <CardTitle className="text-2xl">{term}</CardTitle>
    <span className="text-muted-foreground">{reading}</span>
  </CardHeader>
  <CardContent>{definition}</CardContent>
</Card>
```

### Problems

- Inconsistent behavior when one is updated
- Bloated bundle size
- Harder to maintain consistent UX

### Resolution

Extract shared pattern:
```tsx
// components/search-results/ResultCard.tsx
export function ResultCard({ href, title, reading, description }) {
  return (
    <Link href={href}>
      <Card className="hover:bg-accent transition-colors cursor-pointer">
        <CardHeader className="pb-2">
          <CardTitle className="text-2xl">{title}</CardTitle>
          {reading && <span className="text-muted-foreground">{reading}</span>}
        </CardHeader>
        {description && <CardContent>{description}</CardContent>}
      </Card>
    </Link>
  );
}
```

---

## Anti-Pattern 7: Props Drilling Through Wrappers

### Description

Passing props through multiple wrapper components that don't use them.

### Symptoms

```tsx
// Layout passes props it doesn't use
function PageLayout({ children, vocab, onSelect, isLoading }) {
  return (
    <div className="container">
      <Header />
      <Content vocab={vocab} onSelect={onSelect} isLoading={isLoading}>
        {children}
      </Content>
    </div>
  );
}

// Content also just passes them through
function Content({ children, vocab, onSelect, isLoading }) {
  return (
    <main>
      <VocabSection vocab={vocab} onSelect={onSelect} isLoading={isLoading} />
      {children}
    </main>
  );
}
```

### Resolution

Use composition pattern:
```tsx
function PageLayout({ children }) {
  return (
    <div className="container">
      <Header />
      <main>{children}</main>
    </div>
  );
}

// Parent composes directly
<PageLayout>
  <VocabSection vocab={vocab} onSelect={onSelect} isLoading={isLoading} />
</PageLayout>
```

---

## Anti-Pattern 8: Mixed Server/Client Concerns

### Description

Combining server-side data fetching patterns with client-side interactivity in confusing ways.

### Symptoms

```tsx
// Confusing: Is this server or client?
export default function VocabPage({ params }) {
  const [selected, setSelected] = useState(null); // Client state
  const { data } = await getClient().query(...);  // Server fetch

  // But this needs client interactivity...
  return <button onClick={() => setSelected(data)}>{data.term}</button>;
}
```

### Resolution

Clear separation:
```tsx
// app/vocab/[term]/page.tsx - Server Component
export default async function VocabPage({ params }) {
  const { data } = await getClient().query(...);
  return <VocabContent vocab={data.vocab} />;
}

// components/VocabContent.tsx - Client Component
"use client";
export function VocabContent({ vocab }) {
  const [selected, setSelected] = useState(null);
  return <button onClick={() => setSelected(vocab)}>{vocab.term}</button>;
}
```

---

## Anti-Pattern 9: Untyped Props

### Description

Components with `any` types or missing type annotations.

### Symptoms

```tsx
// BAD: No types
function DefinitionCard({ definition }) {
  return <div>{definition.text}</div>;
}

// BAD: Using any
function DefinitionCard({ definition }: { definition: any }) {
  return <div>{definition.text}</div>;
}
```

### Problems

- No IDE autocomplete
- No compile-time errors
- Bugs caught only at runtime

### Resolution

```tsx
import type { SourcedDefinition } from "@/lib/types";

interface DefinitionCardProps {
  definition: SourcedDefinition;
}

function DefinitionCard({ definition }: DefinitionCardProps) {
  return <div>{definition.definitionText}</div>;
}
```

---

## Anti-Pattern 10: Side Effects in Render

### Description

Performing side effects directly in the component body or render function.

### Symptoms

```tsx
// BAD: Side effect in render
function VocabList({ terms }) {
  console.log("Rendering vocab list"); // Side effect!
  analytics.track("vocab_viewed");     // Side effect!

  return terms.map(t => <VocabCard key={t.id} term={t} />);
}
```

### Resolution

Use appropriate hooks:
```tsx
function VocabList({ terms }) {
  useEffect(() => {
    analytics.track("vocab_viewed");
  }, []);

  return terms.map(t => <VocabCard key={t.id} term={t} />);
}
```

---

## Detection Commands

### Find God Components (>150 lines)

```bash
find . -name "*.tsx" -exec awk 'END {if(NR>150) print FILENAME": "NR" lines"}' {} \;
```

### Find Local Type Definitions

```bash
grep -rn "^interface\|^type " --include="*.tsx" app/ components/
```

### Find Inline GraphQL Field Selection

```bash
grep -rn "gql\`" --include="*.tsx" -A 20 | grep -v "Fragment" | grep "{"
```

### Find Duplicated Patterns

```bash
# Find similar className patterns
grep -rn "className=\".*hover:bg-accent" --include="*.tsx"
```

### Find Components Without Types

```bash
grep -rn "}: {" --include="*.tsx" | grep -v "}: {"
```
