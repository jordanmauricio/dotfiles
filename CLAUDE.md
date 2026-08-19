# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A macOS dotfiles repo managed by [chezmoi](https://www.chezmoi.io/). This directory is the chezmoi **source** state (`sourceDir` in `.chezmoi.toml.tmpl` points chezmoi at `~/projects/dotfiles` instead of the default `~/.local/share/chezmoi`); the files here are templated/renamed and applied into `$HOME`. There is no build, lint, or test suite — verification is done with chezmoi's own commands.

Chezmoi naming conventions in use:
- `dot_foo` → `~/.foo`; `private_dot_config/...` → `~/.config/...` (0600 perms)
- `*.tmpl` files are Go templates rendered with data from `.chezmoi.toml.tmpl` (prompted on first `init`) and `.chezmoidata/*.yaml`
- `run_once_before_*` / `run_once_after_*` run once per machine, ordered by the numeric prefix
- `run_onchange_*` re-run whenever their rendered contents change (this is how package lists and `defaults write` settings get re-applied when edited)

## Common commands

There is no conventional build/lint/test — chezmoi's own commands are the verification loop:

```bash
chezmoi doctor               # check for common problems (run first when something is off)
chezmoi status               # short summary of what `apply` would change
chezmoi diff                 # builtin diff piped through `hunk pager` (config `[diff] pager`); add --no-pager for plain output
chezmoi verify               # exit 0 iff $HOME matches the source state — closest thing to a "test"
chezmoi apply                # render templates and write to $HOME (also runs changed run_onchange_* scripts)
chezmoi apply -v --dry-run   # verbose no-op
chezmoi apply ~/.zshrc       # apply a single target only
chezmoi execute-template < dot_zshrc.tmpl           # render a single template to stdout
chezmoi execute-template --init --promptString name=Jordan,isWorkLaptop=n < .chezmoi.toml.tmpl   # test the config template
chezmoi cat ~/.zshrc         # show the rendered target for a file
chezmoi data                 # show the template data (prompted values + .chezmoidata)
chezmoi edit [--apply] ~/.zshrc   # edit the source file for a target (opens VS Code per config)
chezmoi re-add               # pull a manually edited target back into the source
chezmoi managed / unmanaged  # list files chezmoi does / doesn't control
chezmoi ignored              # show what .chezmoiignore is excluding
chezmoi update               # git pull + apply
chezmoi cd                   # subshell in the source dir; `chezmoi git -- <args>` runs git there
```

Bootstrap on a fresh machine (from README): `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jordanmauricio`. The pre-req script installs Homebrew, Rust, and 1Password, then pauses for manual 1Password CLI/SSH-agent setup before continuing.

## How the pieces fit together

- **`.chezmoi.toml.tmpl`** — prompts once for `name`, `email`, `workEmail`, `computerName`, `isWorkLaptop`, `gpgGit` (SSH public key used for commit signing). These keys are referenced by templates everywhere (`{{ .name }}`, `{{ .isWorkLaptop }}`, etc.). Adding a new template variable means adding a prompt here.
- **`.chezmoidata/packages.yaml`** — the single source of truth for installed software: `taps`, `brews`, `casks`, `caskswork`, `caskspersonal`, `crates` (cargo), `nodes` (npm -g), `vscode` extensions. `run_onchange_install-packages-darwin.sh.tmpl` renders this into a `brew bundle` Brewfile on stdin plus `cargo install` / `npm install -g` loops. `caskswork` vs `caskspersonal` is gated on `isWorkLaptop`. To add software, edit the YAML, not the script.
- **`.chezmoidata/dockapps.yaml`** — Dock layout, applied by `run_onchange_after_darwin-dock.sh.tmpl` via `dockutil`.
- **`run_onchange_after_darwin-defaults.sh.tmpl`** — large `defaults write` script for macOS system prefs (uses `computerName`). `run_onchange_after_darwin-defaults-chrome.sh` is the Chrome-specific counterpart.
- **`dot_zshrc.tmpl`** — zsh entrypoint. Uses zinit for plugins, powerlevel10k (`dot_p10k.zsh`), fnm (only node manager — nvm was dropped; fnm reads `.nvmrc`/`.node-version`/`engines.node`), bun/go/ruby/android PATH setup, `CLOUDSDK_PYTHON` pinned to `python@3.13` for gcloud while `python3` stays latest. It sources `configs/{functions,aliases,inputrc}` **directly from the chezmoi source dir** (`$CHEZMOI_HOME/configs/...`, i.e. this repo), so those files are not chezmoi-managed targets and don't need the `dot_` prefix — edits there take effect on next shell without `chezmoi apply`. Machine-local / work-specific env (e.g. the ws-opencode block) lives in untracked `~/.zshrc.local`, sourced at the end — never put work identifiers or secrets in the template. `GH_TOKEN` is fetched from 1Password lazily by a `gh()` wrapper on first use (`gh_token` exports it manually for other tools) so shell startup makes no `op` calls. Commit signing is SSH via 1Password (`gpg.format = ssh`); there is no GPG in use.
- **`private_dot_config/private_git/`** — git `config.tmpl` (identity from template data, 1Password as credential helper and SSH signing program, delta pager, `includeIf gitdir:~/projects/kramp/` → `work.tmpl` which sets `{{ .workEmail }}`) and `ignore.tmpl` (global gitignore).
- **`storage/`** — opaque blobs (fonts zip, Raycast export, VS Code profiles) kept in the repo for manual restore; not templated.
- **`.chezmoiignore`** — keeps repo-only files (`README.md`, `CLAUDE.md`, `storage/`, `configs/`, `bin/`) and disabled `skiprun_*` scripts from being copied into `$HOME`; `config`/`ignore` are ignored at the root because they only exist under `private_dot_config/private_git/`. Anything added at the source root that isn't meant for `$HOME` must be listed here.

