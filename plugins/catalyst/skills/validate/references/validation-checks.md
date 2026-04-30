# Validation Checks Reference

Detailed documentation of all validation checks.

## Schema Validation

### plugin.json

```json
{
  "name": "^[a-z][a-z0-9-]*$",
  "description": "string, 10-200 chars",
  "version": "^[0-9]+\\.[0-9]+\\.[0-9]+$"
}
```

### SKILL.md frontmatter

```yaml
name: required, lowercase with hyphens
description: required, 10-500 chars
argument-hint: optional, max 100 chars
metadata:
  author: optional string
  version: optional semver
```

### Command frontmatter

```yaml
description: required, 10-200 chars
```

### Subagent frontmatter

```yaml
name: required, lowercase with hyphens
description: required, 10-200 chars
tools: optional array of strings
```

## Structure Validation

### Required Files

| File | Required | Purpose |
|------|----------|---------|
| `.claude-plugin/plugin.json` | Yes | Plugin manifest |
| `CLAUDE.md` | Yes | Project contract |
| `skills/ship/SKILL.md` | Yes | Main orchestrator |
| `memory/INDEX.md` | Yes | Knowledge index |
| `memory/conventions.md` | Yes | Coding patterns |
| `memory/gotchas.md` | Yes | Known traps |

### Required Directories

| Directory | Required | Purpose |
|-----------|----------|---------|
| `memory/workflows/` | Yes | Per-workflow memory |
| `memory/decisions/` | Yes | Decision records |
| `agents/` | No | Subagent definitions |
| `commands/` | No | Workflow commands |
| `hooks/` | No | Hook configurations |

### Per-Workflow Structure

For each `commands/{name}-flow.md`:

| Required | Path |
|----------|------|
| Yes | `memory/workflows/{name}/` |
| Yes | `memory/workflows/{name}/insights.md` |
| Yes | `memory/workflows/{name}/gotchas.md` |
| Yes | `memory/workflows/{name}/test-flows.md` |
| Yes | `memory/decisions/{name}/` |

## Reference Validation

### @memory/ References

Extract from command files:
```
@memory/INDEX.md
@memory/conventions.md
@memory/workflows/{name}/insights.md
@memory/workflows/{name}/gotchas.md
@memory/workflows/{name}/test-flows.md
```

Each must resolve to existing file.

### @agents/ References

Extract from command files:
```
@agents/tester
@agents/migrator
@agents/e2e-runner
@agents/reviewer
```

Each must resolve to `agents/{name}.md`.

## Syntax Validation

### Markdown Files

- File exists and is not empty
- Valid UTF-8 encoding
- If has `---` at line 1, valid YAML frontmatter

### JSON Files

- Valid JSON syntax
- No trailing commas
- All keys quoted

## Completeness Validation

### Minimum Content

| File | Minimum |
|------|---------|
| `INDEX.md` | Has structure section |
| `conventions.md` | Has naming section |
| `{workflow}/insights.md` | Has template structure |

## Snapshot Validation

### Comparison

```bash
diff -r plugins/{project}-flow/ tests/snapshots/{project}-flow/
```

### Ignored

- Timestamps in comments
- Empty decision directories
- .DS_Store, .git

### Acceptable Drift

- Additional memory content (insights added)
- Additional decision records
- Modified conventions (user customization)

### Unacceptable Drift

- Missing required files
- Changed plugin.json name
- Broken references
