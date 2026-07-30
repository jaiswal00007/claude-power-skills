---
name: write-tests
description: Use when asked to write tests for a file or the current diff — auto-detects the framework, names tests after behavior, runs them, and reports coverage gaps
---

# write-tests

## Overview

Writes meaningful tests for a target file or the current uncommitted diff. Auto-detects the test framework and matches the project's existing test style. Every test verifies real behavior and is named after that behavior — no filler.

## When to Use

- "Write tests for `src/payments.ts`"
- "Add tests for the current diff"
- TDD second step: implementation exists, now write tests to cover it
- Coverage is low on a specific file

**Not for:** test-first TDD (use `/create-spec` to write the spec, then failing tests before implementation).

## Core Pattern

### Step 1 — Figure out what to test

```bash
# If a file was specified, read it
cat <TARGET_FILE> 2>/dev/null | head -120

# If testing the current diff, get it
git diff HEAD 2>/dev/null | head -200

# Detect framework and runner
ls package.json pytest.ini go.mod Makefile 2>/dev/null
cat package.json 2>/dev/null | grep -E '"jest"|"vitest"|"mocha"' | head -3

# Find existing tests to match style
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" \) \
  ! -path '*/node_modules/*' | head -5
```

Read one existing test file to learn the project's naming and structure conventions.

### Step 2 — Enumerate the cases (before writing code)

List the behaviors to cover:
- Happy path
- Validation (invalid inputs, missing fields)
- Edge cases (null, empty, boundary values)
- Error paths
- Any concurrency or auth concerns visible in the source

Each item becomes one test.

### Step 3 — Write the tests

- Match the existing test file's framework, layout, and naming.
- If none exist, create the idiomatic test file for the detected framework.
- One assertion-focused test per behavior; describe the behavior in the test name.
- Cover error and edge cases explicitly — that's where real bugs hide.

### Step 4 — Run and report

```bash
# Run only the new test file (fast feedback)
```

```
Tests added:   N — each named for the behavior it verifies
Result:        X passing / Y failing
Uncovered:     <any behavior from step 2 not covered, and why>
```

If used TDD-first (tests before implementation), it's correct for them to fail — say so and stop for the implementation step.

## Common Mistakes

- **Not reading an existing test file first** — naming conventions and structure vary widely; matching the project style is not optional.
- **Testing implementation details** — test what the function does, not how; internals change, behavior contracts don't.
- **Skipping the enumeration step** — listing cases before writing prevents gaps; jumping straight to code misses edge cases.
- **Filler tests** — `expect(fn()).toBeDefined()` is not a test; name the behavior and assert on it.
