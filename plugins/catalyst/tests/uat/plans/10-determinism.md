# 10: Determinism Check

Verify same inputs produce consistent structural outputs.

## Setup
- fixture: fastapi-starter
- timeout: 240
- runs: 2
- parallel-group: D

## Steps

1. Run `/catalyst:scout`
   - expect: python|fastapi|detected

## Pass Criteria
- Both runs detect same stack markers
- File structure is identical between runs
- Note: LLM text varies naturally; structural output should match
