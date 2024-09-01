#!/bin/sh

# setup node env for latest LTS
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
fnm install --lts
fnm use

# setup gpg
gpg-agent --daemon
echo "allow-preset-passphrase" >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye