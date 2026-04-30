# Catalyst Plugin

Meta-plugin that generates project-specific workflow plugins for Claude Code.

## Overview

Catalyst solves the problem of repetitive setup for deterministic coding workflows. Instead of manually creating CLAUDE.md files, memory systems, and workflow commands for each project, Catalyst analyzes your project and generates a customized `{project}-flow` plugin.

## Skills

| Skill | Purpose | Command |
|-------|---------|---------|
| scout | Analyze project structure, stack, patterns | `/catalyst:scout` |
| scaffold | Generate flow plugin from templates | `/catalyst:scaffold` |
| workflow | CRUD operations for feature workflows | `/catalyst:workflow add auth` |
| review | Check coherence, suggest improvements | `/catalyst:review` |
| validate | Schema, reference, determinism validation | `/catalyst:validate` |

## Quick Start

```bash
# 1. Install catalyst
/plugin install catalyst@huypl53

# 2. In your project directory, analyze it
/catalyst:scout

# 3. Generate the flow plugin
/catalyst:scaffold

# 4. Add feature workflows
/catalyst:workflow add auth
/catalyst:workflow add payment

# 5. Validate the plugin
/catalyst:validate
```

## Generated Plugin Structure

```
plugins/{project}-flow/
├── .claude-plugin/plugin.json
├── CLAUDE.md                 # Project contract
├── skills/ship/SKILL.md      # Main orchestrator
├── commands/
│   ├── auth-flow.md
│   └── crud-flow.md
├── agents/
│   ├── tester.md
│   ├── migrator.md
│   └── reviewer.md
├── memory/
│   ├── INDEX.md              # Knowledge index
│   ├── conventions.md        # Coding patterns
│   ├── gotchas.md            # Known traps
│   ├── workflows/{name}/     # Per-workflow memory
│   │   ├── insights.md
│   │   ├── gotchas.md
│   │   └── test-flows.md
│   └── decisions/{name}/     # ADRs
└── hooks/
    └── settings-hooks.json
```

## Memory System

Each workflow maintains isolated memory:
- **insights.md** - Accumulated learnings
- **gotchas.md** - Known traps and pitfalls
- **test-flows.md** - Test commands

Global memory:
- **INDEX.md** - Cross-cutting knowledge
- **conventions.md** - Project coding patterns

## Workflow Format

Every generated workflow follows this structure:

```markdown
---
description: Feature implementation pipeline
---

## Before You Code (MANDATORY)
1. Read @memory/INDEX.md
2. Read @memory/workflows/{name}/insights.md
3. Read @memory/workflows/{name}/gotchas.md

## Loop
1. Plan → 2. Code → 3. Test → 4. Fix → 5. Review

## After Shipping (MANDATORY)
1. Update insights
2. Capture gotchas
3. Create decision record
```

## Validation

All operations run validation before completing:
- **Schema** - plugin.json, SKILL.md, commands match schemas
- **Structure** - Required files and directories exist
- **References** - All @memory/ and @agents/ paths resolve
- **Snapshot** - Output matches golden files (determinism)

## Testing

```bash
# Unit tests
cd plugins/catalyst/tests
./run-tests.sh

# UAT
cd plugins/catalyst/tests/uat
./run-uat.sh
```

## Related

- Plugin location: `plugins/catalyst/`
- Design doc: `plans/reports/260429-1811-catalyst-plugin-design.md`
- UAT plan: `plans/reports/260429-1825-catalyst-uat-test-plan.md`
