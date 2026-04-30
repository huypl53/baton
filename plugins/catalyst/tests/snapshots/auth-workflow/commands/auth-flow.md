---
description: Authentication implementation pipeline
---

Implement: $ARGUMENTS

## Before You Code (MANDATORY)

1. Read @memory/INDEX.md (global overview)
2. Read @memory/conventions.md (project patterns)
3. Read @memory/workflows/auth/insights.md (auth learnings)
4. Read @memory/workflows/auth/gotchas.md (auth traps)
5. Read @memory/workflows/auth/test-flows.md (existing test commands)

## Loop (strict order, no skipping)

1. **plan**: Outline auth scope
2. **code**: Implement auth logic
3. **migrate**: Create user tables → delegate `@agents/migrator`
4. **unit-test**: Test auth functions → delegate `@agents/tester`. FAIL → fix, re-run. Max 3 attempts.
5. **integration**: Test auth flow → delegate `@agents/tester`. Same fix loop.
6. **e2e**: End-to-end auth test → delegate `@agents/e2e-runner`. Same fix loop.
7. **review**: Code review → delegate `@agents/reviewer`. Address findings.

## After Shipping (MANDATORY)

1. Update @memory/workflows/auth/insights.md
2. Update @memory/workflows/auth/gotchas.md
3. Update @memory/workflows/auth/test-flows.md
4. Create @memory/decisions/auth/YYYY-MM-DD-slug.md (ADR)
5. If global insight → append to @memory/INDEX.md
6. **Report**: Summarize shipped, decisions, insights captured.
