---
name: onboard-me
description: 5-minute codebase onboarding with a Mermaid architecture diagram — what it does, key files, what not to touch
---

Onboard me to this codebase. I'm a new developer. Be concrete and cite real files.

## Signals (language-agnostic)
- README: !`cat README* 2>/dev/null | head -60 || echo "no README"`
- File-type breakdown: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" file-types`
- Top-level layout: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" top-dirs`
- Manifests / entry points: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" manifests`
- Package scripts (if node): !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" node-scripts`
- Route/handler surface: !`git grep -nIE "(router\.|app\.(get|post|put|delete)|@(app|router)\.(route|get|post)|http\.HandleFunc|@RequestMapping)" 2>/dev/null | head -20 || echo "no obvious web routes"`
- Data models: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" test-files-for schema`
- Test count: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/signals.sh" test-count`

## Output a structured guide

### What this project does (2 sentences)

### Architecture at a glance
Produce a **Mermaid diagram** of the real components and how they connect (renders on GitHub):
```mermaid
graph TD
    A[entry point] --> B[...]
    %% replace with the actual modules you found above
```

### The 5 files to read first
List real paths, each with one line on why it matters.

### The 3 things never to touch without deep understanding
Auth, migrations, shared core utils — whatever the danger zones actually are here.

### How to run, test, and build
Exact commands, inferred from the manifests above.

### The most surprising thing about this codebase
One honest, specific observation a newcomer would trip on.
