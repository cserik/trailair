# Skill: bootstrap

Adapt the framework to this project. Run once on install, or whenever the stack changes.

## Steps

1. **Inventory.** Detect: language(s), package manager, test runner, linter,
   formatter, CI, entry points, directory conventions. Read configs, don't guess.
   - Brownfield: infer everything from what exists.
   - Greenfield (empty/near-empty repo): ask the human 3 questions max
     (language, test framework, CI), then scaffold minimally.
2. **Write `context/map.md`.** One screen: what this project is, how it's built,
   how it's tested, where things live, conventions to respect.
3. **Draft `fitness.yaml`.** Fill `gates.run` with the real test/lint commands
   (single-line, quoted; longer logic goes in a script). Gates must pass RIGHT
   NOW on main — encode the status quo, don't aspire. Propose 1–2 metrics only
   if cheap, unambiguous, and NOT re-running the gates.
4. **Integrate CI — verified by outcome, not procedure.** The required end state:
   exactly ONE workflow runs `scripts/eval.sh gates` on pull requests.
   - Existing CI → add the step to that workflow; remove eval.yml if present.
   - No CI → copy `ci/github-eval.yml` to `.github/workflows/eval.yml` (or the
     equivalent for the host's CI system).
   - VERIFY: `grep -rl "eval.sh gates" .github/workflows/` (or the CI config dir)
     returns exactly one file. Zero or two+ = wiring failed. STOP and report —
     do not proceed to step 5 with an unverified gate.
5. **Verify.** Run `scripts/eval.sh gates`. If a gate fails on a clean checkout,
   fix the command (not the code) until it reflects reality.
6. **Stop for approval.** Present map.md + fitness.yaml to the human. Do not
   proceed to other skills until fitness.yaml is approved and committed.

## Not this skill's job

Fixing failing tests, refactoring, or improving anything. Bootstrap only observes and encodes.
