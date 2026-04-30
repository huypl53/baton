# Workflow Templates Reference

Standard workflow templates and customization options.

## Available Templates

| Template | Use Case |
|----------|----------|
| crud | Standard CRUD operations |
| auth | Authentication flows |
| api | API endpoint development |
| payment | Payment integration |
| admin | Admin panel features |
| notification | Notification systems |
| file-upload | File handling |
| search | Search functionality |

## Template Structure

Every workflow has:

```markdown
---
description: {workflow} pipeline for {project}
---

Implement: $ARGUMENTS

## Before You Code (MANDATORY)

1. Read @memory/INDEX.md
2. Read @memory/conventions.md
3. Read @memory/workflows/{name}/insights.md
4. Read @memory/workflows/{name}/gotchas.md
5. Read @memory/workflows/{name}/test-flows.md

## Loop (strict order)

{steps with delegation markers}

## After Shipping (MANDATORY)

1. Update insights
2. Update gotchas
3. Update test-flows
4. Create decision record
5. Update INDEX.md if global
6. Report
```

## Step Types

### Planning Steps

```markdown
1. **Plan**: Outline scope.
   - What's the goal?
   - What components needed?
   - What's the data model?
```

### Implementation Steps

```markdown
2. **Code**: Implement following conventions.md.
   - Component/module
   - Business logic
   - Data handling
```

### Migration Steps

```markdown
3. **Migrate**: If DB changes → delegate `@agents/migrator`.
   - Schema changes
   - Seed data
```

### Testing Steps

```markdown
4. **Unit Test**: Delegate `@agents/tester`.
   FAIL → fix, re-run. Max 3 attempts.

5. **Integration**: Run integration tests.
   Same fix loop.

6. **E2E**: Delegate `@agents/e2e-runner`.
   Same fix loop.
```

### Review Steps

```markdown
7. **Review**: Delegate `@agents/reviewer`.
   Address findings.
```

## Customization

### Adding Steps

```json
{
  "steps": [
    { "name": "plan", "description": "Outline scope" },
    { "name": "code", "description": "Implement" },
    { "name": "security-check", "description": "Security scan", "delegate": "security-scanner" },
    { "name": "unit-test", "delegate": "tester" }
  ]
}
```

### Custom Subagents

```json
{
  "subagents": ["tester", "security-scanner", "perf-analyzer"]
}
```

### Custom Success Criteria

```json
{
  "success_criteria": "All tests pass, security scan clean, perf benchmarks met"
}
```

### Custom Fix Limits

```json
{
  "fix_limits": {
    "unit-test": 5,
    "integration": 3,
    "e2e": 2
  }
}
```

## Workflow-Specific Sections

### Auth Workflow

Additional sections:
- Security Checklist
- Token handling notes
- MFA considerations

### Payment Workflow

Additional sections:
- PCI compliance notes
- Test card numbers
- Webhook handling

### API Workflow

Additional sections:
- API design checklist
- Documentation requirements
- Rate limiting

## Memory Templates

Each workflow creates:

### insights.md

```markdown
# {workflow} Insights

## Key Patterns

## Dependencies

## Common Tasks
```

### gotchas.md

```markdown
# {workflow} Gotchas

## Template

\`\`\`markdown
## [Brief description]

**Symptom**: What happens
**Cause**: Why it happens
**Fix**: How to avoid/resolve
**Found**: YYYY-MM-DD
\`\`\`
```

### test-flows.md

```markdown
# {workflow} Test Flows

## Unit Tests

\`\`\`bash
{test_runner} run {workflow}
\`\`\`

## Integration Tests

## E2E Tests
```
