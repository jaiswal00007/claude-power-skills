---
name: create-spec
description: Spec-driven development — write the spec first, turn each rule into a failing test, then implement
---

Feature to specify: $ARGUMENTS

## PHASE 1 — Specification only (no code, no tests yet)

Context to ground the spec:
!`cat CLAUDE.md 2>/dev/null | head -60 || echo "no CLAUDE.md"`
!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" source-files`

Write a complete specification:

```
## Feature Specification: $ARGUMENTS

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

## PHASE 2 — Generate tests (after approval only)

Detected test runner: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" test-runner`

- Generate a test file where **each spec bullet = one test case**.
- Name each test after the business rule it verifies, not after the implementation.
- Run the detected test runner. All new tests should FAIL (no implementation yet — this is correct).
- Report: `N tests generated, N failing. Ready for implementation.`
