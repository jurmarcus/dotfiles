---
name: React Composition Review
description: This skill should be used when the user asks to "review React components", "check component composition", "audit React patterns", "find God components", "check for compositional patterns", or wants to ensure React code follows functional programming, fragment colocation, and single responsibility principles.
version: 1.0.0
---

# React Composition Review

Review React components to ensure they follow compositional patterns, functional programming principles, and single responsibility. Identify anti-patterns and suggest refactoring opportunities.

## When to Use

Invoke this skill when:
- Reviewing new or existing React components
- Auditing a codebase for compositional patterns
- Checking if components follow project conventions
- Looking for "God components" that need decomposition
- Verifying GraphQL fragment colocation

## Review Process

### Step 1: Identify Component Scope

Determine what to review:
- Single component file
- Component directory
- Entire frontend codebase

For codebase-wide reviews, start with the largest files:
```bash
find . -name "*.tsx" -exec wc -l {} + | sort -rn | head -20
```

### Step 2: Check Against Anti-Patterns

Review each component for these anti-patterns:

#### Anti-Pattern 1: God Components (>150 lines)

**Symptoms:**
- Single file handling multiple concerns
- Multiple GraphQL queries in one component
- Inline sub-components that should be extracted
- Mixed data fetching, state, and presentation

**Detection:**
```bash
# Find files over 150 lines
find . -name "*.tsx" -exec awk 'END {if(NR>150) print FILENAME": "NR" lines"}' {} \;
```

**Resolution:** Decompose into focused, single-responsibility components.

#### Anti-Pattern 2: Inline Type Definitions

**Symptoms:**
```tsx
// BAD: Types defined in component file
interface VocabEntry {
  term: string;
  reading: string;
}

export function VocabCard({ vocab }: { vocab: VocabEntry }) { ... }
```

**Detection:** Search for `interface` or `type` definitions in page/component files.

**Resolution:** Move types to centralized `lib/types/` directory:
```tsx
// GOOD: Import from centralized types
import type { VocabEntry } from "@/lib/types";
```

#### Anti-Pattern 3: Duplicated Constants

**Symptoms:**
```tsx
// BAD: Colors defined in multiple files
const LAYER_COLORS = { vocab: "blue", grammar: "green" };
```

**Detection:** Search for repeated object literals across files.

**Resolution:** Extract to `lib/constants/`:
```tsx
// GOOD: Import from centralized constants
import { LAYER_COLORS } from "@/lib/constants";
```

#### Anti-Pattern 4: Inline GraphQL Field Selection

**Symptoms:**
```tsx
// BAD: Fields listed inline, duplicated across queries
const QUERY = gql`
  query GetVocab($term: String!) {
    vocab(term: $term) {
      term
      reading
      definitions { dictName definitionText }
    }
  }
`;
```

**Detection:** Look for queries without fragment references.

**Resolution:** Use fragment colocation:
```tsx
// GOOD: Fragment defines data needs
const QUERY = gql`
  ${VOCAB_DETAIL_FRAGMENT}
  query GetVocab($term: String!) {
    vocab(term: $term) {
      ...VocabDetail
    }
  }
`;
```

#### Anti-Pattern 5: Div Soup

**Symptoms:**
```tsx
// BAD: Nested divs with inline styling
<div className="p-8">
  <div className="max-w-5xl">
    <div className="mb-8">
      <div className="text-4xl">{title}</div>
    </div>
  </div>
</div>
```

**Detection:** Count nested `<div>` elements without semantic meaning.

**Resolution:** Extract to semantic components:
```tsx
// GOOD: Composed from semantic components
<ContentLayout>
  <DetailsHeader title={title} reading={reading} />
  <DetailSection title="Definitions">
    <DefinitionList definitions={definitions} />
  </DetailSection>
</ContentLayout>
```

#### Anti-Pattern 6: Duplicated UI Patterns

**Symptoms:**
- Same card layout repeated across pages
- Identical loading/error states in multiple components
- Copy-pasted rendering logic

**Detection:** Search for similar JSX structures across files.

**Resolution:** Extract to shared components with props for variation.

### Step 3: Verify Positive Patterns

Check that components follow these patterns:

#### Pattern 1: Fragment Colocation

Components that need data should define their fragments:
```tsx
// Component defines its data needs
export const VOCAB_CARD_FRAGMENT = gql`
  fragment VocabCardData on Vocab {
    term
    reading
    frequency
  }
`;

// Fragment is exported for parent queries
export { VOCAB_CARD_FRAGMENT };
```

#### Pattern 2: Pure Functional Components

Components should be pure functions: props in, JSX out:
```tsx
// GOOD: Pure component
export function DefinitionList({ definitions }: { definitions: SourcedDefinition[] }) {
  return (
    <div className="space-y-6">
      {definitions.map((def, i) => (
        <DefinitionCard key={i} definition={def} />
      ))}
    </div>
  );
}
```

#### Pattern 3: Composition Over Inheritance

Build complex UIs by composing simple components:
```tsx
// GOOD: Page composed from building blocks
<DictionaryPage>
  <PageHeader title={title} badges={badges} />
  <DetailSection title="Definitions">
    <DefinitionList definitions={definitions} />
  </DetailSection>
</DictionaryPage>
```

#### Pattern 4: Single Responsibility

Each component file should have one clear purpose:
- `DefinitionList.tsx` - renders definition lists
- `VocabResultCard.tsx` - renders vocab search results
- `EntryDetailHeader.tsx` - renders entry detail headers

#### Pattern 5: Centralized Imports

All shared resources imported from central locations:
```tsx
import type { VocabEntry, GrammarDetail } from "@/lib/types";
import { LAYER_COLORS, NAME_TYPE_LABELS } from "@/lib/constants";
import { VOCAB_DETAIL_FRAGMENT } from "@/lib/graphql/fragments";
```

### Step 4: Generate Report

After review, produce a structured report:

```markdown
## Component Review: [Component/Directory Name]

### Summary
- Files reviewed: X
- Issues found: Y
- Severity: Low/Medium/High

### Issues

#### [Issue 1: God Component]
- **File:** `path/to/file.tsx`
- **Lines:** 352
- **Problem:** Multiple concerns in single file
- **Recommendation:** Split into VocabEntryDetail, GrammarEntryDetail, etc.

#### [Issue 2: Inline Types]
- **File:** `path/to/file.tsx`
- **Lines:** 15-25
- **Problem:** Local interface definition
- **Recommendation:** Move to lib/types/vocab.ts

### Positive Patterns Found
- Fragment colocation in DefinitionList
- Pure functional components throughout
- Consistent use of centralized constants

### Recommended Actions
1. [Priority] Decompose TermDetail.tsx (352 lines → 5 files)
2. [Medium] Extract inline types from search page
3. [Low] Add missing fragments to names queries
```

## Quick Checklist

For rapid component review, check these items:

- [ ] Component under 150 lines
- [ ] No local interface/type definitions (use lib/types/)
- [ ] No local constant objects (use lib/constants/)
- [ ] GraphQL uses fragments, not inline fields
- [ ] No deeply nested divs (use semantic components)
- [ ] Props are typed with centralized types
- [ ] Component has single, clear responsibility
- [ ] Loading/error states use shared components
- [ ] Exports fragment if component needs data

## Additional Resources

### Reference Files
- **`references/patterns.md`** - Detailed compositional patterns with examples
- **`references/anti-patterns.md`** - Extended anti-pattern catalog

### Examples
- **`examples/good-component.tsx`** - Well-structured component
- **`examples/bad-component.tsx`** - Component needing refactoring
