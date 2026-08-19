## Agent skills

A curated skill set is installed globally. Source repo: `~/projects/skills`; the canonical
copy the agents actually read is `~/.agents/skills` (Claude Code symlinks to it from
`~/.claude/skills`).

**Apply the `flow` skill to route a task to the right one.** It holds the spine
(`grill-with-docs` → `to-spec` → `to-tickets` → `implement` → `code-review`), the side
loops for debugging, TDD, prototyping and research, and the standing rules for all of them.

Do not add skills ad hoc, and never hand-edit anything under `skills/vendor/` — it is
machine-written and wiped on every sync. Declare upstream skills in
`~/projects/skills/vendor.yaml`, write your own under `skills/mine/`, run
`scripts/sync-vendor.sh`, then re-run the installer. Same rule as `packages.yaml`.
