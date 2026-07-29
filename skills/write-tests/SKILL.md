---
name: write-tests
description: Write meaningful tests for a file or the current diff — auto-detects the framework, names tests after behavior, then runs them
---

Write tests for: $ARGUMENTS   (a file/path, or leave empty to test the current diff)

**Rule: every test verifies real behavior. Name each test after the behavior, not the implementation.
No filler tests that only exist to touch a line.**

## 1. Figure out what to test
- Target (from `$ARGUMENTS`, else the diff): !`if [ -n "$ARGUMENTS" ]; then echo "$ARGUMENTS"; else git diff HEAD --name-only 2>/dev/null | grep -ivE '(test|spec)' | head -10 || echo "(specify a file)"; fi`
- Source under test: !`test -n "$ARGUMENTS" && cat "$ARGUMENTS" 2>/dev/null | head -120 || echo "read the target file(s) above"`
- Framework & runner: !`test -f package.json && (grep -qE '"(vitest|jest)"' package.json && echo "node: $(grep -oE 'vitest|jest' package.json | head -1)" || echo "node: check package.json test script"); test -f pyproject.toml -o -f pytest.ini && echo "python: pytest"; test -f Cargo.toml && echo "rust: cargo test"; test -f go.mod && echo "go: testing pkg"; test -f pom.xml && echo "java: junit/maven"; true`
- Existing tests to match style: !`git ls-files 2>/dev/null | grep -iE '(test|spec)' | head -8 || echo "no existing tests — establish a convention"`

## 2. Enumerate the cases (before writing code)
List the behaviors to cover — happy path, validation, edge cases (null/empty/boundary), error
paths, and any concurrency/auth concerns visible in the source. Each becomes one test.

## 3. Write the tests
- Match the existing test file's framework, layout, and naming (read one from step 1 first).
- If none exist, create the idiomatic test file for the detected framework.
- One assertion-focused test per behavior; describe the behavior in the test name.
- Cover the error/edge cases explicitly — that's where real bugs hide.

## 4. Run them and report
Run the detected runner. Report:
```
Tests added:   N — each named for the behavior it verifies
Result:        X passing / Y failing
Uncovered:     <any behavior from step 2 you did NOT cover, and why>
```
If used TDD-first (tests before implementation), it's correct for them to fail — say so and stop
for the implementation step. Otherwise, all new tests should pass.
