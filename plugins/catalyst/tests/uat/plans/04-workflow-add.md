# 04: Workflow Add

Verify workflow add creates complete workflow with memory directories.

## Setup
- snapshot: basic-flow
- timeout: 120
- parallel-group: B

## Steps

1. Run `/catalyst:workflow add payment --description 'Payment processing'`
   - expect: created|added|payment|workflow|success

2. Check directory `memory/workflows/payment` exists

## Pass Criteria
- Workflow add completes
- Workflow directory created
