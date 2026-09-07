#!/bin/sh
# Pre-apply hook: blocks apply if ~/.claude/settings.json has semantic drift.
# For cosmetic-only differences (key ordering), updates the state hash so
# chezmoi does not flag the file as externally modified.

TARGET="$HOME/.claude/settings.json"

[ -f "$TARGET" ] || exit 0
command -v jq >/dev/null || exit 0

RENDERED_RAW=$(chezmoi cat "$TARGET" 2>/dev/null) || exit 0
ACTUAL_RAW=$(cat "$TARGET")

RENDERED=$(printf '%s' "$RENDERED_RAW" | jq -S .)
ACTUAL=$(printf '%s' "$ACTUAL_RAW" | jq -S .)

if [ "$RENDERED" = "$ACTUAL" ]; then
  if [ "$RENDERED_RAW" != "$ACTUAL_RAW" ]; then
    HASH=$(shasum -a 256 "$TARGET" | awk '{print $1}')
    STATE=$(chezmoi state get --bucket="entryState" --key="$TARGET" 2>/dev/null)
    if [ -n "$STATE" ]; then
      MODE=$(printf '%s' "$STATE" | jq '.mode')
      chezmoi state set --bucket="entryState" --key="$TARGET" \
        --value="{\"type\":\"file\",\"mode\":$MODE,\"contentsSHA256\":\"$HASH\"}"
    fi
  fi
  exit 0
fi

printf 'chezmoi: ~/.claude/settings.json has unsynced changes. Run: chezmoi claude sync\n' >&2
exit 1
