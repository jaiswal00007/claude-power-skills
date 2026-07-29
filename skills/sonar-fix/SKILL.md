---
name: sonar-fix
description: Fix coverage-gate failures — find the uncovered lines/branches and write meaningful tests, not filler
---

Fix coverage for: $ARGUMENTS

**Rule: every test you add must verify real behavior. No tests written just to move the number.**

## 1. Understand the target
- The file: !`cat "$ARGUMENTS" 2>/dev/null | head -120 || echo "read the file(s) named in the argument"`
- Its existing tests: !`git ls-files 2>/dev/null | grep -iE '(test|spec)' | grep -i "$(basename "$ARGUMENTS" | sed 's/\.[^.]*$//')" || echo "no obvious test file — you'll create one"`
- Coverage config, if any: !`cat sonar-project.properties 2>/dev/null | grep -i coverage; cat jest.config.* vitest.config.* 2>/dev/null | grep -i coverage; grep -i 'cov' pyproject.toml setup.cfg 2>/dev/null; true`

## 2. Measure current coverage for this file
Pick the command that matches the project (run only the relevant one):
```bash
# node / jest
npx jest --coverage --collectCoverageFrom="$ARGUMENTS" --testPathPattern="$(basename "$ARGUMENTS" | sed 's/\.[^.]*$//')" 2>&1 | tail -30
# node / vitest
npx vitest run --coverage 2>&1 | grep -A5 "$(basename "$ARGUMENTS")" | head -20
# python
python -m pytest --cov="$ARGUMENTS" --cov-report=term-missing 2>&1 | tail -25
# go
go test -coverprofile=/tmp/cov.out ./... && go tool cover -func=/tmp/cov.out | grep "$(basename "$ARGUMENTS" .go)"
```

## 3. Close the gaps meaningfully
For each uncovered line / branch / function the report flags:
- Explain WHY it's uncovered (missing edge case, error path, boundary condition).
- Write a test that exercises it through real behavior. Name it after the behavior.
- Never assert on internals just to touch a line.

## 4. Verify and report
Re-run the coverage command. Report:
```
Coverage before → after:   XX% → YY%
Gate threshold:            (from config, if found)
Tests added:               N — each named for the behavior it verifies
```
