#!/usr/bin/env bash
# decisions-precheck.sh — fast guard before decisions-logger agent.
# Reads the last assistant turn length from CLAUDE_TURN env var (word count proxy).
# Exits 1 (skip agent) if the turn is too short to contain any decisions.
# This prevents the decisions-logger from spinning up on trivial turns like "test" or "ok".
set -uo pipefail

# Minimum word count to warrant running the decisions-logger agent
MIN_WORDS="${DECISIONS_MIN_WORDS:-40}"

# CLAUDE_TURN contains the last assistant turn text (set by Claude Code hook runtime)
TURN_TEXT="${CLAUDE_TURN:-}"

if [ -z "$TURN_TEXT" ]; then
  # No turn text available — skip to be safe (don't waste tokens)
  exit 1
fi

WORD_COUNT=$(printf '%s' "$TURN_TEXT" | wc -w | tr -d ' ')

if [ "$WORD_COUNT" -lt "$MIN_WORDS" ]; then
  # Turn too short to contain decisions — skip agent
  exit 1
fi

# Turn is substantive — allow decisions-logger agent to run
exit 0
