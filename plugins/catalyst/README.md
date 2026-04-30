# Catalyst

Meta-plugin that generates project-specific workflow plugins for Claude Code.

## Skills

| Skill | Description |
|-------|-------------|
| `scout` | Analyze target project structure, stack, patterns |
| `scaffold` | Generate `{project}-flow` plugin from templates |
| `workflow` | CRUD operations on feature workflows |
| `review` | Review generated plugin, suggest improvements |
| `validate` | Ensure outputs are valid and deterministic |

## Quick Start

```bash
# 1. Install catalyst
/plugin install catalyst@huypl53

# 2. Analyze your project
/catalyst:scout

# 3. Generate flow plugin
/catalyst:scaffold

# 4. Add feature workflows
/catalyst:workflow add auth
/catalyst:workflow add payment

# 5. Validate
/catalyst:validate
```

## Generated Plugin Structure

```
plugins/{project}-flow/
├── .claude-plugin/plugin.json
├── CLAUDE.md
├── skills/ship/SKILL.md
├── commands/{feature}-flow.md
├── agents/*.md
├── memory/
│   ├── INDEX.md
│   ├── gotchas.md
│   ├── conventions.md
│   ├── workflows/{feature}/
│   └── decisions/{feature}/
└── hooks/settings-hooks.json
```

## Memory System

Each workflow maintains isolated memory:
- `memory/workflows/{name}/insights.md` - Feature-specific learnings
- `memory/workflows/{name}/gotchas.md` - Feature-specific traps
- `memory/workflows/{name}/test-flows.md` - Test commands

Global knowledge:
- `memory/INDEX.md` - Overview and pointers
- `memory/conventions.md` - Project patterns
- `memory/gotchas.md` - Global gotchas

## Validation

All scaffold/workflow operations run validation before completing:
- Schema validation (plugin.json, SKILL.md, commands)
- Structure validation (required directories/files)
- Reference validation (@memory/, @agents/ paths resolve)
- Snapshot testing (determinism regression)
