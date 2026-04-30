#!/bin/bash
# Validates marketplace.json against Claude Code requirements
# Usage: validate-marketplace-json.sh <path-to-marketplace.json>
# Exit 0 = valid, Exit 1 = invalid

set -euo pipefail

MARKETPLACE_JSON="${1:-.claude-plugin/marketplace.json}"

if [[ ! -f "$MARKETPLACE_JSON" ]]; then
  echo "ERROR: File not found: $MARKETPLACE_JSON"
  exit 1
fi

echo "Validating: $MARKETPLACE_JSON"

# Check required fields
if ! jq -e '.name' "$MARKETPLACE_JSON" >/dev/null 2>&1; then
  echo "FAIL: Required field 'name' is missing"
  exit 1
fi

if ! jq -e '.plugins' "$MARKETPLACE_JSON" >/dev/null 2>&1; then
  echo "FAIL: Required field 'plugins' is missing"
  exit 1
fi

# Check plugins is array
PLUGINS_TYPE=$(jq -r '.plugins | type' "$MARKETPLACE_JSON" 2>/dev/null)
if [[ "$PLUGINS_TYPE" != "array" ]]; then
  echo "FAIL: 'plugins' must be an array"
  exit 1
fi

# Check each plugin has required fields
PLUGIN_COUNT=$(jq '.plugins | length' "$MARKETPLACE_JSON")
for ((i=0; i<PLUGIN_COUNT; i++)); do
  for field in name source; do
    if ! jq -e ".plugins[$i].$field" "$MARKETPLACE_JSON" >/dev/null 2>&1; then
      echo "FAIL: Plugin at index $i missing required field '$field'"
      exit 1
    fi
  done

  # Check plugin source path exists
  SOURCE=$(jq -r ".plugins[$i].source" "$MARKETPLACE_JSON")
  MARKETPLACE_DIR=$(dirname "$MARKETPLACE_JSON")
  PLUGIN_PATH="$MARKETPLACE_DIR/../$SOURCE"

  if [[ ! -d "$PLUGIN_PATH" ]]; then
    echo "WARN: Plugin source path does not exist: $SOURCE"
    echo "      Expected at: $PLUGIN_PATH"
  fi
done

# Check owner is object if present
if jq -e '.owner' "$MARKETPLACE_JSON" >/dev/null 2>&1; then
  OWNER_TYPE=$(jq -r '.owner | type' "$MARKETPLACE_JSON")
  if [[ "$OWNER_TYPE" != "object" ]]; then
    echo "FAIL: 'owner' must be an object {\"name\": \"...\"}"
    exit 1
  fi
fi

echo "PASS: marketplace.json is valid"
exit 0
