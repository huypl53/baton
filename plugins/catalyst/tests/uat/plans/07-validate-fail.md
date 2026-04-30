# 07: Validate Fail

Verify validate skill catches errors in broken plugin.

## Setup
- fixture: broken-plugin
- timeout: 180
- parallel-group: C

## Steps

1. Run `/catalyst:validate`
   - expect: fail|error|missing|invalid|broken

## Pass Criteria
- Validation detects errors in broken plugin
- Should NOT pass validation
