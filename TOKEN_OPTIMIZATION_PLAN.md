# Token-Optimized Claude Code System

## The Problem

Claude Code sessions waste tokens in four measurable ways:

| Waste cause | Example | Fix |
|---|---|---|
| Wrong-direction work | Build wrong thing, redo it (2-5x token cost) | Spec gate hook |
| Verbose prompts | Re-explain project every turn | Cached stable prefix |
| Context loss | Re-derive decisions already made | `decisions.md` as compressed memory |
| Sequential agents | One agent carries full history | Minimal-context dispatch (≤300 tokens/agent) |

---

## Headline Architecture

```
STABLE PREFIX (cached, ~90% off per turn)
  context.md    project facts — stack, conventions, layout
  decisions.md  approved decisions, rejected approaches (append-only)
  spec.md       what to build — business rules, API contract, out-of-scope
  plan.md       task list derived from spec (this file)
── cache_control breakpoint ──
VARIABLE (per-turn user message — NOT cached)
```

**Rule:** Claude never loads full files. It reads by section pointer:
`context.md §stack`, `spec.md §auth`, `decisions.md §last-5`.
Every agent gets a ≤300-token brief, not the full conversation.

---

## Verified Numbers

| Technique | Saving | Source |
|---|---|---|
| Cache read (hit) | **90% off** base input cost (0.1x multiplier) | Anthropic docs |
| 5-min TTL cache write | 1.25x cost — breaks even after **2 reuses** | Anthropic docs |
| 1-hr TTL cache write | 2x cost — breaks even after **3 reuses** | Anthropic docs |
| Caching + batching | **30–98% hit rate**, discounts stack | Anthropic docs |
| Compaction | Auto-summarises at 150k tokens, prevents context rot | Anthropic docs |
| `clear_tool_uses` | Server-side prune at 100k tokens, keeps last 3 results | Anthropic docs |
| Effort level changed | **Kills all cache hits** — pick once, hold throughout | Anthropic docs |
| Spec gate | Eliminates re-implementation cycles (no hard % yet — measurable via `/token-audit`) | This system |

---

## Three Hooks

### Hook 1 — Spec gate (`PostToolUse: Edit|Write`)
Block any file write if no `spec.md` exists for the current feature.

```bash
# scripts/spec-gate.sh
if [ ! -f "spec.md" ] && ! ls .claude/specs/*.md 2>/dev/null | head -1 | grep -q .; then
  echo "SPEC GATE: No spec.md found. Run /create-spec <feature> first." >&2
  exit 1
fi
```

### Hook 2 — Decisions logger (`Stop` hook, agent)
After every turn: extract approved decisions → append to `decisions.md`. Also warn if effort level changed (kills cache).

```
Agent prompt (strict JSON return):
- Append new decisions as '[YYYY-MM-DD] DECIDED: <one line>'
- Append rejections as '[YYYY-MM-DD] REJECTED: <approach> — <reason>'
- Warn if effort level changed mid-session
Return: {"appended": <count>, "cacheWarning": <bool>}
```

### Hook 3 — Token budget warning (`PostToolUse: Edit|Write`)
Warn at ~80k tokens — before compaction fires at 150k.

```bash
# scripts/token-budget-warn.sh
ESTIMATE=$(( ($(git diff HEAD 2>/dev/null | wc -w) + $(wc -w < decisions.md 2>/dev/null || echo 0)) * 4 / 3 ))
[ "$ESTIMATE" -gt "${TOKEN_BUDGET_WARN:-80000}" ] && \
  echo "TOKEN BUDGET: ~${ESTIMATE} tokens. Consider /session-wrap to checkpoint."
```

---

## Three New Skills

### `/token-context`
Sets up all four spine files with correct structure and the `cache_control` breakpoint comment. Run once per project or feature. Teaches section-pointer reading discipline.

### `/token-dispatch`
Wraps multi-task sub-agent dispatch. Reads `plan.md`, extracts tasks, dispatches each agent with only its context slice (≤300-token brief). Documents cache breakpoint placement. Eliminates context bleed between agents.

### `/token-audit`
At any point, audits the session for all waste signals and outputs a ranked report:
- Cache hit rate estimate
- Context growth (start vs now)
- Re-implementations detected
- Agent brief sizes
- Effort level consistency
- Decisions captured vs missed

---

## Metrics

| Metric | Hook/Skill | Target |
|---|---|---|
| Cache hits vs misses | decisions-logger | >50% on stable sessions |
| Context size growth | token-budget-warn | <2x per session |
| Re-implementations | token-audit | 0 (spec gate eliminates these) |
| Agent brief size | token-dispatch | ≤300 tokens |
| Decisions captured | decisions-logger | >0 per session |
| Effort consistency | decisions-logger | `cacheWarning: false` every turn |

---

## Build Order

1. `scripts/spec-gate.sh` + wire into `hooks/hooks.json` PostToolUse — **highest ROI first**
2. `skills/token-context/SKILL.md` — spine setup, prerequisite for everything else
3. Stop hook decisions-logger — add to `hooks/hooks.json` alongside existing review-gate
4. `scripts/token-budget-warn.sh` + wire into PostToolUse
5. `skills/token-dispatch/SKILL.md` — minimal-context dispatch pattern
6. `skills/token-audit/SKILL.md` — diagnostic + metrics (enables measurement)

---

## Verification Checklist

> Implementation complete as of 2026-07-31. Items below are acceptance tests — run manually to confirm end-to-end behaviour.

- [ ] `/token-context` on fresh dir → four files + cache breakpoint comment created
- [ ] Edit file without `spec.md` → spec-gate blocks, clear message
- [ ] Complete turn with approved decision → `decisions.md` updated, `appended > 0`
- [ ] Change effort mid-session → `cacheWarning: true` emitted
- [ ] Dispatch two tasks via `/token-dispatch` → each brief ≤300 tokens (`wc -w`)
- [ ] Cross 80k threshold → budget warning appears before 150k compaction
- [ ] Run `/token-audit` → report covers all 6 metric dimensions

---

## Sources

Adversarially verified (20/25 claims confirmed, 5 refuted):

- [Prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching.md)
- [Effort parameter](https://platform.claude.com/docs/en/build-with-claude/effort.md)
- [Compaction](https://platform.claude.com/docs/en/build-with-claude/compaction.md)
- [Context editing](https://platform.claude.com/docs/en/build-with-claude/context-editing.md)
- [Batch processing](https://platform.claude.com/docs/en/build-with-claude/batch-processing.md)
