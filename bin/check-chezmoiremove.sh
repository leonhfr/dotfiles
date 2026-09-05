#!/bin/sh
### check-chezmoiremove — warn on staged deletions missing from home/.chezmoiremove
###
### For every file staged for deletion under home/, resolves its chezmoi
### target path and checks whether that target is listed in home/.chezmoiremove.
### Files chezmoi itself manages specially (.chezmoi*) are skipped,
### since they have no deployed target.

set -eu

cd "$(git rev-parse --show-toplevel)"

deleted=$(git diff --cached --name-only --diff-filter=D -- home/ || true)
[ -z "$deleted" ] && exit 0

scratch=$(mktemp -d "$PWD/tmp/chezmoiremove-check.XXXXXX")
trap 'rm -rf "$scratch"' EXIT

missing=""
for path in $deleted; do
  rel="${path#home/}"
  case "$rel" in
    .chezmoi*) continue ;;
  esac

  mkdir -p "$scratch/$(dirname "$rel")"
  git show "HEAD:$path" >"$scratch/$rel" 2>/dev/null || continue

  target=$(chezmoi target-path -S "$scratch" "$scratch/$rel" 2>/dev/null || true)
  [ -z "$target" ] && continue
  target_rel="${target#"$HOME"/}"

  found=0
  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    case "$target_rel" in
      "$entry" | "$entry"/*) found=1 ;;
    esac
  done <home/.chezmoiremove

  if [ "$found" -eq 0 ]; then
    missing="${missing}  ${target_rel}  (deleted: ${path})
"
  fi
done

if [ -n "$missing" ]; then
  printf '[hk] deleted source files not listed in home/.chezmoiremove (target machines will keep the old file):\n%s' "$missing" >&2
  exit 1
fi
