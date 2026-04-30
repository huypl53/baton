---
name: catalyst:scaffold
description: "Generate a customized {project}-flow plugin from templates based on scout analysis. Creates CLAUDE.md, memory system, workflow commands, and subagents tailored to the project."
argument-hint: "[--dry-run] [--fixture name]"
metadata:
  author: vtit
  version: "1.0.0"
---

# Scaffold - Flow Plugin Generator

Generates `{project}-flow` plugin from templates based on scout analysis.

## Usage

```bash
/catalyst:scaffold              # Interactive scaffold
/catalyst:scaffold --dry-run    # Preview without writing
/catalyst:scaffold --fixture x  # Use test fixture (for testing)
```

## Prerequisites

Run `/catalyst:scout` first to generate analysis report.

## Process

### 1. Load Analysis

```bash
# Read analysis from scout
cat plans/catalyst-analysis.md
```

If no analysis found, prompt to run scout first.

### 2. Interactive Confirmation

**Stack confirmation:**
```
Detected stack:
  Language: TypeScript
  Framework: Next.js
  Test Runner: Vitest

Confirm? [Y/n]
```

**Workflow selection:**
```
Recommended workflows:
  [x] crud - CRUD operations
  [x] auth - Authentication flow
  [ ] payment - Payment processing
  [ ] api - API development

Select workflows (space to toggle, enter to confirm):
```

**Coding style:**
```
Detected conventions:
  Naming: camelCase
  Indent: 2 spaces
  Quotes: single

Confirm? [Y/n]
```

### 2b. Propose Short Skill Prefix

**Generate short prefix from project name:**

| Project Name | Proposed Prefix | Logic |
|--------------|-----------------|-------|
| `online-tutor` | `ot` | First letter of each word |
| `my-app` | `ma` | First letter of each word |
| `ecommerce` | `ec` | First 2 chars |
| `api-gateway-service` | `ags` | First letter of each word |

**Interactive prompt (MUST ask user to confirm):**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Skill Prefix Selection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plugin: online-tutor-flow
Suggested prefix: ot

With this prefix, your skills will be:
  /ot:ship
  /ot:crud
  /ot:auth

Options:
  [1] Accept "ot"
  [2] Enter custom prefix
  [3] Use full name (online-tutor-flow:*)

Your choice [1]: _
```

**If user chooses [2]:**
```
Enter custom prefix (2-4 lowercase chars): _
```

**Validation rules:**
- 2-4 lowercase characters only
- Must not conflict with existing prefixes (ck, catalyst, daily, nextjs, etc.)
- If conflict detected, prompt again with warning

**Store in plugin.json:**
```json
{
  "name": "online-tutor-flow",
  "skillPrefix": "ot",
  ...
}
```

**Use prefix in skill names:**
```yaml
# skills/ship/SKILL.md
---
name: ot:ship  # NOT online-tutor-flow:ship
---
```

### 3. Generate Plugin Structure

Creates both project marketplace and plugin:

```
{project-root}/
├── .claude-plugin/
│   └── marketplace.json          ← PROJECT MARKETPLACE (enables /plugin install)
│
└── plugins/{project}-flow/
    ├── .claude-plugin/plugin.json    ← from plugin.json.tmpl
    ├── CLAUDE.md                     ← from CLAUDE.md.tmpl
    ├── skills/
    │   └── ship/SKILL.md             ← from ship.SKILL.md.tmpl
    ├── commands/
    │   └── {workflow}-flow.md        ← from workflows/{type}-flow.md.tmpl
    ├── agents/
    │   └── {agent}.md                ← from subagents/{agent}.md.tmpl
    ├── memory/
    │   ├── INDEX.md                  ← from memory/INDEX.md.tmpl
    │   ├── gotchas.md                ← from memory/gotchas.md.tmpl
    │   ├── conventions.md            ← generated from analysis
    │   ├── workflows/
    │   │   └── {workflow}/
    │   │       ├── insights.md
    │   │       ├── gotchas.md
    │   │       └── test-flows.md
    │   └── decisions/
    │       └── {workflow}/
    └── hooks/
        └── settings-hooks.json       ← from hooks/settings-hooks.json.tmpl
```

### 4. Template Variables

| Variable | Source |
|----------|--------|
| `{{project}}` | Analysis or user input |
| `{{language}}` | Detected stack |
| `{{framework}}` | Detected framework |
| `{{test_runner}}` | Detected test runner |
| `{{workflows}}` | Selected workflows |
| `{{date}}` | Current date |

### 4b. Plugin JSON Format (CRITICAL)

**MUST use EXACTLY this format for `.claude-plugin/plugin.json`:**

```json
{
  "name": "{{project}}-flow",
  "description": "{{project}} workflow plugin",
  "version": "1.0.0",
  "author": {
    "name": "catalyst"
  }
}
```

**ALLOWED FIELDS ONLY:**
- `name` (string, required)
- `description` (string, required)  
- `version` (string, required)
- `author` (object with `name`, optional `email`/`url`)
- `repository`, `homepage`, `license`, `keywords` (optional)

**FORBIDDEN FIELDS (will cause install failure):**
| Field | Why Forbidden |
|-------|---------------|
| `skills` | Auto-discovered from skills/ directory |
| `agents` | Auto-discovered from agents/ directory |
| `workflows` | Not part of Claude Code schema |
| `commands` | Auto-discovered |
| `hooks` | Auto-discovered |
| `stack` | Not part of schema |
| `memory` | Not part of schema |
| `generated` | Not part of schema |

**COMMON MISTAKE:** `"author": "string"` — WRONG. Must be `"author": {"name": "string"}`.

### 5. Run Validation

**MANDATORY** - abort if validation fails:

```bash
# Run the validation script (programmatic check)
bash scripts/validate-plugin-json.sh plugins/{{project}}-flow/.claude-plugin/plugin.json

