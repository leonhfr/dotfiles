#!/usr/bin/env bash
set -f

input=$(cat)

if [ -z "$input" ]; then
    printf "Claude"
    exit 0
fi

# Colors
blue='\033[38;2;0;153;255m'
orange='\033[38;2;255;176;85m'
green='\033[38;2;0;175;80m'
cyan='\033[38;2;86;182;194m'
red='\033[38;2;255;85;85m'
yellow='\033[38;2;230;200;0m'
white='\033[38;2;220;220;220m'
magenta='\033[38;2;180;140;255m'
dim='\033[2m'
reset='\033[0m'

sep=" ${dim}│${reset} "

color_for_pct() {
    local pct=$1
    if [ "$pct" -ge 90 ]; then printf "$red"
    elif [ "$pct" -ge 70 ]; then printf "$yellow"
    elif [ "$pct" -ge 50 ]; then printf "$orange"
    else printf "$green"
    fi
}

# Parse JSON (single jq call)
parsed=$(echo "$input" | jq -r '
    (.model.display_name // "Claude"),
    (.context_window.used_percentage // 0 | floor | tostring),
    (.workspace.current_dir // .cwd // "."),
    (.cost.total_duration_ms // 0 | tostring),
    (.effort.level // ""),
    (.session_id // "default"),
    (.worktree.name // ""),
    (.workspace.git_worktree // ""),
    "END"
' 2>/dev/null) || { printf "Claude"; exit 0; }

{
    IFS= read -r model_name
    IFS= read -r pct_used
    IFS= read -r cwd_full
    IFS= read -r duration_ms
    IFS= read -r effort_level
    IFS= read -r session_id
    IFS= read -r wt_name
    IFS= read -r git_worktree
    IFS= read -r _sentinel
} <<< "$parsed"

dirname="${cwd_full##*/}"
[ -z "$dirname" ] && dirname="."

# Git (cached per session, 5s TTL)
CACHE_FILE="/tmp/statusline-git-${session_id}"
CACHE_MAX_AGE=5

cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] && return 0
    local mtime
    mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
    [ $(( $(date +%s) - mtime )) -gt $CACHE_MAX_AGE ]
}

git_branch="" git_dirty=""
if cache_is_stale; then
    if git -C "$cwd_full" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git_branch=$(git -C "$cwd_full" symbolic-ref --short HEAD 2>/dev/null \
            || git -C "$cwd_full" rev-parse --short HEAD 2>/dev/null || echo "")
        [ -n "$(git -C "$cwd_full" --no-optional-locks status --porcelain 2>/dev/null)" ] \
            && git_dirty="*"
    fi
    printf '%s|%s\n' "$git_branch" "$git_dirty" > "$CACHE_FILE"
fi
[ -f "$CACHE_FILE" ] && IFS='|' read -r git_branch git_dirty < "$CACHE_FILE"

# Duration
dur_section=""
if [ "${duration_ms:-0}" -gt 0 ] 2>/dev/null; then
    dur_sec=$(( duration_ms / 1000 ))
    if [ $dur_sec -ge 3600 ]; then
        dur_fmt="$(( dur_sec / 3600 ))h$(( (dur_sec % 3600) / 60 ))m"
    elif [ $dur_sec -ge 60 ]; then
        dur_fmt="$(( dur_sec / 60 ))m"
    else
        dur_fmt="${dur_sec}s"
    fi
    dur_section="${sep}${dim}󰔟 ${reset}${white}${dur_fmt}${reset}"
fi

# Effort
effort_section=""
if [ -n "$effort_level" ]; then
    case "$effort_level" in
        max)    effort_section="${sep}${red}󱐋 max${reset}" ;;
        xhigh)  effort_section="${sep}${red}󱐋 xhigh${reset}" ;;
        high)   effort_section="${sep}${magenta}󱐋 high${reset}" ;;
        medium) effort_section="${sep}${yellow}󱐋 medium${reset}" ;;
        low)    effort_section="${sep}${dim}󱐋 low${reset}" ;;
        *)      effort_section="${sep}${dim}󱐋 ${effort_level}${reset}" ;;
    esac
fi

# Worktree
wt_display="${wt_name:-$git_worktree}"
wt_section=""
[ -n "$wt_display" ] && wt_section="${sep}${yellow}󰘬 ${wt_display}${reset}"

# Assemble
pct_int="${pct_used%.*}"
pct_int="${pct_int:-0}"
pct_color=$(color_for_pct "$pct_int")

line="${blue}${model_name}${reset}"
line+="${sep}${pct_color}󰓅 ${pct_int}%${reset}"
line+="${sep}${cyan}${dirname}${reset}"
[ -n "$git_branch" ] && line+=" ${green}(${git_branch}${red}${git_dirty}${green})${reset}"
line+="${dur_section}"
line+="${effort_section}"
line+="${wt_section}"

printf "%b" "$line"
