# 03: Scaffold Next.js

Verify scaffold works for different stack (Next.js/React).

## Setup
- fixture: nextjs-starter
- timeout: 180
- parallel-group: A

## Steps

1. Run `/catalyst:scout`
   - expect: next|react|typescript|detected

2. Run `/catalyst:scaffold`
   - expect: created|scaffold|complete|plugin|validation

3. Check directory `plugins/*/memory/` exists

## Pass Criteria
- Scout detects Next.js stack
- Scaffold completes with appropriate structure
