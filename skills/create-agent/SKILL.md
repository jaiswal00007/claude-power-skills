
---
name: create-agent
description: Generate a complete, ready-to-save .claude/agents/ subagent file from a name or description
---

Create a subagent for: $ARGUMENTS

## Ground it in this repo
- Layout: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" top-dirs`
- Conventions: !`cat CLAUDE.md 2>/dev/null | head -40 || echo "no CLAUDE.md"`
- Existing agents: !`ls .claude/agents/ 2>/dev/null || echo "none yet"`

## Rules for a good subagent
- The system prompt is specific to THIS codebase, not generic boilerplate.
- The tools list is minimal — only what the agent actually needs.
- The description is precise enough that Claude auto-selects it for the right task (include trigger keywords).
- Owned paths are explicit so the agent doesn't wander.
- Prefer read-only (Read/Grep/Glob) unless the job genuinely requires writing.

## Generate the file

```markdown
---
name: <kebab-case-name>
description: <one sentence, precise enough for auto-selection; include trigger keywords>
tools: <comma-separated minimal set: Read, Grep, Glob, Bash, Edit, Write>
---

# <Agent Display Name>

## Role
<2 sentences: what it does and what it must never do>

## This codebase
Key files you own:
- <real paths from the repo signals above>

## How you work
1. <step-by-step operating procedure>
2. Cite file + line for every claim.
3. Never touch files outside your owned domain.
4. If unsure, say so — don't guess.

## Rules
- <non-negotiable constraints specific to this domain>
```

## Save it
Ask: *"Save this to `.claude/agents/<name>.md`? (yes/no)"*
On yes: create `.claude/agents/` if needed, write the file, then confirm with an example task to test it.
