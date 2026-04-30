#!/bin/bash
# Validates all plugin and marketplace files in a project
# Usage: validate-all.sh [project-path]
# Exit 0 = all valid, Exit 1 = any invalid

set -euo pipefail

PROJECT_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERRORS=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Catalyst Validation"
echo "Project: $PROJECT_PATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Validate project-level marketplace.json
if [[ -f "$PROJECT_PATH/.claude-plugin/marketplace.json" ]]; then
  echo ""
  echo "▶ Project marketplace"
  if ! "$SCRIPT_DIR/validate-marketplace-json.sh" "$PROJECT_PATH/.claude-plugin/marketplace.json"; then
    ((ERRORS++))
  fi
else
  echo ""
  echo "⚠ No project marketplace found at .claude-plugin/marketplace.json"
  echo "  Run /catalyst:scaffold to create one"
fi

# Validate all plugin.json files in plugins/
if [[ -d "$PROJECT_PATH/plugins" ]]; then
  for plugin_json in "$PROJECT_PATH"/plugins/*/.claude-plugin/plugin.json; do
    if [[ -f "$plugin_json" ]]; then
      echo ""
      echo "▶ Plugin: $(dirname "$(dirname "$plugin_json")" | xargs basename)"
      if ! "$SCRIPT_DIR/validate-plugin-json.sh" "$plugin_json"; then
        ((ERRORS++))
      fi
    fi
  done
else
  echo ""
  echo "⚠ No plugins/ directory found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $ERRORS -eq 0 ]]; then
  echo "✓ All validations passed"
  exit 0
else
  echo "✗ $ERRORS validation(s) failed"
  exit 1
fi
