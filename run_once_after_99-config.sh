#!/bin/sh

# setup node env for latest LTS
fnm install --lts
fnm use

# setup gpg
gpg-agent --daemon
echo "allow-preset-passphrase" >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye