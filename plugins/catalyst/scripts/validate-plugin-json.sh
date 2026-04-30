#!/bin/bash
# Validates plugin.json against Claude Code requirements
# Usage: validate-plugin-json.sh <path-to-plugin.json>
# Exit 0 = valid, Exit 1 = invalid

set -euo pipefail

PLUGIN_JSON="${1:-.claude-plugin/plugin.json}"

if [[ ! -f "$PLUGIN_JSON" ]]; then
  echo "ERROR: File not found: $PLUGIN_JSON"
  exit 1
fi

echo "Validating: $PLUGIN_JSON"

# Check for forbidden fields that cause Claude Code install failure
FORBIDDEN_FIELDS=(skills agents workflows commands hooks stack memory generated)
for field in "${FORBIDDEN_FIELDS[@]}"; do
  if jq -e "has(\"$field\")" "$PLUGIN_JSON" >/dev/null 2>&1; then
    echo "FAIL: Forbidden field '$field' found in plugin.json"
    echo "      Claude Code auto-discovers these - remove this field"
    exit 1
  fi
done

# Check author is object, not string
AUTHOR_TYPE=$(jq -r '.author | type // "null"' "$PLUGIN_JSON" 2>/dev/null)
if [[ "$AUTHOR_TYPE" == "string" ]]; then
  echo "FAIL: 'author' must be an object {\"name\": \"...\"}, not a string"
  echo "      Change from: \"author\": \"name\""
  echo "      Change to:   \"author\": {\"name\": \"name\"}"
  exit 1
fi

# Check required fields
for field in name description version; do
  if ! jq -e ".$field" "$PLUGIN_JSON" >/dev/null 2>&1; then
    echo "FAIL: Required field '$field' is missing"
    exit 1
  fi
done

# Check name format (lowercase, alphanumeric, hyphens)
NAME=$(jq -r '.name' "$PLUGIN_JSON")
if [[ ! "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "FAIL: Plugin name must be lowercase alphanumeric with hyphens"
  echo "      Got: $NAME"
  exit 1
fi

# Check version format
VERSION=$(jq -r '.version' "$PLUGIN_JSON")
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "FAIL: Version must be semver format (e.g., 1.0.0)"
  echo "      Got: $VERSION"
  exit 1
fi

echo "PASS: plugin.json is valid"
exit 0
