#!/bin/sh

# Exit immediately if op is already in $PATH.
type op >/dev/null 2>&1 && exit

case "$(uname -s)" in
Darwin)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "[dotfiles] Installing 1password-cli"
    brew install 1password-cli
    ;;
*)
    echo "[dotfiles] unsupported OS"
    exit 1
    ;;
esac
