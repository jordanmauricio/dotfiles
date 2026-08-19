#!/bin/sh
# Print the entries of one or more .chezmoidata/packages.yaml lists, one per line.
#
#   packages-list.sh casks,caskspersonal
#
# Used by the bootstrap workflow so it can reason about the package lists without
# editing the source state it is supposed to be testing.
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

awk -v keys="${1:?usage: packages-list.sh <key>[,<key>...]}" '
  BEGIN { n = split(keys, k, ","); for (i = 1; i <= n; i++) want[k[i]] = 1 }
  # A bare "key:" line opens a list; any following one closes the previous one.
  /^ *[A-Za-z0-9@_]+: *$/ { key = $0; gsub(/[ :]/, "", key); in_want = (key in want); next }
  in_want && /^ *- / {
    sub(/^ *- */, ""); sub(/ *#.*$/, ""); gsub(/"/, "")
    if ($0 != "") print
  }
' "$repo_root/.chezmoidata/packages.yaml"
