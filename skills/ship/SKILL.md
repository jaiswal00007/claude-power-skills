---
name: ship
description: Use when ready to open a PR for the current branch — generates a title and description from the diff and commits, pushes, and opens the PR via gh CLI with graceful fallback if gh is unavailable
---

# ship

## Overview

Opens a pull request for the current branch. Generates the PR title and body from actual commits and diffstat. Refuses to open from the default branch. Graceful fallback if `gh` is missing or unauthed.

## When to Use

- "Open a PR for this branch"
- "Ship this"
- After finishing a feature and passing code review

## Core Pattern

### Step 1 — Gather context

```bash
git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not a git repo"

# Default branch
DEF=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo main)

# Commits ahead of default
git log --oneline "$DEF"..HEAD 2>/dev/null | head -20

# Diffstat
git diff "$DEF"...HEAD --stat 2>/dev/null | tail -40

# gh available and authed?
command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && echo "gh ready" || echo "gh unavailable"
```

### Step 2 — Refuse to ship from the default branch

If the current branch IS the default branch, **STOP** and tell the user to create a feature branch first (`git checkout -b <name>`). Do not open a PR from the default branch.

### Step 3 — Generate the PR description

From the commits and diffstat, write a title and body:

```
## What changed
- <bullets grounded in the actual commits/diff>

## Why
- <the intent / problem being solved>

## How it was verified
- <tests run, and the /code-review verdict if one was produced this session>
```

Fold any extra context (e.g. `Closes #123`) into the body.

### Step 4 — Open the PR (newline-safe via --body-file)

```bash
cat > /tmp/ship-pr-body.md <<'EOF'
<the generated body>
EOF
git push -u origin HEAD
gh pr create --title "<generated title>" --body-file /tmp/ship-pr-body.md
```

Print the returned PR URL.

### Step 5 — Fallback if gh is missing or unauthed

Do NOT fail. Print:
- the current branch name and the `git push -u origin HEAD` command,
- the ready-to-paste title and body,
- the exact `gh pr create --title "..." --body-file ...` command to run once `gh` is set up.

## Common Mistakes

- **Opening from the default branch** — always check and block this.
- **Vague PR descriptions** — every bullet must be grounded in an actual commit or changed file, not a summary of intent.
- **Hard-failing when gh is unavailable** — always print the fallback so the user can finish manually.
