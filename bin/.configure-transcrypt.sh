#!/bin/sh
set -eu

CHEZMOI_DIR="$HOME/.local/share/chezmoi"

eval "$(/opt/homebrew/bin/brew shellenv)"

# Exits early if transcrypt is already set up
git -C "$CHEZMOI_DIR" config --local transcrypt.version >/dev/null 2>&1 && exit 0

if ! command -v transcrypt >/dev/null 2>&1; then
    echo "[dotfiles] Installing transcrypt"
    brew install transcrypt
fi

echo "[dotfiles] Configuring transcrypt"
PASSPHRASE=$(op read "op://Personal/Dotfiles Transcrypt Passphrase/password" --account my)
(cd "$CHEZMOI_DIR" && transcrypt -c aes-256-cbc -p "$PASSPHRASE" -y)

# Force re-checkout so encrypted files in the working tree are decrypted
git -C "$CHEZMOI_DIR" checkout HEAD -- .
