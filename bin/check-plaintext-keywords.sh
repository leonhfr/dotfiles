#!/bin/sh
### check-plaintext-keywords — warn on staged, non-encrypted_ files containing work-specific keywords
###
### Keeps work/personal separation clean. Content that must stay inside
### an encrypted_ file should never appear in a plain committed file.
### Checks the staged content of every non-deleted file whose basename
### isn't prefixed encrypted_ for a fixed keyword list, case-insensitively.

set -eu

cd "$(git rev-parse --show-toplevel)"

keywords="qonto qontoctl leon.hollender"

changed=$(git diff --cached --name-only --diff-filter=d || true)
[ -z "$changed" ] && exit 0

hits=""
for path in $changed; do
  [ "$path" = "bin/check-plaintext-keywords.sh" ] && continue
  base=$(basename "$path")
  case "$base" in
    encrypted_*) continue ;;
  esac

  content=$(git show ":$path" 2>/dev/null) || continue

  for kw in $keywords; do
    if printf '%s' "$content" | grep -qIi -- "$kw"; then
      hits="${hits}  ${path}: contains \"${kw}\"
"
    fi
  done
done

if [ -n "$hits" ]; then
  printf '[hk] warning: work-specific keyword found in non-encrypted_ file(s):\n%s' "$hits" >&2
  exit 1
fi
