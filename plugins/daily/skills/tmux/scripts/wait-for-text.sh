#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  wait-for-text.sh -t target -p pattern [options]
  wait-for-text.sh -t target --idle [options]

Poll a tmux pane for text, or detect idle by pane-content hash stability.

Options:
  -t, --target           tmux target (session:window.pane or %<pane_id>), required
  -p, --pattern          regex pattern to look for
  -F, --fixed            treat pattern as a fixed string (grep -F)
  -S, --socket-path      tmux socket path (passed to tmux -S)
  -L, --socket           tmux socket name (passed to tmux -L)
  --idle                 enable idle detection mode (ignores --pattern)
  --idle-confirm-seconds seconds pane must remain unchanged to confirm idle (default: 10)
  -T, --timeout          seconds to wait (integer, default: 15)
  -i, --interval         poll interval in seconds (default: 1)
  -l, --lines            number of history lines to inspect (integer, default: 1000)
  -h, --help             show this help
USAGE
}

target=""
pattern=""
grep_flag="-E"
socket_name=""
socket_path=""
timeout=15
interval=1
lines=1000
idle_mode=false
idle_confirm_seconds=10

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)                target="${2-}"; shift 2 ;;
    -p|--pattern)               pattern="${2-}"; shift 2 ;;
    -F|--fixed)                 grep_flag="-F"; shift ;;
    -S|--socket-path)           socket_path="${2-}"; shift 2 ;;
    -L|--socket)                socket_name="${2-}"; shift 2 ;;
    --idle)                     idle_mode=true; shift ;;
    --idle-confirm-seconds)     idle_confirm_seconds="${2-}"; shift 2 ;;
    -T|--timeout)               timeout="${2-}"; shift 2 ;;
    -i|--interval)              interval="${2-}"; shift 2 ;;
    -l|--lines)                 lines="${2-}"; shift 2 ;;
    -h|--help)                  usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$target" ]]; then
  echo "target is required" >&2
  usage
  exit 1
fi

if [[ "$idle_mode" == false && -z "$pattern" ]]; then
  echo "pattern is required unless --idle is set" >&2
  usage
  exit 1
fi

if ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
  echo "timeout must be an integer number of seconds" >&2
  exit 1
fi

if ! [[ "$lines" =~ ^[0-9]+$ ]]; then
  echo "lines must be an integer" >&2
  exit 1
fi

if ! [[ "$idle_confirm_seconds" =~ ^[0-9]+$ ]]; then
  echo "idle-confirm-seconds must be an integer" >&2
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found in PATH" >&2
  exit 1
fi

if [[ -n "$socket_name" && -n "$socket_path" ]]; then
  echo "Use either -L or -S, not both" >&2
  exit 1
fi

tmux_cmd=(tmux)
if [[ -n "$socket_name" ]]; then
  tmux_cmd+=(-L "$socket_name")
elif [[ -n "$socket_path" ]]; then
  tmux_cmd+=(-S "$socket_path")
fi

start_epoch=$(date +%s)
deadline=$((start_epoch + timeout))

if [[ "$idle_mode" == true ]]; then
  stable_for=0
  prev_hash=""
  while true; do
    pane_text="$("${tmux_cmd[@]}" capture-pane -p -J -t "$target" -S "-${lines}" 2>/dev/null || true)"
    curr_hash="$(printf '%s' "$pane_text" | sha256sum | cut -d' ' -f1)"

    if [[ -n "$prev_hash" && "$curr_hash" == "$prev_hash" ]]; then
      stable_for=$((stable_for + 1))
    else
      stable_for=0
      prev_hash="$curr_hash"
    fi

    if (( stable_for >= idle_confirm_seconds )); then
      exit 0
    fi

    now=$(date +%s)
    if (( now >= deadline )); then
      echo "Timed out after ${timeout}s waiting for idle (${idle_confirm_seconds}s unchanged)" >&2
      echo "Last ${lines} lines from $target:" >&2
      printf '%s\n' "$pane_text" >&2
      exit 1
    fi

    sleep "$interval"
  done
fi

while true; do
  pane_text="$("${tmux_cmd[@]}" capture-pane -p -J -t "$target" -S "-${lines}" 2>/dev/null || true)"

  if printf '%s\n' "$pane_text" | grep $grep_flag -- "$pattern" >/dev/null 2>&1; then
    exit 0
  fi

  now=$(date +%s)
  if (( now >= deadline )); then
    echo "Timed out after ${timeout}s waiting for pattern: $pattern" >&2
    echo "Last ${lines} lines from $target:" >&2
    printf '%s\n' "$pane_text" >&2
    exit 1
  fi

  sleep "$interval"
done
