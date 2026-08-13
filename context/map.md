# map.md — trailair (the framework repo itself)

A thin, runtime-agnostic agent contract that attaches to any project. This repo
is self-bootstrapped: this map, fitness.yaml, and the CI describe trailair
itself. Installed into a host project, bootstrap regenerates all three.

- Built with: bash + markdown. No dependencies.
- Tested by: `scripts/selftest.sh` (the only gate) — verifies eval.sh and the
  pre-commit hook can actually fail. `eval.sh gates` runs it.
- CI: there is only ONE set of workflow definitions, the templates in `ci/`.
  `scripts/install.sh` copies them into `.github/workflows/`, and this repo runs
  the same command on itself. `.github/` is generated, never hand-edited.
- Layout: skills/ (playbooks), scripts/ (install, eval, selftest),
  hooks/ (pre-commit), ci/ (CI templates), context/ (this memory), docs/.
- Conventions: conventional commits, trunk-based, one logical change per PR,
  every executable file must be exercised by selftest or shellcheck.
