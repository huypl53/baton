# 08: Review Coherence

Verify review skill analyzes plugin and provides suggestions.

## Setup
- snapshot: basic-flow
- timeout: 180
- parallel-group: C

## Steps

1. Run `/catalyst:review`
   - expect: review|check|coherence|suggestion|analysis|structure

## Pass Criteria
- Review completes with analysis
- Shows review checks or suggestions
