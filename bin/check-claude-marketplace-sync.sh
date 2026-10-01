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
PERSONAL_SETTINGS="home/.chezmoitemplates/claude_settings_personal.json"
WORK_SETTINGS="home/.chezmoitemplates/encrypted_claude_settings_work.json"

normalize() {
    printf '%s' "$1" | sed 's|git@github\.com:||; s|\.git$||'
}

# Compare effective marketplace sources for each machine.
personal_yaml_sources=$(yq eval '.claude_marketplaces | to_entries | map(select(.key == "common" or .key == "personal")) | .[].value[]' "$YAML" 2>/dev/null | grep -v '^anthropics/')
work_yaml_sources=$(yq eval '.claude_marketplaces | to_entries | map(select(.key == "common" or .key == "work")) | .[].value[]' "$YAML" 2>/dev/null | grep -v '^anthropics/')

personal_settings_sources=$(
    jq -r '[.extraKnownMarketplaces // {} | .[].source | (.repo // .url)] | .[]' "$BASE_SETTINGS" 2>/dev/null
    jq -r '[.extraKnownMarketplaces // {} | .[].source | (.repo // .url)] | .[]' "$PERSONAL_SETTINGS" 2>/dev/null
)
work_settings_sources=$(
    jq -r '[.extraKnownMarketplaces // {} | .[].source | (.repo // .url)] | .[]' "$BASE_SETTINGS" 2>/dev/null
    jq -r '[.extraKnownMarketplaces // {} | .[].source | (.repo // .url)] | .[]' "$WORK_SETTINGS" 2>/dev/null
)

warnings=0
check_sync() {
    machine=$1
    yaml_sources=$2
    settings_sources=$3

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
            printf '[marketplace-sync] %s is in %s claude_marketplaces but missing from extraKnownMarketplaces\n' "$src" "$machine" >&2
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
            printf '[marketplace-sync] %s is in %s extraKnownMarketplaces but missing from claude_marketplaces\n' "$src" "$machine" >&2
            warnings=$((warnings + 1))
        fi
    done <<EOF
$settings_sources
EOF
}

check_sync personal "$personal_yaml_sources" "$personal_settings_sources"
check_sync work "$work_yaml_sources" "$work_settings_sources"

[ "$warnings" -gt 0 ] && exit 1 || exit 0
