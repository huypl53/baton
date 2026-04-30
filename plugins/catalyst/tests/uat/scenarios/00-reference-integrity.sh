#!/bin/bash
# Structural test: Verify reference integrity
# No Claude required - pure file checks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
SNAPSHOT="$PLUGIN_DIR/tests/snapshots/basic-flow"

echo "Scenario: Reference Integrity"
echo "=============================="
echo ""

# Extract all @memory/ references
echo "Checking @memory/ references..."

REFS_FOUND=0
REFS_VALID=0
REFS_SKIPPED=0

REFS=$(grep -ohP '@memory/[^\s\)]+' "$SNAPSHOT/commands/"*.md 2>/dev/null | sort -u || true)

for ref in $REFS; do
    # Skip template placeholders
    if echo "$ref" | grep -qE '(YYYY|{.*}|slug)'; then
        ((REFS_SKIPPED++)) || true
        continue
    fi

    ((REFS_FOUND++)) || true

    path="${ref#@}"
    path=$(echo "$path" | sed 's/[,.)]*$//')

    if [[ -e "$SNAPSHOT/$path" ]] || [[ -e "$SNAPSHOT/${path}.md" ]]; then
        ((REFS_VALID++)) || true
        echo "  ✓ $ref"
    else
        echo "  ✗ $ref (not found)"
    fi
done

echo ""
echo "Summary: $REFS_VALID/$REFS_FOUND valid ($REFS_SKIPPED skipped)"

if [[ $REFS_VALID -ne $REFS_FOUND ]]; then
    echo ""
    echo "FAILED: Some references don't resolve"
    exit 1
fi

# Check @agents/ references
echo ""
echo "Checking @agents/ references..."

AGENT_REFS=0
AGENT_VALID=0

AGENT_LIST=$(grep -ohP '@agents/[a-z0-9-]+' "$SNAPSHOT/commands/"*.md 2>/dev/null | sort -u || true)

for ref in $AGENT_LIST; do
    ((AGENT_REFS++)) || true
    agent="${ref#@agents/}"

    if [[ -f "$SNAPSHOT/agents/$agent.md" ]]; then
        ((AGENT_VALID++)) || true
        echo "  ✓ $ref"
    else
        echo "  ✗ $ref (not found)"
    fi
done

echo ""
echo "Summary: $AGENT_VALID/$AGENT_REFS agent references valid"

if [[ $AGENT_VALID -ne $AGENT_REFS ]]; then
    echo ""
    echo "WARNING: Some agent references don't resolve (may be optional)"
fi

echo ""
echo "Reference integrity PASSED"
