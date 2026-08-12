# Skill: memory

Keep the agent's context small, current, and trustworthy.

## Files

- `context/map.md` — regenerate (via bootstrap step 2) when it contradicts reality.
  Symptom: you keep being surprised by the codebase.
- `context/decisions.md` — append-only. Format per entry (3 lines):
  date+title / decision / why. Never delete; supersede with a new entry.
- `context/memory.md` — cross-session scratch. Compact when > 100 lines:
  fold resolved items into decisions.md or delete; keep only open threads.

## Rules

- Memory records facts and decisions, not hopes ("TODO: someday…" goes to the backlog).
- When compacting, prefer deleting to summarizing — stale summaries lie.
- After any merged PR that changes structure or conventions: update map.md in that PR.
