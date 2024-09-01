#!/bin/bash

set -eu

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until this script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install curl if it's not already installed
if ! command -v curl >/dev/null; then
  sudo apt update
  sudo apt install -y curl
fi

# Install Homebrew if it's not already installed
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install Rust if it's not already installed
if ! command cargo >/dev/null; then
  /bin/bash -c "$(curl https://sh.rustup.rs -sSf)" | sh -s -- -y
fi

# Install password manager if it's not already installed
if ! command op >/dev/null; then
  brew install --cask 1password
  brew install 1password-cli

  echo "1Password has been installed. Perform the manual setup to integrate them as defined in the readme. Afterwards, press any key to continue."
  read -n 1 -s -r
  echo "Continuing with the script..."
fi