# Also run skill-based validation
/catalyst:validate plugins/{{project}}-flow --strict
```

**Validation script checks:**
- No forbidden fields (skills, agents, workflows, etc.)
- Author is object, not string
- Required fields present (name, description, version)
- Name format correct (lowercase, alphanumeric, hyphens)
- Version is semver format

If FAIL:
- Show errors
- Abort scaffold
- Do not create marketplace

If PASS:
- Continue to marketplace registration

### 6. Create Project Marketplace

**CRITICAL:** Create `.claude-plugin/marketplace.json` at **PROJECT ROOT** (not inside the plugin).

This makes the project itself a marketplace so the plugin can be installed via Claude Code's plugin system.

```bash
mkdir -p .claude-plugin
```

Create `.claude-plugin/marketplace.json`:

```json
{
  "name": "{{project}}-marketplace",
  "description": "Local marketplace for {{project}} workflows",
  "owner": {
    "name": "{{project}}"
  },
  "plugins": [
    {
      "name": "{{project}}-flow",
      "source": "./plugins/{{project}}-flow",
      "description": "{{project}} workflow plugin",
      "version": "1.0.0"
    }
  ]
}
```

### 7. Installation Instructions

After scaffold completes, output these commands for the user:

```
✓ Scaffold complete: {{project}}-flow
  Skill prefix: {{prefix}}

To install the plugin:

  1. Add the project as a marketplace:
     /plugin marketplace add ./

  2. Install the plugin:
     /plugin install {{project}}-flow@{{project}}-marketplace

  3. Reload plugins:
     /reload-plugins

Your new skills (using short prefix "{{prefix}}"):
  /{{prefix}}:ship
  /{{prefix}}:crud
  /{{prefix}}:auth
  /{{prefix}}:api
```

### 8. Symlink CLAUDE.md (Optional)

```bash
# Link CLAUDE.md to target project root for global context
ln -sf "$(pwd)/plugins/{{project}}-flow/CLAUDE.md" "./CLAUDE.md"
```

### 9. Setup Validation Hooks (Optional but Recommended)

Add hooks to `.claude/settings.json` for ongoing validation:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {
          "tool": "Write",
          "filePath": "**/.claude-plugin/plugin.json"
        },
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'jq -e \".author | type != \\\"string\\\"\" \"$CLAUDE_FILE_PATH\" >/dev/null || { echo \"ERROR: author must be object\"; exit 1; }'"
          }
        ]
      }
    ]
  }
}
```

This hook will **block invalid plugin.json writes** at save time, preventing install failures.

## Dry-Run Mode

With `--dry-run`:

```
Would create:

  .claude-plugin/marketplace.json          ← PROJECT MARKETPLACE (new)

  plugins/sample-flow/
    .claude-plugin/plugin.json
    CLAUDE.md
    skills/ship/SKILL.md
    commands/crud-flow.md
    commands/auth-flow.md
    agents/tester.md
    agents/migrator.md
    agents/e2e-runner.md
    agents/reviewer.md
    memory/INDEX.md
    memory/gotchas.md
    memory/conventions.md
    memory/workflows/crud/insights.md
    memory/workflows/auth/insights.md
    ...

Total: 16 files (1 marketplace + 15 plugin files)

No files written.
```

## Output

```
✓ Scaffold: sample-flow
  Skill prefix: sf

Created:
  - .claude-plugin/marketplace.json (project marketplace)
  - plugins/sample-flow/ (plugin directory)
    - 4 skills
    - 2 workflow commands
    - 4 subagents
    - 8 memory files
    - 1 hook config

Validation: PASS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

To install the plugin, run these commands:

  /plugin marketplace add ./
  /plugin install sample-flow@sample-marketplace
  /reload-plugins

Your new skills (short prefix "sf"):
  /sf:ship
  /sf:crud
  /sf:auth

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next:
  /catalyst:workflow add payment
```

## Template Processing

Templates use simple `{{variable}}` substitution:

```markdown
# {{project}}-flow CLAUDE.md

Project: {{project}}
Framework: {{framework}}
Generated: {{date}}

## Conventions

{{conventions}}
```

For conditional sections, use markers:

```markdown
{{#if auth_workflow}}
## Auth Flow

Read @memory/workflows/auth/insights.md before implementing auth.
{{/if}}
```

## Error Handling

| Error | Action |
|-------|--------|
| No analysis | Prompt to run scout |
| Template missing | Abort with error |
| Validation FAIL | Abort, show errors |
| Directory exists | Ask to overwrite |

## Testing

Use fixtures for deterministic testing:

```bash
/catalyst:scaffold --fixture sample-project
# Uses tests/fixtures/sample-project/ as input
# Uses tests/fixtures/user-inputs/basic.json for responses
# Compares output to tests/snapshots/basic-flow/
```
