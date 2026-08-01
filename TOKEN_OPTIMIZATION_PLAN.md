# Token-Optimized Claude Code — Workflow Playbook

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Guide a developer from project start to merged PR using the token optimization system — achieving measurable cost reduction with 4 tracked metrics.

**Architecture:** Stable 4-file prefix cached at the Claude API level (90% off per hit) + spec-gate hook preventing wrong-direction work + minimal-context agent dispatch (≤300 tokens per agent). Every step in this guide is a slash command or a clearly labeled Claude action.

**Tech Stack:** Claude Code CLI, claude-power-skills plugin v0.3.x, `gh` CLI (for `/ship`)

## Global Constraints

- Never change effort level mid-session — one effort level per session, picked at start
- Never edit `context.md` mid-session — update only at session boundaries
- Every file edit requires a spec in `.claude/specs/` or `spec.md` at repo root (spec-gate hook enforces this)
- Sub-agent briefs must be ≤300 tokens (~225 words) — use `/token-dispatch` to extract them

---

## Section 1 — Why: The 4 Waste Modes This System Eliminates

| Waste mode | What it costs | Fix in this system |
|---|---|---|
| Re-implementation without spec | 2–5× token cost per redo | Spec-gate hook blocks edits without spec |
| Full context passed to sub-agents | 3,000–8,000 tokens of irrelevant history per agent | `/token-dispatch` caps briefs at ≤300 tokens |
| Lost decisions re-derived next session | Hundreds of tokens to re-explain what was already decided | `decisions.md` — read at session start |
| No warning before 150k compaction | Forced summarisation mid-task = context loss | Token-budget-warn hook fires at 80k |

**What the system saves (verified numbers):**

| Technique | Saving | Source |
|---|---|---|
| Cache read hit | **90% off** base input cost (0.1× multiplier) | Anthropic docs |
| 5-min TTL cache write | 1.25× cost — breaks even after 2 reuses | Anthropic docs |
| Spec gate | Eliminates re-implementation cycles | This system |
| Minimal agent briefs | 94% less context cost (50k → 3k for 10 agents) | This system |

**Anti-patterns that kill savings — avoid these:**
- Editing `context.md` mid-session → cache miss on that turn
- Changing effort level mid-session → invalidates all cache hits
- Passing full conversation to sub-agents → 3,000–8,000 tokens of irrelevant history
- Skipping `decisions.md` read at session start → re-derive decisions already made

---

## Section 2 — Quick-Start

```
/token-context → /create-spec → writing-plans → implement → verify → /shadow-reviewer → /ship
```

Run `/token-audit` at any point to see your 4 cost metrics.

**Prerequisites:**
```bash
/plugin marketplace add jaiswal00007/claude-power-skills
/plugin install claude-power-skills@claude-power-skills
```
Verify install: type `/token-context` — if it autocompletes, you're ready.

---

## Section 3 — The 7-Step Workflow

### Step 1 — `/token-context` (run once per project)

**Trigger:** Type `/token-context` in your project root.

**What Claude does:**
- Creates `.claude/specs/` directory (checked by spec-gate hook on every edit)
- Creates 4 spine files at repo root:

| File | Contents | TTL |
|---|---|---|
| `context.md` | Stack, conventions, layout — fill in once | Project lifetime |
| `decisions.md` | Append-only log — starts empty, you append decisions manually | Permanent |
| `spec.md` | Stub — replaced per feature via `/create-spec` | Per feature |
| `plan.md` | Stub — expanded via writing-plans each session | Per session |

- Adds cache breakpoint at end of `context.md`:
  ```markdown
  ## §cache-breakpoint
  <!-- claude: cache_control breakpoint — stable prefix ends here -->
  ```

**Reading discipline (established here, enforced throughout):**
```
context.md §stack       ← read only this section, not the full file
context.md §layout      ← read only this section
decisions.md            ← always full-read (small by design)
spec.md §business-rules ← read only the relevant section
plan.md                 ← read current task only
```

**Cost signal:** After this step, every subsequent turn reads the 4 files from cache at 10% of base input cost.

**Exit condition:** 4 files exist at repo root, `.claude/specs/` exists, cache breakpoint visible in `context.md`.

**Fill in `context.md` now** — the more accurate it is, the more you save:
```markdown
# Project Context

## §stack
<language, runtime version, framework, database, test runner>

## §conventions
<naming conventions, file layout rules, patterns to follow>

## §layout
<key directories and what they contain>

## §cache-breakpoint
<!-- claude: cache_control breakpoint — stable prefix ends here -->
```

---

### Step 2 — `/create-spec <feature-name>`

**Trigger:** Type `/create-spec <feature-name>` when starting a new feature.

