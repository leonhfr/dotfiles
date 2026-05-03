#!/bin/sh

if op whoami >/dev/null 2>&1; then
    exit 0
fi

echo "[dotfiles] Please sign in to 1Password and enable CLI integration"
echo "[dotfiles] (Settings → Developer → Connect with 1Password CLI)"
until op whoami >/dev/null 2>&1; do
    sleep 3
done
echo "[dotfiles] 1Password authenticated"
