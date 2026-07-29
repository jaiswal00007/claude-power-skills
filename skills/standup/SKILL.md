---
name: standup
description: Auto-generate your daily standup from git history, open PRs, and failing tests — sounds human, not like a report
---

Generate my standup for today.

## Yesterday
- Commits: !`git log --oneline --since="yesterday" --author="$(git config user.name)" 2>/dev/null | head -10 || echo "no commits"`
- Merged PRs: !`gh pr list --author="@me" --state=merged --limit=5 2>/dev/null || echo "(gh unavailable)"`

## In progress
- Open PRs: !`gh pr list --author="@me" --state=open 2>/dev/null || echo "(gh unavailable)"`
- Assigned issues: !`gh issue list --assignee="@me" --state=open --limit=5 2>/dev/null || echo "(gh unavailable)"`
- Uncommitted work: !`git status --short 2>/dev/null | head -8`

## Blockers signal
- Failing tests (best-effort, quick): !`test -f package.json && echo "run: npm test"; test -f pyproject.toml -o -f pytest.ini && echo "run: pytest"; test -f Cargo.toml && echo "run: cargo test"; true`

## Output format
```
✅ Yesterday:  <what actually shipped — from commits/PRs above>
🔨 Today:      <what's in progress + next logical step>
🚧 Blockers:   <anything blocking, or "None">
```
Keep it under 6 bullets total. Write like a human developer talking to teammates — not a status report generator. If there's nothing real to say for a section, say "None."
