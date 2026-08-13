# Contributing

Humans and agents contribute through the same door: a PR that passes the fitness gate.

## Branching & PR strategy

- Trunk-based: `main` is always green. No long-lived branches.
- `feature/<slug>` / `fix/<slug>` — one logical change each.
- Conventional commits. One logical change per PR; if a plan has 4 parts, that's 4 PRs.
- Every PR description includes: what changed, why, fitness before/after.
- Nothing auto-merges. Ever. Agent-authored PRs especially need a skeptical human read.

## Changing fitness.yaml

- Never in the same branch as the change it evaluates. Fitness changes get their own PR.
- Raising the coverage floor: fitness.yaml-only PR, no other files.
- Lowering the coverage floor: requires an explicit written justification in the
  PR body. "The new tests are slow" is not one.

## What makes a good contribution

- Smaller is better. A skill that gets shorter and clearer is a great PR.
- Runtime-agnostic only: nothing may require a specific agent product to work.
- New skills must fit on ~one screen and state when NOT to use them.
- Every new executable file must be exercised by `scripts/selftest.sh` or the
  lint workflow. If it can't fail in a test, it isn't covered.
