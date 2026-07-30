---
name: autopilot
description: Use when given a GitHub issue number and asked to implement it end-to-end — fetch the issue, plan, get approval, implement via TDD, and open a PR
---

# autopilot

## Overview

Drives a GitHub issue from number to opened PR. Gated — stops for user approval before writing any code.

## When to Use

- "Work on issue #42"
- "Implement and ship issue #123"
- Any request that gives you a GitHub issue number and wants a full implementation cycle

**Not for:** tasks without an issue number (use `/safe-task`), or repos without `gh` CLI available (graceful fallback still works).

## Core Pattern

### 1. Load context

```bash
gh issue view <ISSUE_NUMBER>
cat CLAUDE.md 2>/dev/null | head -80 || echo "no CLAUDE.md"
git rev-parse --abbrev-ref HEAD   # current branch
```

Detect the test runner by looking for `package.json` scripts, `pytest.ini`, `go.mod`, `Makefile` test targets, etc.

### 2. Plan (STOP here)

Create a working branch:
```bash
git checkout -b "autopilot/issue-<NUMBER>"
```

Write an implementation plan: exact files to change, test strategy, and any risk.

**STOP. Show the plan. Wait for explicit user approval before writing any code.**

### 3. TDD (after approval only)

1. Write FAILING tests first that encode the issue's acceptance criteria.
2. Run the test runner. Confirm they fail for the right reason.
3. Write the minimum implementation to make them pass.
4. Re-run tests until green. Show the final output.

### 4. Open the PR

```bash
cat > /tmp/autopilot-pr-body.md <<'EOF'
Closes #<NUMBER>

## What changed
- <bullet the actual changes>

## How it was verified
- Implemented via TDD: failing tests first, then implementation.
- <paste the passing test summary>
EOF
git push -u origin HEAD
gh pr create --title "fix: closes #<NUMBER>" --body-file /tmp/autopilot-pr-body.md
```

Show the PR URL. If `gh` is unavailable, print the branch name and the ready-to-paste PR body.

## Common Mistakes

- **Writing code before approval** — the plan gate is mandatory; never skip it.
- **Writing tests after implementation** — TDD means failing tests FIRST.
- **Opening PR from the default branch** — always create a feature branch first.
