# Repository audit — findings

**Date:** 2026-08-12
**Scope:** full repository (`scripts/`, `hooks/`, `.github/`, `ci/`, `fitness.yaml`, docs, skills, context)
**Method:** three parallel review passes over partitioned scopes (shell, CI/config, docs-as-instructions), with findings verified by execution (`bash -n`, `shellcheck` 0.11.0, live runs of `eval.sh` and `selftest.sh` against throwaway repo copies) and by reading the source.

## Headline

This project's thesis is that *"a gate that cannot fail is decorative"* (`scripts/selftest.sh:3`). Both critical findings are violations of exactly that: the enforcement machinery can silently no-op and still report green.

---

## Critical

### 1. `scripts/eval.sh` exits 0 when `fitness.yaml` is missing or mis-keyed

**Location:** `scripts/eval.sh:9,23,57`

`FIT` is passed straight to `awk`. If the file is absent, awk writes an error to stderr but nothing checks its status. The heredoc at `:42-44` receives empty input, the loop body never executes, `fail` stays `0`, and `exit $fail` returns success.

Confirmed by execution, two ways:

- Deleting `fitness.yaml` → `bash scripts/eval.sh gates` prints only the awk error to stderr, **exit 0**.
- Renaming the top-level key `gates:` → `Gates:` (a plausible typo) → **exit 0**, zero gates run, no error emitted at all.

**Failure scenario:** `fitness.yaml` is deleted, renamed, or typo'd during a merge or refactor. The pre-commit hook and the CI gate step both report green while enforcing nothing.

**Fix:** after computing `FIT`, add `[ -f "$FIT" ] || { echo "fitness.yaml not found at $FIT" >&2; exit 1; }`. Additionally, count the gate rows actually processed in `gates`/`all` mode and fail if zero.

### 2. `selftest.sh` reports `hook-blocks-red-commit` PASS even when the hook was never installed

**Location:** `scripts/selftest.sh:47-50`

```bash
( cd "$T/d" && git init -q && git add -A \
  && bash hooks/install.sh >/dev/null \
  && git -c user.email=t@t -c user.name=t commit -qm x >/dev/null 2>&1 )
check "hook-blocks-red-commit" 1 $?
```

The `&&` chain short-circuits. If any earlier step fails — most importantly `hooks/install.sh` itself — `git commit` never runs, but the subshell still exits non-zero, which the check accepts as proof that the hook blocked the commit.

