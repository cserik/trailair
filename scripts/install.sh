#!/usr/bin/env bash
# install.sh — the single install path for trailair.
#
# Wires the shipped templates into the host repo:
#   ci/github-eval.yml                 -> .github/workflows/eval.yml
#   ci/github-lint.yml                 -> .github/workflows/lint.yml   (only if the repo has shell)
#   ci/github-pull_request_template.md -> .github/pull_request_template.md
#   hooks/pre-commit                   -> $(git rev-parse --git-path hooks)/pre-commit
#
# Idempotent: existing files are left alone and reported, never overwritten.
# If the repo ALREADY has CI, do not let this add a competing workflow — pass
# --no-ci and fold `bash scripts/eval.sh gates` into the existing workflow
# instead (see skills/bootstrap.md step 4).
#
# Usage: scripts/install.sh [--no-ci] [--no-hook]
set -eu

want_ci=1
want_hook=1
for arg in "$@"; do
  case "$arg" in
    --no-ci)   want_ci=0 ;;
    --no-hook) want_hook=0 ;;
    *) echo "usage: scripts/install.sh [--no-ci] [--no-hook]" >&2; exit 2 ;;
  esac
done

root=$(git rev-parse --show-toplevel) || {
  echo "install.sh: not a git repository (run 'git init' first)" >&2; exit 1; }
cd "$root"

place () { # $1 = source, $2 = destination
  if [ -e "$2" ]; then
    echo "  skip   $2 (already exists)"
  else
    mkdir -p "$(dirname "$2")"
    cp "$1" "$2"
    echo "  add    $2"
  fi
}

if [ "$want_ci" -eq 1 ]; then
  existing=$(ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | wc -l | tr -d ' ')
  if [ "$existing" != "0" ] && [ ! -f .github/workflows/eval.yml ]; then
    echo "install.sh: this repo already has CI workflows." >&2
    echo "  Do NOT add a second definition of 'green'. Add this step to the" >&2
    echo "  existing workflow instead:  - run: bash scripts/eval.sh gates" >&2
    echo "  Then re-run with --no-ci to install the hook only." >&2
    exit 1
  fi
  echo "CI:"
  place ci/github-eval.yml .github/workflows/eval.yml
  if ls scripts/*.sh hooks/pre-commit >/dev/null 2>&1; then
    place ci/github-lint.yml .github/workflows/lint.yml
  fi
  place ci/github-pull_request_template.md .github/pull_request_template.md
fi

if [ "$want_hook" -eq 1 ]; then
  echo "Hook:"
  # Resolves correctly inside linked worktrees and honours core.hooksPath.
  hookdir=$(git rev-parse --git-path hooks)
  mkdir -p "$hookdir"
  cp hooks/pre-commit "$hookdir/pre-commit"
  chmod +x "$hookdir/pre-commit"
  echo "  add    $hookdir/pre-commit"
fi

echo "trailair installed. Next: point your agent at AGENTS.md and say 'bootstrap this project'."
