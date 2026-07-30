---
name: time-machine
description: Use when you need to find the exact commit that introduced a bug — runs automated git bisect with a repro command, or falls back to manual archaeology, and delivers a precise birth certificate for the bug
---

# time-machine

## Overview

Forensic bug archaeology: finds the exact commit that introduced a bug and explains the mechanism. Uses automated `git bisect run` when a repro command exists; falls back to manual diff inspection otherwise. Diagnosis only — does not fix.

## When to Use

- "When did this regression appear?"
- "Find the commit that broke X"
- Any bug where the root cause commit is unknown

**Not for:** fixing bugs — this skill stops at a precise diagnosis.

## Core Pattern

### Step 1 — Establish the crime scene

```bash
# Where does the symptom live?
git grep -nI "<symptom keyword>" 2>/dev/null | head -15

# Recent history
git log --oneline -20 2>/dev/null

# Detect test runner
ls package.json pytest.ini go.mod Makefile 2>/dev/null
```

### Step 2 — Choose the strategy

**Preferred — automated bisect** (when a repro command exists):

Ask the user (or infer) a command that exits non-zero when the bug is present — e.g. a single failing test. Find a known-good older commit, then:

```bash
git bisect start
git bisect bad HEAD
git bisect good <known-good-sha>       # e.g. a tag or commit from before the bug
git bisect run <repro-command>          # e.g.: npm test -- path/to/failing.test
git bisect reset                        # ALWAYS reset when done
```

`git bisect run` prints `<sha> is the first bad commit`. That is the answer.

**Fallback — manual archaeology** (no repro command):

```bash
# Commits touching the files where the symptom lives
git log --oneline -8 -- $(git grep -lI "<symptom>" 2>/dev/null | head -3) 2>/dev/null
```

Read each suspect's diff with `git show <sha>` and reason about which one flipped the behavior.

### Step 3 — Deliver the timeline

```
🕰  BUG BIRTH CERTIFICATE
First bad commit:  <sha>
Author / date:     <who> / <when>
What changed:      <the specific hunk that broke it>
Why it broke:      <mechanism — the exact logic that flipped>
Last good state:   <sha before it>
```

Do not fix it unless asked.

## Common Mistakes

- **Forgetting `git bisect reset`** — always reset when done; a bisect left running corrupts your working tree state.
- **Using the automated path without a reliable repro command** — a flaky test produces a wrong bisect result; verify the repro command is deterministic first.
- **Diagnosing vaguely** — "something changed in auth" is not a birth certificate; name the exact hunk and the exact mechanism.
