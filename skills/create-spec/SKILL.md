---
name: create-spec
description: Use when starting a new feature and wanting spec-driven development — write the spec first, get approval, then turn each rule into a failing test before implementation
---

# create-spec

## Overview

Spec-driven development: write a complete specification, stop for approval, then generate one failing test per spec rule. Implementation only begins after the tests exist. Combines the clarity of upfront design with the discipline of TDD.

## When to Use

- Starting a new feature or significant behavior change
- When requirements need to be agreed on before any code is written
- "Spec out X before we build it"

**Not for:** bug fixes with a clear reproduction case (go straight to TDD).

## Core Pattern

### Phase 1 — Specification only (no code, no tests yet)

Read project context first:
```bash
cat CLAUDE.md 2>/dev/null | head -60 || echo "no CLAUDE.md"
# List source files to understand existing structure
find . -type f \( -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.js" \) \
  ! -path "*/node_modules/*" ! -path "*/.git/*" | head -30
```

Write a complete specification:

```
## Feature Specification: <name>

### What it does (2 sentences)

### Business rules
- One bullet per rule. Each bullet becomes exactly one test.
- Cover: happy path, validation, edge cases, error cases.

### API contract
- Input:  parameters, types, validation
- Output: success response shape
- Errors: every error case with its message

### Edge cases
- Empty / null inputs, boundary values, concurrency, unauthorized access

### Out of scope
- What this feature explicitly does NOT do
```

**STOP. Show the spec. Wait for explicit user approval before continuing.**

### Phase 2 — Generate tests (after approval only)

Detect the test runner:
```bash
# Check for common runners
ls package.json pytest.ini go.mod Makefile 2>/dev/null
cat package.json 2>/dev/null | grep -E '"test":|"jest"|"vitest"' | head -5
```

- Generate a test file where **each spec bullet = one test case**.
- Name each test after the business rule it verifies, not the implementation.
- Run the detected test runner. All new tests should FAIL (no implementation yet — this is correct).
- Report: `N tests generated, N failing. Ready for implementation.`

## Common Mistakes

- **Writing any code before the spec is approved** — phase 1 ends at the approval gate, full stop.
- **Writing tests after implementation** — tests must exist and fail before implementation begins.
- **Vague business rules** — each bullet must be specific enough to become exactly one test; "handles errors" is not a rule.
- **Skipping the out-of-scope section** — scope creep during implementation is prevented by making exclusions explicit.
