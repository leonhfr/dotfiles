#!/bin/sh
### check-skill-tags — warn on active #skill brew tags with no corresponding skill directory
###
### For every uncommented brew in packages.yaml tagged with exactly #skill,
### checks that home/dot_claude/skills/<name>/SKILL.md exists in the working tree.
### Skips commented-out lines (# - name #skill) and variant tags (#skill?, #skill:...).

set -eu

cd "$(git rev-parse --show-toplevel)"

PACKAGES="home/.chezmoidata/packages.yaml"
SKILLS_DIR="home/dot_claude/skills"

# Use staged version if packages.yaml is staged, else on-disk.
if git diff --cached --name-only | grep -qF "$PACKAGES"; then
  content=$(git show ":$PACKAGES" 2>/dev/null)
else
  [ -f "$PACKAGES" ] || exit 0
  content=$(cat "$PACKAGES")
fi

names=$(printf '%s' "$content" \
  | grep -E '^ +- [^ ]+ #skill$' \
  | sed 's/.*- //' \
  | sed 's/ #skill$//' \
  | sed 's|.*/||' \
  | sed 's/@.*//')

[ -z "$names" ] && exit 0

missing=0
for name in $names; do
  if [ ! -f "$SKILLS_DIR/$name/SKILL.md" ]; then
    printf '[hk] missing skill: %s/%s/SKILL.md (brew tagged #skill)\n' "$SKILLS_DIR" "$name" >&2
    missing=1
  fi
done

[ "$missing" -eq 0 ] || exit 1
