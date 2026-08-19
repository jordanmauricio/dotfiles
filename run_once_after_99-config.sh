#!/bin/sh

# setup node env for latest LTS
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
fnm install --lts
fnm use
