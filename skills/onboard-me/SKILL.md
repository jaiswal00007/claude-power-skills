---
name: onboard-me
description: 5-minute codebase onboarding with a Mermaid architecture diagram — what it does, key files, what not to touch
---

Onboard me to this codebase. I'm a new developer. Be concrete and cite real files.

## Signals (language-agnostic)
- README: !`cat README* 2>/dev/null | head -60 || echo "no README"`
- File-type breakdown: !`git ls-files 2>/dev/null | python3 -c "import sys,collections; exts=collections.Counter(f.rsplit('.',1)[-1] if '.' in f else '(none)' for f in sys.stdin.read().split()); [print(f'{v:>6}  .{k}') for k,v in exts.most_common(10)]" 2>/dev/null || echo "n/a"`
- Top-level layout: !`git ls-files 2>/dev/null | python3 -c "import sys; dirs=sorted(set(f.split('/')[0]+'/' for f in sys.stdin.read().split() if '/' in f)); [print(d) for d in dirs[:25]]" 2>/dev/null || echo "n/a"`
- Manifests / entry points: !`ls package.json pyproject.toml Cargo.toml go.mod pom.xml build.gradle Makefile 2>/dev/null`
- Package scripts (if node): !`test -f package.json && python3 -c "import json; d=json.load(open('package.json')); [print(k+':',v) for k,v in d.get('scripts',{}).items()]" 2>/dev/null | head -17 || echo "n/a"`
- Route/handler surface: !`git grep -nIE "(router\.|app\.(get|post|put|delete)|@(app|router)\.(route|get|post)|http\.HandleFunc|@RequestMapping)" 2>/dev/null | head -20 || echo "no obvious web routes"`
- Data models: !`git ls-files 2>/dev/null | python3 -c "import sys,re; [print(f) for f in sys.stdin.read().split() if re.search(r'(schema|model|entity|migration)',f,re.I)]" | head -12`
- Test count: !`git ls-files 2>/dev/null | python3 -c "import sys,re; files=[f for f in sys.stdin.read().split() if re.search(r'(test|spec)',f,re.I)]; print(len(files))"`

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
