---
name: standup
description: Use when asked to generate a daily standup update — pulls yesterday's commits, open and merged PRs, assigned issues, and failing tests, then formats it as a human-sounding standup
---

# standup

## Overview

Auto-generates a daily standup from real git and GitHub signals. The output sounds like a developer talking to teammates — not a status report. Stays under 6 bullets total.

## When to Use

- "Generate my standup"
- "What did I do yesterday?"
- Any request for a daily update or status summary

## Core Pattern

### Gather signals

```bash
# Yesterday's commits
git log --oneline --since="yesterday" --author="$(git config user.name)" 2>/dev/null | head -10 \
  || echo "no commits"

# Merged PRs
gh pr list --author="@me" --state=merged --limit=5 2>/dev/null || echo "(gh unavailable)"

# Open PRs
gh pr list --author="@me" --state=open 2>/dev/null || echo "(gh unavailable)"

# Assigned issues
gh issue list --assignee="@me" --state=open --limit=5 2>/dev/null || echo "(gh unavailable)"

# Uncommitted work in progress
git status --short 2>/dev/null | head -8

# Failing tests (quick best-effort — run whatever runner is present, capture pass/fail)
```

### Produce the standup

```
✅ Yesterday:  <what actually shipped — from commits/PRs above>
🔨 Today:      <what's in progress + next logical step>
🚧 Blockers:   <anything blocking, or "None">
```

Keep it under 6 bullets total. Write like a human developer talking to teammates — not a status report generator. If there's nothing real to say for a section, say "None."

## Common Mistakes

- **Inventing content** — every bullet must come from the signals gathered above; if commits or PRs show nothing, report nothing.
- **Reporting file names instead of outcomes** — "merged PR #42: fixed login timeout" beats "changed auth.ts".
- **Including all 10 commits** — pick the 2-3 most significant; teammates don't need a full log.
