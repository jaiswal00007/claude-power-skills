---
name: suggest-agents
description: Analyze this repo and recommend which custom subagents to create, ranked by impact
---

Analyze this repository and recommend the subagents worth creating for it.

## Repo signals
- Top-level layout: !`python3 -c "import subprocess; files=subprocess.run(['git','ls-files'],capture_output=True,text=True).stdout.split(); dirs=sorted(set(f.split('/')[0]+'/' for f in files if '/' in f)); [print(d) for d in dirs[:25]]"`
- File-type mix: !`python3 -c "import subprocess,collections; files=subprocess.run(['git','ls-files'],capture_output=True,text=True).stdout.split(); exts=collections.Counter(f.rsplit('.',1)[-1] if '.' in f else '(none)' for f in files); [print(f'{v:>6}  {k}') for k,v in exts.most_common(10)]"`
- Manifests: !`python3 -c "import os; [print(f) for f in ['package.json','pyproject.toml','Cargo.toml','go.mod','pom.xml'] if os.path.exists(f)]"`
- Test footprint: !`python3 -c "import subprocess,re; files=subprocess.run(['git','ls-files'],capture_output=True,text=True).stdout.split(); print(sum(1 for f in files if re.search(r'(test|spec)',f,re.I)))"` test files
- Conventions: !`cat CLAUDE.md 2>/dev/null | head -40 || echo "no CLAUDE.md"`
- Existing agents: !`ls .claude/agents/ 2>/dev/null || echo "none yet"`

## Recommend 5–8 subagents tailored to THIS repo
For each:

```
Agent name:        kebab-case-name
When to use:       one-sentence trigger
Problem it solves: the pain point it removes
Owned domain:      which files/folders it focuses on
Tools it needs:    minimal set — Read / Grep / Glob / Bash / Edit / Write
System prompt gist: 2–3 sentences of its instructions
```

**Rank by:** (how often it'd be used) × (how much main-thread context it saves).
Favor read-only agents (Read/Grep/Glob) — they're safer and still high-value.

Finish with: *"Which should I create? Reply with the numbers or 'all'."*
Then use `/create-agent` to generate the chosen ones.
