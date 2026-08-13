# Skill: bootstrap

Adapt trailair to this project. Run once on install, or whenever the stack changes.

## Steps

1. **Inventory.** Detect: language(s), package manager, test runner, linter,
   formatter, coverage tool, CI, entry points, directory conventions. Read
   configs, don't guess.
   - Brownfield: infer everything from what exists.
   - Greenfield (empty/near-empty repo): ask the human 3 questions max
     (language, test framework, CI), then scaffold minimally — including a real
     test runner and one real passing test, so the test gate below is honest
     from the first commit.
2. **Write `context/map.md`.** One screen: what this project is, how it's built,
   how it's tested, where things live, conventions to respect.
3. **Draft `fitness.yaml`.** Single-line quoted `run:` values; longer logic goes
   in a script. Gates must pass RIGHT NOW on main — encode the status quo, don't
   aspire. Metrics are reported only, never optimized: propose 1–2 at most, and
   only if cheap, unambiguous, and NOT re-running the gates.

   Two gates are MANDATORY output. Do not skip them because the project lacks them:
   - **A test gate.** The project's real test command. If there is no test
     runner, do not emit an empty gate and move on — scaffold one (greenfield)
     or STOP and tell the human that trailair cannot guarantee anything without
     it, and ask how they want to proceed (brownfield).
   - **A coverage-floor gate.** Measure current coverage, then pin the floor to
     `floor(current)` using the tool's own threshold flag, e.g.
     `run: "pytest --cov=src --cov-fail-under=41"`. At 41% today, pin 41 — the
     gate's job is preventing regression, not passing judgement. If the language
     has no practical coverage tool, record that in `context/decisions.md` with
     the reason, and say so explicitly in your report.

   The floor only ratchets up. Raising it is a fitness.yaml-only PR; lowering it
   needs a written human justification (see CONTRIBUTING.md).
4. **Integrate.** Run `scripts/install.sh`. It installs the pre-commit hook and,
   if the project has no CI, the workflow templates from `ci/`.
   - It refuses when existing CI is present — that is correct. Add
     `bash scripts/eval.sh gates` as a step in the EXISTING workflow, then
     re-run `scripts/install.sh --no-ci`.
   - VERIFY: `grep -rl "eval.sh gates" .github/workflows/` (or the host's CI
     config dir) returns exactly one file. Zero or two+ = wiring failed. STOP
     and report — do not proceed with an unverified gate.
5. **Verify.** Run `scripts/eval.sh gates`. If a gate fails on a clean checkout,
   fix the command (not the code) until it reflects reality.
6. **Stop for approval.** Present map.md + fitness.yaml to the human. Do not
   proceed to other skills until fitness.yaml is approved and committed.
7. **Point at what's next.** On an existing codebase, offer `skills/audit.md` —
   it turns the inventory you just took into a prioritized findings list the
   human can pick from. Offer it; don't run it unasked.

## Not this skill's job

Fixing failing tests, refactoring, or improving anything. Bootstrap only observes
and encodes — the one exception is scaffolding a test runner in an empty repo,
because a project with no test gate makes every other guarantee here hollow.
Noting what's wrong isn't its job either: bootstrap observes, audit reports,
feature changes.
