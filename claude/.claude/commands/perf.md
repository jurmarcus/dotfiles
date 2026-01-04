Performance analysis and optimization: $ARGUMENTS

## 1. Profile Before Optimizing

**Rule**: Never optimize without profiling. Measure first!

### Python Profiling
```python
import cProfile
import pstats

profiler = cProfile.Profile()
profiler.enable()
result = slow_function()
profiler.disable()

stats = pstats.Stats(profiler)
stats.sort_stats('cumtime')
stats.print_stats(10)  # Top 10 slowest
```

### TypeScript Profiling
```typescript
console.time('operation');
await slowOperation();
console.timeEnd('operation');

// Chrome DevTools: node --inspect app.ts
```

### Rust Profiling
```bash
cargo bench
cargo install flamegraph
cargo flamegraph --bin myapp
```

## 2. Common Performance Issues

### Algorithmic Complexity
- O(n^2) nested loops -> O(n) with hash map
- Repeated sorting -> single pass
- Linear search -> binary search or hash lookup

### Unnecessary Allocations
- Clone/copy when borrow works
- String concatenation in loops
- Not preallocating collections

### Database N+1 Queries
- Query in loop -> batch queries
- Missing indexes -> add indexes
- No joins -> use joins

### Synchronous I/O
- Blocking file reads -> async
- Sequential HTTP requests -> parallel

## 3. Optimization Techniques

### Caching
```python
from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_computation(n):
    return sum(i**2 for i in range(n))
```

### Lazy Evaluation
```typescript
function* lazyMap<T, U>(items: T[], fn: (item: T) => U) {
    for (const item of items) {
        yield fn(item);
    }
}
```

### Parallel Processing
```rust
use rayon::prelude::*;

fn process_parallel(items: &[Item]) -> Vec<Result> {
    items.par_iter()
        .map(process_item)
        .collect()
}
```

## 4. Performance Checklist

**Before Optimizing**:
- [ ] Profile to find bottleneck
- [ ] Set performance goal (e.g., "< 100ms")
- [ ] Write benchmark
- [ ] Ensure tests pass

**During Optimization**:
- [ ] Change one thing at a time
- [ ] Benchmark after each change
- [ ] Keep tests passing

**After Optimization**:
- [ ] Verify performance goal met
- [ ] Check memory usage
- [ ] Review code readability

## 5. Anti-Patterns

**Don't**:
- Optimize without profiling (premature optimization)
- Sacrifice readability for 1% speedup
- Break tests to make code faster

**Do**:
- Profile first, optimize second
- Focus on algorithmic improvements
- Benchmark before/after
