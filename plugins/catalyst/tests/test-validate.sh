#!/bin/bash
# Test validate skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
SNAPSHOTS_DIR="$SCRIPT_DIR/snapshots"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

echo "Test: Validate skill"
echo "===================="

PLUGIN="$SNAPSHOTS_DIR/basic-flow"

echo ""
echo "Testing schema validation..."

# plugin.json schema
if jq -e '
    (.name | type == "string") and
    (.description | type == "string") and
    (.version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
' "$PLUGIN/.claude-plugin/plugin.json" >/dev/null 2>&1; then
    pass "plugin.json matches schema"
else
    fail "plugin.json schema mismatch"
fi

echo ""
echo "Testing structure validation..."

# Required memory files
for f in "INDEX.md" "conventions.md" "gotchas.md"; do
    if [[ -f "$PLUGIN/memory/$f" ]]; then
        pass "memory/$f exists"
    else
        fail "memory/$f missing"
    fi
done

# Required directories
for d in "workflows" "decisions"; do
    if [[ -d "$PLUGIN/memory/$d" ]]; then
        pass "memory/$d/ exists"
    else
        fail "memory/$d/ missing"
    fi
done

echo ""
echo "Testing reference validation..."

# Extract and check @memory/ references
refs_found=0
refs_valid=0

while IFS= read -r line; do
    if echo "$line" | grep -q '@memory/'; then
        ref=$(echo "$line" | grep -oP '@memory/[^\s]+' | head -1)
        # Skip template placeholders (YYYY-MM-DD, {name}, etc.)
        if echo "$ref" | grep -qE '(YYYY|{.*})'; then
            continue
        fi
        ((refs_found++)) || true
        path="${ref#@}"
        # Handle directory refs (ending with /)
        if [[ "$path" == */ ]]; then
            path="${path%/}"
            if [[ -d "$PLUGIN/$path" ]]; then
                ((refs_valid++)) || true
            fi
        else
            # Check if file exists (with or without extension)
            if [[ -f "$PLUGIN/$path" ]] || [[ -f "$PLUGIN/$path.md" ]]; then
                ((refs_valid++)) || true
            fi
        fi
    fi
done < <(find "$PLUGIN/commands" -name "*.md" -exec cat {} \; 2>/dev/null)

if [[ $refs_found -gt 0 ]]; then
    if [[ $refs_valid -eq $refs_found ]]; then
        pass "All $refs_found @memory/ references resolve"
    else
        fail "$refs_valid/$refs_found @memory/ references resolve"
    fi
else
    warn "No @memory/ references found"
fi

echo ""
echo "Testing syntax validation..."

# All .md files parse (have content)
md_count=0
md_valid=0

while IFS= read -r file; do
    ((md_count++)) || true
    if [[ -s "$file" ]]; then
        ((md_valid++)) || true
    fi
done < <(find "$PLUGIN" -name "*.md" -type f)

if [[ $md_valid -eq $md_count ]]; then
    pass "All $md_count .md files are valid"
else
    fail "$md_valid/$md_count .md files are valid"
fi

echo ""
echo -e "${GREEN}All validate tests passed${NC}"
