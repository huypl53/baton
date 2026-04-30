---
name: catalyst:validate
description: "Validate generated flow plugins for schema compliance, reference integrity, and determinism. Ensures all @memory/ and @agents/ paths resolve, all required files exist, and output matches snapshots."
argument-hint: "[--schema|--refs|--snapshot|--strict] [plugin-path]"
metadata:
  author: vtit
  version: "1.0.0"
---

# Validate - Plugin Validation & Determinism Checks

Ensures generated flow plugins are valid and deterministic.

## Usage

```bash
/catalyst:validate                    # Full validation of current plugin
/catalyst:validate --schema           # Schema validation only
/catalyst:validate --refs             # Reference validation only
/catalyst:validate --snapshot         # Compare against golden files
/catalyst:validate --strict           # Fail on any warning
/catalyst:validate path/to/plugin     # Validate specific plugin
```

## Validation Checks

| Check | What It Does | Severity |
|-------|--------------|----------|
| Schema | Validate plugin.json, SKILL.md, command frontmatter | FAIL |
| Structure | Verify memory/workflows/{name}/ exists for each workflow | FAIL |
| References | All @memory/ paths in workflows resolve to files | FAIL |
| Subagents | All delegated agents in workflows exist in agents/ | WARN |
| Syntax | All .md files parse, frontmatter is valid YAML | FAIL |
| Completeness | Required files exist (INDEX.md, conventions.md) | FAIL |
| Snapshot | Compare output against snapshots/ for regression | WARN |

## Process

1. **Detect plugin path** - Use argument or find nearest flow plugin
2. **Run checks** - Execute selected or all validation checks
3. **Report results** - PASS/WARN/FAIL per check with details
4. **Return status** - Exit 0 if PASS, exit 1 if any FAIL

## Check Details

### Schema Validation

Validates JSON/YAML against schemas in `schemas/`:

#### Plugin JSON Validation (CRITICAL)

**Check for forbidden fields that cause Claude Code install failure:**

```bash
# Check for forbidden fields
FORBIDDEN='skills|agents|workflows|commands|hooks|stack|memory|generated'
if grep -E "\"($FORBIDDEN)\":" .claude-plugin/plugin.json; then
  echo "FAIL: plugin.json contains forbidden fields"
  exit 1
fi

# Check author is object, not string
if jq -e '.author | type == "string"' .claude-plugin/plugin.json >/dev/null 2>&1; then
  echo "FAIL: author must be object {\"name\": \"...\"}, not string"
  exit 1
fi

# Validate required fields exist
jq -e '.name and .description and .version' .claude-plugin/plugin.json
```

**Valid plugin.json example:**
```json
{
  "name": "my-flow",
  "description": "My workflow plugin",
  "version": "1.0.0",
  "author": {"name": "catalyst"}
}
```

#### Other Schema Validations

```bash
# SKILL.md frontmatter
yq '.frontmatter' skills/*/SKILL.md | validate-against skill-frontmatter.schema.json

# Command frontmatter
yq '.frontmatter' commands/*.md | validate-against workflow-command.schema.json
```

### Structure Validation

Verifies directory structure:

```
memory/
├── INDEX.md          ✓ required
├── gotchas.md        ✓ required
├── conventions.md    ✓ required
├── workflows/        ✓ required dir
│   └── {workflow}/   ✓ must exist for each command
│       ├── insights.md
│       ├── gotchas.md
│       └── test-flows.md
└── decisions/        ✓ required dir
```

### Reference Validation

Extracts and validates all references:

```markdown
# In commands/auth-flow.md:
Read @memory/INDEX.md           → check: memory/INDEX.md exists
Read @memory/workflows/auth/    → check: memory/workflows/auth/ exists
Delegate @agents/tester         → check: agents/tester.md exists
```

### Snapshot Validation

Compares current output against golden files:

```bash
diff -r plugins/{project}-flow/ tests/snapshots/{project}-flow/
# Any diff = determinism regression = WARN (or FAIL with --strict)
```

## Output Format

```
✓ Schema validation: PASS (5/5 files)
✓ Structure validation: PASS
✓ Reference validation: PASS (12 refs resolved)
⚠ Subagent validation: WARN (reviewer.md referenced but optional)
✓ Syntax validation: PASS
✓ Completeness validation: PASS
✓ Snapshot validation: PASS (no drift)

Overall: PASS (1 warning)
```

## Implementation

```bash
#!/bin/bash
# Validation logic

PLUGIN_PATH="${1:-.}"
STRICT="${STRICT:-false}"
CHECKS="${CHECKS:-all}"

validate_schema() {
    local file="$1"
    local schema="$2"
    
    if command -v ajv &>/dev/null; then
        ajv validate -s "$schema" -d "$file" 2>&1
    elif command -v jq &>/dev/null; then
        # Basic JSON syntax check
        jq '.' "$file" >/dev/null 2>&1
    fi
}

validate_structure() {
    local plugin="$1"
    local errors=0
    
    # Required files
    for f in INDEX.md gotchas.md conventions.md; do
        [[ -f "$plugin/memory/$f" ]] || { echo "Missing: memory/$f"; ((errors++)); }
    done
    
    # Required dirs
    for d in workflows decisions; do
        [[ -d "$plugin/memory/$d" ]] || { echo "Missing: memory/$d/"; ((errors++)); }
    done
    
    # Workflow structure
    for cmd in "$plugin"/commands/*-flow.md; do
        [[ -f "$cmd" ]] || continue
        name=$(basename "$cmd" -flow.md)
        [[ -d "$plugin/memory/workflows/$name" ]] || {
            echo "Missing: memory/workflows/$name/ for $cmd"
            ((errors++))
        }
    done
    
    return $errors
}

validate_refs() {
    local plugin="$1"
    local errors=0
    
    # Extract @memory/ and @agents/ references
    grep -rh '@memory/\|@agents/' "$plugin/commands/" 2>/dev/null | while read -r ref; do
        path=$(echo "$ref" | grep -oP '@(memory|agents)/[^\s]+')
        resolved="${path#@}"
        [[ -e "$plugin/$resolved" ]] || {
            echo "Broken ref: $path"
            ((errors++))
        }
    done
    
    return $errors
}

# Main
echo "Validating: $PLUGIN_PATH"
echo ""

# Run checks based on flags
case "$CHECKS" in
    schema) validate_schema "$PLUGIN_PATH" ;;
    refs) validate_refs "$PLUGIN_PATH" ;;
    structure) validate_structure "$PLUGIN_PATH" ;;
    *) 
        validate_schema "$PLUGIN_PATH"
        validate_structure "$PLUGIN_PATH"
        validate_refs "$PLUGIN_PATH"
        ;;
esac
```

## Integration

**scaffold** and **workflow** skills MUST run validate before completing:

```markdown
# In scaffold/SKILL.md:
7. **Run validate** - `/catalyst:validate --strict`
8. If FAIL → abort, show errors
9. If PASS → continue to marketplace registration
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks PASS (warnings allowed unless --strict) |
| 1 | Any check FAIL |
| 2 | Invalid arguments or plugin not found |
