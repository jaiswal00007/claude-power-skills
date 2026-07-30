---
name: create-agent
description: Use when asked to create a custom subagent for this repo — generates a complete, ready-to-save .claude/agents/ file grounded in the actual codebase
---

# create-agent

## Overview

Generates a complete `.claude/agents/<name>.md` subagent file tailored to the current repository. The result is specific to this codebase — not generic boilerplate.

## When to Use

- "Create an agent that handles database migrations"
- "Build a subagent for reviewing API surface changes"
- Any request to create a reusable specialized agent for a repo

## Core Pattern

### Step 1 — Ground it in this repo

```bash
# Top-level layout
ls -1 2>/dev/null | head -20

# Project conventions
cat CLAUDE.md 2>/dev/null | head -40 || echo "no CLAUDE.md"

# Existing agents (avoid duplicates)
ls .claude/agents/ 2>/dev/null || echo "none yet"
```

### Step 2 — Generate the file

```markdown
---
name: <kebab-case-name>
description: <one sentence, precise enough for auto-selection; include trigger keywords>
tools: <comma-separated minimal set: Read, Grep, Glob, Bash, Edit, Write>
---

# <Agent Display Name>

## Role
<2 sentences: what it does and what it must never do>

## This codebase
Key files you own:
- <real paths from the repo signals above>

## How you work
1. <step-by-step operating procedure>
2. Cite file + line for every claim.
3. Never touch files outside your owned domain.
4. If unsure, say so — don't guess.

## Rules
- <non-negotiable constraints specific to this domain>
```

### Step 3 — Save it

Ask: *"Save this to `.claude/agents/<name>.md`? (yes/no)"*

On yes: create `.claude/agents/` if needed, write the file, then confirm with an example task to test it.

## Rules for a good subagent

- System prompt is specific to THIS codebase, not generic boilerplate
- Tools list is minimal — only what the agent actually needs
- Description is precise enough for auto-selection (include trigger keywords)
- Owned paths are explicit so the agent doesn't wander
- Prefer read-only (`Read`/`Grep`/`Glob`) unless the job genuinely requires writing

## Common Mistakes

- **Generic descriptions** — "helps with code" won't auto-select; name the domain and trigger explicitly.
- **Over-broad tool lists** — every extra tool is a permission prompt; trim to what's actually needed.
- **No owned paths** — agents without a domain wander into unrelated files.
