# Design notes

## Why runtime-agnostic
The repo ships no agent. Playbooks are markdown; the universal interfaces are
the filesystem, git, shell, and CI. Any agent that has those can drive the loop.

## Why fitness.yaml is the core
Autoresearch works because it has one fixed metric. Arbitrary projects don't,
so the framework's real job is discovering and pinning a per-project fitness
function (bootstrap), then defending it (gates in CI, keep-or-revert in the loop).

## Trust model
- Gates in CI are authoritative; local runs are a convenience.
- The improve loop can only open PRs. Merge rights stay human.
- fitness.yaml changes are quarantined into their own PRs so an agent can
  never redefine "better" and exploit the new definition in one step.
- KNOWN CONSTRAINT: PRs created with the default GITHUB_TOKEN do not trigger
  on:pull_request workflows (GitHub's anti-recursion rule). Auto PRs would land
  with zero checks — silently bypassing the gate. self-improve.yml therefore
  mints a GitHub App token (actions/create-github-app-token) so agent-authored
  PRs get the same fitness gate as human ones. Do not "fix" this with a
  personal PAT on a public repo.

## ci/ vs .github/
Anything under .github/ is invisible to GitHub unless it sits at the host
repo's root — so shipped workflow files either collide with the host's CI
(root install) or become dead files (subfolder install). Therefore: .github/
belongs to agentloop's own CI only; host-facing templates live in ci/ and
bootstrap wires them into whatever CI system the host uses.

## One definition of "green"
On brownfield installs, do not run eval.yml alongside an existing CI workflow —
two workflows means two competing definitions of green and doubled test time.
Bootstrap step 4 folds `scripts/eval.sh gates` into the existing workflow and
deletes eval.yml. fitness.yaml stays the single source of truth either way.

## Metrics must be cheap
Metrics run after gates in `eval.sh all`. A metric that re-invokes the gates
(e.g. timing the test suite by running it again) doubles CI time. Time the
gates inside CI with workflow timing instead, or measure something orthogonal.

## Greenfield vs brownfield
Bootstrap branches on what it finds: an empty repo gets scaffolding proposals;
an existing repo gets inference (test runner, lint, conventions) and a draft
fitness.yaml that encodes the status quo before anything is "improved."
