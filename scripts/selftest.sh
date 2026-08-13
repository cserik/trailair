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

# 4. pre-commit hook blocks a commit on red, permits on green.
#    Each step is checked independently: an && chain would let a broken
#    installer masquerade as a blocked commit (the two files this test exists
#    to cover are hooks/pre-commit and scripts/install.sh).
mkfix "$T/d" 'gates:
  - name: red
    run: "false"'
mkdir -p "$T/d/hooks" && cp "$ROOT/hooks/pre-commit" "$T/d/hooks/pre-commit"
cp "$ROOT/scripts/install.sh" "$T/d/scripts/install.sh"
( cd "$T/d" && git init -q ) ; check "fixture-git-init" 0 $?
( cd "$T/d" && git add -A ) ; check "fixture-git-add" 0 $?
( cd "$T/d" && bash scripts/install.sh --no-ci >/dev/null 2>&1 ) ; check "install-succeeds" 0 $?

hookpath=$( cd "$T/d" && git rev-parse --git-path hooks )
[ -f "$T/d/$hookpath/pre-commit" ]; check "hook-file-created" 0 $?
[ -x "$T/d/$hookpath/pre-commit" ]; check "hook-file-executable" 0 $?

before=$( cd "$T/d" && git rev-list --count HEAD 2>/dev/null || echo 0 )
( cd "$T/d" && git -c user.email=t@t -c user.name=t commit -qm x >/dev/null 2>&1 )
check "hook-blocks-red-commit" 1 $?
after=$( cd "$T/d" && git rev-list --count HEAD 2>/dev/null || echo 0 )
[ "$before" = "$after" ]; check "red-commit-created-no-commit" 0 $?

( cd "$T/d" && printf 'gates:\n  - name: green\n    run: "true"\n' > fitness.yaml && git add -A )
( cd "$T/d" && git -c user.email=t@t -c user.name=t commit -qm x >/dev/null 2>&1 )
check "hook-permits-green-commit" 0 $?
green=$( cd "$T/d" && git rev-list --count HEAD 2>/dev/null || echo 0 )
[ "$green" -gt "$after" ]; check "green-commit-actually-landed" 0 $?

# 5. a missing fitness.yaml must fail loudly, never pass silently
mkfix "$T/e" 'gates:
  - name: ok
    run: "true"'
rm "$T/e/fitness.yaml"
out=$(bash "$T/e/scripts/eval.sh" gates 2>&1); rc=$?
check "missing-fitness-exits-nonzero" 1 "$rc"
echo "$out" | grep -q "not found"; check "missing-fitness-reason-shown" 0 $?

# 6. a mis-keyed / empty gates section must fail, not report an empty green
mkfix "$T/f" 'Gates:
  - name: typo
    run: "true"'
out=$(bash "$T/f/scripts/eval.sh" gates 2>&1); rc=$?
check "no-gates-exits-nonzero" 1 "$rc"
echo "$out" | grep -q "no gates found"; check "no-gates-reason-shown" 0 $?

# 7. an unknown mode must error, not silently no-op with exit 0
mkfix "$T/g" 'gates:
  - name: ok
    run: "true"'
bash "$T/g/scripts/eval.sh" gate >/dev/null 2>&1; check "unknown-mode-rejected" 2 $?

# 8. an embedded quote must be rejected, not silently truncated
mkfix "$T/h" 'gates:
  - name: quoted
    run: "echo \"hi\""'
out=$(bash "$T/h/scripts/eval.sh" gates 2>&1); rc=$?
check "embedded-quote-rejected" 1 "$rc"
echo "$out" | grep -q "embedded quote"; check "embedded-quote-reason-shown" 0 $?

exit $fails
