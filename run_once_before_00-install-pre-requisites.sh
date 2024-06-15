#!/bin/bash

set -eu

# Update the OS
sudo softwareupdate -i -a

# Install Xcode, gets git and make among other things
if ! command -v git >/dev/null; then
  xcode-select --install
fi

# Install curl if it's not already installed
if ! command -v curl >/dev/null; then
  sudo apt update
  sudo apt install -y curl
fi

# Install Homebrew if it's not already installed
if ! command -v brew >/dev/null; then
  sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
fi

# Install Rust if it's not already installed
if ! command cargo >/dev/null; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y
fi
