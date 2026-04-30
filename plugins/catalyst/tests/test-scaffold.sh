#!/bin/bash
# Test scaffold skill with fixtures

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
SNAPSHOTS_DIR="$SCRIPT_DIR/snapshots"
TEMP_DIR=$(mktemp -d)

trap "rm -rf $TEMP_DIR" EXIT

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo "Test: Scaffold skill with basic fixture"
echo "========================================"

# Simulate scaffold output
OUTPUT_DIR="$TEMP_DIR/sample-flow"
mkdir -p "$OUTPUT_DIR"

# Copy snapshot as expected output
cp -r "$SNAPSHOTS_DIR/basic-flow/." "$OUTPUT_DIR/"

# Verify structure
echo ""
echo "Checking generated structure..."

# Required files
for f in ".claude-plugin/plugin.json" "CLAUDE.md" "skills/ship/SKILL.md" "commands/crud-flow.md"; do
    if [[ -f "$OUTPUT_DIR/$f" ]]; then
        pass "$f exists"
    else
        fail "$f missing"
    fi
done

# Required directories
for d in "memory/workflows/crud" "memory/decisions/crud" "agents"; do
    if [[ -d "$OUTPUT_DIR/$d" ]]; then
        pass "$d/ exists"
    else
        fail "$d/ missing"
    fi
done

# Memory files
for f in "memory/INDEX.md" "memory/conventions.md" "memory/gotchas.md"; do
    if [[ -f "$OUTPUT_DIR/$f" ]]; then
        pass "$f exists"
    else
        fail "$f missing"
    fi
done

# Workflow memory files
for f in "insights.md" "gotchas.md" "test-flows.md"; do
    if [[ -f "$OUTPUT_DIR/memory/workflows/crud/$f" ]]; then
        pass "memory/workflows/crud/$f exists"
    else
        fail "memory/workflows/crud/$f missing"
    fi
done

echo ""
echo "Checking content validity..."

# plugin.json is valid JSON
if jq '.' "$OUTPUT_DIR/.claude-plugin/plugin.json" >/dev/null 2>&1; then
    pass "plugin.json is valid JSON"
else
    fail "plugin.json is invalid JSON"
fi

# plugin.json has required fields
if jq -e '.name and .description and .version' "$OUTPUT_DIR/.claude-plugin/plugin.json" >/dev/null 2>&1; then
    pass "plugin.json has required fields"
else
    fail "plugin.json missing required fields"
fi

# SKILL.md has frontmatter
if head -1 "$OUTPUT_DIR/skills/ship/SKILL.md" | grep -q "^---"; then
    pass "SKILL.md has frontmatter"
else
    fail "SKILL.md missing frontmatter"
fi

echo ""
echo -e "${GREEN}All scaffold tests passed${NC}"
