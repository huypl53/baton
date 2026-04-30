# UAT Test Index

Master index for Catalyst plugin user acceptance tests.

## Test Suite

| ID | Test | Fixture | Skills Tested | Parallel Group |
|----|------|---------|---------------|----------------|
| 01 | Scout Basic | fastapi-starter | scout | A |
| 02 | Scaffold FastAPI | fastapi-starter | scout, scaffold | A |
| 03 | Scaffold Next.js | nextjs-starter | scout, scaffold | A |
| 04 | Workflow Add | basic-flow (snapshot) | workflow add | B |
| 05 | Workflow CRUD | basic-flow (snapshot) | workflow list/edit/remove | B |
| 06 | Validate Pass | basic-flow (snapshot) | validate | C |
| 07 | Validate Fail | broken-plugin | validate | C |
| 08 | Review | basic-flow (snapshot) | review | C |
| 09 | Full Flow E2E | fastapi-starter | scout, scaffold, workflow, validate | D |
| 10 | Determinism | fastapi-starter | scout (x2) | D |
| 11 | Scaffold Go/Gin | go-gin-starter | scout, scaffold | A |

## Parallel Execution

Tests within the same group can run in parallel (independent fixtures/snapshots):

| Group | Tests | Description |
|-------|-------|-------------|
| A | 01, 02, 03, 11 | Independent fixture tests (different stacks) |
| B | 04, 05 | Workflow CRUD on basic-flow snapshot |
| C | 06, 07, 08 | Validation and review tests |
| D | 09, 10 | Full flow and determinism (sequential) |

## Execution Guide (Using tmux Skill)

Uses `~/.claude/skills/tmux/scripts/` helpers for reliable automation.

### 1. Environment Setup

```bash
# Paths
TMUX_SKILL="$HOME/.claude/skills/tmux/scripts"
PLUGIN_DIR="/path/to/catalyst"
TEST_DIR="/tmp/catalyst-uat-$$"

# Copy fixture
cp -r "$PLUGIN_DIR/tests/uat/fixtures/<fixture>" "$TEST_DIR"
cd "$TEST_DIR"

# Initialize git (required)
git init -q && git add -A && git commit -q -m "init"

# Install catalyst plugin locally
mkdir -p .claude/plugins
cp -r "$PLUGIN_DIR" .claude/plugins/catalyst

# Permissive settings
cat > .claude/settings.json << 'EOF'
{"permissions": {"allow": ["Bash(*)", "Write(*)", "Edit(*)", "Read(*)"]}}
EOF
```

### 2. Start Claude Session (Isolated Socket)

```bash
SOCKET_DIR="${TMPDIR:-/tmp}/claude-tmux-sockets"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/uat-$$.sock"
SESSION="uat-$$"

# Start session with isolated socket
tmux -S "$SOCKET" new-session -d -s "$SESSION" -c "$TEST_DIR"
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 "claude --dangerously-skip-permissions" C-m

# Wait for Claude to be ready (trust prompt)
"$TMUX_SKILL/wait-for-text.sh" -S "$SOCKET" -t "$SESSION":0.0 -p "trust this folder" -T 30
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 "1" C-m

# Wait for idle (ready for commands)
"$TMUX_SKILL/wait-for-text.sh" -S "$SOCKET" -t "$SESSION":0.0 --idle --idle-confirm-seconds 5 -T 60
```

### 3. Execute Commands

```bash
# Send command with proper Enter
"$TMUX_SKILL/tmux-send-and-enter.sh" -S "$SOCKET" -t "$SESSION":0.0 -- '/catalyst:scout'

# Wait for idle (hash-based detection)
"$TMUX_SKILL/wait-for-text.sh" -S "$SOCKET" -t "$SESSION":0.0 --idle --idle-confirm-seconds 5 -T 180

# Capture output
OUTPUT=$(tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -200)
```

### 4. Verify Results

```bash
# Pattern match (case-insensitive)
echo "$OUTPUT" | grep -qiE "python|fastapi|detected"

# File check
[[ -f "$TEST_DIR/plans/catalyst-analysis.md" ]]

# Directory check
[[ -d "$TEST_DIR/plugins/" ]] || [[ -d "$TEST_DIR/.claude-plugin/" ]]
```

### 5. Cleanup

```bash
tmux -S "$SOCKET" kill-session -t "$SESSION" 2>/dev/null || true
rm -rf "$TEST_DIR"
rm -f "$SOCKET"
```

## Plan Format

```markdown
# Test Name

Description of what this tests.

## Setup
- fixture: fastapi-starter
- timeout: 180
- parallel-group: A

## Steps

1. Run `/catalyst:scout`
   - expect: python|fastapi|detected

2. Check file `plans/catalyst-analysis.md` exists

3. Run `/catalyst:scaffold`
   - expect: created|complete|success|validation

## Pass Criteria
- All expect patterns match
- All file/directory checks pass
```

## Pass/Fail Logic

- **PASS**: All steps succeed
- **FAIL**: Any step fails
- **SKIP**: Fixture missing OR Claude unavailable

## Structural Tests (No Claude)

Run without Claude (bash scripts in `../scenarios/`):

```bash
bash ../scenarios/00-structure-check.sh
bash ../scenarios/00-schema-validation.sh
bash ../scenarios/00-reference-integrity.sh
bash ../scenarios/00-determinism-basic.sh
```

## Monitor Sessions

To watch a running UAT session:

```bash
tmux -S "$SOCKET" attach -t "$SESSION"
# Detach: Ctrl+b d
```

To capture output once:

```bash
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -200
```
