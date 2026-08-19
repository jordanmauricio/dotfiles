# Machine tooling reference

How a machine provisioned by these dotfiles is meant to be used — by Jordan and by
Claude alike. Single source of truth; imported into `~/.claude/CLAUDE.md` (global, every
session) and this repo's `CLAUDE.md`. View from any shell with `tools`.

Everything here is installed by `chezmoi apply` from `.chezmoidata/packages.yaml`.
**If a tool is missing, add it to the yaml and apply — don't `brew install`/`npm i -g`/`pip install` ad hoc.**

## Tool map — use the right-hand column

| Instead of | Use | Notes |
|---|---|---|
| `ls` | `eza` | `ls` is aliased. `l` (long, all, git status), `ll`, `lt` (by mtime), `ld` (dirs only) |
| `cat` | `bat` | aliased; `bat -p` for plain, `bat -l yaml` to force a language |
| `cd` | `z` (zoxide) | `cd`/`..`/`...`/`-` are aliased to `z`; `zz` = previous dir |
| `find` | `fd` | `fd pattern [path]`; respects .gitignore; `fd -H` hidden, `-t f/d`, `-e ext`, `-x cmd` |
| `grep -r` | `rg` (ripgrep) | `rg pattern [path]`; `-n` line numbers (default), `-t js`, `-g '!dist'`, `-l` files only |
| `du -sh *` | `dust` | `dust` (tree), `dust -d 1` |
| `top`/`htop`/`gtop` | `btm` (bottom) | |
| `sed -i` (GNU) | `gsed` | macOS `sed` is BSD; `gnu-sed` installs `gsed`. Plain `grep` is GNU via the `grep` formula |
| `git diff` pager | `delta` | automatic (`core.pager`); `git hdiff` / `git hshow` open **hunk** (interactive TUI) |
| `git difftool` | `hunk` | `git difftool [ref]` → hunk side-by-side. `git mergetool` → VS Code (hunk has no merge mode) |
| `curl` for APIs | `http` (httpie) | `xh` would be the faster drop-in if ever wanted |
| `jq` | `jq` / `jless` | `jless file.json` for interactive viewing |
| `npm install` | `ni` / `nr` / `nu` / `nlx` (@antfu/ni) | detects npm/pnpm/yarn/bun from the lockfile. `nup` = npm update, `nri` = reinstall node_modules |
| `man` | `man`, `manpdf` | `manpdf foo` opens in Preview |
| `wget` | `wget` / `curl` | both installed |
| `unzip`/`tar` | `unar` | handles every archive format |
| `yt-dlp`, `ffmpeg`, `imagemagick`, `webp`, `pandoc`, `poppler` (pdftotext) | — | installed for media/doc work |
| `croc` | — | send files between machines |
| `topgrade` | — | upgrades brew, cargo, npm, fnm, zinit etc. in one go — **this is how things get upgraded**; chezmoi only installs |

Shell helpers (see `configs/functions`): `mk dir` (mkdir + cd), `cdf` (cd to frontmost Finder window), `gz file`, `dataurl file`, `unshorten url`, `meteo [city]`, `cpwd`, `flushdns`, `cleanupds`, `deletenmodules`, `ip`/`ipl`.

Keybindings: `^p`/`^n` = history prefix search. Tab completion is fzf-tab with `eza` previews. `Ctrl-T`/`Ctrl-R`/`Alt-C` = fzf (uses `fd`).

## Languages & runtimes

| | Rule |
|---|---|
| **Node** | **fnm only** (nvm and brew `node` were removed). `fnm` auto-switches on `cd` from `.nvmrc` / `.node-version` / `package.json#engines.node`. `fnm ls`, `fnm install <v>`, `fnm default <v>`. Globals live under fnm's default version; declare them in `packages.yaml → nodes:`. Package manager per repo via `ni`/`nr`; pnpm home is `~/Library/pnpm`. |
| **Python** | `python3` = Homebrew latest (`python`). `python@3.13` is installed **only** for gcloud (`CLOUDSDK_PYTHON` is pinned to it in `.zshrc`); bump that one line when gcloud supports newer. Projects use `uv` (`uv venv`, `uv run`, `uv python install`). No global `pip install`. |
| **Go** | Homebrew `go`; `GOPATH=~/go`, `~/go/bin` on PATH. No `GOROOT` export (go knows its own). |
| **Java** | `openjdk` (Android Studio) and `zulu@17` cask (React Native) are both needed — don't dedupe. |
| **Ruby** | none managed. `fastlane` is brew-installed self-contained. If Ruby is ever needed, add it deliberately (rbenv was removed). |
| **Rust** | rustup (installed by the pre-req script); crates in `packages.yaml → crates:` (`dum`, `jless`). |
| **Bun** | Homebrew `bun` (core formula, not the tap). |
| **Cloud** | `gcloud` (cask), `terraform` (hashicorp tap — BSL, not in core), `firebase-cli`, `rclone`. |

## Secrets — never in this repo

- Everything comes from **1Password** (`op`). The repo is public; templates must only contain `{{ .name }}`-style placeholders or `op` lookups, never values.
- `GH_TOKEN` is fetched lazily on the first `gh` call (`gh()` wrapper); `gh_token` exports it for other tools in the current shell.
- Git credentials: `op` credential helper + `op read op://Personal/GitHub/password`. Commit signing: **SSH via 1Password** (`gpg.format = ssh`, `op-ssh-sign`). There is no GPG anywhere.
- Machine-local / work-only env (project IDs, cluster names, anything with an employer name in it) goes in **`~/.zshrc.local`** — sourced last, untracked, never committed.
- Before committing: `git diff` and grep for emails, tokens, `ssh-`, work identifiers.

