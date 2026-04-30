# 09: Full Flow (E2E)

Complete user journey from empty project to working workflow execution.

## Setup
- fixture: fastapi-starter
- timeout: 300
- parallel-group: D

## Steps

1. Run `/catalyst:scout`
   - expect: python|fastapi|detected|analysis

2. Run `/catalyst:scaffold`
   - expect: created|scaffold|complete|plugin|validation

3. Run `/catalyst:workflow add auth --description 'Authentication'`
   - expect: auth|created|added|workflow

4. Run `/catalyst:validate`
   - expect: pass|valid|check|structure

## Pass Criteria
- All steps complete successfully
- Full flow demonstrates end-to-end capability
