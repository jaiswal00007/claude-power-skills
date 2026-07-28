---
name: ship
description: Open a PR for the current branch with an auto-generated description from the diff and commits — graceful fallback if gh is missing
trigger: /ship
---

Open a pull request for the current branch. Extra context (e.g. `Closes #123`): $ARGUMENTS

## Context
- Current branch: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not a git repo"`
- Default branch: !`gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@origin/@@' || echo main`
- Commits ahead: !`DEF=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo main); git log --oneline "$DEF"..HEAD 2>/dev/null | head -20 || git log --oneline -10 2>/dev/null`
- Diffstat: !`DEF=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo main); git diff "$DEF"...HEAD --stat 2>/dev/null | tail -40 || git diff HEAD --stat 2>/dev/null | tail -40`
- gh available & authed: !`command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && echo "yes" || echo "no — will use fallback"`

## 1. Refuse to ship from the default branch
If the current branch IS the default branch, STOP and tell the user to create a feature branch
first (`git checkout -b <name>`). Do not open a PR from the default branch.

## 2. Generate the PR description
From the commits and diffstat above, write a title and a body:
```
## What changed
- <bullets grounded in the actual commits/diff>

## Why
- <the intent / problem being solved>

## How it was verified
- <tests run, and the /code-review verdict if one was produced this session>
```
Fold any `$ARGUMENTS` (e.g. `Closes #123`) into the body.

## 3. Open the PR (newline-safe via --body-file)
```bash
cat > /tmp/devloop-pr-body.md <<'EOF'
<the generated body>
EOF
git push -u origin HEAD
gh pr create --title "<generated title>" --body-file /tmp/devloop-pr-body.md
```
Print the returned PR URL.

## 4. Fallback if gh is missing/unauthed
Do NOT fail. Print:
- the current branch name and the `git push -u origin HEAD` command,
- the ready-to-paste title and body,
- the exact `gh pr create --title "..." --body-file ...` command to run once `gh` is set up.