Confirmed by execution: with a deliberately broken `hooks/install.sh` (typo'd source filename in the `cp`), the exact test-4 command yields subshell exit `1` → selftest reports **PASS**, yet `.git/hooks/pre-commit` was never created and `git log` showed zero commits. The companion check `hook-permits-green-commit` (`:51-53`) has the identical blind spot: with no hook installed, nothing blocks anything, so it passes trivially.

**Impact:** the one test whose entire purpose is verifying that the pre-commit hook enforces cannot detect a regression in `hooks/install.sh` or `hooks/pre-commit` — the two files it exists to test.

**Fix:** do not chain with `&&`. Check each step's exit code independently, assert `.git/hooks/pre-commit` exists and is executable after install, and compare `git rev-list --count HEAD` before and after to confirm a commit was actually attempted.

---

## High

### 3. `.github/workflows/lint.yml` is red on a stock checkout

**Location:** `.github/workflows/lint.yml:10`

The step runs `shellcheck scripts/*.sh hooks/pre-commit hooks/install.sh` with no severity flag and no `.shellcheckrc` present. Running that exact command (shellcheck 0.11.0) exits 1:

- `scripts/agent.sh:5` — `SC2034 (warning): PROMPT appears unused`, because all three runtime-invocation lines (`:8-10`) are commented out by design. shellcheck cannot see through the comments, so this fires unconditionally in the shipped default state.
- `scripts/eval.sh:36` — `SC2181 (style)`, the `if [ $? -eq 0 ]` indirect exit-code check.

**Failure scenario:** every PR opened against this repo fails `shell-lint` with no code change required, contradicting `CONTRIBUTING.md:7` ("Trunk-based: `main` is always green") and training reviewers to ignore the check.

**Fix:** add `# shellcheck disable=SC2034` above the `PROMPT=` line (it *is* used once a runtime is configured), and rewrite `eval.sh:36` as `if out=$(sh -c "$cmd" 2>&1); then` to avoid SC2181.

### 4. README instructs enabling a workflow that no install path delivers

**Location:** `README.md:32-33`

> "(Optional) Enable `.github/workflows/self-improve.yml` for nightly background improvement PRs."

But the brownfield install command (`README.md:20-24`) runs `--exclude='./.github'`, so a host project never receives that file; and `skills/bootstrap.md` step 4 (`:18-25`) only copies `ci/github-eval.yml` → `.github/workflows/eval.yml`. Grepping every `.md`/`.yml`/`.sh` for `github-self-improve` returns only the file itself — it is referenced by name nowhere in the instructions.

**Fix:** have bootstrap's CI-integration step optionally copy `ci/github-self-improve.yml` → `.github/workflows/self-improve.yml`, or point the README explicitly at that source template.

---

## Medium

### 5. Greenfield install leaks framework-only CI into host projects

**Location:** `README.md:19` ("Greenfield: use this repo as a GitHub template. Done.")

GitHub's template-copy mechanism has no exclude option, so it copies `.github/workflows/lint.yml` and `.github/workflows/self-improve.yml` verbatim into the new project. This contradicts `context/decisions.md:3-6` ("Host CI templates live in ci/, never .github/ … .github/ is exclusively agentloop's own CI and is excluded from installs") and `docs/design.md:24-29`. `skills/bootstrap.md` step 4 only verifies that *some* workflow runs `eval.sh gates` — the inherited `eval.yml` satisfies that, so bootstrap marks CI "integrated" and never strips the leaked files.

**Fix:** add a bootstrap cleanup step for template-copied repos, or change the greenfield instructions to use the same excluding tar install as brownfield.

### 6. `hooks/install.sh` hardcodes `.git/hooks`, ignoring worktrees and `core.hooksPath`

**Location:** `hooks/install.sh:5-7`

In a linked git worktree, `.git` at the worktree root is a *file*, not a directory, so the `cp` fails outright. If `core.hooksPath` is configured elsewhere, the hook installs to a path git never consults — a silent false sense that enforcement is active. Both are plausible here, since agent-driven workflows commonly run in worktrees.

**Fix:** resolve the destination with `git rev-parse --git-path hooks` instead of hardcoding.

### 7. `scripts/agent.sh` is a stub that CI runs unconditionally on cron

**Location:** `scripts/agent.sh:7-11`, `.github/workflows/self-improve.yml:28`

All three runtime lines are commented out, so the script always falls through to `exit 1`. The scheduled job (`cron: "0 2 * * 1-5"`) therefore fails every run until a human edits the file, and neither `README.md:32-33` nor `docs/design.md` mentions this required edit alongside the GitHub App token setup.

**Fix:** document the required `agent.sh` runtime edit as part of enabling self-improve.

---

## Low

### 8. Unrecognized `MODE` in `eval.sh` silently no-ops with exit 0

**Location:** `scripts/eval.sh:8,28,46`

`MODE="${1:-all}"` is never validated. A typo such as `scripts/eval.sh gate` matches neither the gates block nor the metrics block, so the script does nothing and exits 0 (confirmed by execution). No current caller is affected — `hooks/pre-commit`, `.github/workflows/eval.yml`, and `scripts/selftest.sh` all pass exactly `gates`/`metrics` — but it is a landmine for future edits.

**Fix:** validate `MODE` against `gates|metrics|all` and error otherwise.

### 9. `eval.sh` quoted-value parser truncates on embedded escaped quotes

**Location:** `scripts/eval.sh:19`

`sub(/^"/,"",line); sub(/".*$/,"",line)` extracts up to the *first* remaining `"`. A value like `run: "echo \"hi\""` is truncated at the escaped quote and a mangled command runs silently. Not exercised by the current `fitness.yaml`, so unconfirmed by execution.

**Fix:** detect and reject embedded `"` in `run:` values rather than silently truncating.

### 10. `ci/github-pull_request_template.md` is orphaned

It exists and is duplicated verbatim as `.github/pull_request_template.md` for this repo's own use, but no skill or doc instructs a host-project bootstrap to wire it in.

### 11. CONTRIBUTING's skill-authoring rule is unmet by 3 of 4 shipped skills

`CONTRIBUTING.md:18` requires new skills to "state when NOT to use them". Only `skills/bootstrap.md:31-33` has such a section. `skills/feature.md`, `skills/improve-loop.md`, and `skills/memory.md` have none (`feature.md`'s `## Anti-patterns` covers what to avoid *while using* the skill, a different concept).

**Fix:** add a one-line "don't use this when…" to each skill, or relax the CONTRIBUTING wording to match practice.

---

## Verified clean

- **Template drift:** `diff` on all three `ci/github-*` ↔ `.github/*` pairs returns 0 — byte-identical. `lint.yml` correctly has no `ci/` counterpart (framework-repo-only by its own header).
- **YAML validity:** all five YAML files parse cleanly under `yaml.safe_load`.
- **Actions:** `actions/checkout@v4` and `actions/create-github-app-token@v2` both resolve to real tags; inputs and outputs match documented interfaces.
- **Permissions:** `self-improve.yml` correctly declares `contents: write` + `pull-requests: write`; `eval.yml`/`lint.yml` correctly omit elevated permissions. Cron syntax is valid.
- **Portability:** no BSD/macOS issues — no `sed -i`, `grep -P`, or `readlink -f`; `mktemp -d` and `wc -l` usage are both handled correctly.
- **Fitness ↔ eval alignment:** `bash scripts/eval.sh all` yields `GATE selftest PASS`, `METRIC skills_doc_lines 107`. No mismatch between definitions and implementation.
- **Enforcement works when nothing upstream is broken:** in a clean repo copy, `hooks/install.sh` correctly copies and chmods the hook; a real commit against a failing gate was blocked, and one against a passing gate succeeded.
- **Context freshness:** `context/map.md`, `context/decisions.md`, and `context/memory.md` all genuinely describe *this* repo, not a leftover template.
- **Convention consistency:** branch naming and commit conventions agree across `AGENTS.md`, `CONTRIBUTING.md`, `skills/feature.md`, and `skills/improve-loop.md`. `improve-loop.md` is budget-bounded with no infinite-loop risk.

---

## Suggested order of work

1. Findings 1 and 2 together — they are the same class of defect (enforcement that silently no-ops) and finding 1's fix should come with a selftest case that would have caught it.
2. Finding 3 — unblocks CI so subsequent PRs get honest signal.
3. Findings 4 and 5 — install-path correctness.

Per `AGENTS.md:14`, each gets its own branch and PR. Note `AGENTS.md:19`: a `fitness.yaml` change may not share a branch with the code it evaluates — none of findings 1–3 touch it.
