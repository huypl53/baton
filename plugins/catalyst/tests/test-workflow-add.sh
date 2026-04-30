#!/bin/bash
# Test workflow add skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNAPSHOTS_DIR="$SCRIPT_DIR/snapshots"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo "Test: Workflow add skill"
echo "========================"

# Check auth-workflow snapshot
SNAPSHOT="$SNAPSHOTS_DIR/auth-workflow"

echo ""
echo "Checking auth-workflow snapshot..."

# Required files
for f in "commands/auth-flow.md"; do
    if [[ -f "$SNAPSHOT/$f" ]]; then
        pass "$f exists"
    else
        fail "$f missing"
    fi
done

# Memory structure
for f in "insights.md" "gotchas.md" "test-flows.md"; do
    if [[ -f "$SNAPSHOT/memory/workflows/auth/$f" ]]; then
        pass "memory/workflows/auth/$f exists"
    else
        fail "memory/workflows/auth/$f missing"
    fi
done

# Decisions directory
if [[ -d "$SNAPSHOT/memory/decisions/auth" ]]; then
    pass "memory/decisions/auth/ exists"
else
    fail "memory/decisions/auth/ missing"
fi

echo ""
echo "Checking command content..."

# Command has frontmatter
if head -1 "$SNAPSHOT/commands/auth-flow.md" | grep -q "^---"; then
    pass "auth-flow.md has frontmatter"
else
    fail "auth-flow.md missing frontmatter"
fi

# Command has mandatory sections
if grep -q "Before You Code (MANDATORY)" "$SNAPSHOT/commands/auth-flow.md"; then
    pass "auth-flow.md has Before You Code section"
else
    fail "auth-flow.md missing Before You Code section"
fi

if grep -q "After Shipping (MANDATORY)" "$SNAPSHOT/commands/auth-flow.md"; then
    pass "auth-flow.md has After Shipping section"
else
    fail "auth-flow.md missing After Shipping section"
fi

# Command references correct memory paths
if grep -q "@memory/workflows/auth/insights.md" "$SNAPSHOT/commands/auth-flow.md"; then
    pass "auth-flow.md references auth memory"
else
    fail "auth-flow.md missing auth memory references"
fi

echo ""
echo -e "${GREEN}All workflow add tests passed${NC}"
