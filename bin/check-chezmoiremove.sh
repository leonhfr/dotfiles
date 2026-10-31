#!/bin/sh
### check-chezmoiremove — warn on staged deletions/renames missing from home/.chezmoiremove
###
### For every file staged for deletion or rename under home/, resolves the
### old path's chezmoi target and checks whether that target is still managed
### by an indexed replacement or listed in home/.chezmoiremove. Replacements
### may manage the exact target or replace an ancestor with a symlink. Only the
### old side of a rename is checked. Files chezmoi itself manages specially
### (.chezmoi*) are skipped because they have no deployed target.

set -eu

cd "$(git rev-parse --show-toplevel)"

source_is_in_index() {
  source=$1
  case "$source" in
    "$PWD"/*) source=${source#"$PWD"/} ;;
    *) return 1 ;;
  esac
  git cat-file -e ":$source" 2>/dev/null
}

# Return success when the old target is still represented by the current source
# state, either directly or beneath a managed symlink.
target_has_replacement() {
  candidate=$1

  source=$(chezmoi source-path "$candidate" 2>/dev/null || true)
  if [ -n "$source" ] && source_is_in_index "$source"; then
    return 0
  fi

  candidate=$(dirname "$candidate")
  while [ "$candidate" != "$HOME" ] && [ "$candidate" != "/" ]; do
    source=$(chezmoi source-path "$candidate" 2>/dev/null || true)
    if [ -n "$source" ] && source_is_in_index "$source"; then
      case "$(basename "$source")" in
        symlink_* | *_symlink_*) return 0 ;;
      esac
      return 1
    fi
    candidate=$(dirname "$candidate")
  done

  return 1
}

changed=$(git diff --cached --name-status --diff-filter=DR -- home/ || true)
[ -z "$changed" ] && exit 0

scratch=$(mktemp -d "${TMPDIR:-/tmp}/chezmoiremove-check.XXXXXX")
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

  if target_has_replacement "$target"; then
    continue
  fi

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
