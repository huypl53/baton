---
name: catalyst:workflow
description: "CRUD operations for feature workflows. Add, edit, remove, or list workflows in a flow plugin. Creates workflow commands, memory directories, and registers in plugin manifest."
argument-hint: "<add|edit|remove|list> [name] [--dry-run]"
metadata:
  author: vtit
  version: "1.0.0"
---

# Workflow - Feature Workflow CRUD

Manage feature workflows in a flow plugin.

## Usage

```bash
/catalyst:workflow add auth          # Create new workflow
/catalyst:workflow edit auth         # Modify existing workflow
/catalyst:workflow remove payment    # Delete workflow
/catalyst:workflow list              # Show all workflows
/catalyst:workflow add auth --dry-run # Preview changes
```

## Subcommands

### add

Create a new feature workflow.

**Process:**

1. **Interactive: Name and description**
   ```
   Workflow name: auth
   Description: Authentication implementation pipeline
   ```

2. **Interactive: Define steps**
   ```
   Steps (in order):
   1. plan - Outline scope
   2. code - Implement
   3. migrate - Database changes [delegate: migrator]
   4. unit-test - Test functions [delegate: tester]
   5. integration - Test flow [delegate: tester]
   6. e2e - End-to-end test [delegate: e2e-runner]
   7. review - Code review [delegate: reviewer]
   ```

3. **Interactive: Subagents**
   ```
   Subagents needed:
   [x] tester
   [x] migrator
   [x] e2e-runner
   [x] reviewer
   ```

4. **Interactive: Success criteria**
   ```
   Success criteria: All tests pass, review approved
   ```

5. **Interactive: Fix limits**
   ```
   Max retry per test type: 3
   ```

6. **Create files:**
   - `commands/{name}-flow.md`
   - `memory/workflows/{name}/insights.md`
   - `memory/workflows/{name}/gotchas.md`
   - `memory/workflows/{name}/test-flows.md`
   - `memory/decisions/{name}/` (directory)

7. **Run validate** - abort if FAIL

8. **Update INDEX.md** - add workflow entry

**Output:**
```
✓ Workflow added: auth

Created:
  commands/auth-flow.md
  memory/workflows/auth/insights.md
  memory/workflows/auth/gotchas.md
  memory/workflows/auth/test-flows.md
  memory/decisions/auth/

Validation: PASS

Use: /your-project-flow:auth-flow "implement login"
```

### edit

Modify an existing workflow.

**Process:**

1. Load existing workflow from `commands/{name}-flow.md`
2. Interactive: show current config, ask what to change
3. Update command file
4. Run validate
5. Report changes

### remove

Delete a workflow.

**Process:**

1. Confirm deletion
2. Remove files:
   - `commands/{name}-flow.md`
   - `memory/workflows/{name}/` (directory)
   - `memory/decisions/{name}/` (directory)
3. Update INDEX.md
4. Report

**Safety:** Asks for confirmation. Use `--force` to skip.

### list

Show all workflows in the plugin.

**Output:**
```
Workflows in sample-flow:

  crud     CRUD operations pipeline
  auth     Authentication implementation pipeline
  api      API endpoint development pipeline

Total: 3 workflows
```

## File Generation

### Command File Template

```markdown
---
description: {{description}}
---

Implement: $ARGUMENTS

## Before You Code (MANDATORY)

1. Read @memory/INDEX.md (global overview)
2. Read @memory/conventions.md (project patterns)
3. Read @memory/workflows/{{name}}/insights.md ({{name}} learnings)
4. Read @memory/workflows/{{name}}/gotchas.md ({{name}} traps)
5. Read @memory/workflows/{{name}}/test-flows.md (existing test commands)

## Loop (strict order, no skipping)

{{#each steps}}
{{index}}. **{{name}}**: {{description}}{{#if delegate}} → delegate `@agents/{{delegate}}`{{/if}}
{{/each}}

## After Shipping (MANDATORY)

1. Update @memory/workflows/{{name}}/insights.md
2. Update @memory/workflows/{{name}}/gotchas.md
3. Update @memory/workflows/{{name}}/test-flows.md
4. Create @memory/decisions/{{name}}/{{date}}-slug.md (ADR)
5. If global insight → append to @memory/INDEX.md
6. **Report**: Summarize shipped, decisions, insights captured.
```

### Memory Files

**insights.md:**
```markdown
# {{name}} Insights

Accumulated learnings for {{name}} workflow.

## Key Patterns

<!-- Add patterns discovered -->
```

**gotchas.md:**
```markdown
# {{name}} Gotchas

Traps specific to {{name}} workflow.

<!-- Add gotchas as discovered -->
```

**test-flows.md:**
```markdown
# {{name}} Test Flows

Test commands for {{name}} workflow.

## Unit Tests

\`\`\`bash
{{test_runner}} run {{name}}
\`\`\`
```

## Validation

After add/edit, runs `/catalyst:validate` with checks:
- Command file has valid frontmatter
- Memory directory exists with required files
- All @memory/ references resolve
- All @agents/ references exist

## Dry-Run Mode

```
Would create 4 files, modify 1 file:

  + commands/payment-flow.md
  + memory/workflows/payment/insights.md
  + memory/workflows/payment/gotchas.md
  + memory/workflows/payment/test-flows.md
  ~ memory/INDEX.md (add workflow entry)

No files written.
```

## Error Handling

| Error | Action |
|-------|--------|
| Workflow exists (add) | Ask to edit instead |
| Workflow not found (edit/remove) | Show available workflows |
| Validation FAIL | Abort, show errors |
| Missing plugin | Prompt to run scaffold first |
