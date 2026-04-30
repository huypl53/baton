#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANDBOX="/tmp/claude-setup-test-$$"

log() { printf '\033[36m[test]\033[0m %s\n' "$1"; }

cleanup() {
  if [ -d "$SANDBOX" ]; then
    log "Cleaning up $SANDBOX"
    rm -rf "$SANDBOX"
  fi
}

# Cleanup on exit (optional - comment out to inspect results)
# trap cleanup EXIT

log "Creating sandbox at $SANDBOX"
mkdir -p "$SANDBOX"

# Run setup.sh with fake HOME
log "Running setup.sh with HOME=$SANDBOX"
HOME="$SANDBOX" "$SCRIPT_DIR/setup.sh"

# Show results
log "Results:"
echo ""
find "$SANDBOX" -type l -exec ls -la {} \; 2>/dev/null | sed 's|'$SANDBOX'|$SANDBOX|g'
echo ""
log "Directory structure:"
tree "$SANDBOX" 2>/dev/null || find "$SANDBOX" -not -name '.' | sort | sed 's|'$SANDBOX'|$SANDBOX|g'

echo ""
log "Sandbox preserved at: $SANDBOX"
log "Run 'rm -rf $SANDBOX' to clean up"
