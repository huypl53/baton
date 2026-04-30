#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# All Claude config directories
CLAUDE_CONFIGS=("$HOME/.claude" "$HOME/.claude-glm" "$HOME/.claude-api-proxy")

log() { printf '\033[32m[setup]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[warn]\033[0m %s\n' "$1"; }

symlink() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    local current_target
    current_target=$(readlink "$dst")
    if [ "$current_target" = "$src" ]; then
      log "Already linked: $dst"
      return 0
    fi
    warn "Updating symlink: $dst"
    rm "$dst"
  elif [ -e "$dst" ]; then
    warn "Backing up existing: $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  ln -s "$src" "$dst"
  log "Linked: $dst -> $src"
}

# Verify config directories exist (created by claude-personal/setup.sh)
for config_dir in "${CLAUDE_CONFIGS[@]}"; do
  if [ ! -d "$config_dir/skills" ]; then
    warn "$config_dir/skills does not exist. Run claude-personal/setup.sh first."
    exit 1
  fi
done

# Parse optional plugin CSV
PLUGINS_CSV=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --plugins)
      PLUGINS_CSV="${2:-}"
      shift 2
      ;;
    *)
      warn "Unknown argument: $1"
      shift
      ;;
  esac
done

# Known plugin skill roots
declare -A PLUGIN_PATHS=(
  [daily]="$SCRIPT_DIR/plugins/daily/skills"
  [nextjs]="$SCRIPT_DIR/plugins/nextjs/skills"
  [catalyst]="$SCRIPT_DIR/plugins/catalyst/skills"
)

# Always install marketplace manifest directory for local testing/registration
log "Setting up marketplace manifest..."
for config_dir in "${CLAUDE_CONFIGS[@]}"; do
  symlink "$SCRIPT_DIR/.claude-plugin" "$config_dir/.claude-plugin-marketplace"
done

# Install plugin skills only when requested
if [ -n "$PLUGINS_CSV" ]; then
  log "Setting up plugin skills..."
  IFS=',' read -r -a requested_plugins <<< "$PLUGINS_CSV"
  for plugin in "${requested_plugins[@]}"; do
    plugin="$(echo "$plugin" | xargs)"
    [ -n "$plugin" ] || continue

    plugin_skill_root="${PLUGIN_PATHS[$plugin]:-}"
    if [ -z "$plugin_skill_root" ] || [ ! -d "$plugin_skill_root" ]; then
      warn "Unknown plugin '$plugin' - skipping"
      continue
    fi

    for skill_dir in "$plugin_skill_root"/*/; do
      [ -d "$skill_dir" ] || continue
      skill_name=$(basename "$skill_dir")
      for config_dir in "${CLAUDE_CONFIGS[@]}"; do
        symlink "$skill_dir" "$config_dir/skills/$skill_name"
      done
    done
  done
else
  log "No --plugins flag passed; skipping plugin skill installation"
fi

log "Setup complete!"
printf '\n'
printf 'Usage: ./setup.sh --plugins daily,nextjs,catalyst\n'
