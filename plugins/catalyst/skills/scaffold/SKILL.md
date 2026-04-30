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

### 3. Generate Plugin Structure

From `templates/flow-plugin/`:

```
plugins/{project}-flow/
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

### 5. Run Validation

**MANDATORY** - abort if validation fails:

```bash
/catalyst:validate plugins/{{project}}-flow --strict
```

If FAIL:
- Show errors
- Abort scaffold
- Do not register in marketplace

If PASS:
- Continue to marketplace registration

### 6. Register in Marketplace

Add to `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "{{project}}-flow",
      "source": "./plugins/{{project}}-flow",
      "description": "{{project}} workflow plugin"
    }
  ]
}
```

### 7. Symlink to Target (Optional)

```bash
# Link CLAUDE.md to target project
ln -sf "$(pwd)/plugins/{{project}}-flow/CLAUDE.md" "{{target}}/.claude/CLAUDE.md"
```

## Dry-Run Mode

With `--dry-run`:

```
Would create 15 files in plugins/sample-flow/:

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

No files written.
```

## Output

```
✓ Scaffold: sample-flow

Created:
  - 4 skills
  - 2 workflow commands
  - 4 subagents
  - 8 memory files
  - 1 hook config

Validation: PASS
Marketplace: registered

Next steps:
  /plugin install sample-flow@huypl53
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
