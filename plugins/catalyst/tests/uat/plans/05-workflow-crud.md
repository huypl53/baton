# 05: Workflow CRUD

Verify edit, remove, list operations work correctly.

## Setup
- snapshot: basic-flow
- timeout: 180
- parallel-group: B

## Steps

1. Run `/catalyst:workflow list`
   - expect: workflow|list|available|none|crud

2. Run `/catalyst:workflow add testflow --description 'Test workflow'`
   - expect: created|added|testflow|success

3. Run `/catalyst:workflow edit testflow --description 'Updated'`
   - expect: edit|update|modify|success

4. Run `/catalyst:workflow remove testflow`
   - expect: remove|delete|success

## Pass Criteria
- All CRUD operations respond appropriately
