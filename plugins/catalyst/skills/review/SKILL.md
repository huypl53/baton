---
name: catalyst:review
description: "Review generated flow plugins for coherence, completeness, and style compliance. Checks subagent references, memory structure, hooks, and suggests improvements. Can auto-fix common issues."
argument-hint: "[plugin-path] [--auto-fix]"
metadata:
  author: vtit
  version: "1.0.0"
---

# Review - Plugin Coherence Review

Review and improve generated flow plugins.

## Usage

```bash
/catalyst:review                    # Review current plugin
/catalyst:review ./plugins/myapp    # Review specific plugin
/catalyst:review --auto-fix         # Auto-fix common issues
```

## Review Checks

### 1. Coherence

Are all references consistent?

| Check | What |
|-------|------|
| Subagent refs | Commands reference existing agents |
| Memory refs | @memory/ paths resolve |
| Workflow refs | INDEX.md lists all workflows |
| Cross-refs | Workflows don't reference each other's memory |

### 2. Completeness

Are required files present?

| Required | Location |
|----------|----------|
| Plugin manifest | .claude-plugin/plugin.json |
| Project contract | CLAUDE.md |
| Ship skill | skills/ship/SKILL.md |
| Global memory | memory/INDEX.md, conventions.md, gotchas.md |
| Workflow memory | memory/workflows/{name}/ for each command |
| Decisions dir | memory/decisions/{name}/ for each workflow |

### 3. Style

Does plugin match project conventions?

- File naming consistent
- Frontmatter format correct
- Memory file structure matches templates
- Command structure follows pattern

### 4. Evolution

Is memory being used effectively?

- INDEX.md has overview content
- Insights files have entries (not just templates)
- Gotchas captured
- Decision records present

## Process

1. **Read all plugin files**
   ```
   .claude-plugin/plugin.json
   CLAUDE.md
   skills/*/SKILL.md
   commands/*.md
   agents/*.md
   memory/**/*.md
   hooks/*.json
   ```

2. **Run coherence checks**
   - Extract all @memory/ and @agents/ references
   - Verify each resolves to existing file
   - Check INDEX.md lists all workflows

3. **Run completeness checks**
   - Required files exist
   - Required directories exist
   - Workflow memory directories match commands

4. **Run style checks**
   - Frontmatter valid
   - File naming consistent
   - Structure matches templates

5. **Run evolution checks**
   - Memory files have content beyond template
   - Decision records exist for mature workflows

6. **Generate report**

7. **Interactive: apply suggestions**
   - Show fixable issues
   - Offer auto-fix

8. **Update INDEX.md with learnings**

## Report Format

```
Plugin Review: myapp-flow

## Coherence
✓ Subagent references: PASS (4 agents, all exist)
✓ Memory references: PASS (12 refs, all resolve)
⚠ Workflow refs: WARN (payment not in INDEX.md)

## Completeness
✓ Required files: PASS (8/8)
✓ Required dirs: PASS (4/4)
⚠ Workflow memory: WARN (api/ missing test-flows.md)

## Style
✓ Frontmatter: PASS
✓ Naming: PASS

## Evolution
⚠ Insights: WARN (2/3 workflows have no insights)
✗ Decisions: FAIL (0 decision records)

## Summary
  ✓ Passed: 6
  ⚠ Warnings: 3
  ✗ Failed: 1

## Suggestions

1. Add 'payment' to INDEX.md workflows section
2. Create memory/workflows/api/test-flows.md
3. Document insights in auth and crud workflows
4. Create first decision record

Apply auto-fixes? [y/N]
```

## Auto-Fix Capabilities

| Issue | Fix |
|-------|-----|
| Missing from INDEX.md | Add workflow entry |
| Missing memory file | Create from template |
| Missing decisions dir | Create directory |
| Broken @memory/ ref | Suggest correct path |

## Improvement Suggestions

Beyond fixes, suggests improvements:

- **Consolidate**: Common patterns across workflows → conventions.md
- **Document**: Frequently used commands → test-flows.md
- **Capture**: Repeated gotchas → gotchas.md
- **Decide**: Significant choices → decisions/

## Integration

Run review after major changes:

```bash
# After scaffold
/catalyst:scaffold
/catalyst:review

# After adding workflows
/catalyst:workflow add payment
/catalyst:review

# Periodic check
/catalyst:review --auto-fix
```

## Memory Update

After review, updates `memory/INDEX.md`:

```markdown
## Review History

- 2026-04-29: Initial review, 3 warnings fixed
- 2026-05-01: Added auth insights
```
