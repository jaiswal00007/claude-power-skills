---
name: token-audit
description: Use when wanting to measure token waste in the current Claude Code session — surfaces cache hit rate, context growth, re-implementations, agent brief sizes, decisions captured, and effort consistency as a ranked report with concrete fixes
---

# Token Audit

## Overview

Audits the current session across six token waste dimensions and produces a ranked report: worst waste first, each finding with a concrete fix. Gathers all signals via bash commands, then synthesises the report directly — no external agent invocation required.

## When to Use

- At the end of a session to measure efficiency
- When a session feels expensive or slow
- When setting up the token-context system for the first time (baseline measurement)
- After any architectural change to verify improvements

## Core Pattern

### Step 1 — Gather signals

```bash
# Context size proxy
git diff HEAD 2>/dev/null | wc -w
wc -w decisions.md 2>/dev/null || echo "0 (decisions.md missing)"

# Re-implementation signals
git log --oneline -20

# Hook wiring check
cat hooks/hooks.json | grep -E "spec-gate|decisions-logger|token-budget"

# Decisions captured
grep -c "DECIDED\|REJECTED" decisions.md 2>/dev/null || echo "0"
```

### Step 2 — Invoke the token-auditor agent

The `token-auditor` agent (`.claude/agents/token-auditor.md`) runs the full audit and produces the ranked report. It is read-only — it never modifies files.

### Step 3 — Read the report

```
TOKEN WASTE REPORT
==================
RANK 1 — [dimension] [CRITICAL|HIGH|LOW|OK]
  Finding: <file:line citation>
  Impact:  <token cost consequence>
  Fix:     <single actionable step>
...
SUMMARY: CRITICAL: X  HIGH: X  LOW: X  OK: X
```

### Step 4 — Act on CRITICAL findings first

| CRITICAL signal | Fix |
|---|---|
| 0 decisions captured | Wire decisions-logger Stop hook in `hooks/hooks.json` |
| Effort level changed | Pick effort at session start, never change it |
| Re-implementation in git log | Check spec-gate PostToolUse hook is wired |
| decisions.md missing | Run `/token-context` to set up the spine |

## Six Dimensions

| # | Dimension | Target | What breaks it |
|---|---|---|---|
| 1 | Cache hit rate | >50% stable sessions | Effort change, file edits above breakpoint |
| 2 | Context growth | <2x per session | Long sessions without /session-wrap |
| 3 | Re-implementations | 0 | Missing spec gate |
| 4 | Agent brief sizes | ≤300 tokens | Full conversation passed to sub-agents |
| 5 | Decisions captured | >0 per session | Missing decisions-logger hook |
| 6 | Effort consistency | No switches | Changing effort mid-session |

## Common Mistakes

- **Running /token-audit before setting up the spine** — the report will show everything as CRITICAL or UNKNOWN. Run `/token-context` first to establish a baseline, then audit.
- **Ignoring UNKNOWNS** — an UNKNOWN means a measurement gap, not a clean bill. Fix the missing hook or file so future audits have real data.
- **Auditing once and not again** — run after each major session to track whether the system is improving. The first audit is the baseline; subsequent audits show the trend.
