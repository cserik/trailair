# agentloop

A tiny, runtime-agnostic framework for **self-improving agent workflows** that adapts to any project — greenfield or brownfield.

No SDK. No vendor lock. Just markdown playbooks, git, and CI. Bring your own coding agent (Claude Code, Codex, Cursor, aider, anything that can read files and run shell commands).

## The idea

Borrowed from [karpathy/autoresearch](https://github.com/karpathy/autoresearch), generalized to software projects:

- **The agent is the mutation operator.** It proposes small changes.
- **`fitness.yaml` is the fitness function.** It defines what "better" means *in this project*.
- **Keep-or-revert.** Changes that don't pass gates or improve metrics are discarded.
- **PRs are the trust boundary.** The loop opens PRs; humans merge.

## Quickstart

1. Install:
   - **Greenfield**: use this repo as a GitHub template. Done.
   - **Brownfield**: from your project root:
     `tar -C /path/to/agentloop --exclude='./.git' --exclude='./.github' -cf - . | tar -xf -`
     (`.github/` is agentloop's OWN CI, never installed into hosts — the
     host-facing CI templates are in `ci/` and bootstrap wires them in.
     Don't use Finder drag or `cp agentloop/*`: both silently drop dotfiles.)
2. Run `hooks/install.sh` to enable the pre-commit gate (requires a git repo).
3. Point your agent at `AGENTS.md` and say: *"bootstrap this project"*.
   - Bootstrap inventories the codebase, writes `context/map.md`, drafts
     `fitness.yaml` for your approval, and wires the gate into your EXISTING CI
     if you have one (no duplicate workflows).
4. Ask for features normally: *"add rate limiting to the API"*.
   - The feature skill researches, plans, decomposes, and works branch-per-task.
5. (Optional) Enable `.github/workflows/self-improve.yml` for nightly background
   improvement PRs. Requires a GitHub App token — see docs/design.md.

## Layout

```
AGENTS.md            entrypoint for any agent (CLAUDE.md points here)
fitness.yaml         what "better" means — gates + metrics (generated, human-approved)
skills/              playbooks: bootstrap, feature, improve-loop, memory
hooks/               git hooks (universal — no runtime-specific hooks)
context/             map.md, decisions.md, memory.md — the agent's working memory
scripts/             agent.sh (pluggable runner), eval.sh (fitness runner)
.github/workflows/   eval gate on PRs + nightly self-improve job
```

## Principles

1. **Small over complete.** Every file should be readable in one sitting. If a skill needs a framework, it's too big.
2. **The repo ships no agent.** Playbooks are plain markdown any agent can follow.
3. **Nothing merges itself.** Background improvement opens PRs labeled `auto`; a human merges.
4. **Adapt, don't assume.** Bootstrap discovers the stack; nothing hardcodes a language or test runner.
5. **The gate must actually fail.** Every enforcement mechanism is smoke-tested to confirm it can return non-zero.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs from humans and agents are equally welcome — both go through the same fitness gate.

MIT licensed.
