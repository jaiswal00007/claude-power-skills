---
name: shadow-reviewer
description: Use when you want an adversarial multi-agent review of the current diff — three skeptical reviewers each try to break the code, then a judge delivers a SAFE TO SHIP / NEEDS CHANGES / DO NOT MERGE verdict
---

# shadow-reviewer

## Overview

Adversarial code review: nobody is trying to validate the code — every reviewer is trying to break it. Three parallel reviewers each attack from a distinct angle, then a judge synthesizes findings into a severity-ranked verdict. Heavier than `/code-review` — use for pre-merge gates or high-risk changes.

## When to Use

- Before merging a significant or risky change
- When you want maximum adversarial scrutiny
- "Give this a thorough review before it ships"

**For a fast, repeatable in-loop review**, use `/code-review` instead.

## Core Pattern

### Step 1 — Gather the diff

```bash
git diff HEAD 2>/dev/null | head -400
git diff HEAD --name-only 2>/dev/null
```

Detect the test runner (look for `package.json`, `pytest.ini`, `go.mod`, `Makefile`, etc.).

### Step 2 — Spawn three adversarial reviewers in parallel

One message, three Agent tool calls. Each gets the diff and ONE lens. Return findings as `file:line — severity — problem`.

1. **Security & data reviewer** — injection, auth bypass, leaked secrets, unsafe deserialization, missing authz checks, PII handling, unsafe SQL/shell/eval.
2. **Edge-case & correctness reviewer** — nulls, empty collections, off-by-one, concurrency/races, large inputs, timezone/encoding, error paths that swallow failures, broken existing behavior.
3. **Operability reviewer** — "what does the 3am page look like?" — missing logs/metrics, unbounded retries, resource leaks, silent failure modes, no rollback path, config that differs in prod.

### Step 3 — Run the tests yourself

Pick the detected runner and record pass/fail.

### Step 4 — Deliver the verdict (you, after all three return)

Synthesize findings. De-duplicate. Rank by severity.

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

## Common Mistakes

- **Running reviewers sequentially** — they must run in parallel (one message, three tool calls).
- **Soft findings instead of adversarial ones** — reviewers should actively try to find ways the code breaks, not look for things to improve.
- **Omitting the test run** — the Tests line in the verdict is required.
