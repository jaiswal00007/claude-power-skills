---
name: token-context
description: Use when starting a new project or feature and wanting to set up the four-file context spine (context.md, decisions.md, spec.md, plan.md) that enables prompt caching and cross-session memory — run once per project or per feature before any implementation begins
---

# Token Context

## Overview

Sets up the **four-file context spine** — the stable prefix that gets cached by the Claude API (90% off per cache hit). Each file serves a distinct memory role so Claude never re-explains the project and never loses decisions across sessions.

## The Four Files

| File | Purpose | TTL |
|---|---|---|
| `context.md` | Project facts: stack, conventions, file layout | Project lifetime |
| `decisions.md` | Approved decisions + rejected approaches (append-only) | Permanent |
| `spec.md` | What to build: business rules, API contract, out-of-scope | Per feature |
| `plan.md` | Task list derived from spec (this session's work) | Per session |

**Cache breakpoint rule:** The stable prefix ends after `context.md`, `decisions.md`, `spec.md`, and `plan.md`. The `cache_control` breakpoint sits here — before the per-turn user message. Everything above is cached at 10% of base token cost after the first turn.

## Core Pattern

### Step 1 — Create the spine files

```bash
# .claude/specs/ holds per-feature spec files (one per feature, checked by spec-gate)
mkdir -p .claude/specs

# context.md and decisions.md live at REPO ROOT (not inside .claude/)
# — they must be at root so the cache breakpoint covers them in every session
touch context.md decisions.md
```

### Step 2 — Populate context.md

```markdown
# Project Context

## §stack
<language, runtime version, framework, database, test runner>

## §conventions
<naming conventions, file layout rules, patterns to follow>

## §layout
<key directories and what they contain>

## §cache-breakpoint
<!-- claude: cache_control breakpoint — stable prefix ends here -->
```

### Step 3 — Populate decisions.md (starts empty)

```markdown
# Decisions

<!-- Append-only. Format: [YYYY-MM-DD] DECIDED: or [YYYY-MM-DD] REJECTED: -->
```

### Step 4 — Create spec.md for the current feature

Run `/create-spec <feature>` to generate a full spec, OR scaffold manually:

```markdown
# Spec: <feature name>

## Business rules
- <each rule becomes one test>

## API contract
- <endpoints, inputs, outputs>

## Out of scope
- <explicit exclusions>
```

### Step 5 — Teach Claude the section-pointer discipline

Agents and sub-agents read files **by section**, not full-load:

```
Read context.md §stack      ← not the whole file
Read spec.md §business-rules ← not the whole file
Read decisions.md            ← small, append-only, always full read
```

## Reading Discipline — Never Full-Load

Full-loading all four files on every turn wastes tokens and risks cache misses if content changes. Instead:

- `context.md` → read the section relevant to the current task (`§stack`, `§conventions`, `§layout`)
- `decisions.md` → always full-read (it's small by design)
- `spec.md` → read the section for the current feature
- `plan.md` → read the current task only

## Common Mistakes

- **Editing context.md mid-session** — any change to a cached file causes a cache miss on that turn. Update `context.md` at session boundaries, not mid-task.
- **Putting dynamic content above the breakpoint** — timestamps, per-request context, or anything that changes turn-to-turn must go in the user message, below the breakpoint.
- **Changing effort level mid-session** — effort level is part of the rendered prompt. Changing it invalidates all cache hits. Pick once at session start and hold it.
- **Skipping decisions.md** — if the decisions-logger Stop hook isn't running, every decision made this session is lost when the session ends.
