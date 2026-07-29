#!/usr/bin/env bash
# signals.sh — shared helper for skill signal lines
# Usage: bash signals.sh <subcommand> [arg]
# All subcommands print to stdout and exit 0 (never block a skill).

CMD="${1:-}"
ARG="${2:-}"

case "$CMD" in

  node-scripts)
    python3 - <<'EOF'
import json, os
if os.path.exists('package.json'):
    d = json.load(open('package.json'))
    [print(k + ': ' + v) for k, v in d.get('scripts', {}).items()]
else:
    print('n/a')
EOF
    ;;

  file-types)
    python3 - <<'EOF'
import subprocess, collections
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
exts = collections.Counter(f.rsplit('.',1)[-1] if '.' in f else '(none)' for f in files)
[print(f'{v:>6}  .{k}') for k, v in exts.most_common(10)]
EOF
    ;;

  top-dirs)
    python3 - <<'EOF'
import subprocess
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
dirs = sorted(set(f.split('/')[0]+'/' for f in files if '/' in f))
[print(d) for d in dirs[:25]]
EOF
    ;;

  manifests)
    python3 - <<'EOF'
import os
for f in ['package.json','pyproject.toml','Cargo.toml','go.mod','pom.xml','build.gradle','Makefile']:
    if os.path.exists(f):
        print(f)
EOF
    ;;

  manifests-short)
    python3 - <<'EOF'
import os
for f in ['package.json','pyproject.toml','Cargo.toml','go.mod','pom.xml']:
    if os.path.exists(f):
        print(f)
EOF
    ;;

  test-runner)
    python3 - <<'EOF'
import os
runners = [
    ('package.json',   'npm test'),
    ('pyproject.toml', 'pytest'),
    ('pytest.ini',     'pytest'),
    ('Cargo.toml',     'cargo test'),
    ('go.mod',         'go test ./...'),
    ('pom.xml',        'mvn test'),
]
[print(r) for f, r in runners if os.path.exists(f)] or print('unknown')
EOF
    ;;

  test-runner-node)
    # Detects node framework (vitest/jest) from package.json, falls back to test-runner
    python3 - <<'EOF'
import os, json
if os.path.exists('package.json'):
    pkg = json.load(open('package.json'))
    deps = {**pkg.get('dependencies',{}), **pkg.get('devDependencies',{})}
    fw = next((k for k in ['vitest','jest'] if k in deps), '')
    print('node: ' + (fw if fw else 'check scripts'))
else:
    runners = [
        ('pyproject.toml', 'python: pytest'),
        ('pytest.ini',     'python: pytest'),
        ('Cargo.toml',     'rust: cargo test'),
        ('go.mod',         'go: testing pkg'),
        ('pom.xml',        'java: junit/maven'),
    ]
    [print(r) for f, r in runners if os.path.exists(f)] or print('unknown')
EOF
    ;;

  test-runner-check)
    # Variant for session-wrap/standup with "check:" / "run:" prefix
    PREFIX="${ARG:-check}"
    python3 - "$PREFIX" <<'EOF'
import os, sys
prefix = sys.argv[1] if len(sys.argv) > 1 else 'check'
runners = [
    ('package.json',   prefix + ': npm test'),
    ('pyproject.toml', prefix + ': pytest'),
    ('pytest.ini',     prefix + ': pytest'),
    ('Cargo.toml',     prefix + ': cargo test'),
]
[print(r) for f, r in runners if os.path.exists(f)] or print('no test runner detected')
EOF
    ;;

  test-files)
    # List tracked files matching test/spec, up to 8
    python3 - <<'EOF'
import subprocess, re
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
found = [f for f in files if re.search(r'(test|spec)', f, re.I)]
[print(f) for f in found[:8]] or print('no existing tests — establish a convention')
EOF
    ;;

  test-files-for)
    # List test files matching a source file basename
    # ARG: source file path (e.g. src/foo.ts)
    python3 - "$ARG" <<'EOF'
import subprocess, re, os, sys
arg = sys.argv[1] if len(sys.argv) > 1 else ''
base = os.path.splitext(os.path.basename(arg))[0].lower() if arg else ''
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
found = [f for f in files if re.search(r'(test|spec)', f, re.I) and (not base or base in f.lower())]
[print(f) for f in found[:8]] or print('no obvious test file — you will create one')
EOF
    ;;

  test-count)
    python3 - <<'EOF'
import subprocess, re
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
print(sum(1 for f in files if re.search(r'(test|spec)', f, re.I)))
EOF
    ;;

  test-count-full)
    # Includes _test. .test. .spec. patterns for scope-check
    python3 - <<'EOF'
