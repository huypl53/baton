#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tmux-send-and-enter.sh -t target -- text

Agent-safe tmux input helper: sends literal text to a target pane and always follows with Enter (C-m) to execute.

Options:
  -t, --target    tmux target (session:window.pane or %<pane_id>), required
  -L, --socket    tmux socket name (passed to tmux -L)
  -S, --socket-path  tmux socket path (passed to tmux -S)
  -h, --help      show this help

Examples:
  ./scripts/tmux-send-and-enter.sh -t claude-python:0.0 -- 'print("hello")'
  ./scripts/tmux-send-and-enter.sh -S /tmp/claude.sock -t mysession:0.0 -- 'python3 -q'
  ./scripts/tmux-send-and-enter.sh -t %42 -- '/status'
USAGE
}

target=""
socket_name=""
socket_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)      target="${2-}"; shift 2 ;;
    -L|--socket)      socket_name="${2-}"; shift 2 ;;
    -S|--socket-path) socket_path="${2-}"; shift 2 ;;
    -h|--help)        usage; exit 0 ;;
    --)               shift; break ;;
    *)                echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$target" ]]; then
  echo "target is required" >&2
  usage
  exit 1
fi

if [[ -n "$socket_name" && -n "$socket_path" ]]; then
  echo "Use either -L or -S, not both" >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "text is required after --" >&2
  usage
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found in PATH" >&2
  exit 1
fi

text="$*"

tmux_cmd=(tmux)
if [[ -n "$socket_name" ]]; then
  tmux_cmd+=(-L "$socket_name")
elif [[ -n "$socket_path" ]]; then
  tmux_cmd+=(-S "$socket_path")
fi

"${tmux_cmd[@]}" send-keys -t "$target" -l -- "$text"
"${tmux_cmd[@]}" send-keys -t "$target" C-m
