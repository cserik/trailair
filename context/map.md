# map.md — agentloop (the framework repo itself)

A runtime-agnostic framework for self-improving agent workflows. This repo is
self-bootstrapped: this map, fitness.yaml, and the CI describe agentloop itself.
Installed into a host project, bootstrap regenerates all three.

- Built with: bash + markdown. No dependencies.
- Tested by: `scripts/selftest.sh` (the only gate) — verifies eval.sh and the
  pre-commit hook can actually fail. `eval.sh gates` runs it.
- CI: `.github/workflows/` is agentloop's OWN CI (eval gate, shellcheck,
  nightly self-improve). NOT shipped to hosts — host-facing CI templates live
  in `ci/` and are wired in by bootstrap step 4.
- Layout: skills/ (playbooks), scripts/ (eval, selftest, agent runner),
  hooks/ (git hooks), ci/ (host CI templates), context/ (this memory), docs/.
- Conventions: conventional commits, trunk-based, one logical change per PR,
  every executable file must be exercised by selftest or shellcheck.
