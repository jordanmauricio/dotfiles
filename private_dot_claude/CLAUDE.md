# Machine-wide guidance (this Mac is provisioned by ~/projects/dotfiles via chezmoi)

@~/projects/dotfiles/docs/tooling.md

Short version, always in force:
- Use the modern tools from the tool map (`eza`, `bat`, `fd`, `rg`, `dust`, `btm`, `z`, `delta`/`hunk`, `ni`) and fnm-managed node, `uv` for python.
- Install software by editing `~/projects/dotfiles/.chezmoidata/packages.yaml` then `chezmoi apply` — never ad-hoc `brew install`, `npm i -g`, `pip install`, `cargo install`. Upgrades are `topgrade`'s job.
- Secrets only via 1Password (`op`); nothing secret or work-identifying in the dotfiles repo (it's public). Machine/work-local env goes in `~/.zshrc.local`.
- Before committing dotfiles: scan the diff for emails, tokens, keys, employer names. Commit signing is SSH via 1Password; there is no GPG.
- When the shell/tooling misbehaves, walk the "When something's off" checklist in the reference before changing anything.