**What Claude does (Phase 1 — spec only, no code):**
- Reads `context.md §stack` and `§layout` by section pointer (not full file)
- Detects test runner: `ls package.json pytest.ini go.mod Makefile 2>/dev/null`
- Writes `spec.md` and `.claude/specs/<feature-name>.md` with this structure:
  ```markdown
  ## Feature Specification: <name>

  ### What it does (2 sentences)

  ### Business rules
  - One bullet per rule — each bullet becomes exactly one test
  - Cover: happy path, validation, edge cases, error cases

  ### API contract
  - Input:  parameters, types, validation
  - Output: success response shape
  - Errors: every error case with its message

  ### Edge cases
  - Empty/null inputs, boundary values, concurrency, unauthorized access

  ### Out of scope
  - What this feature explicitly does NOT do
  ```
- **HARD STOP — shows spec, waits for explicit user approval. No code, no tests until you type "approved" or equivalent.**

**What Claude does (Phase 2 — after approval only):**
- Generates one failing test per business rule bullet
- Runs test suite — all new tests must FAIL (this is correct — no implementation yet)
- Reports: `N tests generated, N failing. Ready for implementation.`

**Cost signal:** Spec-gate hook now allows file edits (it checks `.claude/specs/<feature-name>.md`). Without this, every edit fires the gate and aborts subsequent hooks.

**Exit condition:** `spec.md` approved, N failing tests confirmed, spec-gate hook no longer blocks.

---

### Step 3 — Switch to Plan (Claude invokes `writing-plans`)

**Trigger:** After spec approval, Claude automatically invokes `superpowers:writing-plans`.

