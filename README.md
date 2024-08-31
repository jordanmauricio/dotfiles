# Dotfiles Setup

These dotfiles are managed by [Chezmoi](https://www.chezmoi.io/).

## Setup new machine

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jordanmauricio`
```

### Manual step required for 1Password

- Go to Account > Settings > Developer
  - Select `Integrate with 1Password CLI`
  - Turn on Touch ID
  - Enable SSH Agent

## After Setup

- Configure SSH
- Manually configure Finder settings

## Guides

[Chezmoi Templating](https://www.chezmoi.io/user-guide/templating)
[Install pre-requisites](https://www.chezmoi.io/user-guide/frequently-asked-questions/usage/#how-do-i-install-pre-requisites-for-templates)
[Install password manager on init](https://www.chezmoi.io/user-guide/advanced/install-your-password-manager-on-init/)

[Eventually move local markdown to 1password file](https://www.chezmoi.io/user-guide/password-managers/1password/)
