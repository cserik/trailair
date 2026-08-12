# decisions.md (append-only)

2026-08-12 — Host CI templates live in ci/, never .github/
Files shipped to host projects must not live under .github/ (root-merge
collides with host CI; subfolder install makes them dead files GitHub ignores).
.github/ is exclusively agentloop's own CI and is excluded from installs.

2026-08-12 — The framework repo is self-bootstrapped
fitness.yaml, context/map.md, and .github/ describe agentloop itself so the
public repo has a real gate for contributions (human and auto PRs alike).
Bootstrap overwrites all three when installing into a host project.

2026-08-12 — self-improve.yml stays cron/manual-only
The GitHub App token means agent PRs can trigger workflows. The cron-only
trigger is what prevents a self-improve → PR → self-improve recursion. Do not
add push/pull_request triggers to self-improve.yml.
