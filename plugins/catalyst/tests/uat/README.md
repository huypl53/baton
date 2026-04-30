# Catalyst UAT

User acceptance tests for Catalyst plugin. **These are instructions for agents to execute via tmux.**

## Dependencies

- `~/.claude/skills/tmux/` - Required for automated test execution
  - `scripts/wait-for-text.sh` - Idle detection and pattern matching
  - `scripts/tmux-send-and-enter.sh` - Send commands with Enter

## Structure

```
uat/
├── README.md              # This file
├── plans/                 # Test plans (agent follows these)
│   ├── 00-index.md        # Master index + execution guide
│   └── NN-*.md            # Individual test plans
├── fixtures/              # Test project templates
│   ├── fastapi-starter/   # Python FastAPI project
│   ├── nextjs-starter/    # Next.js React project
│   ├── go-gin-starter/    # Go/Gin REST API project
│   └── broken-plugin/     # Invalid plugin (for fail tests)
├── scenarios/             # Structural tests (bash, no Claude)
│   └── 00-*.sh
└── results/               # Outputs (gitignored)
```

## Parallel Execution

Tests are grouped for parallel execution:

| Group | Tests | Description |
|-------|-------|-------------|
| A | 01, 02, 03, 11 | Independent fixtures (fastapi, nextjs, go-gin) |
| B | 04, 05 | Workflow CRUD on basic-flow snapshot |
| C | 06, 07, 08 | Validation and review tests |
| D | 09, 10 | Full flow and determinism (sequential) |

Run groups A tests in parallel, then B, then C, then D.

## For Agents

**Start here:** Read `plans/00-index.md` for:
- How to set up test environment
- How to drive Claude via tmux skill helpers
- How to verify pass/fail
- Parallel execution groups

Each `plans/NN-*.md` is a self-contained test case with:
- Setup requirements (fixture/snapshot)
- Steps to execute
- Expected outputs
- Pass criteria
- Parallel group assignment

## For Humans

### Structural Tests (No Claude)

```bash
bash scenarios/00-structure-check.sh
bash scenarios/00-schema-validation.sh
bash scenarios/00-reference-integrity.sh
bash scenarios/00-determinism-basic.sh
```

### Manual Testing

```bash
# Setup
TEST_DIR="/tmp/catalyst-test-$$"
cp -r fixtures/fastapi-starter "$TEST_DIR"
cd "$TEST_DIR"
git init && git add -A && git commit -m "init"

# Run Claude and test skills
claude
/catalyst:scout
/catalyst:scaffold
/catalyst:validate
```

## Fixtures

| Fixture | Description |
|---------|-------------|
| `fastapi-starter` | Python/FastAPI project for scout/scaffold |
| `nextjs-starter` | Next.js/React project for cross-stack tests |
| `go-gin-starter` | Go/Gin REST API for cross-language tests |
| `broken-plugin` | Invalid plugin structure for validate-fail |
