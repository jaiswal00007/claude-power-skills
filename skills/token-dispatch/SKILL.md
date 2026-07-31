---
name: token-dispatch
description: Use when dispatching sub-agents for any multi-task work and wanting each agent to receive only the minimal context slice it needs — prevents context bleed, keeps agent briefs under 300 tokens, and preserves the stable prefix cache across parallel agents
---

# Token Dispatch

## Overview

Instead of passing the full conversation to sub-agents (which carries thousands of tokens of irrelevant history), the dispatcher extracts a **≤300-token brief** from the spine files for each agent. Each agent gets exactly what it needs — nothing more.

## Why This Matters

A sub-agent dispatched with the full conversation context:
- Carries 3000–8000 tokens of history it doesn't need
- Can't cache its prefix (every agent has a different history)
- Takes longer to reach the actual task

A sub-agent dispatched with a minimal brief:
- Carries ~150–300 tokens — only task + relevant spec + stack
- Its stable prefix can be cached across similar agents
- Reaches the task immediately

## Core Pattern

### Step 1 — Extract the task brief from plan.md

```bash
# Read the current task from plan.md
grep -A3 "^- \[ \]" plan.md | head -4
```

### Step 2 — Identify the relevant spec section

```bash
# Read only the section of spec.md that applies to this task
grep -A20 "^## <relevant-section>" spec.md
```

### Step 3 — Build the minimal brief (≤300 tokens target)

```
Task: <plan.md task text — 50-100 tokens>

Spec rules that apply:
<spec.md relevant section — 100-150 tokens>

Stack: <context.md §stack — 1-2 lines, ~30 tokens>

Return: <structured output schema — 20-50 tokens>
```

**Check brief size before dispatching:**
```bash
echo "<brief text>" | wc -w
# Target: under 225 words (~300 tokens)
# If over: trim spec section to key rules only
```

### Step 4 — Dispatch in parallel, not sequentially

```
# Wrong — sequential, context accumulates:
agent1 → wait → agent2 → wait → agent3

# Right — parallel, each gets its own minimal brief:
agent1 (brief1) ┐
agent2 (brief2) ├→ all run simultaneously
agent3 (brief3) ┘
```

### Step 5 — Collect and merge results

Each agent returns structured output (JSON or markdown table). Merge at the dispatcher level — not by passing one agent's output to the next agent as context.

## Brief Template

```
Task: [TASK FROM PLAN.MD]

Spec rules:
[RELEVANT SECTION FROM SPEC.MD — key rules only]

Stack: [CONTEXT.MD §STACK — one line]

Return format: [JSON SCHEMA OR MARKDOWN STRUCTURE]
```

## Quick Reference

| Check | Command | Target |
|---|---|---|
| Brief word count | `echo "<brief>" \| wc -w` | ≤225 words |
| Tasks remaining | `grep "^- \[ \]" plan.md \| wc -l` | — |
| Spec section | `grep -A20 "^## <section>" spec.md` | — |
| Stack line | `grep -A3 "^## §stack" context.md` | — |

## Common Mistakes

- **Passing full conversation as context** — the most common mistake. Sub-agents don't need conversation history; they need the task brief.
- **Sequential dispatch when tasks are independent** — if task B doesn't depend on task A's output, run them in parallel.
- **Forgetting the return schema** — agents without a clear output format produce verbose prose that's expensive to parse and re-summarise.
- **Briefs over 300 tokens** — almost always caused by copying an entire spec section instead of extracting only the rules relevant to this specific task.
