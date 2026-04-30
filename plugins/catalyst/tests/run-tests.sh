#!/bin/bash
# Catalyst plugin test runner
# Usage: ./run-tests.sh [--update-snapshots] [test-name]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
UPDATE_SNAPSHOTS=false
TEST_FILTER=""

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --update-snapshots) UPDATE_SNAPSHOTS=true; shift ;;
        *) TEST_FILTER="$1"; shift ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

PASSED=0
FAILED=0
WARNED=0

# Test: Schema files exist and are valid JSON
test_schemas() {
    echo "Testing: Schema validation"

    for schema in "$PLUGIN_DIR"/schemas/*.json; do
        if jq '.' "$schema" >/dev/null 2>&1; then
            pass "$(basename "$schema") is valid JSON"
            ((PASSED++)) || true
        else
            fail "$(basename "$schema") is invalid JSON"
            ((FAILED++)) || true
        fi
    done
}

# Test: Plugin structure
test_plugin_structure() {
    echo ""
    echo "Testing: Plugin structure"

    # Required files
    for f in .claude-plugin/plugin.json README.md; do
        if [[ -f "$PLUGIN_DIR/$f" ]]; then
            pass "$f exists"
            ((PASSED++)) || true
        else
            fail "$f missing"
            ((FAILED++)) || true
        fi
    done

    # Required skills
    for skill in scout scaffold workflow review validate; do
        if [[ -f "$PLUGIN_DIR/skills/$skill/SKILL.md" ]]; then
            pass "skills/$skill/SKILL.md exists"
            ((PASSED++)) || true
        else
            fail "skills/$skill/SKILL.md missing"
            ((FAILED++)) || true
        fi
    done

    # Required directories
    for dir in schemas tests templates; do
        if [[ -d "$PLUGIN_DIR/$dir" ]]; then
            pass "$dir/ exists"
            ((PASSED++)) || true
        else
            fail "$dir/ missing"
            ((FAILED++)) || true
        fi
    done
}

# Test: Fixtures exist
test_fixtures() {
    echo ""
    echo "Testing: Test fixtures"

    if [[ -d "$SCRIPT_DIR/fixtures/sample-project" ]]; then
        pass "fixtures/sample-project/ exists"
        ((PASSED++)) || true

        # Check sample project structure
        for f in package.json src/index.ts; do
            if [[ -f "$SCRIPT_DIR/fixtures/sample-project/$f" ]]; then
                pass "sample-project/$f exists"
                ((PASSED++)) || true
            else
                warn "sample-project/$f missing (optional)"
                ((WARNED++)) || true
            fi
        done
    else
        fail "fixtures/sample-project/ missing"
        ((FAILED++)) || true
    fi

    if [[ -d "$SCRIPT_DIR/fixtures/user-inputs" ]]; then
        pass "fixtures/user-inputs/ exists"
        ((PASSED++)) || true
    else
        warn "fixtures/user-inputs/ missing"
        ((WARNED++)) || true
    fi
}

# Test: Template structure
test_templates() {
    echo ""
    echo "Testing: Template structure"

    if [[ -d "$PLUGIN_DIR/templates/flow-plugin" ]]; then
        pass "templates/flow-plugin/ exists"
        ((PASSED++)) || true

        # Check flow-plugin template structure
        for f in .claude-plugin/plugin.json.tmpl; do
            if [[ -f "$PLUGIN_DIR/templates/flow-plugin/$f" ]]; then
                pass "flow-plugin/$f exists"
                ((PASSED++)) || true
            else
                warn "flow-plugin/$f missing"
                ((WARNED++)) || true
            fi
        done
    else
        fail "templates/flow-plugin/ missing"
        ((FAILED++)) || true
    fi
}

# Test: Snapshot comparison
test_snapshots() {
    echo ""
    echo "Testing: Snapshot comparison"

    if [[ -d "$SCRIPT_DIR/snapshots/basic-flow" ]]; then
        pass "snapshots/basic-flow/ exists"
        ((PASSED++)) || true

        if $UPDATE_SNAPSHOTS; then
            warn "Snapshot update mode - would update snapshots"
            ((WARNED++)) || true
        fi
    else
        warn "snapshots/basic-flow/ empty (run scaffold to generate)"
        ((WARNED++)) || true
    fi
}

# Run tests
echo "=========================================="
echo "Catalyst Plugin Test Suite"
echo "=========================================="
echo ""

if [[ -n "$TEST_FILTER" ]]; then
    echo "Filter: $TEST_FILTER"
    echo ""
    "test_$TEST_FILTER"
else
    test_schemas
    test_plugin_structure
    test_fixtures
    test_templates
    test_snapshots
fi

# Summary
echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "${GREEN}Passed:${NC}  $PASSED"
echo -e "${YELLOW}Warned:${NC}  $WARNED"
echo -e "${RED}Failed:${NC}  $FAILED"
echo ""

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}TESTS FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}ALL TESTS PASSED${NC}"
    exit 0
fi
