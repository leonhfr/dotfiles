#!/bin/sh

# Exit immediately if op is already in $PATH.
type op >/dev/null 2>&1 && exit

eval "$(/opt/homebrew/bin/brew shellenv)"

if ! [ -d "/Applications/1Password.app" ]; then
    echo "[dotfiles] Installing 1Password"
    brew install --cask 1password
    open "/Applications/1Password.app"
fi

echo "[dotfiles] Installing 1password-cli"
brew install --cask 1password-cli
