#!/bin/sh

# setup node env for latest LTS
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
fnm install --lts
fnm use

# setup gpg
gpg-agent --daemon
echo "allow-preset-passphrase" >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye

# kill sudo loop
# if [ -f /tmp/sudo_loop.pid ]; then
#   kill "$(cat /tmp/sudo_loop.pid)" && rm /tmp/sudo_loop.pid
# fi