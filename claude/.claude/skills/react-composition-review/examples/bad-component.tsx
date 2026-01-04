/**
 * BAD EXAMPLE: Component with multiple anti-patterns
 *
 * Anti-patterns demonstrated:
 * 1. Local type definitions (should be in lib/types/)
 * 2. Magic color values (should be in lib/constants/)
 * 3. Inline GraphQL fields (should use fragments)
 * 4. Div soup (should use semantic components)
 * 5. Duplicated card pattern (should use ResultCard)
 * 6. God component (multiple concerns in one file)
 */

import { gql } from "@apollo/client";
import { useQuery } from "@apollo/client/react";
import Link from "next/link";

// BAD: Local type definitions - should be in lib/types/
interface VocabEntry {
  term: string;
  reading: string | null;
  definitionText: string | null;
  frequency: number | null;
}

interface GrammarEntry {
  pattern: string;
  reading: string | null;
  meaning: string | null;
  jlpt: number | null;
}

interface NameEntry {
  name: string;
  reading: string | null;
  nameType: string;
}

// BAD: Inline field selection - should use fragments
const SEARCH_QUERY = gql`
  query SearchAll($query: String!) {
    searchVocab(query: $query) {
      term
      reading
      definitionText
      frequency
    }
    searchGrammar(query: $query) {
      pattern
      reading
      meaning
      jlpt
    }
    searchNames(query: $query) {
      name
      reading
      nameType
    }
  }
`;

// BAD: Magic values - should be in lib/constants/
const NAME_TYPE_LABELS = {
  surname: "Surname",
  given: "Given Name",
  place: "Place",
};

export function SearchResults({ query }: { query: string }) {
  const { loading, error, data } = useQuery(SEARCH_QUERY, {
    variables: { query },
  });

  // BAD: Inline loading state - should use shared component
  if (loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse bg-gray-200 h-32 rounded" />
      </div>
    );
  }

  // BAD: Inline error state - should use shared component
  if (error) {
    return (
      <div className="p-8">
        <p className="text-red-500">Error loading results</p>
      </div>
    );
  }

  return (
    // BAD: Div soup - should use ContentLayout
    <div className="min-h-screen p-8 bg-gray-50">
      <div className="max-w-5xl mx-auto">
        <div className="mb-8">
          <h1 className="text-4xl font-bold">Search Results</h1>
          <p className="text-gray-600">
            Found {data.searchVocab.length + data.searchGrammar.length} results
          </p>
        </div>

        {/* BAD: Inline card rendering - should use VocabResultCard */}
        <div className="space-y-4 mb-8">
          <h2 className="text-2xl font-semibold">Vocabulary</h2>
          {data.searchVocab.map((vocab: VocabEntry, i: number) => (
            <Link key={i} href={`/vocab/${encodeURIComponent(vocab.term)}`}>
              {/* BAD: Duplicated card pattern */}
              <div className="p-5 bg-white rounded-lg border hover:shadow-md transition-shadow cursor-pointer">
                <div className="flex items-baseline gap-3 mb-2">
                  <span className="text-xl font-semibold">{vocab.term}</span>
                  {vocab.reading && (
                    <span className="text-base text-gray-500">{vocab.reading}</span>
                  )}
                  {vocab.frequency && (
                    // BAD: Magic color value
                    <span className="ml-auto px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
                      #{vocab.frequency}
                    </span>
                  )}
                </div>
                {vocab.definitionText && (
                  <p className="text-gray-600">{vocab.definitionText}</p>
                )}
              </div>
            </Link>
          ))}
        </div>

        {/* BAD: Nearly identical pattern repeated for grammar */}
        <div className="space-y-4 mb-8">
          <h2 className="text-2xl font-semibold">Grammar</h2>
          {data.searchGrammar.map((grammar: GrammarEntry, i: number) => (
            <Link key={i} href={`/grammar/${encodeURIComponent(grammar.pattern)}`}>
              {/* BAD: Same card pattern duplicated */}
              <div className="p-5 bg-white rounded-lg border hover:shadow-md transition-shadow cursor-pointer">
                <div className="flex items-baseline gap-3 mb-2">
                  <span className="text-xl font-semibold">{grammar.pattern}</span>
                  {grammar.reading && (
                    <span className="text-base text-gray-500">{grammar.reading}</span>
                  )}
                  {grammar.jlpt && (
                    // BAD: Magic color value
                    <span className="ml-auto px-2 py-1 text-xs bg-green-100 text-green-800 rounded">
                      N{grammar.jlpt}
                    </span>
                  )}
                </div>
                {grammar.meaning && (
                  <p className="text-gray-600">{grammar.meaning}</p>
                )}
              </div>
            </Link>
          ))}
        </div>

        {/* BAD: Yet another duplicated pattern */}
        <div className="space-y-4">
          <h2 className="text-2xl font-semibold">Names</h2>
          {data.searchNames.map((name: NameEntry, i: number) => (
            <Link key={i} href={`/names/${encodeURIComponent(name.name)}`}>
              <div className="p-5 bg-white rounded-lg border hover:shadow-md transition-shadow cursor-pointer">
                <div className="flex items-baseline gap-3 mb-2">
                  <span className="text-xl font-semibold">{name.name}</span>
                  {name.reading && (
                    <span className="text-base text-gray-500">{name.reading}</span>
                  )}
                  <span className="ml-auto px-2 py-1 text-xs bg-purple-100 text-purple-800 rounded">
                    {NAME_TYPE_LABELS[name.nameType as keyof typeof NAME_TYPE_LABELS] || name.nameType}
                  </span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}

/**
 * REFACTORING RECOMMENDATIONS:
 *
 * 1. Move types to lib/types/
 *    - VocabEntry → lib/types/vocab.ts
 *    - GrammarEntry → lib/types/grammar.ts
 *    - NameEntry → lib/types/names.ts
 *
 * 2. Move constants to lib/constants/
 *    - NAME_TYPE_LABELS → lib/constants/labels.ts
 *
 * 3. Create GraphQL fragments
 *    - VOCAB_SEARCH_FRAGMENT in lib/graphql/fragments/vocab.ts
 *    - GRAMMAR_SEARCH_FRAGMENT in lib/graphql/fragments/grammar.ts
 *    - NAME_SEARCH_FRAGMENT in lib/graphql/fragments/names.ts
 *
 * 4. Extract result card components
 *    - VocabResultCard in components/search-results/
 *    - GrammarResultCard
 *    - NameResultCard
 *
 * 5. Use shared loading/error components
 *    - QueryLoading, QueryError from components/ui/
 *
 * 6. Use layout components
 *    - ContentLayout wrapper
 *    - DetailSection for each category
 */
