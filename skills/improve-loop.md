# Skill: improve-loop

Autoresearch-style background improvement. Mutate → evaluate → keep-or-revert → PR.

## Preconditions

`fitness.yaml` approved; gates pass on main. Otherwise run bootstrap and stop.

## Steps

1. **Branch** `improve/<yyyymmdd>-<slug>`. Create `improve-runs/<branch>/results.tsv`
   with columns: `generation  mutation  gates  metric  delta  kept`.
2. **Baseline.** Run `scripts/eval.sh all`; record as generation 0.
3. **Pick a mutation.** In order of preference:
   a. an item from `docs/improvement-backlog.md`
   b. a small self-generated idea targeting a fitness metric
   c. a docs/skills clarity improvement (framework repos only)
   One mutation = one small, coherent change. Never combine.
4. **Evaluate.** Run `scripts/eval.sh all`.
   - Any gate fails → revert, log `kept=no`.
   - Gates pass, metric improved → commit, log `kept=yes`.
   - Gates pass, metric neutral → keep only if it reduces size/complexity; else revert.
5. **Repeat** 3–4 until `budget.minutes_per_run` or `max_mutations_per_run` is hit.
6. **PR.** If ≥1 mutation kept: open a PR labeled `auto` containing the kept commits
   + results.tsv. Description: what improved, by how much, what was tried and reverted.
   If nothing kept: push nothing; append learnings to `context/memory.md`.

## Hard rules

- Never modify `fitness.yaml` in an improve branch.
- Never merge. Never touch CI permissions or secrets.
- The eval is authoritative — no "it should be faster" without a measured delta.
