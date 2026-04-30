---
name: ship
description: "Main pipeline orchestrator for sample. Coordinates code → test → fix → verify loop with memory-aware context."
argument-hint: "<feature-description>"
metadata:
  author: catalyst
  version: "1.0.0"
---

# Ship - sample Pipeline Orchestrator

Main entry point for implementing features in sample.

## Usage

```bash
/sample-flow:ship "Add user profile page"
```

## Process

### 1. Context Loading

Read accumulated knowledge:
```
@memory/INDEX.md
@memory/conventions.md
@memory/gotchas.md
```

### 2. Workflow Detection

Based on feature description, select appropriate workflow:
- CRUD operation → `/sample-flow:crud-flow`

### 3. Execute Workflow

Delegate to selected workflow command.

### 4. Post-Ship

Update memory:
1. Capture insights in relevant workflow memory
2. Add gotchas discovered
3. Create decision record if significant

## Subagents

| Agent | When |
|-------|------|
| `@agents/tester` | Unit/integration tests |
| `@agents/reviewer` | Code review |

## Fix Loop

Max 3 attempts per test type:
1. Run test
2. If fail → analyze, fix
3. Re-run test
4. If still fail after 3 → escalate to user
