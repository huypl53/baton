# Dry-Run Output Format

Standard format for `--dry-run` mode across all skills.

## Format

```
Would {action} {count} files in {path}:

  + {new-file-path}
  ~ {modified-file-path} ({change-description})
  - {deleted-file-path}

{additional-info}

No files written.
```

## Examples

### scaffold --dry-run

```
Would create 15 files in plugins/sample-flow/:

  + .claude-plugin/plugin.json
  + CLAUDE.md
  + skills/ship/SKILL.md
  + commands/crud-flow.md
  + commands/auth-flow.md
  + agents/tester.md
  + agents/migrator.md
  + agents/e2e-runner.md
  + agents/reviewer.md
  + memory/INDEX.md
  + memory/gotchas.md
  + memory/conventions.md
  + memory/workflows/crud/insights.md
  + memory/workflows/crud/gotchas.md
  + memory/workflows/crud/test-flows.md

Would modify 1 file:
  ~ .claude-plugin/marketplace.json (add plugin entry)

No files written.
```

### workflow add --dry-run

```
Would create 4 files, modify 1 file:

  + commands/payment-flow.md
  + memory/workflows/payment/insights.md
  + memory/workflows/payment/gotchas.md
  + memory/workflows/payment/test-flows.md
  ~ memory/INDEX.md (add workflow entry)

No files written.
```

### workflow remove --dry-run

```
Would delete 4 files, 2 directories, modify 1 file:

  - commands/payment-flow.md
  - memory/workflows/payment/insights.md
  - memory/workflows/payment/gotchas.md
  - memory/workflows/payment/test-flows.md
  - memory/workflows/payment/
  - memory/decisions/payment/
  ~ memory/INDEX.md (remove workflow entry)

No files deleted.
```

## Implementation

```bash
dry_run_report() {
    local action="$1"
    local created=()
    local modified=()
    local deleted=()
    
    # ... populate arrays ...
    
    echo "Would $action ${#created[@]} files:"
    for f in "${created[@]}"; do
        echo "  + $f"
    done
    
    if [[ ${#modified[@]} -gt 0 ]]; then
        echo ""
        echo "Would modify ${#modified[@]} file(s):"
        for f in "${modified[@]}"; do
            echo "  ~ $f"
        done
    fi
    
    if [[ ${#deleted[@]} -gt 0 ]]; then
        echo ""
        echo "Would delete ${#deleted[@]} file(s):"
        for f in "${deleted[@]}"; do
            echo "  - $f"
        done
    fi
    
    echo ""
    echo "No files written."
}
```
