#!/usr/bin/env bash
# selftest.sh — the framework's own fitness gate. Tests that eval.sh and the
# pre-commit hook actually enforce (i.e. CAN return non-zero). A gate that
# cannot fail is decorative; this script exists so that regression is caught.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fails=0
check () { # $1 desc, $2 expected exit, $3 actual exit
  if [ "$2" = "$3" ]; then echo "SELFTEST  $1  PASS"
  else echo "SELFTEST  $1  FAIL (want exit $2, got $3)"; fails=1; fi
}

mkfix () { # $1 fixture dir, $2 fitness body
  mkdir -p "$1/scripts" && cp "$ROOT/scripts/eval.sh" "$1/scripts/" && printf '%s\n' "$2" > "$1/fitness.yaml"
}

# 1. failing gate → exit 1 AND failure output is surfaced
mkfix "$T/a" 'gates:
  - name: boom
    run: "echo the-reason-why && exit 1"'
out=$(bash "$T/a/scripts/eval.sh" gates 2>&1); rc=$?
check "failing-gate-exits-nonzero" 1 "$rc"
echo "$out" | grep -q "the-reason-why"; check "failure-output-surfaced" 0 $?
echo "$out" | grep -q "GATE  boom  FAIL"; check "failure-labeled-FAIL" 0 $?

# 2. passing gates → exit 0
mkfix "$T/b" 'gates:
  - name: ok
    run: "true"'
bash "$T/b/scripts/eval.sh" gates >/dev/null 2>&1; check "passing-gate-exits-zero" 0 $?

# 3. block scalar → rejected loudly, exit 1
mkfix "$T/c" 'gates:
  - name: bad
    run: |
      echo hi'
out=$(bash "$T/c/scripts/eval.sh" gates 2>&1); rc=$?
check "block-scalar-rejected" 1 "$rc"
echo "$out" | grep -q "INVALID"; check "block-scalar-reason-shown" 0 $?

# 4. pre-commit hook blocks a commit on red, permits on green
mkfix "$T/d" 'gates:
  - name: red
    run: "false"'
cp -R "$ROOT/hooks" "$T/d/hooks"
( cd "$T/d" && git init -q && git add -A \
  && bash hooks/install.sh >/dev/null \
  && git -c user.email=t@t -c user.name=t commit -qm x >/dev/null 2>&1 )
check "hook-blocks-red-commit" 1 $?
( cd "$T/d" && printf 'gates:\n  - name: green\n    run: "true"\n' > fitness.yaml \
  && git add -A && git -c user.email=t@t -c user.name=t commit -qm x >/dev/null 2>&1 )
check "hook-permits-green-commit" 0 $?

exit $fails
