# 01: Scout Basic

Verify scout skill detects project stack correctly.

## Setup
- fixture: fastapi-starter
- timeout: 120
- parallel-group: A

## Steps

1. Run `/catalyst:scout`
   - expect: python|fastapi|detected|analysis

2. Check file `plans/catalyst-analysis.md` exists

## Pass Criteria
- Scout completes with stack detection
- Analysis file created
