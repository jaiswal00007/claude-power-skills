---
name: scope-check
description: Analyze the blast radius of a task before writing any code — files, importers, tests, risk score
---

Task: $ARGUMENTS

**Analysis only. Do NOT write any code until the user approves.**

## 1. Identify the target files
Name the files this task will most likely change. Then find who depends on them.

## 2. Map the blast radius
- Repo file types (to pick the right search): !`python3 -c "import subprocess,collections; files=subprocess.run(['git','ls-files'],capture_output=True,text=True).stdout.split(); exts=collections.Counter(f.rsplit('.',1)[-1] if '.' in f else '(none)' for f in files); [print(f'{v:>6}  {k}') for k,v in exts.most_common(8)]"`
- Importers / references across the codebase (language-agnostic):
  !`python3 -c "import subprocess; out=subprocess.run(['git','grep','-lIn','-e','import','-e','require','-e','include','-e','use '],capture_output=True,text=True).stdout; print(len(out.splitlines()))"` files contain imports — after you name the target files, run `git grep -n "<basename>"` on each to find direct dependents.
- Tests in the repo: !`python3 -c "import subprocess,re; files=subprocess.run(['git','ls-files'],capture_output=True,text=True).stdout.split(); print(sum(1 for f in files if re.search(r'(test|spec|_test\.|\.test\.|\.spec\.)',f,re.I)))"` test files
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
