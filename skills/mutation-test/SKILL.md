---
name: mutation-test
description: Use when you want to verify that tests actually catch bugs — injects five targeted mutations into a file and checks whether tests fail, exposing gaps in test coverage
---

# mutation-test

## Overview

Proves tests are real by injecting subtle source mutations and checking whether the test suite catches them. A mutation that survives (tests stay green) exposes a real coverage gap. Always reverts each mutation before applying the next.

## When to Use

- "Are these tests actually testing anything?"
- Before marking coverage complete on a critical file
- After writing tests, to verify they'd catch regressions

**Not for:** measuring line coverage (use your coverage tool). This tests the *quality* of assertions, not which lines are executed.

## Core Pattern

### Step 1 — Setup

```bash
# Read the target file
cat <TARGET_FILE> | head -120

# Find its test files (look for *.test.*, *.spec.*, test_*.py, etc.)
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" \) \
  | xargs grep -l "<basename of TARGET_FILE>" 2>/dev/null | head -5

# Detect test runner and confirm baseline is GREEN before mutating
```

Run the test suite. Record that it passes. **Do not proceed if baseline is failing.**

### Step 2 — Inject mutations, one at a time

For each mutation: apply → run tests → record result → **revert before the next one**.

Pick the 5 that apply to this file:

1. Flip a comparison: `>` → `>=` (or `<` → `<=`)
2. Flip an arithmetic op: `+` → `-`
3. Remove a null / empty / bounds guard
4. Invert a boolean condition (`true` → `false`, or negate an `if`)
5. Delete one branch of an if/else (make it a no-op)

**Always revert each mutation before applying the next. Leave the file exactly as you found it.**

### Step 3 — Report

```
MUTATION SCORE: X / 5 caught

Survived mutations (real test gaps):
- <mutation> at <file:line> — tests stayed green — missing assertion: <what to add>
```

If score < 4/5, write the specific tests that would kill the surviving mutants.

## Common Mistakes

- **Not reverting between mutations** — stacked mutations produce misleading results; one mutation at a time.
- **Skipping the baseline check** — mutating a file with already-failing tests produces meaningless results.
- **Choosing mutations that don't apply** — pick the 5 most relevant to this file's actual logic, not a generic list.
