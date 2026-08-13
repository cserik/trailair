# decisions.md (append-only)

2026-08-12 — The framework repo is self-bootstrapped
fitness.yaml, context/map.md, and the CI describe trailair itself so the
public repo has a real gate for contributions.
Bootstrap overwrites all three when installing into a host project.

2026-08-13 — One set of CI definitions, in ci/, dogfooded
The previous split (ci/ templates plus a separate .github/ tree for the
framework's own CI) drifted, leaked framework-only workflows into
template-copied projects, and shipped a lint workflow that was red on a stock
checkout. Now ci/ is the only source; scripts/install.sh generates
.github/workflows/, which is output and is never hand-edited.

2026-08-13 — The self-improvement loop is removed
Cron-driven mutate/keep-or-revert required a hand-edited runner stub (shipped
broken, so every scheduled run failed), an App token plus secrets, and it
optimized proxy metrics rather than intent — inverting the "thin attachment"
goal. Removed entirely; git history is the archive. Metrics are reported only.

2026-08-13 — A test gate and a coverage floor are mandatory bootstrap output
Encoding the status quo is honest everywhere else, but a project with no test
gate gives an agent no signal that it broke something, making every other
guarantee hollow. The floor is pinned to current coverage so adoption never
breaks on day one; it ratchets up only, and lowering it needs written human
justification in the PR body.

2026-08-13 — Audit reports, it never remediates
`skills/audit.md` is read-only: it writes a capped, evidence-cited
`context/findings.md` and stops, because an agent that both diagnoses and fixes
is the improve loop again. Re-runs overwrite the file; declined findings become
entries here so they don't resurface. The `skills_doc_lines` metric rises as an
accepted cost of the fourth playbook.

2026-08-13 — The repo's own audit log moved to docs/audit-2026-08.md
Root `findings.md` collided with the generated `context/findings.md` the audit
skill now writes. The historical log is dated and filed under docs/; the
generated one is agent output and never hand-edited.

2026-08-13 — The project is named trailair
trailer + air: it attaches to a project you already have and carries the agent
contract along without becoming the project, at near-zero weight.
Renamed from agentloop, which described the now-removed improve loop.
