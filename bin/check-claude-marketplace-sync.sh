#!/bin/sh
### check-claude-marketplace-sync — warn when claude_marketplaces in encrypted_claude.yaml
### is out of sync with extraKnownMarketplaces in the settings templates.
###
### Both directions are checked: a marketplace present in one place but absent
### in the other triggers a warning. anthropics/claude-plugins-official is
### skipped because it is a built-in marketplace that needs no explicit entry.

set -eu

cd "$(git rev-parse --show-toplevel)"

YAML="home/.chezmoidata/encrypted_claude.yaml"
BASE_SETTINGS="home/.chezmoitemplates/claude_settings.json"
WORK_SETTINGS="home/.chezmoitemplates/encrypted_claude_settings_work.json"

normalize() {
    printf '%s' "$1" | sed 's|git@github\.com:||; s|\.git$||'
}

# All marketplace sources from yaml (common + personal + work)
yaml_sources=$(yq eval '.claude_marketplaces | to_entries | .[].value | .[]' "$YAML" 2>/dev/null | grep -v '^anthropics/')

# All extraKnownMarketplaces repo/url values from settings template files
settings_sources=$(
    jq -r '[.extraKnownMarketplaces // {} | .[].source | (.repo // .url)] | .[]' "$BASE_SETTINGS" 2>/dev/null
    jq -r '[.extraKnownMarketplaces // {} | .[].source | (.repo // .url)] | .[]' "$WORK_SETTINGS" 2>/dev/null
)

warnings=0

# yaml → settings: every yaml entry must appear in settings
while IFS= read -r src; do
    [ -z "$src" ] && continue
    needle=$(normalize "$src")
    found=0
    while IFS= read -r s; do
        [ -z "$s" ] && continue
        [ "$(normalize "$s")" = "$needle" ] && found=1 && break
    done <<EOF
$settings_sources
EOF
    if [ "$found" -eq 0 ]; then
        printf '[marketplace-sync] %s is in claude_marketplaces but missing from extraKnownMarketplaces\n' "$src" >&2
        warnings=$((warnings + 1))
    fi
done <<EOF
$yaml_sources
EOF

# settings → yaml: every settings entry must appear in yaml
while IFS= read -r src; do
    [ -z "$src" ] && continue
    needle=$(normalize "$src")
    found=0
    while IFS= read -r s; do
        [ -z "$s" ] && continue
        [ "$(normalize "$s")" = "$needle" ] && found=1 && break
    done <<EOF
$yaml_sources
EOF
    if [ "$found" -eq 0 ]; then
        printf '[marketplace-sync] %s is in extraKnownMarketplaces but missing from claude_marketplaces\n' "$src" >&2
        warnings=$((warnings + 1))
    fi
done <<EOF
$settings_sources
EOF

[ "$warnings" -gt 0 ] && exit 1 || exit 0
