Refactor $ARGUMENTS with these priorities:

1. **Readability** - Clear names, small functions, obvious flow
2. **Maintainability** - Single responsibility, loose coupling
3. **Testability** - Pure functions where possible, injectable dependencies
4. **Performance** - Only if there's an obvious win without sacrificing clarity

Constraints:
- Preserve existing behavior exactly (no feature changes)
- Keep changes minimal and focused
- Explain the reasoning for significant changes
