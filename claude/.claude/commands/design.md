Create detailed implementation plan for: $ARGUMENTS

## 1. Understand the Request

- Clarify requirements if ambiguous
- Identify scope and constraints
- List acceptance criteria
- Note any dependencies

## 2. Analyze Current State

- Read relevant existing code
- Understand current architecture
- Identify patterns already in use
- Find similar implementations to reference

## 3. Create Implementation Plan

Write to `~/plans/<feature-name>.md` with this structure:

```markdown
# Plan: <Feature Name>

## Status: draft | in-progress | complete

## Goal
[One paragraph describing what we're building and why]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## Current State Analysis

### Existing Patterns
- [Pattern 1]: [Where it's used]
- [Pattern 2]: [Where it's used]

### Files to Modify
| File | Changes |
|------|---------|
| `path/to/file.ts` | [Description] |

### Files to Create
| File | Purpose |
|------|---------|
| `path/to/new.ts` | [Description] |

---

## Implementation Phases

### Phase 1: [Name]
**Goal**: [What this phase accomplishes]

#### Steps
1. [Step with specific file and code changes]
2. [Step with specific file and code changes]

#### Validation
- [ ] [How to verify this phase works]

### Phase 2: [Name]
...

---

## Technical Decisions

### Decision 1: [Title]
**Options**:
- Option A: [Pros/Cons]
- Option B: [Pros/Cons]

**Chosen**: [Option] because [reason]

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk] | Low/Med/High | Low/Med/High | [Strategy] |

---

## Testing Strategy

- Unit tests: [What to test]
- Integration tests: [What to test]
- Manual validation: [Steps]
```

## 4. Review with User

Present the plan summary and ask:
- "Does this match your vision?"
- "Any constraints I should know about?"
- "Ready to start Phase 1?"

## Important Rules

- Plans go in `~/plans/` directory
- Be specific - include file paths and code snippets
- Break into small, testable phases
- Each phase should be independently verifiable
- Include rollback strategy for risky changes
