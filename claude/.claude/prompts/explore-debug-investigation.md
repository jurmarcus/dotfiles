# Debug Investigation

> Systematic bug investigation without touching code — gather evidence first | Model: default | Agents: 0

---

I'm seeing [DESCRIBE_SYMPTOM]. Investigate this systematically without making any changes.
Follow this investigation protocol:

## Step 1: Reproduce & Characterize

- What exactly is the observed behavior vs expected behavior?
- Is it deterministic or intermittent?
- When did it start? (check recent commits with `sl log -n 20`)
- What's the minimal reproduction case?

## Step 2: Trace the Execution Path

Starting from the entry point that triggers the bug:
1. Trace the code path that handles this case
2. At each function boundary, note: what goes in, what comes out, what could go wrong
3. Identify the exact line where behavior diverges from expectation
4. Check error handling — is an error being swallowed somewhere?

## Step 3: Check the Usual Suspects

- **State mutation**: Is shared state being modified unexpectedly?
- **Race condition**: Are concurrent operations interfering?
- **Type coercion**: Is a type being silently converted? (especially null/undefined/None)
- **Off-by-one**: Array indexing, loop bounds, string slicing
- **Stale cache**: Is a cached value not being invalidated?
- **Environment**: Different behavior in dev vs prod? Check env vars with direnv.
- **Dependency version**: Did a dependency update change behavior?

## Step 4: Gather Evidence

Before proposing a fix, present:
1. **Root cause**: The specific line(s) and condition that causes the bug
2. **Evidence**: Why you believe this is the cause (trace output, code analysis)
3. **Blast radius**: What else could be affected by this code path
4. **Fix options**: 2-3 approaches with trade-offs

Do NOT fix anything until I approve an approach.

---

## Notes

- **"Without making any changes"**: Forces thorough investigation before jumping to fixes. The most common debugging mistake is guessing and patching.
- **Trace-based approach**: Following actual execution paths catches bugs that "reading the code" misses — especially interaction bugs between modules.
- **"Usual suspects" checklist**: These categories cover ~80% of bugs. The checklist prevents tunnel vision on one hypothesis.
- **Evidence before fix**: Requiring root cause + evidence prevents "fix the symptom, not the cause" patches.
- **Multiple fix options**: The first fix idea is often not the best. Presenting options with trade-offs leads to better decisions.
