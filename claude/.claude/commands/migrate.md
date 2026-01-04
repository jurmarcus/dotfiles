Migrate code from one pattern/library to another: $ARGUMENTS

## 1. Assess Migration Scope

### Identify What's Changing
- Old pattern/library/API
- New pattern/library/API
- All files affected
- Dependencies involved

### Risk Assessment
```
Migration: [from] -> [to]

Files affected: X
Lines of code: ~Y
Risk level: Low/Medium/High

Breaking changes:
- [ ] API changes
- [ ] Type changes
- [ ] Behavior changes
- [ ] Config changes
```

## 2. Create Migration Plan

### Preparation
- [ ] Document current behavior
- [ ] Write tests for current behavior (if missing)
- [ ] Create feature branch
- [ ] Set up new dependency (if applicable)

### Migration Phases

**Phase 1: Parallel Implementation**
- Add new implementation alongside old
- Both work simultaneously
- No breaking changes

**Phase 2: Gradual Switchover**
- Migrate one component/file at a time
- Verify after each migration
- Keep old code as fallback

**Phase 3: Cleanup**
- Remove old implementation
- Remove compatibility shims
- Update documentation

## 3. Execute Migration

For each file:

```
path/to/file.ts

Before:
[code snippet showing old pattern]

After:
[code snippet showing new pattern]

Changes:
- [Specific change 1]
- [Specific change 2]
```

### Verification Checklist
After each file:
- [ ] Types pass (`tsc --noEmit` / `cargo check` / `pyright`)
- [ ] Tests pass
- [ ] Behavior unchanged

## 4. Common Migrations

### TypeScript
- any -> proper types
- namespace -> ES modules
- enum -> const objects

### Rust
- unwrap -> proper error handling
- String -> &str where possible
- Vec -> iterators

### Python
- sync -> async
- requests -> httpx
- dict -> dataclass/Pydantic

## 5. Rollback Plan

Always have a way back:
- Keep old code in git history
- Document revert commands
- Test rollback before completing

## Important Rules

- **Never migrate without tests** - add them first if missing
- **One file at a time** - verify each before moving on
- **Preserve behavior** - refactoring, not rewriting
- **Commit frequently** - small, atomic commits
- Ask before starting: "Ready to begin migration?"
