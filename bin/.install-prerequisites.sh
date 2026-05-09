#!/bin/sh
set -eu

case "$(uname -s)" in
Darwin)
    "$(dirname "$0")/.install-homebrew.sh"
    "$(dirname "$0")/.install-password-manager.sh"
    "$(dirname "$0")/.configure-transcrypt.sh"
    ;;
*)
    echo "[dotfiles] unsupported OS"
    exit 1
    ;;
esac
