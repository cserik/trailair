# Skill: feature

Turn a user request into researched, planned, decomposed, reviewable work.

## Steps

1. **Research.** Read `context/map.md` and relevant code. If the request involves
   external tech, research current best practice. Write findings (5–10 bullets)
   into the plan file, with sources if external.
2. **Plan.** Create `plans/<slug>.md`: goal, approach, out-of-scope, risks.
3. **Decompose.** Split into tasks sized "one reviewable PR each" (rule of thumb:
   < ~300 changed lines, one logical change). If it fits in one PR, don't split.
4. **Checkpoint.** Show the plan to the human. Ambiguities are questions here,
   not assumptions later.
5. **Execute per task:** branch `feature/<slug>-<n>` → implement → run
   `scripts/eval.sh gates` → commit (conventional) → open PR referencing the plan
   → stop. Next task starts after merge (or on explicit go-ahead, stacked on the
   previous branch).
6. **Close out.** When all tasks merge: update `context/map.md` if structure
   changed, append one line to `context/decisions.md` for any settled decision.

## Anti-patterns

- Mega-PRs. Silent assumption-making. Plans that restate the request without decisions.
