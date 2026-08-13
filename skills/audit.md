# Skill: audit

Survey an existing codebase and hand the human a prioritized list of what's
wrong. Read-only: audit reports, it never remediates.

## Steps

1. **Check preconditions.** `context/map.md` must exist and describe THIS
   project — if not, run `skills/bootstrap.md` first. Read
   `context/decisions.md` and drop anything already settled or declined there;
   a declined finding does not come back.
2. **Sweep, in this order.** Fixed categories, no others:
   - **security** — injection, authn/authz gaps, secrets in source, unsafe
     deserialization, missing validation at boundaries, known-vulnerable deps.
   - **correctness** — swallowed errors, race conditions, off-by-one, wrong
     defaults, tests that cannot fail.
   - **structure** — leaked layers, duplicated logic, god modules, circular deps.
   - **maintenance** — dead code, stale pins, missing docs on public surface.
3. **Evidence or it doesn't exist.** Every finding cites `path:line` you have
   actually read. No speculation, no "consider reviewing X", no findings about
   code you didn't open.
4. **Score each finding:** severity (Critical/High/Medium/Low), the `path:line`
   evidence, why it matters (real impact, not a restatement), a proposed fix,
   and a size estimate (S/M/L).
5. **Cap and order.** ~15 findings max, highest severity first. If you found
   more, say so in one closing line — do not extend the list.
6. **Write `context/findings.md`** (overwrite; it is generated output, not a
   committed template), using this shape:

   ```
   ## High
   ### 3. Session token compared with `==`
   - Evidence: `src/auth/session.py:88`
   - Why: timing-attack surface on the primary auth path.
   - Fix: use `hmac.compare_digest`.
   - Size: S
   ```
7. **Stop.** Present the list and ask which items to act on. No branch, no
   edit, no commit, no PR — the human picks what matters.
8. **Route the picks.** Each picked finding becomes one task under
   `skills/feature.md`, and its PR cites the finding. Each declined finding gets
   a three-line entry appended to `context/decisions.md` so the next audit
   skips it.

## When not to use this skill

On a greenfield or empty repo — there is nothing to observe yet, run bootstrap.
Mid-feature: findings turn into scope creep, audit between tasks. As a stand-in
for `fitness.yaml`: gates enforce, audit only informs. And never to fix
anything — deciding what gets changed is the human's call, not the agent's.

## Anti-patterns

- Findings without a line citation, or padded to hit the cap.
- Opening a PR "while you're in there". Auditing and fixing in the same pass.
- Re-raising something `context/decisions.md` already declined.
