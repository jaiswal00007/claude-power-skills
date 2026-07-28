---
name: mutation-test
description: Prove your tests actually catch bugs by injecting subtle mutations and checking if tests fail
trigger: /mutation-test
---

Prove the tests for $ARGUMENTS are real — not just green theater.

## Setup
- The file: !`cat "$ARGUMENTS" 2>/dev/null | head -120 || echo "read the file named in the argument"`
- Its tests: !`git ls-files 2>/dev/null | grep -iE '(test|spec)' | grep -i "$(basename "$ARGUMENTS" | sed 's/\.[^.]*$//')" || echo "locate the test file for this source"`
- Test command: !`test -f package.json && echo "npm test"; test -f pyproject.toml -o -f pytest.ini && echo "pytest"; test -f Cargo.toml && echo "cargo test"; test -f go.mod && echo "go test ./..."; test -f pom.xml && echo "mvn test"; true`
- Baseline — confirm tests are GREEN before mutating: run the command above and record it.

## Inject mutations — ONE at a time
For each, apply the change, run the tests, record caught (tests fail = good) or **survived** (tests
still pass = a real gap), then **revert before the next one**. Pick the 5 that apply to this file:

1. Flip a comparison: `>` → `>=`  (or `<` → `<=`)
2. Flip an arithmetic op: `+` → `-`
3. Remove a null / empty / bounds guard
4. Invert a boolean condition (`true` → `false`, or negate an `if`)
5. Delete one branch of an if/else (make it a no-op)

⚠️ Always revert each mutation before applying the next. Leave the file exactly as you found it.

## Report
```
MUTATION SCORE: X / 5 caught

Survived mutations (these expose real test gaps):
- <mutation> at <file:line> — tests stayed green — missing assertion: <what to add>
```
If score < 4/5, write the specific tests that would kill the surviving mutants.
