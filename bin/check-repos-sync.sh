#!/bin/sh
### check-repos-sync — fail the commit when ghq clones drift from encrypted_repos.yaml
###
### Compares the repos tracked in home/.chezmoidata/encrypted_repos.yaml
### (common + current machine scope, templated by chezmoi) against the repos
### actually cloned, per `ghq list`. The commit fails when the two sets differ
### in either direction: tracked but not cloned, or cloned but not tracked.
###
### Roots differ per machine (see home/private_dot_config/git/config.tmpl:
### ~/src plus ~/work for work orgs). `ghq root --all` reports every root, so
### no root is hardcoded. Worktrees are skipped: like
### home/dot_local/bin/executable_repos, an entry whose .git is a file (not a
### directory) is a worktree, not a clone.
###
### Reads the working-tree encrypted_repos.yaml via chezmoi, not the staged
### copy, so a partially staged change is compared as it stands on disk.

set -eu

cd "$(git rev-parse --show-toplevel)"

# Without both tools the check cannot run. Do not block the commit.
command -v ghq >/dev/null 2>&1 || exit 0
command -v chezmoi >/dev/null 2>&1 || exit 0

# normalize a git URL to ghq's listing form:
#   git@github.com:leonhfr/notes.git -> github.com/leonhfr/notes
norm() {
  sed -e 's#^git@##' -e 's#^ssh://##' -e 's#^https://##' -e 's#^http://##' \
      -e 's#\.git$##' -e 's#:#/#'
}

TMP=$(mktemp -d "$PWD/tmp/repos-sync.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

# Tracked: common + current machine scope, normalized, sorted-unique.
chezmoi execute-template '{{ range (concat .repos.common (index .repos .machine)) }}{{ . }}
{{ end }}' | grep . | norm | sort -u > "$TMP/tracked"

# Roots, longest first, so a nested root strips before its parent.
ghq root --all | sed 's#/$##' | awk '{ print length, $0 }' | sort -rn | cut -d' ' -f2- > "$TMP/roots"

# Cloned: every ghq full path minus worktrees, with its root prefix stripped
# back to host/owner/repo form, sorted-unique.
ghq list --full-path | while IFS= read -r dir; do
  [ -n "$dir" ] || continue
  [ -f "$dir/.git" ] && continue
  rel=""
  while IFS= read -r root; do
    case "$dir" in
      "$root"/*) rel="${dir#"$root"/}"; break ;;
    esac
  done < "$TMP/roots"
  [ -n "$rel" ] && printf '%s\n' "$rel"
done | sort -u > "$TMP/cloned"

missing=$(comm -23 "$TMP/tracked" "$TMP/cloned")
untracked=$(comm -13 "$TMP/tracked" "$TMP/cloned")

[ -z "$missing" ] && [ -z "$untracked" ] && exit 0

{
  printf '[hk] ghq clones do not match home/.chezmoidata/encrypted_repos.yaml (machine: %s):\n' \
    "$(chezmoi execute-template '{{ .machine }}')"
  if [ -n "$missing" ]; then
    printf '  tracked but not cloned (clone it, or remove it from the list with repo remove):\n'
    printf '%s\n' "$missing" | sed 's/^/    /'
  fi
  if [ -n "$untracked" ]; then
    printf '  cloned but not tracked (track it with repo add, or delete the clone):\n'
    printf '%s\n' "$untracked" | sed 's/^/    /'
  fi
} >&2
exit 1
