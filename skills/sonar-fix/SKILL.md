---
name: sonar-fix
description: Use when a coverage gate is failing or coverage is too low on a specific file — finds uncovered lines and branches, then writes meaningful tests that verify real behavior (not filler)
---

# sonar-fix

## Overview

Fixes coverage-gate failures by identifying uncovered lines and branches, understanding WHY they're uncovered, and writing tests that verify real behavior. The constraint is firm: every test must exercise something real — no tests written just to move the number.

## When to Use

- "Coverage gate is failing"
- "Sonar is blocking the PR"
- "Coverage on `src/payments.ts` is too low"

## Core Pattern

### Step 1 — Understand the target

```bash
# Read the file under test
cat <TARGET_FILE> | head -120

# Find existing test files
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" \) \
  | xargs grep -l "<basename of TARGET_FILE>" 2>/dev/null | head -5

# Coverage config (thresholds, exclude patterns)
cat jest.config.* .nycrc coverage/.nycrc sonar-project.properties 2>/dev/null | head -30
```

### Step 2 — Measure current coverage for this file

Run the appropriate command:

```bash
# Jest
npx jest --coverage --collectCoverageFrom="<TARGET>" \
  --testPathPattern="$(basename "<TARGET>" | sed 's/\.[^.]*$//')" 2>&1 | tail -30

# Vitest
npx vitest run --coverage 2>&1 | grep -A5 "$(basename "<TARGET>")" | head -20

# pytest
python -m pytest --cov="<TARGET>" --cov-report=term-missing 2>&1 | tail -25

# Go
go test -coverprofile=/tmp/cov.out ./... && go tool cover -func=/tmp/cov.out | grep "$(basename "<TARGET>" .go)"
```

### Step 3 — Close the gaps meaningfully

For each uncovered line / branch / function:
- Explain WHY it's uncovered (missing edge case, error path, boundary condition).
- Write a test that exercises it through real behavior. Name it after the behavior.
- **Never assert on internals just to touch a line.**

### Step 4 — Verify and report

Re-run the coverage command. Report:

```
Coverage before → after:   XX% → YY%
Gate threshold:            (from config, if found)
Tests added:               N — each named for the behavior it verifies
```

## Common Mistakes

- **Writing filler tests** — `expect(fn()).toBeDefined()` touches a line but proves nothing; name the behavior, assert on the behavior.
- **Ignoring branch coverage** — a line being executed doesn't mean both branches of an `if` are covered; check the branch column.
- **Not reading the file before writing tests** — every test must be grounded in the actual logic, not guessed.
