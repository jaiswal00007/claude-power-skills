---
name: code-review
description: Fast diff-scoped multi-agent review — 3 parallel reviewers on the current changes + a SHIP/NEEDS-CHANGES/BLOCKED verdict
---

Review the current uncommitted changes. Fast and diff-scoped — this runs repeatedly in the loop,
so keep it tight. Optional focus paths: $ARGUMENTS

## The diff under review
!`git diff HEAD 2>/dev/null | head -400 || echo "no git diff — review the most recently changed files instead"`
Changed files: !`git diff HEAD --name-only 2>/dev/null || echo "(none detected)"`
Test runner present: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" test-runner`

## How to run it
Spawn **three reviewers in parallel** via the Agent tool — one message, three tool calls — each
given the diff above and ONE lens. **Review only the changed lines.** Each reviewer caps at its
top 5 findings, returned as `file:line — severity — problem`.

1. **Correctness & edge-cases** — nulls, empty collections, off-by-one, concurrency/races, error
   paths that swallow failures, behavior of existing code the diff touches.
2. **Security & data** — injection, auth/authz gaps, leaked secrets, unsafe eval/SQL/shell, PII.
3. **Operability** — the 3am-pager view: missing logs/metrics, unbounded retries, resource leaks,
   silent failures, config that differs in prod.

Then **run the detected test runner** and record pass/fail.

## Verdict (you, after the three return)
De-duplicate, rank by severity, emit exactly this block:

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

> Note: this is the fast, repeat-callable, diff-scoped review. For a heavier standalone audit of
> the full working tree, use `/shadow-reviewer`.
