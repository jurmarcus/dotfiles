Generate comprehensive tests for code: $ARGUMENTS

## 1. Understand the Code

- Read the target file/function
- Identify all public APIs, functions, classes, methods
- Understand expected behavior, edge cases, and error conditions
- Check existing tests to avoid duplication

## 2. Determine Test Framework

Auto-detect based on project structure:

**Python**:
- pytest (preferred if pyproject.toml exists)
- unittest (fallback)

**TypeScript**:
- Jest (if jest.config.js exists)
- Vitest (if vite.config.ts exists)
- Node test runner (fallback)

**Rust**:
- Built-in `#[test]` and `#[cfg(test)]`

## 3. Generate Test Cases

Create tests for:
- Happy path (expected inputs -> expected outputs)
- Edge cases (boundary values, empty inputs, null/None)
- Error conditions (invalid inputs, exceptions)
- Integration tests (if function interacts with other modules)

## 4. Test Structure

**Python (pytest)**:
```python
import pytest
from module import function_to_test

def test_happy_path():
    result = function_to_test(valid_input)
    assert result == expected_output

def test_edge_case_empty_input():
    with pytest.raises(ValueError):
        function_to_test("")

@pytest.mark.parametrize("input,expected", [
    (1, "one"),
    (2, "two"),
])
def test_parametrized(input, expected):
    assert function_to_test(input) == expected
```

**TypeScript (Jest/Vitest)**:
```typescript
import { describe, it, expect } from '@jest/globals';
import { functionToTest } from './module';

describe('functionToTest', () => {
  it('should handle happy path', () => {
    expect(functionToTest(validInput)).toBe(expectedOutput);
  });

  it('should handle edge cases', () => {
    expect(() => functionToTest('')).toThrow();
  });

  it.each([
    [1, 'one'],
    [2, 'two'],
  ])('should handle input %p', (input, expected) => {
    expect(functionToTest(input)).toBe(expected);
  });
});
```

**Rust**:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_happy_path() {
        let result = function_to_test(valid_input);
        assert_eq!(result, expected_output);
    }

    #[test]
    #[should_panic(expected = "invalid input")]
    fn test_invalid_input() {
        function_to_test(invalid_input);
    }
}
```

## 5. Run Tests

After generating tests:
- Write test file to appropriate location
- Run tests to verify they pass
- If tests fail, fix the test code (not the source code, unless there's a bug)

## 6. Coverage Report

Summarize what was tested:
- List all test cases created
- Note any edge cases that couldn't be tested
- Suggest additional tests if needed

## Best Practices

- **Test names are documentation**: Use descriptive names
- **One assertion per test**: Easier to debug failures
- **Arrange-Act-Assert** (AAA) pattern
- **Mock external dependencies**: Don't hit real APIs/databases
- **Fast tests**: Tests should run in milliseconds
