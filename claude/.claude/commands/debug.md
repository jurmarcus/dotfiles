Investigate and diagnose issue without fixing: $ARGUMENTS

Your goal is to **understand** the problem, not fix it yet.

## 1. Reproduce the Issue

- Understand what the user is describing
- Find relevant code paths
- Identify how to trigger the issue
- Document reproduction steps

## 2. Gather Evidence

### Code Analysis
- Read the relevant source files
- Trace the execution path
- Identify all functions/modules involved
- Look for recent changes (`sl log -p <file>`)

### Error Analysis
- Parse error messages carefully
- Check stack traces for root cause
- Look for similar issues in the codebase
- Search for related TODO/FIXME comments

### State Analysis
- What inputs trigger this?
- What state is required?
- Are there race conditions?
- Any timing dependencies?

## 3. Form Hypotheses

List **all possible causes** ranked by likelihood:

```
High likelihood:
1. [Hypothesis] - [Evidence supporting it]

Medium likelihood:
2. [Hypothesis] - [Evidence]

Low likelihood:
3. [Hypothesis] - [Evidence]
```

## 4. Present Findings

Summarize in this format:

```
## Issue Summary
[One sentence description]

## Root Cause
[What's actually happening and why]

## Evidence
- [File:line] - [What it shows]

## Recommended Fix
[High-level approach, not implementation]

## Risk Assessment
- Complexity: Low/Medium/High
- Regression risk: Low/Medium/High
- Files affected: [list]
```

## Important Rules

- **DO NOT fix the issue** - only investigate
- Be thorough - check all related code
- Consider edge cases and race conditions
- Look at sl history for context
- Ask clarifying questions if needed

After presenting findings, ask: "Should I proceed with the fix?"
