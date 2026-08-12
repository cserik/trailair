# AGENTS.md — how to operate in this repository

You are a coding agent working in a project that uses **agentloop**. Follow these rules regardless of which runtime you are.

## On every session start

1. Read `context/map.md`. If it's missing OR describes a different project
   (a fresh install still carries agentloop's own map), run `skills/bootstrap.md` first.
2. Read `fitness.yaml`. It defines the gates you must never break and the metrics you may optimize.
3. Skim `context/decisions.md` for constraints already settled — do not relitigate them.

## Workflow rules

- **One task, one branch, one PR.** Branch names: `feature/<slug>`, `fix/<slug>`, `improve/<yyyymmdd>-<slug>`.
- **Commits:** conventional commits (`feat:`, `fix:`, `docs:`, `chore:`, `improve:`). Small, atomic.
- **Before any commit:** run `scripts/eval.sh gates`. If a gate fails, fix or revert — never commit a broken gate.
- **Every PR** includes fitness results before/after (paste the `results.tsv` lines or `eval.sh` output).
- **Never merge.** Open the PR and stop. Humans merge.
- **Never edit** `fitness.yaml` and the change it's evaluating in the same branch. Fitness changes get their own PR.

## Skills (playbooks)

| When the user wants… | Follow |
|---|---|
| Set up / adapt to this project | `skills/bootstrap.md` |
| A feature, fix, or change | `skills/feature.md` |
| Background/self improvement | `skills/improve-loop.md` |
| Context is stale or bloated | `skills/memory.md` |

Skills are instructions, not code. Read the whole skill before starting.

## Memory

- `context/map.md` — what this project is and how it's built (regenerate when stale).
- `context/decisions.md` — append-only log of settled decisions (ADR-lite, 3 lines each).
- `context/memory.md` — scratch notes across sessions; compact it per `skills/memory.md`.

## Safety rails

- Do not touch secrets, credentials, or CI permissions.
- Do not add dependencies without noting it in the PR description with a one-line justification.
- If a task is ambiguous, write your interpretation in the plan and ask — don't guess silently.
