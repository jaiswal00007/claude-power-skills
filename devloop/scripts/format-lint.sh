#!/usr/bin/env bash
# devloop :: format-lint.sh
# PostToolUse(Edit|Write) hook. Reads tool-call JSON on stdin, formats/lints ONLY the
# touched file with whatever tool is installed, and prints one status line to stdout.
# Never blocks: always exits 0. Loop-safe: edits the file in place via the tool's own
# CLI (no Edit tool call), so it does not re-trigger PostToolUse.
set -uo pipefail

# --- extract the touched file from stdin (jq preferred, sed fallback) ---
input="$(cat 2>/dev/null || true)"
if command -v jq >/dev/null 2>&1; then
  FILE="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
else
  FILE="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi

[ -n "${FILE:-}" ] || exit 0
[ -f "$FILE" ] || exit 0

ext="${FILE##*.}"
ran=""
warn=""

# run a command if its binary exists; capture stderr tail on failure
try() {
  command -v "$1" >/dev/null 2>&1 || return 1
  local out
  if out="$("$@" 2>&1)"; then
    return 0
  else
    warn="${warn}${warn:+; }$1: $(printf '%s' "$out" | tail -1)"
    return 0   # non-fatal — we still exit 0
  fi
}

case "$ext" in
  js|jsx|ts|tsx|mjs|cjs|json|css|scss|less|html|md|yaml|yml)
    if try npx --no-install prettier --write "$FILE"; then ran="${ran}prettier "; fi
    if command -v npx >/dev/null 2>&1 && npx --no-install eslint --version >/dev/null 2>&1; then
      try npx --no-install eslint --fix "$FILE" && ran="${ran}eslint "
    fi
    ;;
  py)
    if command -v ruff >/dev/null 2>&1; then
      try ruff format "$FILE" && ran="${ran}ruff-format "
      try ruff check --fix "$FILE" && ran="${ran}ruff-lint "
    elif command -v black >/dev/null 2>&1; then
      try black -q "$FILE" && ran="${ran}black "
    fi
    ;;
  go)
    try gofmt -w "$FILE" && ran="${ran}gofmt "
    try goimports -w "$FILE" && ran="${ran}goimports "
    ;;
  rs)
    try rustfmt "$FILE" && ran="${ran}rustfmt "
    ;;
  *)
    echo "devloop: no formatter for .$ext — skipped ($FILE)"
    exit 0
    ;;
esac

if [ -z "$ran" ]; then
  echo "devloop: no formatter installed for .$ext — skipped ($FILE)"
else
  echo "devloop: formatted $FILE (${ran% })"
fi
[ -n "$warn" ] && echo "devloop: lint warnings: $warn"
exit 0

