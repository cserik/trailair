# Design notes

## Why runtime-agnostic
The repo ships no agent. Playbooks are markdown; the universal interfaces are
the filesystem, git, shell, and CI. Any agent that has those can drive it.

## Why fitness.yaml is the core
An agent that can't be told what "green" means will invent its own definition.
fitness.yaml pins it once, per project, in commands that actually run — then
defends it in two places at once (the pre-commit hook and CI), so a local pass
and a CI pass can never disagree.

## Trust model
- Gates in CI are authoritative; local runs are a convenience.
- Agents can only open PRs. Merge rights stay human.
- fitness.yaml changes are quarantined into their own PRs so an agent can
  never redefine "green" and exploit the new definition in one step.

## One set of CI definitions
`ci/` holds the only workflow templates. `scripts/install.sh` copies them into
`.github/workflows/`, and this repo installs them on itself the same way a host
project does. This is deliberate: an earlier layout kept a separate `.github/`
tree "for the framework's own CI", which drifted from the `ci/` templates,
leaked framework-only workflows into projects installed via GitHub's template
button, and left a lint workflow that was red on a stock checkout. One source,
dogfooded, cannot drift.

## One definition of "green"
On brownfield installs, do not run eval.yml alongside an existing CI workflow —
two workflows means two competing definitions of green and doubled test time.
`scripts/install.sh` refuses to add a workflow when it finds existing CI; fold
`bash scripts/eval.sh gates` into that workflow instead. fitness.yaml stays the
single source of truth either way.

## Why there is no self-improvement loop
An earlier version shipped a nightly "improve loop": an agent proposing random
mutations on cron, keeping whatever moved a metric. It was removed. It required
a runner script every adopter had to hand-edit (shipped as a stub that failed
every scheduled run), it needed a GitHub App token and secrets, and it optimized
proxy metrics rather than intent. Above all it inverted the point of this repo:
a thin trailer you attach to your project, not an autonomous process running in
it. Agents here run when you ask them to. If you want background automation,
that's a decision for your project, not a default of the contract.

## Why audit only reports

The audit skill surveys an existing codebase and writes `context/findings.md`.
It never branches, never edits, never opens a PR. That split is the same line
the improve loop crossed: an agent that both decides what is wrong AND acts on
it is optimizing its own proxy for intent. So the three skills stay disjoint —
bootstrap observes, audit reports, feature changes — and a human stands between
the list and the diff. Findings are capped, severity-ordered, and must cite a
`path:line`; an uncitable finding is a hunch, and hunches don't earn a slot.
Re-runs overwrite the file, and anything you decline is recorded in
`context/decisions.md` so it doesn't come back next time.

## Metrics are reported, not enforced
Metrics run after gates in `eval.sh all` and only print. With no loop optimizing
them, their job is visibility — drift you can see in CI output and PR bodies.
Keep them cheap: a metric that re-invokes the gates doubles CI time.

## Why tests are mandatory
Bootstrap deliberately encodes the status quo everywhere else — but a project
with no test gate gives the agent no way to know it broke something, which makes
every other guarantee here hollow. So a test gate is required output, and a
coverage floor is pinned to current coverage: brownfield adoption never fails on
day one, but coverage can never silently regress. Raising the floor is a
fitness.yaml-only PR; lowering it needs a human justification in the PR body.

## Greenfield vs brownfield
Bootstrap branches on what it finds: an empty repo gets scaffolding proposals
(including a real test runner and one real passing test, so the mandatory gate
is honest from the first commit); an existing repo gets inference (test runner,
lint, conventions) and a draft fitness.yaml that encodes the status quo.
