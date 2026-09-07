#!/bin/sh
set -eu

if ! xcode-select -p >/dev/null 2>&1; then
    echo "[dotfiles] Installing Xcode Command Line Tools"
    xcode-select --install
    until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "[dotfiles] Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
