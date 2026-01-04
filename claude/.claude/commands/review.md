Review code for bugs, patterns, and improvements: $ARGUMENTS

## Review Checklist

### 1. Correctness
- **Bugs**: Logic errors, off-by-one errors, race conditions
- **Type safety**: Unsafe casts, missing null/None checks, type mismatches
- **Error handling**: Unhandled errors, swallowed exceptions, panic paths
- **Edge cases**: Empty inputs, boundary values, concurrent access

### 2. Security
- **Injection vulnerabilities**: SQL injection, XSS, command injection
- **Authentication/Authorization**: Missing checks, privilege escalation
- **Secrets**: Hardcoded credentials, API keys in code
- **Resource exhaustion**: Memory leaks, unbounded loops, DoS vectors

### 3. Performance
- **Algorithmic complexity**: O(n^2) where O(n) possible
- **Unnecessary allocations**: Clone/copy when borrow/reference works
- **Database queries**: N+1 queries, missing indexes
- **Caching**: Repeated expensive computations

### 4. Code Quality
- **DRY violations**: Duplicated logic, copy-paste code
- **Complexity**: Functions > 50 lines, deep nesting (>3 levels)
- **Naming**: Unclear variable names, inconsistent conventions
- **Comments**: Missing docstrings, outdated comments

### 5. Best Practices

**Python**:
- Use type hints everywhere
- Prefer composition over inheritance
- Use `with` for resource management
- Avoid mutable default arguments

**TypeScript**:
- Enable strict mode
- Prefer `const` over `let`
- Use discriminated unions
- Avoid `any` type

**Rust**:
- Prefer borrowing over cloning
- Use iterators instead of loops
- Avoid `unwrap()` in production
- Use `Result<T, E>` for errors

## Review Output Format

```markdown
# Code Review: <file>

## Critical Issues (Must Fix)
- **Line 42**: SQL injection vulnerability
  ```
  // BAD
  query(&format!("SELECT * FROM users WHERE id = {}", user_id))

  // GOOD
  query("SELECT * FROM users WHERE id = $1").bind(user_id)
  ```

## Warnings (Should Fix)
- **Line 78**: Potential null pointer dereference
- **Line 112**: O(n^2) complexity, use HashSet instead

## Suggestions (Nice to Have)
- **Line 23**: Consider extracting to helper function

## Good Practices
- Type safety: All functions have type annotations
- Testing: Comprehensive test coverage

## Summary
- Critical: 1
- Warnings: 2
- Suggestions: 2
- Overall: **Needs revision** (fix critical issues before merging)
```

## Review Process

1. **Read the entire file** - Understand context before reviewing
2. **Check against checklist** - Systematically review each category
3. **Prioritize issues** - Critical > Warnings > Suggestions
4. **Provide examples** - Show bad code and good code
5. **Be constructive** - Explain *why* something is an issue
6. **Acknowledge good code** - Highlight well-written sections
