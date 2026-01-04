Scan codebase for dead code: $ARGUMENTS

## What This Command Does

Performs a comprehensive scan of the codebase to find:
- Unused imports
- Unused variables and functions
- Unused exports (TypeScript)
- Unreachable code
- Unused dependencies

## Scan Process

### 1. Detect Project Type

Check for project markers:
- `pyproject.toml` → Python project
- `package.json` → TypeScript/JavaScript project
- `Cargo.toml` → Rust project

### 2. Run Language-Specific Analysis

**Python** (using ruff):
```bash
uvx ruff check --select=F401,F841,F811,F821,F823 .
```
- F401: Unused imports
- F841: Unused variables
- F811: Redefinition of unused name
- F821: Undefined name
- F823: Local variable referenced before assignment

**TypeScript** (using knip):
```bash
bunx knip
```
Detects:
- Unused files
- Unused exports
- Unused dependencies
- Duplicate exports

**Rust** (using cargo):
```bash
cargo clippy -- -W dead_code -W unused_imports -W unused_variables
```

### 3. Output Format

```markdown
# Dead Code Report

## Summary
- **Python**: 12 issues found
- **TypeScript**: 5 unused exports
- **Rust**: 3 dead code warnings

## Python Issues

### Unused Imports (F401)
| File | Line | Import |
|------|------|--------|
| src/utils.py | 3 | `os` |
| src/parser.py | 7 | `json` |

### Unused Variables (F841)
| File | Line | Variable |
|------|------|----------|
| src/main.py | 42 | `temp_result` |

## TypeScript Issues

### Unused Exports
| File | Export |
|------|--------|
| src/utils.ts | `formatDate` |
| src/api.ts | `legacyEndpoint` |

### Unused Dependencies
| Package | Type |
|---------|------|
| lodash | dependency |
| @types/node | devDependency |

## Rust Issues

| File | Line | Warning |
|------|------|---------|
| src/lib.rs | 45 | function `old_parser` is never used |

## Recommendations

1. **Safe to remove**: Unused imports and variables
2. **Review first**: Unused exports (may be public API)
3. **Check tests**: Unused functions might be tested elsewhere
```

## Optional Scope

If $ARGUMENTS is provided, limit scan to that path:
- `/deadcode src/` - Scan only src directory
- `/deadcode src/utils.py` - Scan single file

## After Scan

1. **Review each issue** - Some "unused" code may be intentional (public API, future use)
2. **Remove obvious dead code** - Unused imports, unreachable code
3. **Document kept code** - If keeping unused code, add comment explaining why
4. **Run tests** - Verify removal didn't break anything
