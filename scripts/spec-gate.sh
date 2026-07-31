#!/usr/bin/env bash
# Spec gate — blocks Edit/Write if no spec.md exists for the current feature.
# Runs as PostToolUse hook before format-lint and explain-diff.
# Exit 1 aborts the hook chain; Claude Code will not proceed with the Edit/Write.
set -uo pipefail

SPEC_ROOT=".claude/specs"
SPEC_FOUND=""

# Check .claude/specs/*.md
if ls "${SPEC_ROOT}"/*.md 2>/dev/null | head -1 | grep -q .; then
  SPEC_FOUND=$(ls "${SPEC_ROOT}"/*.md 2>/dev/null | head -1)
fi

# Check repo-root spec.md
if [ -z "$SPEC_FOUND" ] && [ -f "spec.md" ]; then
  SPEC_FOUND="spec.md"
fi

# Check CWD spec.md
if [ -z "$SPEC_FOUND" ] && [ -f "$(pwd)/spec.md" ]; then
  SPEC_FOUND="$(pwd)/spec.md"
fi

if [ -n "$SPEC_FOUND" ]; then
  echo "SPEC GATE: OK — spec found at ${SPEC_FOUND}"
  exit 0
fi

cat >&2 <<'EOF'
SPEC GATE: No specification found for this feature.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The edit has been written to disk (PostToolUse fires after edits).
Remaining hooks in this chain have been aborted.

Expected one of:
  .claude/specs/<feature>.md
  spec.md (repo root)

Run /create-spec <feature-name>, get the spec approved,
then continue editing.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
exit 1
