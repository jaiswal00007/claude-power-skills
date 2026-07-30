---
name: scope-check
description: Use before writing any code when you want to understand the blast radius of a task — maps target files, downstream dependents, test coverage, and produces a 1-10 risk score before asking for approval
---

# scope-check

## Overview

Analysis-only pre-flight that maps the blast radius of a task: which files change, who imports them, how many tests cover the area, and a risk score. Produces a structured report and waits for user approval before any code is written.

## When to Use

- "How risky is this change?"
- Before refactoring shared utilities or public APIs
- Any task where you're unsure how many things will break
- "Check the scope before we start"

**Not for:** writing or changing code — this is analysis only.

## Core Pattern

### Step 1 — Identify target files

Name the files the task will most likely change.

### Step 2 — Map the blast radius

```bash
# File-type mix (to pick the right search tool)
find . -type f ! -path '*/.git/*' ! -path '*/node_modules/*' \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10

# For each target file, find direct dependents
git grep -n "<basename-of-target>" 2>/dev/null | grep -v "^Binary" | head -30

# Test coverage of the area
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" \) \
  ! -path '*/node_modules/*' | xargs grep -l "<basename-of-target>" 2>/dev/null | head -10

# Recent churn in this area
git log --oneline -10 -- <target-files> 2>/dev/null || echo "no history"
```

### Step 3 — Score the risk (1–10)

Weigh:
- Number of files affected
- Whether public APIs or exported signatures change
- Whether auth / DB / config / payments are involved
- Test coverage of the area

### Step 4 — Report

```
Files to change:           N
Files affected downstream: N
Tests covering this area:  N
Risk score:                X/10
Recommendation:            proceed / proceed with caution / needs discussion
```

**Wait for user approval before touching any code.**

## Common Mistakes

- **Running the analysis and immediately writing code** — the approval gate is mandatory; stop and wait.
- **Searching only by exact filename** — also grep by exported symbol names, especially for shared utilities.
- **Ignoring test gaps** — low test count in a high-churn area is itself a risk factor worth calling out.
