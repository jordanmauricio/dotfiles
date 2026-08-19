#!/bin/sh

# setup node env for latest LTS
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
fnm install --lts
fnm use

# kill sudo loop
# if [ -f /tmp/sudo_loop.pid ]; then
#   kill "$(cat /tmp/sudo_loop.pid)" && rm /tmp/sudo_loop.pid
# fi