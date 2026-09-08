#!/bin/sh
# Pre-apply hook: gates ~/.claude/settings.json apply on drift from the
# chezmoi-rendered version.
#   - no difference: proceed
#   - cosmetic-only difference (same after jq -S): overwrite
#   - real (key/value) difference: ask before overwriting, abort otherwise
#
# In every case apply is allowed to proceed, the entryState hash is reset to
# the file's current on-disk hash first. Without this, chezmoi's own apply
# step sees the on-disk hash diverge from its recorded state and prompts a
# second time to confirm overwriting an "externally modified" file.

TARGET="$HOME/.claude/settings.json"

[ -f "$TARGET" ] || exit 0
command -v jq >/dev/null || exit 0

sync_state_hash() {
  HASH=$(shasum -a 256 "$TARGET" | awk '{print $1}')
  STATE=$(chezmoi state get --bucket="entryState" --key="$TARGET" 2>/dev/null)
  [ -n "$STATE" ] || return 0
  MODE=$(printf '%s' "$STATE" | jq '.mode')
  chezmoi state set --bucket="entryState" --key="$TARGET" \
    --value="{\"type\":\"file\",\"mode\":$MODE,\"contentsSHA256\":\"$HASH\"}"
}

RENDERED_RAW=$(chezmoi cat "$TARGET" 2>/dev/null) || exit 0
ACTUAL_RAW=$(cat "$TARGET")

if [ "$RENDERED_RAW" = "$ACTUAL_RAW" ]; then
  sync_state_hash
  exit 0
fi

RENDERED=$(printf '%s' "$RENDERED_RAW" | jq -S .)
ACTUAL=$(printf '%s' "$ACTUAL_RAW" | jq -S .)

if [ "$RENDERED" = "$ACTUAL" ]; then
  sync_state_hash
  exit 0
fi

# say COLOR MESSAGE... -> styled with gum when available, plain text otherwise.
# This hook runs on hooks.apply.pre, which fires before packages (including
# gum) are installed on a fresh machine, so gum can't be a hard dependency.
say() {
  COLOR="$1"; shift
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground "$COLOR" "$*" >&2
  else
    printf '%s\n' "$*" >&2
  fi
}

# confirm PROMPT -> 0 if the user agrees, 1 otherwise (including no TTY).
confirm() {
  if command -v gum >/dev/null 2>&1; then
    gum confirm "$1"
    return $?
  fi
  if [ -r /dev/tty ]; then
    printf '%s [y/N] ' "$1" >&2
    { read -r ANSWER < /dev/tty; } 2>/dev/null
  else
    ANSWER=""
  fi
  case "$ANSWER" in
    y|Y|yes|Yes) return 0 ;;
    *) return 1 ;;
  esac
}

say 226 "chezmoi: ~/.claude/settings.json has unsynced changes."
if confirm "Run \`chezmoi claude diff\` to inspect. Overwrite with the chezmoi-managed version?"; then
  sync_state_hash
  exit 0
fi

say 226 "aborted. Run: chezmoi claude sync"
exit 1
