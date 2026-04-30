# 02: Scaffold FastAPI

Verify scaffold creates complete plugin structure for Python/FastAPI project.

## Setup
- fixture: fastapi-starter
- timeout: 180
- parallel-group: A

## Steps

1. Run `/catalyst:scout`
   - expect: python|fastapi|detected

2. Run `/catalyst:scaffold`
   - expect: created|scaffold|complete|plugin|validation

3. Check directory `plugins/*/memory/` exists

4. Check directory `plugins/*/commands/` exists

5. Check file `plugins/*/.claude-plugin/plugin.json` exists

## Pass Criteria
- Scaffold completes successfully
- Core directories created under plugins/
