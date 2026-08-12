# Contributing

Humans and agents contribute through the same door: a PR that passes the fitness gate.

## Branching & PR strategy

- Trunk-based: `main` is always green. No long-lived branches.
- `feature/<slug>` / `fix/<slug>` — human-initiated work.
- `improve/<yyyymmdd>-<slug>` — improve-loop output, labeled `auto`.
- Conventional commits. One logical change per PR; if a plan has 4 parts, that's 4 PRs.
- Every PR description includes: what changed, why, fitness before/after.
- Nothing auto-merges. Ever. `auto`-labeled PRs especially need a skeptical human read.

## What makes a good framework contribution

- Smaller is better. A skill that gets shorter and clearer is a great PR.
- Runtime-agnostic only: nothing may require a specific agent product to work.
- New skills must fit on ~one screen and state when NOT to use them.

## Improvement backlog

Ideas the improve loop can pick from live in `docs/improvement-backlog.md`. Adding
a well-scoped backlog item is a valuable contribution on its own.