## Git

Identity: personal by default; anything under `~/projects/kramp/` gets `workEmail` via `includeIf` → `~/.config/git/work`.

| Alias | Does | | Alias | Does |
|---|---|---|---|---|
| `g` | `git` (shell) | | `p` | push |
| `st` / `sts` | status / short | | `pn` | push `--no-verify` |
| `co` / `br` / `ci` | checkout / branch / commit | | `pf` | push `--force-with-lease` |
| `amend` | amend, keep message | | `pff` | push `--force` (raw) |
| `l` / `ll` / `lg` / `lm` | graph log / oneline graph / with patches / bullet list | | `pnf` | push `--no-verify --force-with-lease` |
| `ld [days]` | my commits last N days | | `pr <n>` | fetch & checkout PR #n |
| `df` | word diff | | `unstage` | `reset HEAD --` (safe) |
| `hdiff` / `hshow` | diff / show in hunk | | `patch` | plain diff, no pager |
| `stl` | modified + untracked files | | `show-ignored` | what .gitignore hides |

New branches auto-push with plain `git push` (`push.autoSetupRemote`). `pull.rebase = false`. OMZ git plugin aliases (`gst`, `gco`, `gp`, …) are also loaded.

## chezmoi workflow

Source dir is **`~/projects/dotfiles`** (set via `sourceDir`; binary at `~/bin/chezmoi`, updated by hand with `sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin`).

```
chezmoi status          # what would change           chezmoi apply [--force]   # write + run changed scripts
chezmoi diff            # builtin diff → hunk pager   chezmoi verify            # exit 0 = $HOME matches source
chezmoi doctor          # when anything is weird      chezmoi re-add <file>     # pull a live edit back (NOT for .tmpl files)
chezmoi cat ~/.zshrc    # render a target             chezmoi execute-template < x.tmpl
```

Rules that bite:
- **`run_once_*` scripts are keyed by content hash** — any edit makes them run again on next apply. Check `chezmoi status` for ` R` rows first; `--exclude=scripts` skips them.
- `run_onchange_*` re-run when their rendered content changes (so editing `packages.yaml` re-runs `brew bundle` — that's intended; it's `--no-upgrade` and idempotent).
- Disable a script by renaming to `skiprun_*` (ignored by `.chezmoiignore`).
- Anything at the source root that isn't for `$HOME` must be in `.chezmoiignore` (`README.md`, `docs`, `storage`, `configs`, …).
- `configs/{aliases,functions}` are sourced straight from the source dir — edits are live in the next shell, no apply needed.
- **Homebrew ≥ 6 refuses untrusted third-party taps.** Every tap in `packages.yaml → taps:` is `brew trust`ed by the bundle script; a new tap *must* be listed there, not just implied by `tap/name` in a formula.
- `--force` on apply is needed when a target was hand-edited since the last apply; port the edit into the source first or it's lost.
- Data prompts (`name`, `email`, `workEmail`, `computerName`, `isWorkLaptop` (bool), `gpgGit` = SSH signing pubkey) live in `~/.config/chezmoi/chezmoi.toml`; `chezmoi init` regenerates it from the template without re-prompting.

## Shell internals (why startup is ~0.13 s, and how to not break it)

- Powerlevel10k loads first with instant prompt; **everything else is zinit turbo** (`zinit wait lucid for …`) and loads after the first prompt. Don't add sync `zinit light` / `eval "$(...)"` lines above it without reason.
- `brew shellenv`, `zoxide init`, `fzf --zsh`, `brew command-not-found-init` are cached by **evalcache** in `~/.zsh-evalcache/`. After upgrading one of those tools run **`_evalcache_clear`**. `fnm env` is intentionally *not* cached (per-shell multishell path).
- `compinit` runs with `-C` (no compaudit, reuse `~/.zcompdump`). **After installing a tool that ships completions, run `compinit` once** (or `rm ~/.zcompdump*`).
- No `op`, `gem`, `brew --prefix`, or `nvm` calls happen at startup any more — keep it that way. Measure with `time zsh -i -c exit`; profile with `zmodload zsh/zprof` at the top of `.zshrc` + `zprof`.
- `~/.inputrc` is readline config for bash/python REPLs; it is **not** sourced into zsh.

## When something's off — checklist

1. `chezmoi doctor` · `chezmoi status` · `chezmoi verify` — is `$HOME` in sync with the repo?
2. `which -a <tool>` — shadowed by a stale binary (`~/.local/bin`, old `~/bin`, nvm remnants)? PATH order is brew → `~/bin` → `~/.local/bin` → fnm → pnpm → cargo → go.
3. Node wrong? `fnm ls`, `fnm current`, check for `.nvmrc`/`engines.node` in the repo; globals missing → they belong in `packages.yaml → nodes:` and install under fnm's default.
4. gcloud complains about Python → `echo $CLOUDSDK_PYTHON`, `brew list python@3.13`.
5. Completions missing/stale → `compinit`; weird `brew`/`zoxide`/`fzf` behaviour after upgrade → `_evalcache_clear`.
6. `brew bundle` fails on a tap → `brew trust --tap <tap>` and add it to `taps:`.
7. `gh` unauthenticated → run `gh` once (lazy token) or `gh_token`; `op signin` if 1Password CLI isn't unlocked.
8. Shell slow again → `time zsh -i -c exit`; anything > 0.2 s, look for new sync `eval`s in `.zshrc`/`.zshrc.local`.
9. `chezmoi diff` "hangs" → it's paging through `hunk`; `q` to quit, or `--no-pager`.
