#!/usr/bin/env bash
# devloop :: explain-diff.sh
# PostToolUse(Edit|Write) hook. Reads tool-call JSON on stdin and prints a cheap,
# AI-free summary of what changed in the touched file (line counts, hunk headers,
# a few added lines) to stdout so the assistant sees each change narrated.
# Never blocks: always exits 0.
set -uo pipefail

input="$(cat 2>/dev/null || true)"
if command -v jq >/dev/null 2>&1; then
  FILE="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
else
  FILE="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi

[ -n "${FILE:-}" ] || exit 0

if ! command -v git >/dev/null 2>&1 || ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "devloop: (no git) change to $FILE not summarized"
  exit 0
fi

# Pick ONE diff source so counts, hunks, and added-lines all agree.
# Prefer unstaged changes; fall back to staged (covers files added but not yet unstaged).
diffsrc="git diff"
numstat="$(git diff --numstat -- "$FILE" 2>/dev/null)"
if [ -z "$numstat" ]; then
  diffsrc="git diff --cached"
  numstat="$(git diff --cached --numstat -- "$FILE" 2>/dev/null)"
fi

if [ -z "$numstat" ]; then
  # brand-new untracked file
  if [ -f "$FILE" ]; then
    lines="$(wc -l < "$FILE" 2>/dev/null | tr -d ' ')"
    echo "devloop change summary — $FILE: new file (~${lines:-0} lines)"
  fi
  exit 0
fi

added="$(printf '%s' "$numstat" | awk '{print $1}')"
removed="$(printf '%s' "$numstat" | awk '{print $2}')"
echo "devloop change summary — $FILE: +${added:-0} / -${removed:-0} lines"

# hunk headers (function/context) — up to 3
$diffsrc -- "$FILE" 2>/dev/null | grep '^@@' | head -3 | sed 's/^/  hunk: /'
# first few genuinely added lines
$diffsrc -- "$FILE" 2>/dev/null | grep '^+' | grep -v '^+++' | head -3 | sed 's/^+/  + added:/'
exit 0
