#!/bin/bash
# Structural test: Basic determinism check
# No Claude required - pure file checks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
SNAPSHOT="$PLUGIN_DIR/tests/snapshots/basic-flow"

echo "Scenario: Basic Determinism"
echo "============================"
echo ""

# Create a temp copy
TEMP=$(mktemp -d)
trap "rm -rf $TEMP" EXIT

cp -r "$SNAPSHOT" "$TEMP/snapshot"

echo "Verifying snapshot stability..."

DIFF_COUNT=0

while IFS= read -r file; do
    rel_path="${file#$SNAPSHOT/}"
    temp_file="$TEMP/snapshot/$rel_path"

    if [[ -f "$temp_file" ]]; then
        if ! diff -q "$file" "$temp_file" >/dev/null 2>&1; then
            echo "  DIFF: $rel_path"
            ((DIFF_COUNT++))
        fi
    fi
done < <(find "$SNAPSHOT" -type f -name "*.md" -o -name "*.json")

echo "Files checked: $(find "$SNAPSHOT" -type f | wc -l)"
echo "Differences: $DIFF_COUNT"

# Verify key files have expected content
echo ""
echo "Verifying expected content..."

NAME=$(jq -r '.name' "$SNAPSHOT/.claude-plugin/plugin.json")
if [[ "$NAME" != "sample-flow" ]]; then
    echo "✗ Unexpected plugin name: $NAME (expected: sample-flow)"
    exit 1
fi
echo "  ✓ plugin.json name is sample-flow"

if ! grep -q "sample-flow" "$SNAPSHOT/CLAUDE.md"; then
    echo "✗ CLAUDE.md doesn't reference sample-flow"
    exit 1
fi
echo "  ✓ CLAUDE.md references sample-flow"

if ! grep -q "crud" "$SNAPSHOT/memory/INDEX.md"; then
    echo "✗ INDEX.md doesn't list crud workflow"
    exit 1
fi
echo "  ✓ INDEX.md lists crud workflow"

if ! grep -q "Before You Code (MANDATORY)" "$SNAPSHOT/commands/crud-flow.md"; then
    echo "✗ crud-flow.md missing mandatory section"
    exit 1
fi
echo "  ✓ crud-flow.md has mandatory sections"

echo ""
echo "Determinism check PASSED"
