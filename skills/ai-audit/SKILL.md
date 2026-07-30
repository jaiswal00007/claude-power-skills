---
name: ai-audit
description: Use when asked to audit recent code changes, review what changed this week, risk-rank a codebase before a release, or run a recurring security hygiene check — especially when changes may touch auth, secrets, migrations, config, or deploy files
---

# ai-audit

## Overview

Forensic audit of recent git changes, risk-ranked so reviewers spend time on what matters most. Runs targeted diffs on high-risk file patterns, then produces a structured four-tier report.

## When to Use

- "Audit what changed this week"
- "What should I review before the release?"
- "Risk-rank the recent commits"
- Scheduled security hygiene on any codebase

**Not for:** single-PR review (use `/code-review`), or repos with no git history.

## Core Pattern

Run these commands, then synthesize the report below:

```bash
# Commit overview
git log --oneline --since="7 days ago" 2>/dev/null || echo "no history"

# Volume summary
git diff --stat "@{7.days.ago}" 2>/dev/null | tail -1

# Files touched
git diff --name-only "@{7.days.ago}" 2>/dev/null | head -40

# High-risk surface diffs
git diff "@{7.days.ago}" -- '*auth*' '*login*' '*password*' '*token*' '*secret*' '*.env*' 2>/dev/null | head -40
git diff "@{7.days.ago}" -- '*migration*' '*schema*' '*model*' '*entity*' 2>/dev/null | head -40
git diff "@{7.days.ago}" -- '*config*' '*.yml' '*.yaml' 'Dockerfile*' '*deploy*' 2>/dev/null | head -30
```

If the repo has no date-based reflog (shallow clone, CI), fall back to `HEAD~20`.

## Output Contract

The report has exactly these four sections, in this order:

```
Week summary: X commits · X files · +X/-X lines

NEEDS HUMAN REVIEW
  <file> — <specific risk: what changed and what a reviewer must verify>

WORTH CHECKING
  <file> — <why: public API surface, shared utility, dependency bump>

ROUTINE
  <file> — <why low-risk: tests, docs, internal refactor with no public surface change>

SURPRISES
  <file> — <anomaly: deleted with no replacement, change with no commit context, etc.>
```

Each "Needs human review" entry must name the specific risk and state what the reviewer should verify — not just the filename.

## Risk Tiers

| Tier | What belongs here |
|------|-------------------|
| Needs human review | Auth, secrets, env files, DB migrations/schemas, deploy config, large deletions |
| Worth checking | Public API surface, shared utilities, dependency version bumps |
| Routine | Tests, docs, internal refactors with no public surface change |
| Surprises | Deleted files with no replacement, changes with no commit message context |

## Common Mistakes

- **Filing without explaining the risk** — "auth.js changed" is useless; "auth.js: session token lifetime reduced from 24h to 1h — verify intentional" is useful.
- **Treating all YAML as high-risk** — config YAML is risky; test-fixture YAML is routine. Classify by content, not extension.
- **Skipping Surprises** — deletions and unexplained changes are often the most dangerous and the easiest to overlook.
- **Omitting the week summary line** — reviewers use it to calibrate how much time to spend; always include it.
