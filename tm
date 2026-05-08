#!/usr/bin/env bash
# tm — quick tmux session picker / creator
#
# Usage:
#   tm                attach to an existing session, or create one
#   tm <name>         attach to <name>, creating it if missing
#   tm -l, --list     list sessions
#   tm -k <name>      kill session <name>
#   tm -K, --kill-all kill the tmux server
#   tm -h, --help     show help

set -euo pipefail

usage() {
    sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
}

inside_tmux() { [[ -n "${TMUX:-}" ]]; }

attach_or_switch() {
    local name=$1
    if inside_tmux; then
        tmux switch-client -t "$name"
    else
        tmux attach-session -t "$name"
    fi
}

ensure_and_attach() {
    local name=$1
    if ! tmux has-session -t="$name" 2>/dev/null; then
        # -d: create detached so we can switch/attach explicitly
        tmux new-session -d -s "$name"
    fi
    attach_or_switch "$name"
}

list_sessions() {
    tmux list-sessions -F '#{session_name}' 2>/dev/null || true
}

pick_session() {
    local sessions
    sessions=$(list_sessions)

    local choice
    if command -v fzf >/dev/null 2>&1; then
        # Add a synthetic "+ new session" entry on top
        choice=$(printf '+ new session\n%s' "$sessions" \
            | awk 'NF' \
            | fzf --prompt='tmux> ' \
                  --height=40% --reverse --border \
                  --header='enter: attach  |  type new name then esc-enter to create')
    else
        if [[ -z "$sessions" ]]; then
            read -rp "No sessions. Name for new session: " choice
        else
            echo "Sessions:"
            local i=1
            local -a arr=()
            while IFS= read -r s; do
                printf '  %2d) %s\n' "$i" "$s"
                arr+=("$s")
                ((i++))
            done <<< "$sessions"
            printf '  %2d) + new session\n' "$i"
            read -rp "Pick number, or type a name: " input
            if [[ "$input" =~ ^[0-9]+$ ]]; then
                if (( input >= 1 && input <= ${#arr[@]} )); then
                    choice=${arr[input-1]}
                elif (( input == ${#arr[@]} + 1 )); then
                    read -rp "New session name: " choice
                else
                    echo "Out of range." >&2; exit 1
                fi
            else
                choice=$input
            fi
        fi
    fi

    [[ -z "${choice:-}" ]] && exit 0
    if [[ "$choice" == "+ new session" ]]; then
        read -rp "New session name: " choice
        [[ -z "$choice" ]] && exit 0
    fi
    ensure_and_attach "$choice"
}

main() {
    case "${1:-}" in
        -h|--help)     usage; exit 0 ;;
        -l|--list)     list_sessions; exit 0 ;;
        -k)
            shift
            [[ $# -ge 1 ]] || { echo "tm -k requires a session name" >&2; exit 1; }
            tmux kill-session -t "$1"
            ;;
        -K|--kill-all) tmux kill-server 2>/dev/null || true ;;
        '')            pick_session ;;
        -*)            echo "Unknown option: $1" >&2; usage; exit 1 ;;
        *)             ensure_and_attach "$1" ;;
    esac
}

main "$@"
