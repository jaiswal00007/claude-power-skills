---
name: safe-task
description: Use before starting any task that could have significant blast radius — creates a git snapshot, estimates scope, checks for danger zones, and gates on user confirmation before writing code
---

# safe-task

## Overview

Safety gate that runs before any non-trivial task. Snapshots the current state, estimates how many files will be touched, scans for danger zones (auth, DB, payments, config, deploy), and stops for user confirmation when the risk threshold is crossed.

## When to Use

- Before any task affecting more than a few files
- When touching auth, DB, payments, config, or deploy code
- Any time you want a restore point before proceeding
- "Run the safety check before we start"

## Core Pattern

### Step 1 — Snapshot current state

```bash
# How dirty is the working tree?
git status --short 2>/dev/null | wc -l

# Current branch
git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not a git repo"

# Recent history
git log --oneline -5 2>/dev/null || echo "no history"

# Create a restore point
git stash push -m "safe-task snapshot $(date +%Y%m%d-%H%M%S)" 2>/dev/null \
  && echo "stash created" || echo "nothing to stash — working tree clean"
```

### Step 2 — Assess the task

Given the task description:

1. Estimate scope: how many files will this realistically touch?
2. Danger-zone scan — does the task touch any of:
   - Auth / sessions / tokens
   - Database schemas or migrations
   - Payment processing
   - Deploy config, CI/CD, infrastructure
   - Secrets or environment config

3. **If scope > 10 files OR it touches any danger zone:**
   **STOP.** State the risk in one sentence and ask the user to confirm before proceeding.

### Step 3 — Commit to a plan

State the plan in ONE paragraph — what will change and why — before writing any code.

Only proceed once this gate is complete and (if triggered) the user has confirmed.

## Common Mistakes

- **Skipping the gate when "it's a small change"** — small changes in danger zones can cascade; the gate is especially important there.
- **Not creating the stash** — the restore point is the whole point; never skip it.
- **Vague plans** — "I'll update some files" is not a plan; name the specific files and the change.
