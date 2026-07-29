---
name: session-wrap
description: End-of-session handoff — what was done, what's next, decisions made, and update CLAUDE.md
---

This session is ending. Write a handoff so the next session starts warm, not cold.

## Evidence of this session's work
- Changed files: !`git status --short 2>/dev/null; git diff --name-only HEAD 2>/dev/null | head -30`
- Commits made: !`git log --oneline -8 2>/dev/null`
- Test state (best-effort): !`test -f package.json && echo "check: npm test"; test -f pyproject.toml -o -f pytest.ini && echo "check: pytest"; test -f Cargo.toml && echo "check: cargo test"; true`

## Produce the handoff document

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

## Persist it
1. Save to `.claude/session-notes/session-<YYYY-MM-DD>.md` (create the folder if needed).
2. Update `CLAUDE.md` with any new convention, pattern, or warning discovered this session —
   append, don't overwrite. Keep additions terse and factual.
