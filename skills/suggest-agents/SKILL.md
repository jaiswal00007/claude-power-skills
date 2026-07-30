---
name: suggest-agents
description: Use when asked to recommend which custom subagents to create for a repo — analyzes the codebase and produces 5-8 tailored agent recommendations ranked by impact
---

# suggest-agents

## Overview

Analyzes the current repository and recommends which custom subagents would save the most main-thread context, ranked by (usage frequency × context savings). Finishes by offering to create the chosen agents via `create-agent`.

## When to Use

- "What agents should I create for this repo?"
- Setting up a new project's agent configuration
- Auditing whether the existing agent set is still the right one

## Core Pattern

### Gather repo signals

```bash
# Top-level layout
ls -1 | head -20

# File-type mix
find . -type f ! -path '*/.git/*' ! -path '*/node_modules/*' \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15

# Manifests (reveals tech stack)
ls package.json go.mod Cargo.toml pyproject.toml pom.xml build.gradle 2>/dev/null

# Test footprint
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" \) \
  ! -path '*/node_modules/*' | wc -l

# Project conventions
cat CLAUDE.md 2>/dev/null | head -40 || echo "no CLAUDE.md"

# Existing agents (avoid duplicates)
ls .claude/agents/ 2>/dev/null || echo "none yet"
```

### Recommend 5–8 agents tailored to THIS repo

For each:

```
Agent name:         kebab-case-name
When to use:        one-sentence trigger
Problem it solves:  the pain point it removes
Owned domain:       which files/folders it focuses on
Tools it needs:     minimal set — Read / Grep / Glob / Bash / Edit / Write
System prompt gist: 2–3 sentences of its instructions
```

**Rank by:** (how often it'd be used) × (how much main-thread context it saves).
Favor read-only agents (`Read`/`Grep`/`Glob`) — they're safer and still high-value.

Finish with: *"Which should I create? Reply with the numbers or 'all'."*
Then use the `create-agent` skill to generate the chosen ones.

## Common Mistakes

- **Generic suggestions** — "a testing agent" is useless; "an agent that finds untested exports in `src/api/`" is useful.
- **Recommending agents that already exist** — check `.claude/agents/` first and skip duplicates.
- **Over-broad tool lists** — every extra tool is a permission prompt; recommend the minimal set.
