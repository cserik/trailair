#!/usr/bin/env bash
# agent.sh — pluggable agent runner used by CI. Configure ONE line for your runtime.
# The prompt tells the agent to follow AGENTS.md + skills/improve-loop.md.
set -eu
PROMPT="Read AGENTS.md, then execute skills/improve-loop.md exactly. Stop after opening the PR (or after logging a no-result run)."

# --- pick your runtime (uncomment one) ---
# claude -p "$PROMPT" --permission-mode acceptEdits          # Claude Code
# codex exec "$PROMPT"                                        # Codex CLI
# aider --message "$PROMPT" --yes                             # aider
echo "No agent runtime configured. Edit scripts/agent.sh." >&2; exit 1
