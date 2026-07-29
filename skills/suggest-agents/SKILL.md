---
name: suggest-agents
description: Analyze this repo and recommend which custom subagents to create, ranked by impact
---

Analyze this repository and recommend the subagents worth creating for it.

## Repo signals
- Top-level layout: !`git ls-files 2>/dev/null | sed -n 's/\/.*/\//p' | sort -u | head -25`
- File-type mix: !`git ls-files 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10`
- Manifests: !`ls package.json pyproject.toml Cargo.toml go.mod pom.xml 2>/dev/null`
- Test footprint: !`git ls-files 2>/dev/null | grep -iE '(test|spec)' | wc -l | tr -d ' '` test files
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
