#!/usr/bin/env bash
# claude-power-skills installer
# Symlinks (or copies) every skill in ./skills into ~/.claude/skills/
set -euo pipefail

DEST="${HOME}/.claude/skills"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"
MODE="${1:-symlink}"   # symlink (default) | copy

mkdir -p "$DEST"

echo "Installing claude-power-skills → $DEST  (mode: $MODE)"
count=0
for f in "$SRC"/*.md; do
  name="$(basename "$f")"
  target="$DEST/$name"
  if [[ -e "$target" || -L "$target" ]]; then
    echo "  ~ overwriting $name"
    rm -f "$target"
  else
    echo "  + installing $name"
  fi
  if [[ "$MODE" == "copy" ]]; then
    cp "$f" "$target"
  else
    ln -s "$f" "$target"
  fi
  count=$((count+1))
done

echo ""
echo "✅ Installed $count skills. Open Claude Code and type / to see them."
echo "   Try:  /standup   ·   /onboard-me   ·   /shadow-reviewer"
