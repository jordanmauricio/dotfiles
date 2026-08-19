# Agent skills plan

Plan of record for a single curated, **agent-agnostic** skill set shared by Claude Code
and Codex. Written 2026-08-19; nothing below is built yet. Companion to
[`tooling.md`](./tooling.md) — that file describes the machine as it *is*, this one
describes work still to do.

Repo-only (`docs` is in `.chezmoiignore`); never applied to `$HOME`.

## Why

Three sources of skills worth mixing, none of which should be swallowed whole:

- **Matt Pocock** — [mattpocock/skills](https://github.com/mattpocock/skills), docs at
  [aihero.dev/skills](https://www.aihero.dev/skills). Deep, opinionated engineering spine.
- **Addy Osmani** — [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills),
  currently installed as `agent-skills@addy-agent-skills`. Broader, shallower coverage.
- **Mine, plus one-offs found online.**

Installing whole plugins gives ~45 skills, two competing meta-routers, and no way to prune.
The fix is to own the curation layer.

## Decisions locked

| Decision | Choice |
|---|---|
| Repo name | `~/projects/skills` → `github.com/jordanmauricio/skills`, public |
| Upstream handling | **Vendor** pinned copies, not subscribe to upstream plugins |
| Agents in scope | **Claude Code** and **Codex**. OpenCode dropped for now; Gemini/Qwen later |
| Centre of gravity | Plain `SKILL.md` tree. Claude's plugin format is an *adapter*, not the architecture |
| Meta-routers | Drop both (`using-agent-skills`, `ask-matt`); write our own flow doc |
| `~/.claude/settings.json` | **Never** chezmoi-managed — see [Gotchas](#gotchas) |

## Verified facts

Checked on this machine, 2026-08-19. Recorded so we don't re-research.

| Fact | Detail |
|---|---|
| Installed agents | `codex` 0.148.0 (from `packages.yaml → nodes: @openai/codex`), `opencode`. No gemini/qwen |
| `skills` CLI agent targets | ~80, incl. `claude-code`, `codex`, `gemini-cli`, `qwen-code`, `opencode`, `crush`, `cursor`, `zed`, `windsurf`, `goose`, `universal` |
| Multi-agent flag syntax | **Repeated** `-a x -a y`. Comma-separated (`-a x,y`) is rejected as one invalid name |
| Universal skills dir | project `.agents/skills/` (verified) · global `~/.config/agents/skills/` (per docs, **unverified**; Matt's dev script uses `~/.agents/skills` — confirm at install time) |
| Codex resolution | `-a codex` collapses into the universal dir; one tree serves Codex, OpenCode, Gemini CLI |
| Claude Code skills dir | `~/.claude/skills/` — a loose skill dir loads under its **bare** name (that's how `hunk-review` works) |
| `~/.claude/skills/<name>/` | Also a plugin root: `claude plugin init <name>` scaffolds there, auto-loads as `<name>@skills-dir` |
| Install mode | Default is **symlink into a canonical copy**; `--copy` opts out. Single-source-of-truth is the tool's own default |
| Local path as source | Works — `npx skills add ./path` reports "Local path validated" |
| **Discovery depth limit** | `SKILL.md` must sit **at most 5 path segments** below the source root. `packs/core/skills/mine/flow/SKILL.md` (5) is found; `packs/core/skills/vendor/mattpocock/tdd/SKILL.md` (6) is **silently skipped**. `--full-depth` does **not** rescue it |
| Lockfile | `skills-lock.json` per project: `source`, `sourceType`, `skillPath`, `computedHash`. `skills experimental_install` restores it |
| Claude marketplace | Multi-plugin layout with plugins in subdirs **validates** (`claude plugin validate`), incl. arbitrarily nested `skills/` paths |
| Useful Claude CLI | `plugin details <name>` (projected **token cost**), `plugin validate`, `plugin eval`, `plugin tag`, `marketplace add <url\|path\|repo> --scope user\|project\|local --sparse` |
| Codex plugins | Own marketplace system (`codex plugin marketplace add`, local or git; manifest at `.agents/plugins/marketplace.json`, sources `{source:"local",path:"./plugins/x"}`). Curated ones are MCP connectors — **not verified** that Codex plugins can carry skills. Do not build on it |
| Per-agent metadata | `agents/openai.yaml` sidecar inside a skill dir (`interface.display_name`, `interface.short_description`) — Matt ships these for Codex |
| skills.sh parse bug | A "6 skills skipped, colon in description" failure appeared once and **did not reproduce**. Treat as transient, not a constraint |

## Architecture

```
                 ~/projects/skills/packs/*/skills/          canonical, agent-agnostic
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
  npx skills add           .claude-plugin/        (later) .agents/plugins/
  → symlinks into          marketplace.json       marketplace.json
    each agent dir         → namespacing,         → Codex plugin system
    incl. ~/.claude/         subagents, hooks,       (unverified, parked)
                             eval, token cost
```

Three tiers of scope:

| Tier | Lives in | Scope | Tracked |
|---|---|---|---|
| Curated set | `~/projects/skills` | global, every repo | public git |
| Local / work | `~/.claude/skills/<name>/`, `~/.config/agents/skills/<name>/` | this machine | untracked — the `~/.zshrc.local` of skills |
| Project | `<repo>/.claude/skills/`, `<repo>/.agents/skills/` | one repo | that repo |

## Repo layout — `~/projects/skills`

```
skills/
├── packs/
│   ├── core/                           always on
│   │   ├── .claude-plugin/plugin.json  the only Claude-specific file in the pack
│   │   ├── skills/
│   │   │   ├── mine/<name>/SKILL.md
│   │   │   └── vendor/<name>/SKILL.md  pinned, never hand-edited
│   │   └── agents/                     Claude subagents (do not port — see Portability)
│   └── web/                            opt-in per project
├── .claude-plugin/marketplace.json     plugins: [{ name: jordan-core, source: "./packs/core" }]
├── vendor.yaml                         the manifest you edit
├── scripts/sync-vendor.sh
├── evals/                              for `claude plugin eval`
└── LICENSE                             + vendored upstream LICENSEs alongside copies
```

"Pack" rather than "plugin" on purpose: a pack is an agent-agnostic bundle; *plugin* is one
agent's word for it. Splitting `core` / `web` matters because every skill description loads
at session start — `claude plugin details` reports the token cost, so `web` stays off by
default and is enabled per project.

## vendor.yaml and the fork rule

`vendor.yaml` is the `packages.yaml` of that repo — hand-edited single source of truth:

```yaml
vendor:
  - from: mattpocock/skills
    ref: v1.2.3
    into: core
    skills:
      - skills/engineering/grill-with-docs
      - skills/engineering/to-tickets
      - skills/engineering/tdd
  - from: addyosmani/agent-skills
    ref: b3e9059
    into: core
    skills:
      - skills/security-and-hardening
```

`scripts/sync-vendor.sh` shallow-clones each `ref`, copies the listed dirs into
`packs/<into>/skills/vendor/<name>/`, and stamps provenance. Bump a `ref`, re-run,
read the `git diff`. Same loop as editing `packages.yaml` then `chezmoi apply`.

> **The fork rule.** Never hand-edit anything under `vendor/`. It is pristine and
> machine-written, clobbered on every sync. To change a vendored skill, **move it to
> `mine/`, rename it, and delete its line from `vendor.yaml`.** No three-way merge, no
> "did I edit this or did upstream". Forking is also how a skill gets de-Claude-ified
> (see [Portability](#portability-rules)).

## Curation — starting set

Matt's for the spine (deeper, more opinionated), Addy's for breadth Matt doesn't cover,
neither router.

**From Matt** — `grill-with-docs`, `grilling`, `domain-modeling`, `to-spec`, `to-tickets`,
`implement`, `tdd`, `code-review`, `diagnosing-bugs`, `prototype`, `research`,
`codebase-design`, `handoff`, `writing-for-agents`, `resolving-merge-conflicts`.
Add `wayfinder` + `setup-matt-pocock-skills` only if the multi-session flow gets real use.

**From Addy** — `security-and-hardening`, `performance-optimization`, `ci-cd-and-automation`,
`shipping-and-launch`, `api-and-interface-design`, `deprecation-and-migration`, plus the
three subagents (`code-reviewer`, `security-auditor`, `test-engineer`).

**Dropped as duplicates** (Matt's win) — Addy's `spec-driven-development`,
`planning-and-task-breakdown`, `incremental-implementation`, `test-driven-development`,
`code-review-and-quality`, `debugging-and-error-recovery`.

**Dropped as routers** — `using-agent-skills`, `ask-matt`. Two routers argue, and a router
is the cheapest thing to write ourselves. Replaced by `.chezmoitemplates/skills-flow.md`.

**Overlaps to resolve before installing** — Addy's `frontend-ui-engineering` vs the already
installed `frontend-design@claude-plugins-official` (keep the Anthropic one, it updates for
free); Addy's `browser-testing-with-devtools` vs built-in Chrome tooling.

Net: ~24 skills instead of ~45.

## Distribution

No bespoke link script — the repo is just another skills.sh source:

```bash
# from the local path while iterating
npx skills@latest add ~/projects/skills --all -g -a claude-code -a codex

# once pushed
npx skills@latest add jordanmauricio/skills --all -g -a claude-code -a codex

# Claude-native path, for namespacing / subagents / eval / token accounting
claude plugin marketplace add jordanmauricio/skills --scope user
claude plugin install jordan-core@jordan
```

`-a` must be **repeated**, not comma-separated. Use `npx`; do not add `skills` to
`packages.yaml → nodes:` — there's no reason for a global install.

## Portability rules

What makes "agent-agnostic" true rather than aspirational.

1. **No Claude-specific invocation phrasing.** Matt's skills say *"call the Skill tool with
   'research'"*. On Codex that's a dangling tool name. In `mine/`, write *"apply the
   `research` skill"*. For vendored ones: accept the degradation or fork.
2. **`disable-model-invocation: true` is Claude-only.** It's what makes `wayfinder`,
   `to-tickets` etc. user-invoked-only. Elsewhere it's ignored, so those skills become
   model-invokable and can fire unbidden.
3. **Subagents don't port.** Addy's three live in `agents/` — a Claude Code concept. Keep
   them in the pack, don't rely on them elsewhere.
4. **Frontmatter**: only `name` and `description` are universal. One line, no colons.
5. **Skill names are flat and global** in the universal dir — Claude's `pack:skill`
   namespacing does not exist there. No two skills in the set may share a name, across packs.
6. **Ship `agents/openai.yaml`** (`display_name`, `short_description`) for skills that
   should read well in Codex.

## Changes needed in this repo

| Path | Change |
|---|---|
| `.chezmoidata/agents.yaml` | **new** — see below |
| `run_onchange_after_agent-skills.sh.tmpl` | **new** — renders `agents.yaml`, runs `npx skills add` + `claude plugin marketplace add`. Wrap in `{{ if eq .chezmoi.os "darwin" -}}` |
| `.chezmoitemplates/skills-flow.md` | **new** — the flow/router doc, written once |
| `private_dot_claude/CLAUDE.md` | rename to `CLAUDE.md.tmpl`, add `{{ template "skills-flow" . }}` |
| `private_dot_codex/AGENTS.md.tmpl` | **new** — `{{ template "skills-flow" . }}` + `{{ template "tooling" . }}` |
| `docs/tooling.md` | add a "Agent skills" row/section pointing here once built |
| `CLAUDE.md` (repo) | note `.chezmoitemplates/` is now in use (currently listed as available-but-unused) |

```yaml
# .chezmoidata/agents.yaml
agents:
  targets:
    - claude-code
    - codex
  packs:
    - jordanmauricio/skills
```

**Why templating, not importing.** Claude's `@path` import syntax is Claude-only; Codex and
Gemini won't expand it. `.chezmoitemplates/` inlines real text at apply time, so every agent
gets the content. Worth doing for `docs/tooling.md` at the same time — right now
`~/.codex/AGENTS.md` exists, is unmanaged, and Codex therefore knows nothing about the tool map.

## Migration checklist

- [ ] 1. Create `~/projects/skills`: `packs/core`, `vendor.yaml`, `sync-vendor.sh`. Run a sync. Inspect the tree — nothing has touched `$HOME` yet.
- [ ] 2. `claude plugin validate` the marketplace and the pack.
- [ ] 3. `npx skills add ~/projects/skills --all -g -a claude-code -a codex`. Confirm the real global universal path (`~/.config/agents/skills` vs `~/.agents/skills`) and record it above.
- [ ] 4. Smoke-test: one skill fires in Claude Code, one fires in Codex.
- [ ] 5. Write `.chezmoitemplates/skills-flow.md`. Port the **existing** `~/.codex/AGENTS.md` content into the new template *before* applying.
- [ ] 6. Retarget `private_dot_claude/CLAUDE.md` → `.tmpl`; add `private_dot_codex/AGENTS.md.tmpl`.
- [ ] 7. `claude plugin uninstall agent-skills@addy-agent-skills`. Keep `frontend-design@claude-plugins-official`.
- [ ] 8. Push the repo, flip source to `jordanmauricio/skills`, add `.chezmoidata/agents.yaml` + the run_onchange script, `chezmoi apply`.
- [ ] 9. `claude plugin details jordan-core` — record the token cost as a baseline.

## Gotchas

- **`~/.claude/settings.json` must stay unmanaged.** Its `autoMode.environment` block holds
  machine-local project data — private repo slugs, cloud project ids, internal domains —
  which must never reach a public repo, and Claude Code rewrites the file itself anyway.
- **`~/.codex/AGENTS.md` already exists and was hand-created.** `chezmoi apply` needs the
  content ported into the source first, or `--force` will lose it.
- **Vendor upstream `LICENSE` files** next to the copies. Both sets are MIT; attribution is
  a one-line cost.
- **Codex plugin marketplaces are parked, not rejected.** If Codex plugins turn out to carry
  skills, one repo can serve both systems: `.claude-plugin/marketplace.json` and
  `.agents/plugins/marketplace.json` can point at the same `packs/` tree.
- **Never nest deeper than `packs/<pack>/skills/<group>/<name>/SKILL.md`.** That is exactly
  the 5-segment discovery limit. An `<owner>` directory under `vendor/` pushes it to 6 and
  the skill vanishes from `npx skills` with no warning — it still works as a Claude plugin,
  so the failure is Codex-only and silent. Provenance lives in `vendor.yaml` and the
  sync-stamped header, not in the directory name.
- **Watch the token budget.** Every skill description loads at session start. Re-run
  `claude plugin details` after each curation change.

## Open questions

- Real global path for the universal target — settle at step 3.
- Whether `wayfinder` earns its place, or whether `grill-with-docs` covers everything in practice.
- Work-scoped skills: drop-in untracked dirs, or a private pack behind
  `{{ if .isWorkLaptop }}`? Defer until there are more than two.
- Whether Codex daily-driver use makes forking most of Matt's set unavoidable (his skills
  lean harder on Claude tool names than Addy's).
