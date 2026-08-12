#!/usr/bin/env bash
# Copy hooks into .git/hooks (kept as copy, not symlink, for portability).
# Requires a git repo — run from a clone, or `git init` first.
set -eu
root=$(git rev-parse --show-toplevel)
cp "$root/hooks/pre-commit" "$root/.git/hooks/pre-commit"
chmod +x "$root/.git/hooks/pre-commit"
echo "hooks installed"
