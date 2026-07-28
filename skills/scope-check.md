---
name: scope-check
description: Analyze the blast radius of a task before writing any code — files, importers, tests, risk score
trigger: /scope-check
---

Task: $ARGUMENTS

**Analysis only. Do NOT write any code until the user approves.**

## 1. Identify the target files
Name the files this task will most likely change. Then find who depends on them.

## 2. Map the blast radius
- Repo file types (to pick the right search): !`git ls-files 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -8`
- Importers / references across the codebase (language-agnostic):
  !`git ls-files 2>/dev/null | head -1 >/dev/null; git grep -lIn -e 'import' -e 'require' -e 'include' -e 'use ' 2>/dev/null | wc -l | tr -d ' '` files contain imports — after you name the target files, run `git grep -n "<basename>"` on each to find direct dependents.
- Tests in the repo: !`git ls-files 2>/dev/null | grep -iE '(test|spec|_test\.|\.test\.|\.spec\.)' | wc -l | tr -d ' '` test files
- Recent churn in this area: !`git log --oneline -10 2>/dev/null || echo "no history"`

## 3. Score the risk (1–10)
Weigh: number of files affected, whether public APIs / exported signatures change,
whether auth / DB / config / payments are involved, and test coverage of the area.

## 4. Report
```
Files to change:           N
Files affected downstream: N
Tests covering this area:  N
Risk score:                X/10
Recommendation:            proceed / proceed with caution / needs discussion
```

Then **wait for user approval** before touching any code.
