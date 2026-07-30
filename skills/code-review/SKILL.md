---
name: code-review
description: Use when you want a fast diff-scoped review of the current uncommitted changes — spawns three parallel reviewers and delivers a SHIP/NEEDS-CHANGES/DO-NOT-MERGE verdict
---

# code-review

## Overview

Fast, diff-scoped multi-agent review of the current working-tree changes. Three parallel reviewers each focus on one lens, then a judge synthesizes a verdict. Designed to run repeatedly in a dev loop — tight and focused on changed lines only.

## When to Use

- After making changes, before opening a PR
- Repeatedly during a dev loop to catch issues early
- When you want a structured severity-ranked verdict

**Not for:** full working-tree audit of committed code (use `/shadow-reviewer`).

## Core Pattern

### Step 1 — Gather the diff

```bash
git diff HEAD 2>/dev/null | head -400
git diff HEAD --name-only 2>/dev/null
```

Detect the test runner (look for `package.json`, `pytest.ini`, `go.mod`, `Makefile`, etc.).

### Step 2 — Spawn three reviewers in parallel

One message, three Agent tool calls. Give each reviewer the diff and exactly ONE lens. Each caps at top 5 findings, returned as `file:line — severity — problem`. **Review only the changed lines.**

1. **Correctness & edge-cases** — nulls, empty collections, off-by-one, concurrency/races, error paths that swallow failures, behavior of existing code the diff touches.
2. **Security & data** — injection, auth/authz gaps, leaked secrets, unsafe eval/SQL/shell, PII.
3. **Operability** — the 3am-pager view: missing logs/metrics, unbounded retries, resource leaks, silent failures, config that differs in prod.

### Step 3 — Run the test suite

Run the detected test runner. Record pass/fail.

### Step 4 — Deliver the verdict (you, after all three return)

De-duplicate, rank by severity:

```
CODE REVIEW VERDICT
───────────────────
🔴 Blockers:   [file:line each — must fix before merge]
🟡 Should fix: [real issues, not merge-blocking]
🟢 Nits:       [style / preference]
Tests:         pass / fail / not-run

VERDICT: SHIP  |  NEEDS CHANGES  |  DO NOT MERGE
```

Every claim cites file + line. If a reviewer over-flagged, say so.

## Common Mistakes

- **Reviewing the whole file instead of the diff** — review only changed lines.
- **Running reviewers sequentially** — they must run in parallel (one message, three tool calls).
- **Omitting the test run** — the Tests line in the verdict is required.
