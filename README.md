<p align="center">
  <img src="trailair.png" alt="trailair logo" width="200">
</p>

<h1 align="center">trailair</h1>

<p align="center">
  A thin, runtime-agnostic <b>agent contract</b> you bolt onto any project —
  greenfield or brownfield.
</p>

No SDK. No vendor lock. No dependencies. Just markdown playbooks, git, and CI. Bring your own coding agent (Claude Code, Codex, Cursor, aider, anything that can read files and run shell commands).

## Why "trailair"?

**trailer + air.**

- **Trailer** — like a car towing a trailer, you attach trailair to a project you already have. It carries the important stuff along (the agent's instructions, the memory, the quality gates) without becoming the car. Unhitch it and your project is unchanged.
- **Air** — it's markdown and shell. A few kilobytes, zero dependencies, nothing to install, nothing to keep up to date.

## The idea

Coding agents are capable but stateless and unaccountable. trailair fixes both with two files and a hook:

- **`AGENTS.md` is the contract.** One entrypoint every agent runtime reads, so every agent behaves the same way in your repo.
- **`fitness.yaml` is the definition of "green".** Real test, lint, and coverage commands. One source of truth, enforced identically by the pre-commit hook and by CI.
- **`context/` is the memory.** What the project is, what's already been decided, what's still open — so an agent doesn't rediscover your codebase every session.
- **The gate must actually be able to fail.** Every enforcement mechanism here is smoke-tested to prove it can return non-zero. A gate that cannot fail is decorative.

## Quickstart

1. Copy the contract into your project root — the seven paths, and nothing else:
   ```bash
   tar -C /path/to/trailair -cf - \
       ./AGENTS.md ./fitness.yaml ./skills ./scripts ./hooks ./ci ./context \
     | tar -xf -
   ```
   Name the paths. `tar -cf - .` would also carry trailair's own `README.md`,
   `LICENSE`, `CONTRIBUTING.md`, and `.gitignore`, and tar overwrites on
   extract — on an existing project that silently replaces yours.
   (Don't use Finder drag or `cp trailair/*` — both silently drop dotfiles.)
2. Clear the two files that arrive describing trailair rather than you:
   `context/decisions.md` (its decision log — empty it) and, if you use Claude
   Code, add a `CLAUDE.md` pointing at `AGENTS.md`. `context/map.md` and
   `fitness.yaml` you can leave; bootstrap regenerates both.
3. Wire it in:
   ```bash
   scripts/install.sh
   ```
   This installs the pre-commit gate and the CI workflow. If your project already
   has CI, it will refuse rather than create a second definition of "green" —
   re-run with `--no-ci` and add `bash scripts/eval.sh gates` to your existing workflow.
   Either way, verify the gate is wired exactly once:
   ```bash
   grep -rl "eval.sh gates" .github/workflows/ | wc -l   # must be 1
   ```
4. Point your agent at `AGENTS.md` and say: *"bootstrap this project"*.
   - Bootstrap inventories the codebase, writes `context/map.md`, and drafts
     `fitness.yaml` for your approval — including a mandatory test gate and a
     coverage floor pinned to wherever you are today.
   - No test runner in the project? Bootstrap stops and asks rather than shipping
     an empty gate. That is the one thing that will block adoption; nothing else here does.
5. On an existing codebase, say: *"audit this project"*.
   - Audit is read-only. It writes a prioritized, evidence-cited findings list to
     `context/findings.md` and stops. You pick what matters; each pick becomes
     its own small PR. The agent never decides on its own what to fix.
6. Ask for work normally: *"add rate limiting to the API"*. The feature skill
   researches, plans, decomposes, and works branch-per-task.

## Layout

```
AGENTS.md            entrypoint for any agent (CLAUDE.md points here)
fitness.yaml         what "green" means — gates (enforced) + metrics (reported)
skills/              playbooks: bootstrap, audit, feature, memory
scripts/             install.sh (wiring), eval.sh (gate runner), selftest.sh
hooks/               pre-commit — never commit a broken gate
context/             map.md, decisions.md, memory.md — the agent's working memory
ci/                  CI templates, installed into .github/workflows/ by install.sh
docs/                design.md — why the contract is shaped the way it is
```

## Principles

1. **Small over complete.** Every file should be readable in one sitting. If a skill needs a framework, it's too big.
2. **The repo ships no agent.** Playbooks are plain markdown any agent can follow.
3. **Nothing merges itself.** Agents open PRs; a human merges.
4. **Adapt, don't assume.** Bootstrap discovers the stack; nothing hardcodes a language or test runner.
5. **The gate must actually fail.** Enforcement is smoke-tested, not assumed.
6. **Tests are not optional.** Every project gets a test gate and a coverage floor that can only ratchet upward.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs from humans and agents are equally welcome — both go through the same fitness gate.

## License

MIT — see [LICENSE](LICENSE).
