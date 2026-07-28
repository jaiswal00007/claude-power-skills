# 🔁 devloop

**A Claude Code plugin that turns spec → ship into one enforced loop.** Skills give you the
deliberate steps (`/create-spec`, `/write-tests`, `/code-review`, `/ship`, `/standup`); hooks run
the involuntary hygiene on *every* edit (auto-format, lint, explain-the-change) and put a review
brake at the end of every turn.

The difference from a pile of slash commands: **hooks fire whether or not you remember them.**
Formatting always happens. Every change gets narrated. Risky work pauses for a conversation
instead of sailing through.

---

## The loop

| # | Step | Driver | What happens |
|---|------|--------|--------------|
| 1 | `/create-spec <feature>` | skill | Write the spec, stop for your approval |
| 2 | *switch to plan mode* (Shift+Tab) | **you** | Plan the implementation, verify the plan |
| 3 | `/write-tests` | skill | Behavior-focused tests (TDD-first, or right after impl) |
| 4 | implement | Claude + **hooks** | Every edit auto-formats, lints, and gets a diff summary |
| 5 | `/code-review` | skill | 3 parallel reviewers → SHIP / NEEDS CHANGES / DO NOT MERGE |
| 6 | *risky change?* | **hook (Stop)** | Claude pauses and lays out options to discuss — loop continues |
| 7 | `/code-review` again | skill | Re-verdict after fixes |
| 8 | `/ship` | skill | Auto-generated PR from the diff + commits |
| 9 | `/standup` | skill | Log what you shipped, human-toned |

> **Step 2 is manual by design.** A hook *cannot* force plan mode — it's user-initiated only
> (Shift+Tab or `/plan`). `/create-spec` ends by reminding you to switch.

---

## What the hooks do (automatic, every time)

- **Auto-format + lint** — `PostToolUse` on every `Edit`/`Write`. Detects and runs whatever's
  installed: prettier + eslint, ruff/black, gofmt/goimports, rustfmt. Only touches the edited
  file. Never blocks — always exits clean.
- **Explain every change** — a cheap, AI-free `git diff` summary of the touched file
  (`+N / -M lines`, hunk headers, the first added lines) injected into context. Zero token cost.
- **Review-gate** — a `Stop` hook (a small verification agent) inspects the turn's changes. Clean
  work ends the turn immediately. Risky work (touched auth/secrets/migrations/`.env`, deleted
  tests, failing tests, stubbed logic, >~10 files) returns a **"stop coding, discuss options"**
  instruction — so Claude re-plans *with you* instead of barreling on. The loop keeps going; it
  doesn't halt.

**Hooks = involuntary hygiene + the safety brake. Skills = deliberate, AI-heavy reasoning.**

---

## Install

Requires: Claude Code, `git`, and `jq` (soft — hooks degrade gracefully without it). `gh` optional
(only `/ship` uses it, with a paste-ready fallback).

Install as a plugin (from a local marketplace or plugin dir), then:

```
/plugin           # confirm "devloop" is listed
/                 # confirm /create-spec, /write-tests, /code-review, /ship, /standup appear
/reload-plugins   # after editing hooks/ or scripts/ (skill edits are live)
```

Hooks live in `hooks/hooks.json` and fire automatically once the plugin is enabled.

---

## Layout

```
devloop/
├── .claude-plugin/plugin.json    # manifest
├── hooks/hooks.json              # PostToolUse (format+explain) + Stop (review-gate)
├── scripts/
│   ├── format-lint.sh            # language-agnostic formatter/linter on the touched file
│   ├── explain-diff.sh           # cheap git-diff summary → context
│   └── review-gate-prompt.md     # source-of-truth for the Stop agent prompt (inlined in hooks.json)
└── commands/
    ├── code-review.md            # fast diff-scoped 3-agent verdict
    ├── ship.md                   # PR from current branch, gh fallback
    ├── write-tests.md            # behavior-focused tests, framework auto-detected
    └── standup.md                # end-of-loop daily standup
```

## Notes

- **`/code-review` vs `/shadow-reviewer`** — `/code-review` is the fast, diff-scoped, repeat-callable
  variant built for the loop. `/shadow-reviewer` (in the parent skills pack) is the heavier
  standalone audit of the whole tree.
- **No AI cost on edits** — the per-edit hooks are pure shell. The only model call in the automatic
  path is the end-of-turn review-gate, and it's biased to pass clean turns instantly.
- **Editing the review-gate prompt** — change `scripts/review-gate-prompt.md`, then mirror it into
  the inlined string in `hooks/hooks.json` (that's what actually runs).

MIT — part of [claude-power-skills](../README.md).
