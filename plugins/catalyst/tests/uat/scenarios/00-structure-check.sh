#!/bin/bash
# Structural test: Verify catalyst plugin structure
# No Claude required - pure file system checks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

# Helpers
assert_file() {
    local file="$1"
    local msg="${2:-$file}"
    [[ -f "$file" ]] && echo "  ✓ $msg" || { echo "  ✗ Missing: $msg"; exit 1; }
}

assert_dir() {
    local dir="$1"
    local msg="${2:-$dir}"
    [[ -d "$dir" ]] && echo "  ✓ $msg" || { echo "  ✗ Missing: $msg"; exit 1; }
}

assert_valid_json() {
    local file="$1"
    jq empty "$file" 2>/dev/null && echo "  ✓ Valid JSON: $(basename "$file")" || { echo "  ✗ Invalid JSON: $file"; exit 1; }
}

echo "Scenario: Structure Check"
echo "========================="
echo "Plugin: $PLUGIN_DIR"
echo ""

# Verify plugin structure
echo "Checking plugin structure..."
assert_file "$PLUGIN_DIR/.claude-plugin/plugin.json" "Plugin manifest"
assert_valid_json "$PLUGIN_DIR/.claude-plugin/plugin.json"
assert_file "$PLUGIN_DIR/README.md" "Plugin README"

# Verify all skills exist
echo "Checking skills..."
for skill in scout scaffold workflow review validate; do
    assert_file "$PLUGIN_DIR/skills/$skill/SKILL.md" "Skill: $skill"
done

# Verify schemas
echo "Checking schemas..."
for schema in plugin-json skill-frontmatter workflow-command subagent memory-structure; do
    assert_file "$PLUGIN_DIR/schemas/$schema.schema.json" "Schema: $schema"
    assert_valid_json "$PLUGIN_DIR/schemas/$schema.schema.json"
done

# Verify templates
echo "Checking templates..."
assert_dir "$PLUGIN_DIR/templates/flow-plugin" "Flow plugin template"
assert_file "$PLUGIN_DIR/templates/flow-plugin/.claude-plugin/plugin.json.tmpl"
assert_file "$PLUGIN_DIR/templates/flow-plugin/CLAUDE.md.tmpl"

# Verify workflows templates
for wf in crud auth api; do
    assert_file "$PLUGIN_DIR/templates/workflows/$wf-flow.md.tmpl" "Workflow template: $wf"
done

# Verify subagent templates
for agent in tester migrator e2e-runner reviewer; do
    assert_file "$PLUGIN_DIR/templates/subagents/$agent.md.tmpl" "Subagent template: $agent"
done

# Verify test fixtures
echo "Checking test fixtures..."
assert_dir "$PLUGIN_DIR/tests/fixtures/sample-project" "Sample project fixture"
assert_file "$PLUGIN_DIR/tests/fixtures/sample-project/package.json"

# Verify snapshots
echo "Checking snapshots..."
assert_dir "$PLUGIN_DIR/tests/snapshots/basic-flow" "Basic flow snapshot"
assert_file "$PLUGIN_DIR/tests/snapshots/basic-flow/.claude-plugin/plugin.json"
assert_dir "$PLUGIN_DIR/tests/snapshots/auth-workflow" "Auth workflow snapshot"

echo ""
echo "Structure check PASSED"