**What Claude does:**
- Reads `spec.md §business-rules` and `§api-contract` by section pointer
- Reads `context.md §stack` for tech stack line
- Expands `plan.md` stub into a full task list with this header:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [one sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [key technologies]

## Global Constraints
[version floors, naming rules, platform requirements — one line each]
```

- Each task in `plan.md` has: exact file paths, actual test code (no placeholders), implementation code block, exact test command with expected output, commit step
- Saves full plan to `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`
- Self-reviews plan before presenting: checks spec coverage, scans for placeholders, verifies type/name consistency

**Cost signal:** `/token-dispatch` will extract ≤300-token briefs from `plan.md` + `spec.md` for each sub-agent — no full context bleed.

**Exit condition:** `plan.md` has all tasks as unchecked `- [ ]` items. Claude presents:
> "Plan complete. Two execution options:
> 1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks
> 2. **Inline Execution** — execute in this session with checkpoints"

---

### Step 4 — Implement (per task via `/token-dispatch`)

**Trigger:** Choose execution option at end of Step 3. For each task:

**What Claude does:**
- Reads `plan.md` current task only (not full file)
- Builds ≤300-token brief using this template:
  ```
  Task: [plan.md task text — 50-100 tokens]

  Spec rules that apply:
  [spec.md relevant section — 100-150 tokens]

  Stack: [context.md §stack — 1-2 lines, ~30 tokens]

  Return: [structured output schema — 20-50 tokens]
  ```
- Dispatches sub-agent with that brief (not the full conversation)
- Receives result, marks task `- [x]` in `plan.md`
- Append any key decisions to `decisions.md` manually before ending the session

**Verify brief size before dispatch:**
```bash
echo "<brief text>" | wc -w   # must be ≤225 words
```

**Cost signal:** 10 parallel agents × 300 tokens = 3,000 tokens context overhead. Same 10 agents with full conversation = 30,000–80,000 tokens.

**Exit condition:** All tasks `- [x]` in `plan.md`.

---

### Step 5 — Verify Each Task

**Trigger:** After each sub-agent returns, before marking `- [x]`.

**What Claude does:**
- Runs the test command specified in the task (exact command from `plan.md`)
- Expected: previously-failing test now passes
- If test fails: stops, creates targeted debug brief via `/token-dispatch` (does NOT load full context to diagnose)
- If token budget warning fires at 80k: run `/session-wrap` before continuing

**Token budget warning check:**
```bash
# Watch for this output from token-budget-warn hook:
# ⚠ Token budget: ~80k estimated. Consider /session-wrap before 150k compaction.
```

**Exit condition:** All tests pass, `plan.md` fully checked off.

---

### Step 6 — `/shadow-reviewer`

**Trigger:** Type `/shadow-reviewer` after all tasks pass.

**What Claude does:**
- Gathers diff: `git diff HEAD | head -400` and `git diff HEAD --name-only`
- Spawns 3 adversarial reviewers **in parallel** (single message, 3 Agent calls):
  1. **Security & data reviewer** — injection, auth bypass, leaked secrets, unsafe SQL/shell/eval, PII handling
  2. **Edge-case & correctness reviewer** — nulls, empty collections, off-by-one, concurrency, broken existing behavior
  3. **Operability reviewer** — missing logs/metrics, resource leaks, silent failure modes, no rollback path
- Runs tests and records pass/fail
- Synthesizes verdict (every claim cites `file:line`):

```
SHADOW REVIEW VERDICT
─────────────────────
🔴 Blockers:      [must fix before merge — file:line each]
🟡 Should fix:    [real issues, not merge-blocking]
🟢 Nits:          [style / preference]
Tests:            pass / fail / not-run

VERDICT: SAFE TO SHIP  |  NEEDS CHANGES  |  DO NOT MERGE
```

**Exit condition:** Verdict is `SAFE TO SHIP`.

---

### Step 7 — `/ship`

**Trigger:** Type `/ship` after `SAFE TO SHIP` verdict.

**What Claude does:**
- Verifies current branch is NOT default branch (refuses if on `main`/`master` — create a feature branch first)
- Reads `git log --oneline <default>..HEAD` and `git diff <default>...HEAD --stat`
- Generates PR title (≤70 chars) and body grounded in actual commits:
  ```markdown
  ## What changed
  - <bullets from actual commits/diff>

  ## Why
  - <intent / problem being solved>

  ## How it was verified
  - <tests run + /shadow-reviewer verdict>
  ```
- Runs:
  ```bash
  cat > /tmp/ship-pr-body.md <<'EOF'
  <generated body>
  EOF
  git push -u origin HEAD
  gh pr create --title "<generated title>" --body-file /tmp/ship-pr-body.md
  ```
- Prints returned PR URL

**Fallback if `gh` unavailable:** Prints branch name, push command, and ready-to-paste title + body — never hard-fails.

**Exit condition:** PR URL printed.

---

## Section 4 — Metrics

Run `/token-audit` at end of any session to measure all 4 KPIs:

| Metric | Target | How to check | What breaks it |
|---|---|---|---|
| Cost per session ($) | Trending down session-over-session | `/token-audit` ranked report | Not using cache breakpoint; effort changes |
| Cache hit rate | >50% on stable sessions | `/token-audit` → dimension 1 | Editing `context.md` mid-session; changing effort level |
| Re-implementation count | 0 | `/token-audit` → dimension 3 | Starting implementation without spec approval |
| Context growth factor | <2× per session | `/token-audit` → dimension 2 | Long sessions without `/session-wrap` at 80k warning |

**When to run `/token-audit`:**
- End of every session (establish baseline; track trend)
- After first-time setup (before/after comparison)
- When a session felt expensive or slow

**Reading the ranked report:**
- Fix `CRITICAL` findings first — they account for 80%+ of waste
- `decisions captured = 0` → append decisions to `decisions.md` manually at session end
- `cache hit rate < 50%` → check effort level held constant; verify `context.md` not edited mid-session
- `re-implementations > 0` → spec-gate hook may not be wired or was bypassed

**Session start checklist (run mentally every session):**
```
1. Pick effort level — /effort low | medium | high — don't change it
2. Read decisions.md — what did we decide last time?
3. /create-spec if starting a new feature
```

---

## Section 5 — Verification (Acceptance Tests)

Run these manually to confirm the system is working end-to-end:

- [ ] **Spine creation:** `/token-context` on empty dir → `context.md`, `decisions.md`, `spec.md`, `plan.md` created + `.claude/specs/` directory + cache breakpoint comment in `context.md`
- [ ] **Spec gate:** Edit any file without a spec in `.claude/specs/` → hook fires, message includes "edit already written, remaining hooks aborted"
- [ ] **Brief size:** Dispatch two tasks via `/token-dispatch` → `echo "<brief>" | wc -w` shows ≤225 words for each
- [ ] **Budget warning:** Cross 80k token threshold → `⚠ Token budget` warning appears before 150k compaction
- [ ] **Full audit coverage:** `/token-audit` → report covers all 6 dimensions: cache rate, context growth, re-impls, brief sizes, decisions captured, effort consistency

---

## Known Issues

**Acceptance tests not yet verified**
Implementation was marked complete 2026-07-31. The 5 acceptance tests above have not been run end-to-end. Treat them as "verify on first use."

---



## Sources

- [Prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching.md)
- [Effort parameter](https://platform.claude.com/docs/en/build-with-claude/effort.md)
- [Compaction](https://platform.claude.com/docs/en/build-with-claude/compaction.md)
- [Context editing](https://platform.claude.com/docs/en/build-with-claude/context-editing.md)
- [Batch processing](https://platform.claude.com/docs/en/build-with-claude/batch-processing.md)
