---
name: safe-task
description: Safety checklist before any task — git snapshot, scope estimate, danger-zone check
---

Before starting any task, run this safety gate. Do NOT write code until it is complete.

## Snapshot the current state
- Uncommitted changes: !`python3 -c "import subprocess; out=subprocess.run(['git','status','--short'],capture_output=True,text=True).stdout; print(len(out.splitlines()))"` files dirty
- Current branch: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not a git repo"`
- Recent history: !`git log --oneline -5 2>/dev/null || echo "no history"`
- Create a restore point: !`python3 -c "import subprocess; sha=subprocess.run(['git','stash','create'],capture_output=True,text=True).stdout.strip(); print(sha+' (stash object — recover with: git stash apply '+sha+')') if sha else print('working tree clean — HEAD is your restore point')"`

## Assess the task
Task to assess: $ARGUMENTS

1. Estimate scope: how many files will this realistically touch?
2. Danger-zone scan — does the task touch any of these?
   !`python3 -c "import subprocess,re; files=subprocess.run(['git','ls-files'],capture_output=True,text=True).stdout.split(); found=[f for f in files if re.search(r'auth|login|password|secret|token|payment|billing|migration|schema|\.env|Dockerfile|deploy|prod',f,re.I)]; [print(f) for f in found[:15]] or print('(no danger-zone files found)')"`
3. If scope > 10 files OR it touches auth / DB / payments / config / deploy →
   **STOP.** State the risk in one sentence and ask the user to confirm before proceeding.

## Commit to a plan
State the plan in ONE paragraph — what you'll change and why — before writing any code.
Only proceed once this gate is complete and (if triggered) the user has confirmed.