## Conventions / gotchas

- To disable a `run_*` script, rename it `skiprun_*` (matched by `.chezmoiignore`). `skiprun_` is not a chezmoi prefix — without the ignore entry chezmoi would copy it into `~` as a plain file.
- `run_once_*` scripts are keyed by content hash: any edit (even whitespace) makes them run again on next `apply`. Check `chezmoi status` for ` R` rows before applying.
- The chezmoi binary lives at `~/bin/chezmoi` and is updated by hand (`sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin`); it is deliberately not a Homebrew keg because chezmoi is what installs Homebrew.
- Darwin-only scripts are wrapped in `{{ if eq .chezmoi.os "darwin" -}} ... {{ end -}}`; keep that guard when adding new `run_*` scripts.
- `run_onchange_*` scripts re-run on any content change, including comment edits — expect `chezmoi apply` to re-run `brew bundle` / `defaults write` after touching them or their YAML inputs.
- Rust `cargo install` output is redirected in the pre-req script to avoid breaking chezmoi's script handling (see commit history) — keep long-running installers quiet.
- Commit messages in this repo are short and informal (`wip`, `fix`, `rename gcloud`).

## Chezmoi features available but not currently used

Worth knowing before reinventing something by hand (see https://www.chezmoi.io/reference/):

- **`.chezmoiscripts/`** — a directory for `run_*` scripts so they don't clutter the source root (scripts here are not applied as files).
- **`.chezmoitemplates/`** — shared template snippets usable via `{{ template "name" . }}` from any `.tmpl`.
- **`.chezmoiexternal.toml`** — pull external files/archives (e.g. zinit, p10k, fonts) into the target as part of `apply`; an alternative to the committed `storage/fonts.zip` and to cloning zinit inside `.zshrc`.
- **`.chezmoiremove`** / `remove_` prefix — declaratively delete targets. **`.chezmoiversion`** — pin a minimum chezmoi version.
- **Attribute prefixes** not in use: `exact_` (dir with nothing unmanaged), `symlink_`, `modify_` (script that edits an existing file), `create_` (write only if missing), `executable_`, `readonly_`, `empty_`, `encrypted_`.
- **1Password template functions** (`onepasswordRead "op://vault/item/field"`, `onepassword`, `onepasswordItemFields`) — could replace the shell-side `op item get` for `GH_TOKEN` in `dot_zshrc.tmpl`. Related: `chezmoi secret`, `encrypted_` + `age`/gpg for committed secrets.
- **`.chezmoiignore` can be a template** — e.g. ignore darwin-only scripts when `.chezmoi.os != "darwin"` instead of wrapping each script in an `if`.
- **`promptBoolOnce`** for `isWorkLaptop` instead of a `"y"/"n"` string compared with `ne`.
- **`chezmoi docker` / `chezmoi podman`** — try the dotfiles in a throwaway container; **`chezmoi archive`** — tarball of the target state; **`chezmoi merge`** — three-way merge target vs source.
