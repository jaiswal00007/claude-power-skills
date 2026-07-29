---
name: ai-audit
description: Weekly forensic audit of recent changes — risk-ranked for human review, surfaces the scary stuff first
---

Audit the changes from the last 7 days and risk-rank them for human review.

## The week in changes
- Commits: !`git log --oneline --since="7 days ago" 2>/dev/null || echo "no history"`
- Volume: !`git diff --stat "@{7.days.ago}" 2>/dev/null | tail -1 || git diff --stat HEAD~20 2>/dev/null | tail -1 || echo "n/a"`
- Files touched: !`git diff --name-only "@{7.days.ago}" 2>/dev/null | sort -u | head -40 || git diff --name-only HEAD~20 2>/dev/null | sort -u | head -40`
- Deletions: !`git log --diff-filter=D --summary --since="7 days ago" 2>/dev/null | grep -i "delete mode" | head -12 || echo "none"`

## High-risk surface (scan these diffs closely)
- Auth / secrets: !`git diff "@{7.days.ago}" -- '*auth*' '*login*' '*password*' '*token*' '*secret*' '*.env*' 2>/dev/null | head -40 || echo "none touched"`
- Data / migrations: !`git diff "@{7.days.ago}" -- '*migration*' '*schema*' '*model*' '*entity*' 2>/dev/null | head -40 || echo "none touched"`
- Config / deploy: !`git diff "@{7.days.ago}" -- '*config*' '*.yml' '*.yaml' 'Dockerfile*' '*deploy*' 2>/dev/null | head -30 || echo "none touched"`

## Output — risk-ranked, scary stuff first
```
📊 Week summary:      X commits · X files · +X/-X lines
🔴 Needs human review: <auth, DB, config, deletions — file + one-line why>
🟡 Worth checking:     <public APIs, shared utilities>
🟢 Routine:            <tests, docs, internal refactors>
⚠️  Surprises:          <deleted files, anomalies, changes with no obvious reason>
```
For each 🔴 item, state the specific risk and what a reviewer should verify.
