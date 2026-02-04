Update documentation after code changes: $ARGUMENTS

## 1. Identify Changes

- Run `sl status` to see modified files
- Run `sl diff` to see what changed
- Categorize changes:
  - Architecture (new patterns, structure changes)
  - API changes (new functions, changed signatures)
  - Dependencies (new libraries, version updates)
  - UI/UX changes (user-facing features)

## 2. Determine Documentation Scope

| Change Type | Update These Docs |
|-------------|-------------------|
| New component/module | CLAUDE.md (architecture) |
| API changes | README.md (usage examples) |
| New patterns | CLAUDE.md (coding standards) |
| Dependencies | README.md (setup/install) |
| CLI commands | CLAUDE.md (quick reference) |

## 3. Update CLAUDE.md

**CLAUDE.md** is the single source of truth for development patterns and architecture.

Sections to update:
- Architecture Overview
- Coding Standards
- Quick Reference
- Common Tasks
- Tech Stack

## 4. Update README.md

**README.md** is for users and contributors.

Sections to update:
- Installation
- Usage
- Examples
- API Reference

## 5. Update Code Documentation

**Python** (docstrings):
```python
def function(param: str) -> int:
    """One-line summary.

    Args:
        param: Description of param

    Returns:
        Description of return value
    """
```

**TypeScript** (JSDoc):
```typescript
/**
 * One-line summary.
 *
 * @param param - Description of param
 * @returns Description of return value
 */
```

**Rust** (doc comments):
```rust
/// One-line summary.
///
/// # Arguments
/// * `param` - Description of param
///
/// # Returns
/// Description of return value
pub fn my_function(param: &str) -> usize {
```

## 6. Check for Drift

Compare code and docs for inconsistencies:
- Function signatures in README don't match actual code
- Removed features still documented
- New features not documented

## Workflow

1. Read sl diff to understand changes
2. Update CLAUDE.md for architecture/patterns
3. Update README.md for user-facing changes
4. Update code docstrings for new functions
5. Verify examples still work
