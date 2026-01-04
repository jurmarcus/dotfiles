/**
 * GOOD EXAMPLE: Well-structured component following compositional patterns
 *
 * This component demonstrates:
 * - Fragment colocation
 * - Centralized types
 * - Single responsibility
 * - Pure functional approach
 * - Composition over inline logic
 */

import { gql } from "@apollo/client";
import { ResultCard } from "./ResultCard";
import { FrequencyBadge } from "@/components/dictionary";
import type { VocabSearchResult } from "@/lib/types";

// Fragment is colocated with component - defines data needs
export const VOCAB_RESULT_FRAGMENT = gql`
  fragment VocabResultData on VocabSearchResult {
    term
    reading
    definitionText
    pos
    frequency
  }
`;

interface VocabResultCardProps {
  result: VocabSearchResult;
}

/**
 * Search result card for vocabulary entries.
 *
 * Key patterns demonstrated:
 * 1. Uses centralized type (VocabSearchResult from lib/types)
 * 2. Composes from base component (ResultCard)
 * 3. Single responsibility - only renders vocab results
 * 4. Exports fragment for parent queries
 * 5. Pure function - props in, JSX out
 */
export function VocabResultCard({ result }: VocabResultCardProps) {
  return (
    <ResultCard
      href={`/vocab/${encodeURIComponent(result.term)}`}
      title={result.term}
      reading={result.reading}
      badges={
        <>
          {result.pos && (
            <span className="text-xs text-muted-foreground">{result.pos}</span>
          )}
          {result.frequency && <FrequencyBadge frequency={result.frequency} />}
        </>
      }
      description={result.definitionText}
    />
  );
}

// Re-export fragment for parent queries to compose
export { VOCAB_RESULT_FRAGMENT };