import subprocess, re
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
print(sum(1 for f in files if re.search(r'(test|spec|_test\.|\.test\.|\.spec\.)', f, re.I)))
EOF
    ;;

  source-files)
    # Non-test, non-dist source files (for create-spec)
    python3 - <<'EOF'
import subprocess, re
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
filtered = [f for f in files if not re.search(r'(test|spec|node_modules|dist|build)', f, re.I)]
[print(f) for f in filtered[:25]]
EOF
    ;;

  danger-zones)
    python3 - <<'EOF'
import subprocess, re
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
found = [f for f in files if re.search(
    r'auth|login|password|secret|token|payment|billing|migration|schema|\.env|Dockerfile|deploy|prod',
    f, re.I)]
[print(f) for f in found[:15]] or print('(no danger-zone files found)')
EOF
    ;;

  dirty-count)
    python3 - <<'EOF'
import subprocess
out = subprocess.run(['git','status','--short'], capture_output=True, text=True).stdout
print(len(out.splitlines()))
EOF
    ;;

  stash-create)
    python3 - <<'EOF'
import subprocess
sha = subprocess.run(['git','stash','create'], capture_output=True, text=True).stdout.strip()
if sha:
    print(sha + ' (stash object — recover with: git stash apply ' + sha + ')')
else:
    print('working tree clean — HEAD is your restore point')
EOF
    ;;

  default-branch)
    python3 - <<'EOF'
import subprocess
r = subprocess.run(['gh','repo','view','--json','defaultBranchRef','-q','.defaultBranchRef.name'],
                   capture_output=True, text=True)
b = r.stdout.strip()
if not b:
    r2 = subprocess.run(['git','symbolic-ref','--short','refs/remotes/origin/HEAD'],
                        capture_output=True, text=True)
    b = r2.stdout.strip().replace('origin/', '')
print(b or 'main')
EOF
    ;;

  git-deletions)
    python3 - <<'EOF'
import subprocess
out = subprocess.run(
    ['git','log','--diff-filter=D','--summary','--since=7 days ago'],
    capture_output=True, text=True).stdout
lines = [l for l in out.splitlines() if 'delete mode' in l.lower()]
[print(l) for l in lines[:12]] or print('none')
EOF
    ;;

  coverage-config)
    python3 - <<'EOF'
import os
files = (['sonar-project.properties', 'pyproject.toml', 'setup.cfg'] +
         [f for f in os.listdir('.') if f.startswith(('jest.config', 'vitest.config'))])
found = []
for fn in files:
    if os.path.exists(fn):
        for l in open(fn).read().splitlines():
            if 'cov' in l.lower():
                found.append(l)
[print(l) for l in found] or print('no coverage config found')
EOF
    ;;

  importers-count)
    python3 - <<'EOF'
import subprocess
out = subprocess.run(
    ['git','grep','-lIn','-e','import','-e','require','-e','include','-e','use '],
    capture_output=True, text=True).stdout
print(len(out.splitlines()))
EOF
    ;;

  diff-target)
    # List changed files (excluding test files) for write-tests
    ARGS_VAL="${ARG:-}"
    python3 - "$ARGS_VAL" <<'EOF'
import os, subprocess, re, sys
arg = sys.argv[1].strip() if len(sys.argv) > 1 else ''
if arg:
    print(arg)
else:
    files = subprocess.run(['git','diff','HEAD','--name-only'],
                           capture_output=True, text=True).stdout.split()
    filtered = [f for f in files if not re.search(r'(test|spec)', f, re.I)]
    [print(f) for f in filtered[:10]] or print('(specify a file)')
EOF
    ;;

  file-types-short)
    # 8-item variant for scope-check
    python3 - <<'EOF'
import subprocess, collections
files = subprocess.run(['git','ls-files'], capture_output=True, text=True).stdout.split()
exts = collections.Counter(f.rsplit('.',1)[-1] if '.' in f else '(none)' for f in files)
[print(f'{v:>6}  {k}') for k, v in exts.most_common(8)]
EOF
    ;;

  *)
    echo "signals.sh: unknown subcommand '${CMD}'" >&2
    echo "Available: file-types, file-types-short, top-dirs, manifests, manifests-short,"
    echo "  test-runner, test-runner-node, test-runner-check, test-files, test-files-for,"
    echo "  test-count, test-count-full, source-files, danger-zones, dirty-count,"
    echo "  stash-create, default-branch, git-deletions, coverage-config,"
    echo "  importers-count, diff-target" >&2
    exit 0
    ;;
esac
