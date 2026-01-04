Guided refactoring with safety checks: $ARGUMENTS

## 1. Analyze Current Code

- Read the target file/function/module
- Understand its current behavior
- Identify refactoring opportunities:
  - Extract functions (reduce complexity)
  - Extract types/interfaces (improve reusability)
  - Replace conditionals with polymorphism
  - Remove duplication (DRY principle)
  - Simplify logic (reduce cognitive load)

## 2. Propose Refactoring Plan

Present the plan before making changes:

```markdown
## Refactoring Plan: <target>

### Current Issues
- Function too long (120 lines)
- Duplicated validation logic (3 places)
- Deep nesting (4 levels)

### Proposed Changes
1. Extract validation to `validateInput()` helper
2. Extract nested logic to `processItem()` helper
3. Replace if/else chain with strategy pattern

### Impact
- Files changed: 1
- New functions: 2
- Lines: 120 -> 80 (33% reduction)

### Safety
- Tests exist (will verify behavior unchanged)
- No API changes (internal refactor only)
```

## 3. Safety Checks

**Before refactoring**:
- [ ] Run all tests: Establish baseline
- [ ] Check test coverage: Ensure behavior is tested
- [ ] Review dependencies: Understand what depends on this code

**During refactoring**:
- [ ] Make small changes: One pattern at a time
- [ ] Run tests after each change: Catch regressions immediately
- [ ] Keep types: Don't change public APIs

**After refactoring**:
- [ ] Run full test suite: Verify all tests still pass
- [ ] Run type checker: Ensure type safety maintained
- [ ] Review diff: Ensure only intended changes

## 4. Red Flags (Don't Refactor)

**Stop if**:
- No tests exist (write tests first)
- Tests are failing (fix tests first)
- Code is actively being changed by others (coordinate)
- Deadline is tight (refactor after release)

## 5. Refactoring Patterns

### Extract Function
```python
# Before
def process(data):
    if not data: raise ValueError()
    if len(data) > 100: raise ValueError()
    result = []
    for item in data:
        if item.active:
            result.append(item.value * 2)
    return result

# After
def process(data):
    validate_data(data)
    return [process_item(item) for item in data if item.active]

def validate_data(data):
    if not data or len(data) > 100:
        raise ValueError("Invalid data")

def process_item(item):
    return item.value * 2
```

### Replace Conditionals
```python
# Before
def get_price(customer_type):
    if customer_type == "regular":
        return base_price
    elif customer_type == "premium":
        return base_price * 0.9
    elif customer_type == "vip":
        return base_price * 0.8

# After
PRICING = {
    "regular": lambda: base_price,
    "premium": lambda: base_price * 0.9,
    "vip": lambda: base_price * 0.8,
}

def get_price(customer_type):
    return PRICING[customer_type]()
```

## Workflow

1. **Read code** - Understand current behavior
2. **Identify smells** - Long functions, duplication, complexity
3. **Propose plan** - What to change and why
4. **Run tests** - Establish baseline (all passing)
5. **Make small change** - One pattern at a time
6. **Run tests** - Verify behavior unchanged
7. **Repeat** - Until refactoring complete
8. **Review diff** - Ensure clean changes
