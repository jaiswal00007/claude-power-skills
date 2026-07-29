---
name: autopilot
description: Drive a GitHub issue from number to opened PR — fetch, plan, get approval, TDD, verify, open PR
---

Take issue #$ARGUMENTS from open issue to opened pull request. Gated — you stop for approval.

## 1. Load context
- The issue: !`gh issue view $ARGUMENTS 2>/dev/null || echo "gh not available or issue not found — paste the issue text and continue"`
- Project conventions: !`cat CLAUDE.md 2>/dev/null | head -80 || echo "no CLAUDE.md"`
- Default branch: !`python3 -c "import subprocess; r=subprocess.run(['gh','repo','view','--json','defaultBranchRef','-q','.defaultBranchRef.name'],capture_output=True,text=True); b=r.stdout.strip(); r2=subprocess.run(['git','symbolic-ref','--short','refs/remotes/origin/HEAD'],capture_output=True,text=True) if not b else None; print(b or r2.stdout.strip().replace('origin/','') if r2 else b or 'main')"`
- Test runner: !`python3 -c "import os; runners=[('package.json','npm test'),('pyproject.toml','pytest'),('pytest.ini','pytest'),('Cargo.toml','cargo test'),('go.mod','go test ./...'),('pom.xml','mvn test')]; [print(r) for f,r in runners if os.path.exists(f)] or print('unknown')"`

## 2. Plan (STOP here)
- Create a working branch: !`git checkout -b "autopilot/issue-$ARGUMENTS" 2>/dev/null && echo "on new branch" || echo "branch exists — reusing"`
- Write an implementation plan: exact files to change, the test strategy, and any risk.
- **STOP. Show the plan. Wait for explicit user approval before writing code.**

## 3. TDD (after approval)
1. Write the FAILING tests first that encode the issue's acceptance criteria.
2. Run the detected test runner. Confirm they fail for the right reason.
3. Write the minimum implementation to make them pass.
4. Re-run tests until green. Show the final run output.

## 4. Open the PR
Write the PR body to a file so newlines render correctly, then open it:
```bash
cat > /tmp/autopilot-pr-body.md <<'EOF'
Closes #$ARGUMENTS

## What changed
- <bullet the actual changes>

## How it was verified
- Implemented via TDD: failing tests first, then implementation.
- <paste the passing test summary>
EOF
git push -u origin HEAD
gh pr create --title "fix: closes #$ARGUMENTS" --body-file /tmp/autopilot-pr-body.md
```
Show the PR URL. If `gh` is unavailable, print the branch name and the ready-to-paste PR body instead.
