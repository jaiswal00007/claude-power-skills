---
name: write-tests
description: Write meaningful tests for a file or the current diff — auto-detects the framework, names tests after behavior, then runs them
---

Write tests for: $ARGUMENTS   (a file/path, or leave empty to test the current diff)

**Rule: every test verifies real behavior. Name each test after the behavior, not the implementation.
No filler tests that only exist to touch a line.**

## 1. Figure out what to test
- Target (from `$ARGUMENTS`, else the diff): !`python3 -c "import os,subprocess,re; arg=os.environ.get('ARGUMENTS','').strip(); print(arg) if arg else [print(f) for f in subprocess.run(['git','diff','HEAD','--name-only'],capture_output=True,text=True).stdout.split() if not re.search(r'(test|spec)',f,re.I)][:10] or print('(specify a file)')"`
- Source under test: !`test -n "$ARGUMENTS" && cat "$ARGUMENTS" 2>/dev/null | head -120 || echo "read the target file(s) above"`
- Framework & runner: !`python3 -c "import os,json; pkg=os.path.exists('package.json') and json.load(open('package.json')); deps=pkg and {**pkg.get('dependencies',{}),**pkg.get('devDependencies',{})}; fw=next((k for k in ['vitest','jest'] if deps and k in deps),''); runners=[('package.json','node: '+fw if fw else 'node: check scripts'),('pyproject.toml','python: pytest'),('pytest.ini','python: pytest'),('Cargo.toml','rust: cargo test'),('go.mod','go: testing pkg'),('pom.xml','java: junit/maven')]; [print(r) for f,r in runners if os.path.exists(f)] or print('unknown')"`
- Existing tests to match style: !`python3 -c "import subprocess,re; files=subprocess.run(['git','ls-files'],capture_output=True,text=True).stdout.split(); [print(f) for f in files if re.search(r'(test|spec)',f,re.I)][:8] or print('no existing tests — establish a convention')"`

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
