# ⚡ Claude Power Skills

**A single [Claude Code](https://claude.com/claude-code) plugin: 17 engineering-discipline skills + automatic hooks that turn your AI agent from a code generator into a disciplined engineering teammate.**

Safety gates. Adversarial multi-agent review. Automated `git bisect` bug hunting. Coverage repair. Spec-driven TDD. Instant onboarding with architecture diagrams. Plus **hooks** that auto-format, lint, explain every change, and brake on risky work — all in one install.

## Install (one command)

```
/plugin marketplace add YOUR_USERNAME/claude-power-skills
/plugin install claude-power-skills@claude-power-skills
```

Everything — all 17 skills **and** the hooks — installs together. Type `/` to see them; the hooks start firing automatically. (Testing locally first? `/plugin marketplace add /path/to/claude-power-skills`.)

---

## Why this exists

AI agents are fast but reckless. They rewrite 40 files when asked to change 2, validate their own work, and declare victory without running the tests. This plugin adds the missing engineering discipline two ways: **skills** you invoke deliberately, and **hooks** that run automatically on every edit whether you remember them or not.

Every skill is **language-agnostic** (Node, Python, Rust, Go, Java — auto-detected), degrades gracefully when `gh`/git/tests are missing, and costs **zero tokens until invoked**.

## The hooks (automatic, every edit/turn)

- **Auto-format + lint** — `PostToolUse` runs prettier/eslint/ruff/black/gofmt/rustfmt on each edited file.
- **Explain every change** — a cheap, AI-free `git diff` summary injected into context after every edit.
- **Review-gate** — a `Stop` hook that pauses on risky work (auth/secrets/migrations, failing tests, big blast radius) and makes Claude lay out options to discuss instead of barreling on.

---

## The 17 skills

### 🛡️ Safety & trust
| Command | What it does |
|---|---|
| `/safe-task <task>` | Safety gate before any work — snapshot, danger-zone scan (auth/db/payments), scope estimate. Stops and asks before risky work. |
| `/scope-check <task>` | Blast-radius analysis before writing code — files, downstream importers, tests, a 1–10 risk score. |
| `/shadow-reviewer` | **⭐ Adversarial multi-agent review.** Spawns 3 skeptical reviewers in parallel (security · edge-cases · 3am-pager), runs your tests, and a judge delivers a `SHIP / NEEDS CHANGES / DO NOT MERGE` verdict. |
| `/ai-audit` | Weekly forensic audit of recent changes, risk-ranked — the scary auth/db/config diffs surface first. |

### 🔧 Workflow
| Command | What it does |
|---|---|
| `/autopilot <issue#>` | GitHub issue → plan (you approve) → TDD → verified PR. Gated at every risky step. |
| `/time-machine <bug>` | **⭐ Finds the bug's birth certificate** via automated `git bisect run` — the exact first-bad commit, author, and the hunk that broke it. |
| `/create-spec <feature>` | Spec-driven development — write the spec, get approval, turn each rule into a failing test, then implement. |
| `/sonar-fix <file>` | Fixes coverage-gate failures by writing tests that verify *real behavior* — not filler to game the metric. |

### 📅 Daily driver
| Command | What it does |
|---|---|
| `/standup` | Your daily standup from git history + open PRs + failing tests. Sounds like a human, not a report bot. |
| `/onboard-me` | **⭐ 5-minute codebase tour with a Mermaid architecture diagram** (renders on GitHub), the 5 files to read first, and the 3 things never to touch. |
| `/session-wrap` | End-of-session handoff — what was done, what's next, decisions made — saved to disk and folded into `CLAUDE.md`. |

### 🧪 Meta / quality
| Command | What it does |
|---|---|
| `/mutation-test <file>` | **⭐ Proves your tests are real** by injecting 5 subtle bugs one at a time and checking which slip through. Gives a mutation score + the exact tests to add. |
| `/suggest-agents` | Reads your repo and recommends the custom subagents worth creating, ranked by impact. |
| `/create-agent <desc>` | Generates a complete, ready-to-save `.claude/agents/` subagent file tailored to your codebase. |

⭐ = the ones that make people go *"wait, it can do that?"*

### 🔁 Dev loop (chain these + the hooks)
| Command | What it does |
|---|---|
| `/write-tests [file]` | Behavior-focused tests, framework auto-detected — TDD-first or right after implementation. |
| `/code-review [paths]` | Fast diff-scoped 3-agent review + a `SHIP / NEEDS CHANGES / DO NOT MERGE` verdict. Repeat-callable. |
| `/ship` | Opens a PR for the current branch with an auto-generated description; graceful fallback if `gh` is missing. |

**The loop:** `/create-spec` → *(plan mode)* → `/write-tests` → implement *(hooks format/lint/explain each edit)* → `/code-review` → `/ship` → `/standup`. The `Stop` review-gate hook pauses on risky work so you re-plan together instead of the loop halting.

---

## Install

```
/plugin marketplace add YOUR_USERNAME/claude-power-skills
/plugin install claude-power-skills@claude-power-skills
```

One install gets all 17 skills **and** the hooks. They're available globally, in every project. Edit a skill's `SKILL.md` and it takes effect immediately; after editing `hooks/` or `scripts/`, run `/reload-plugins`.

---

## How it works

Each skill is a `skills/<name>/SKILL.md` with YAML frontmatter and inline shell injection:

```markdown
---
name: standup
description: Auto-generate your daily standup
trigger: /standup
---

## Yesterday
- Commits: !`git log --oneline --since="yesterday" 2>/dev/null`
...
```

The `` !`command` `` syntax runs live shell commands and injects the output into Claude's context when you invoke the skill — so Claude reasons over *your actual repo state*, not guesses. `$ARGUMENTS` passes whatever you type after the command. The **hooks** (`hooks/hooks.json` + `scripts/`) run automatically — no invocation needed.

---

## Requirements

- **Claude Code** (any recent version)
- **git** — most skills use it; they degrade gracefully without it
- **gh** (GitHub CLI) — optional, only `/autopilot`, `/standup`, `/ai-audit` use it and all have fallbacks

No language runtime is required to install — skills auto-detect Node / Python / Rust / Go / Java per project.

---

## Contributing

PRs welcome. A good skill is: one clear job, language-agnostic, graceful when tools are missing, and stops for human approval before anything destructive. Add `skills/<name>/SKILL.md`, add a row to a table above, open a PR.

## License

MIT — see [LICENSE](LICENSE). Use them, fork them, ship them.
