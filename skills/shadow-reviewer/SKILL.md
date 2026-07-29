---
name: shadow-reviewer
description: Adversarial multi-agent code review — three skeptical reviewers try to break your diff, then a judge delivers a ship verdict
---

Run an adversarial review of the current uncommitted changes. Nobody here is trying to
validate the code — every reviewer is trying to break it.

## The diff under review
!`git diff HEAD 2>/dev/null | head -400 || echo "no git diff — review the most recently changed files instead"`
Changed files: !`git diff HEAD --name-only 2>/dev/null || echo "(none detected)"`
Test runner present: !`test -f package.json && echo "npm/node"; { test -f pyproject.toml || test -f pytest.ini || test -f setup.py; } && echo "python/pytest"; test -f Cargo.toml && echo "cargo"; test -f go.mod && echo "go"; test -f pom.xml && echo "maven"; true`

## How to run it
Spawn **three reviewers in parallel** using the Agent tool — one message, three tool calls —
each given the diff above and ONE lens. They must return findings as `file:line — severity — problem`.

1. **Security & data reviewer** — injection, auth bypass, leaked secrets, unsafe deserialization,
   missing authz checks, PII handling, unsafe SQL/shell/eval.
2. **Edge-case & correctness reviewer** — nulls, empty collections, off-by-one, concurrency/races,
   large inputs, timezone/encoding, error paths that swallow failures, broken existing behavior.
3. **Operability reviewer** — "what does the 3am page look like?" — missing logs/metrics, unbounded
   retries, resource leaks, silent failure modes, no rollback path, config that differs in prod.

Then **run the tests yourself** (pick the runner detected above) and record pass/fail.

## The judge (you, after the three return)
Synthesize their findings. De-duplicate. Rank by severity. Then deliver:

```
SHADOW REVIEW VERDICT
─────────────────────
🔴 Blockers:      [must fix before merge — file:line each]
🟡 Should fix:    [real issues, not merge-blocking]
🟢 Nits:          [style / preference]
Tests:            pass / fail / not-run

VERDICT: SAFE TO SHIP  |  NEEDS CHANGES  |  DO NOT MERGE
```
Be specific. Every claim cites a file and line. If a reviewer cried wolf, say so.
