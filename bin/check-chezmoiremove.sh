#!/bin/sh
### check-chezmoiremove — warn on staged deletions/renames missing from home/.chezmoiremove
###
### For every file staged for deletion or rename under home/, resolves the
### old path's chezmoi target and checks whether that target is listed in
### home/.chezmoiremove. A rename orphans the old target exactly like a
### deletion does, so both are checked; only the old path is checked for a
### rename, since the new path is still validly managed. Files chezmoi
### itself manages specially (.chezmoi*) are skipped, since they have no
### deployed target.

set -eu

cd "$(git rev-parse --show-toplevel)"

changed=$(git diff --cached --name-status --diff-filter=DR -- home/ || true)
[ -z "$changed" ] && exit 0

scratch=$(mktemp -d "$PWD/tmp/chezmoiremove-check.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
printf '%s\n' "$changed" >"$scratch/changed.txt"

missing=""
exec 3<"$scratch/changed.txt"
while IFS="$(printf '\t')" read -r status path _new <&3; do
  case "$status" in
    D | R*) ;;
    *) continue ;;
  esac

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
    missing="${missing}  ${target_rel}  (${status}: ${path})
"
  fi
done
exec 3<&-

if [ -n "$missing" ]; then
  printf '[hk] deleted/renamed source files not listed in home/.chezmoiremove (target machines will keep the old file):\n%s' "$missing" >&2
  exit 1
fi
