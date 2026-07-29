---
name: safe-task
description: Safety checklist before any task — git snapshot, scope estimate, danger-zone check
---

Before starting any task, run this safety gate. Do NOT write code until it is complete.

## Snapshot the current state
- Uncommitted changes: !`git status --short 2>/dev/null | wc -l | tr -d ' '` files dirty
- Current branch: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not a git repo"`
- Recent history: !`git log --oneline -5 2>/dev/null || echo "no history"`
- Create a restore point: !`git stash create 2>/dev/null | grep . && echo "(stash object created — recover with 'git stash apply <sha>')" || echo "working tree clean — HEAD is your restore point"`

## Assess the task
Task to assess: $ARGUMENTS

1. Estimate scope: how many files will this realistically touch?
2. Danger-zone scan — does the task touch any of these?
   !`git ls-files 2>/dev/null | grep -iE 'auth|login|password|secret|token|payment|billing|migration|schema|\.env|Dockerfile|deploy|prod' | head -15 || echo "(scanning current dir)"; ls 2>/dev/null | grep -iE 'auth|secret|\.env|payment|deploy' | head`
3. If scope > 10 files OR it touches auth / DB / payments / config / deploy →
   **STOP.** State the risk in one sentence and ask the user to confirm before proceeding.

## Commit to a plan
State the plan in ONE paragraph — what you'll change and why — before writing any code.
Only proceed once this gate is complete and (if triggered) the user has confirmed.
