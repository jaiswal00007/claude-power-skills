---
name: session-wrap
description: Use at the end of a working session to produce a handoff document and update CLAUDE.md — so the next session starts warm with full context about what was done, what's next, and what to avoid
---

# session-wrap

## Overview

End-of-session handoff that grounds itself in real git evidence. Produces a structured document covering what was accomplished, what's unfinished, decisions made, and landmines discovered. Persists the document and updates `CLAUDE.md` with any new conventions found.

## When to Use

- "Wrap up the session"
- Before handing off to another agent or developer
- At natural stopping points during long tasks

## Core Pattern

### Step 1 — Gather evidence

```bash
# Changed files
git status --short 2>/dev/null
git diff --name-only HEAD 2>/dev/null | head -30

# Commits made this session
git log --oneline -8 2>/dev/null

# Test state (best-effort)
# Run whatever test runner is present; record pass/fail/unknown
```

### Step 2 — Produce the handoff document

```
# Session handoff — <today's date>

## Accomplished
- <specific files changed, features added — grounded in the git evidence above>

## Not finished (and why)
- <what's left, blockers hit>

## Decisions made (brief ADR-style)
- <decision> — because <reason>

## Do this first next session
1. <the single most important next step>

## Landmines / gotchas discovered
- <anything that would bite the next session>

## Current state
- Tests: <pass/fail/unknown>   Branch: <name>   Uncommitted: <yes/no>
```

### Step 3 — Persist it

1. Save to `.claude/session-notes/session-<YYYY-MM-DD>.md` (create the folder if needed).
2. Update `CLAUDE.md` with any new convention, pattern, or warning discovered this session — append, don't overwrite. Keep additions terse and factual.

## Common Mistakes

- **Vague "accomplished" entries** — ground every bullet in a real file path or commit; "worked on auth" is useless.
- **Skipping CLAUDE.md update** — conventions discovered this session should be persisted so future sessions don't rediscover them.
- **Omitting landmines** — surprises that bit you this session are the highest-value thing to pass forward.
