#!/bin/bash
# Check that every GUI cask in packages.yaml *would* install, without installing it.
#
#   CASK_MODE=resolve   ask Homebrew to resolve the cask and plan the install
#                       (`brew install --cask --dry-run`). Catches the common
#                       breakage: a cask renamed, deprecated or removed upstream.
#                       No download, no disk cost.
#   CASK_MODE=fetch     the above, plus download the artifact and verify its
#                       checksum (`brew fetch`). Additionally catches dead download
#                       URLs and artifacts that changed without a cask bump. The
#                       download cache is emptied after every cask so peak disk stays
#                       flat instead of accumulating tens of gigabytes of apps.
#
# Every cask is checked even after one fails, so a single dead cask does not hide the
# state of the rest. Exits non-zero if any check failed.
#
# Written for bash 3.2 (what macOS ships): no mapfile, no associative arrays.
set -uo pipefail

eval "$(/opt/homebrew/bin/brew shellenv)"

mode=${CASK_MODE:-fetch}
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ "${IS_WORK_LAPTOP:-false}" = "true" ]; then
  gated_key=caskswork; other_key=caskspersonal
else
  gated_key=caskspersonal; other_key=caskswork
fi

# visual-studio-code is really installed by brew bundle (the 37 vscode extension
# entries need a working `code` binary), so it is not simulated here.
applicable=$("$here/packages-list.sh" "casks,$gated_key" | grep -vx 'visual-studio-code')
# The laptop-type gate only decides what a real machine downloads. Resolving the other
# side too is free, and keeps a rename in the unused list from going unnoticed.
resolve_only=$("$here/packages-list.sh" "$other_key")

count() { printf '%s\n' "$1" | grep -c '[^[:space:]]'; }

n_applicable=$(count "$applicable")
n_resolve_only=$(count "$resolve_only")
failed_resolve=""
failed_fetch=""

echo "cask simulation: mode=$mode, laptop-set=$gated_key"
echo "  $n_applicable applicable cask(s), $n_resolve_only resolve-only cask(s)"

for cask in $applicable $resolve_only; do
  echo "--- resolve $cask"
  brew install --cask --dry-run "$cask" || failed_resolve="$failed_resolve $cask"
done

if [ "$mode" = fetch ]; then
  for cask in $applicable; do
    echo "--- fetch $cask"
    brew fetch --cask --retry "$cask" || failed_fetch="$failed_fetch $cask"
    # Drop the artifact immediately; the runner has far less disk than these apps need.
    rm -rf "$(brew --cache)/downloads"/* 2>/dev/null
  done
  df -h /
fi

n_failed_resolve=$(printf '%s' "$failed_resolve" | wc -w | tr -d ' ')
n_failed_fetch=$(printf '%s' "$failed_fetch" | wc -w | tr -d ' ')
n_total=$((n_applicable + n_resolve_only))

echo
echo "======================= cask simulation summary ======================="
echo "resolved: $((n_total - n_failed_resolve))/$n_total ok"
if [ "$mode" = fetch ]; then
  echo "fetched:  $((n_applicable - n_failed_fetch))/$n_applicable ok"
fi
if [ -n "$failed_resolve" ]; then echo "FAILED to resolve:$failed_resolve"; fi
if [ -n "$failed_fetch" ];   then echo "FAILED to fetch:  $failed_fetch"; fi
echo "======================================================================="

[ -z "$failed_resolve" ] && [ -z "$failed_fetch" ]
