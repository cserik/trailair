#!/usr/bin/env bash
# eval.sh — run the fitness function defined in fitness.yaml.
# Usage: scripts/eval.sh [gates|metrics|all]   (default: all)
# Zero-dependency YAML reading: extracts name/run pairs with awk, so fitness.yaml
# must keep its simple flat structure with single-line quoted run: commands.
# Block scalars (run: |) are rejected loudly. Exits non-zero if any gate fails.
set -u
MODE="${1:-all}"
FIT="$(dirname "$0")/../fitness.yaml"

run_section () { # $1 = section name (gates|metrics)
  awk -v sec="$1" '
    $0 ~ "^"sec":" {in_sec=1; next}
    /^[a-z_]+:/ && in_sec {in_sec=0}
    in_sec && /name:/ {line=$0; sub(/.*name:[ ]*/,"",line); sub(/[ ]*#.*$/,"",line); name=line}
    in_sec && /run:/  {
      line=$0; sub(/.*run:[ ]*/,"",line)
      if (line ~ /^[|>]/) { print name"\tBLOCK_SCALAR"; next }
      if (line ~ /^"/) { sub(/^"/,"",line); sub(/".*$/,"",line) }
      else { sub(/[ ]*#.*$/,"",line) }
      print name"\t"line
    }
  ' "$FIT"
}

fail=0
TAB="$(printf '\t')"
if [ "$MODE" = "gates" ] || [ "$MODE" = "all" ]; then
  while IFS="$TAB" read -r name cmd; do
    [ -z "${cmd:-}" ] && continue
    if [ "$cmd" = "BLOCK_SCALAR" ]; then
      echo "GATE  $name  INVALID: block scalars (run: |) are not supported; use a script" >&2
      fail=1; continue
    fi
    out=$(sh -c "$cmd" 2>&1)
    if [ $? -eq 0 ]; then echo "GATE  $name  PASS"
    else
      echo "GATE  $name  FAIL"
      echo "$out" | tail -20 | sed 's/^/    | /'
      fail=1
    fi
  done <<EOG
$(run_section gates)
EOG
fi
if [ "$MODE" = "metrics" ] || [ "$MODE" = "all" ]; then
  while IFS="$TAB" read -r name cmd; do
    [ -z "${cmd:-}" ] && continue
    if [ "$cmd" = "BLOCK_SCALAR" ]; then
      echo "METRIC  $name  INVALID: block scalars not supported" >&2; continue
    fi
    out=$(sh -c "$cmd" 2>/dev/null) && echo "METRIC  $name  $(echo "$out" | tr -d '[:space:]')" || echo "METRIC  $name  ERR"
  done <<EOG
$(run_section metrics)
EOG
fi
exit $fail
