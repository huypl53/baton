---
description: CRUD operations pipeline for sample
---

Implement: $ARGUMENTS

## Before You Code (MANDATORY)

1. Read @memory/INDEX.md (global overview)
2. Read @memory/conventions.md (project patterns)
3. Read @memory/workflows/crud/insights.md (CRUD learnings)
4. Read @memory/workflows/crud/gotchas.md (CRUD traps)
5. Read @memory/workflows/crud/test-flows.md (existing test commands)

## Loop (strict order, no skipping)

1. **Plan**: Outline CRUD operations needed.
2. **Code**: Implement following conventions.md.
3. **Migrate**: If DB changes → delegate `@agents/migrator`.
4. **Unit Test**: Delegate `@agents/tester`. FAIL → fix, re-run. Max 3 attempts.
5. **Integration**: Run integration tests. Same fix loop.
6. **Review**: Delegate `@agents/reviewer`. Address findings.

## After Shipping (MANDATORY)

1. Update @memory/workflows/crud/insights.md (what learned)
2. Update @memory/workflows/crud/gotchas.md (new traps found)
3. Update @memory/workflows/crud/test-flows.md (new test commands)
4. Create @memory/decisions/crud/YYYY-MM-DD-slug.md (ADR if significant)
5. If global insight → append to @memory/INDEX.md
6. **Report**: Summarize shipped, decisions, insights captured.
