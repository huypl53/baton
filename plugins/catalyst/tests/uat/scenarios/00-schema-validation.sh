#!/bin/bash
# Structural test: Validate schemas and snapshots
# No Claude required - pure file checks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
SNAPSHOT="$PLUGIN_DIR/tests/snapshots/basic-flow"

# Helpers
assert_file() {
    [[ -f "$1" ]] || { echo "  ✗ Missing: $1"; exit 1; }
}

assert_dir() {
    [[ -d "$1" ]] || { echo "  ✗ Missing: $1"; exit 1; }
}

echo "Scenario: Schema Validation"
echo "============================"
echo ""

# Validate plugin.json against schema
echo "Validating plugin.json..."

NAME=$(jq -r '.name' "$SNAPSHOT/.claude-plugin/plugin.json")
DESC=$(jq -r '.description' "$SNAPSHOT/.claude-plugin/plugin.json")
VERSION=$(jq -r '.version' "$SNAPSHOT/.claude-plugin/plugin.json")

[[ "$NAME" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "Invalid name format: $NAME"; exit 1; }
[[ ${#DESC} -ge 10 ]] || { echo "Description too short"; exit 1; }
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Invalid version: $VERSION"; exit 1; }

echo "  ✓ name: $NAME"
echo "  ✓ description: ${DESC:0:50}..."
echo "  ✓ version: $VERSION"

# Validate SKILL.md frontmatter
echo ""
echo "Validating SKILL.md frontmatter..."

SKILL_FILE="$SNAPSHOT/skills/ship/SKILL.md"

if head -1 "$SKILL_FILE" | grep -q "^---"; then
    FRONTMATTER=$(sed -n '2,/^---$/p' "$SKILL_FILE" | head -n -1)
    SKILL_NAME=$(echo "$FRONTMATTER" | grep "^name:" | cut -d: -f2- | tr -d ' ')
    SKILL_DESC=$(echo "$FRONTMATTER" | grep "^description:" | cut -d: -f2-)

    [[ -n "$SKILL_NAME" ]] || { echo "Missing skill name"; exit 1; }
    [[ -n "$SKILL_DESC" ]] || { echo "Missing skill description"; exit 1; }

    echo "  ✓ name: $SKILL_NAME"
    echo "  ✓ description: found"
else
    echo "Missing frontmatter in SKILL.md"
    exit 1
fi

# Validate command frontmatter
echo ""
echo "Validating command frontmatter..."

CMD_FILE="$SNAPSHOT/commands/crud-flow.md"

if head -1 "$CMD_FILE" | grep -q "^---"; then
    CMD_DESC=$(sed -n '2,/^---$/p' "$CMD_FILE" | grep "^description:" | cut -d: -f2-)
    [[ -n "$CMD_DESC" ]] || { echo "Missing command description"; exit 1; }
    echo "  ✓ description: found"
else
    echo "Missing frontmatter in command"
    exit 1
fi

# Validate memory structure
echo ""
echo "Validating memory structure..."

for f in INDEX.md conventions.md gotchas.md; do
    assert_file "$SNAPSHOT/memory/$f"
    echo "  ✓ $f"
done

for d in workflows decisions; do
    assert_dir "$SNAPSHOT/memory/$d"
    echo "  ✓ $d/"
done

WORKFLOW="crud"
for f in insights.md gotchas.md test-flows.md; do
    assert_file "$SNAPSHOT/memory/workflows/$WORKFLOW/$f"
done
echo "  ✓ workflows/$WORKFLOW/ (complete)"

echo ""
echo "Schema validation PASSED"
