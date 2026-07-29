---
name: scope-check
description: Analyze the blast radius of a task before writing any code — files, importers, tests, risk score
---

Task: $ARGUMENTS

**Analysis only. Do NOT write any code until the user approves.**

## 1. Identify the target files
Name the files this task will most likely change. Then find who depends on them.

## 2. Map the blast radius
- Repo file types (to pick the right search): !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" file-types-short`
- Importers / references across the codebase (language-agnostic):
  !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" importers-count` files contain imports — after you name the target files, run `git grep -n "<basename>"` on each to find direct dependents.
- Tests in the repo: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" test-count-full` test files
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
