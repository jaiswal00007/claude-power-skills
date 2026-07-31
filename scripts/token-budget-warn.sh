#!/usr/bin/env bash
# Token budget warning — warns when context proxy crosses TOKEN_BUDGET_WARN threshold.
# Runs as PostToolUse hook after format-lint and explain-diff.
# Proxy: word count of (git diff HEAD + decisions.md) × 4/3 ≈ token estimate.
# The 4/3 multiplier (≈0.75 words/token) is a rough heuristic for English prose + code
# mixed content. Actual token count will differ by ±30%. This is an early warning only —
# Claude's automatic compaction fires at 150k tokens regardless of this script.
# Override threshold: export TOKEN_BUDGET_WARN=60000 (warn earlier) or 100000 (later).
set -uo pipefail

THRESHOLD="${TOKEN_BUDGET_WARN:-80000}"

DIFF_WORDS=$(git diff HEAD 2>/dev/null | wc -w | tr -d ' ')
DECISIONS_WORDS=$(wc -w < decisions.md 2>/dev/null | tr -d ' ' || echo 0)
ESTIMATE=$(( (DIFF_WORDS + DECISIONS_WORDS) * 4 / 3 ))

if [ "$ESTIMATE" -gt "$THRESHOLD" ]; then
  echo "TOKEN BUDGET: Context estimated at ~${ESTIMATE} tokens (threshold: ${THRESHOLD})."
  echo "Consider /session-wrap to checkpoint before continuing."
  echo "Tip: compaction fires automatically at 150k — act now to preserve cache hits."
fi

exit 0
