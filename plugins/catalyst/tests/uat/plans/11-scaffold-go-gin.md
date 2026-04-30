# 11: Scaffold Go/Gin

Test plugin detection and scaffolding for Go/Gin REST API.

## Setup
- fixture: go-gin-starter
- timeout: 180
- parallel-group: A

## Steps

1. Run `/catalyst:scout`
   - expect: go|gin|api|detected

2. Check file `plans/catalyst-analysis.md` exists

3. Run `/catalyst:scaffold`
   - expect: created|complete|success|validation

4. Check directory `plugins/go-gin-starter-flow/.claude-plugin/` exists

5. Check directory `plugins/go-gin-starter-flow/memory/` exists

6. Check directory `plugins/go-gin-starter-flow/commands/` exists

## Pass Criteria
- All steps pass
- Plugin correctly detects Go/Gin stack
- Auto-validation runs after scaffold
