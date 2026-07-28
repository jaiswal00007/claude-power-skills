---
name: time-machine
description: Find the exact commit that introduced a bug using automated git bisect, then explain how it broke
trigger: /time-machine
---

Bug to hunt: $ARGUMENTS

**Forensics, not repair.** Find the commit that gave birth to this bug and explain it.

## 1. Establish the crime scene
- Where the symptom lives: !`git grep -nI "$ARGUMENTS" 2>/dev/null | head -15 || echo "no literal match — search by symptom, not by the raw argument string"`
- Recent history: !`git log --oneline -20 2>/dev/null`
- Test runner: !`test -f package.json && echo "npm test"; test -f pyproject.toml -o -f pytest.ini && echo "pytest"; test -f Cargo.toml && echo "cargo test"; test -f go.mod && echo "go test ./..."; test -f pom.xml && echo "mvn test"; true`

## 2. Choose the strategy
**Preferred — automated bisect (when a repro command exists).**
Ask the user (or infer) a command that exits non-zero when the bug is present, e.g. a single
failing test. Then find a known-good older commit and run:
```bash
git bisect start
git bisect bad HEAD
git bisect good <known-good-sha>       # e.g. a tag or a commit from before the bug
git bisect run <repro-command>          # e.g. npm test -- path/to/failing.test
git bisect reset                        # ALWAYS reset when done
```
`git bisect run` prints `<sha> is the first bad commit`. That is the answer.

**Fallback — manual archaeology (no repro command).**
Inspect the suspects around where the symptom lives:
!`git log --oneline -8 -- $(git grep -lI "$ARGUMENTS" 2>/dev/null | head -3) 2>/dev/null || echo "narrow by file once you've located the symptom"`
Read each suspect's diff with `git show <sha>` and reason about which one flipped behavior.

## 3. Deliver the timeline
```
🕰  BUG BIRTH CERTIFICATE
First bad commit:  <sha>
Author / date:     <who> / <when>
What changed:      <the specific hunk that broke it>
Why it broke:      <mechanism — the exact logic that flipped>
Last good state:   <sha before it>
```
Do not fix it unless asked — hand off a precise diagnosis.
