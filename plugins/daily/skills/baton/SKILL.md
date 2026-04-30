---
name: daily:baton
description: "Post-task checklist with persistent insights. (1) Read accumulated core insights, (2) test critical paths + new changes via browser UAT, (3) document for future sessions, (4) capture new insights. Knowledge compounds across sessions — future invocations test previously identified critical features."
argument-hint: "[--skip-uat|--skip-docs|--skip-insights]"
metadata:
  author: vtit
  version: "2.0.0"
---

# Baton - Smart Post-Task Checklist

A **learning system** that accumulates knowledge across sessions. Each invocation:
1. **Reads** past insights (what's core/essential)
2. **Tests** critical paths + new changes
3. **Documents** for future comprehension
4. **Captures** new insights for next session

## Insight Accumulation

```
Session 1: Implement auth → capture "auth flow is critical"
Session 2: Add profile → read insights → test auth still works + test profile
Session 3: Fix bug → read insights → test auth + profile + fix
```

**Insights file:** `docs/core-insights.md` (created on first run)

## Arguments

| Flag | Effect |
|------|--------|
| `--skip-uat` | Skip browser UAT |
| `--skip-docs` | Skip docs update |
| `--skip-insights` | Skip insight capture (NOT RECOMMENDED) |

## Workflow

```
/baton → [Read Insights] → [UAT: Critical + New] → [Update Docs] → [Capture Insights]
```

<HARD-GATE>
1. **Read Insights** — MUST read `docs/core-insights.md` before testing
2. **Test Critical Paths** — If UI work, MUST test previously identified critical features
3. **Documentation** — MUST update `./docs` with changes
4. **Capture Insights** — MUST add new core insights for future sessions
</HARD-GATE>

### Investigation-Only Rule

Never ask the user about repository facts.  
Determine them from code, docs, git state, and tool output only.  
If unresolved, continue investigating; do not escalate as a question.

If sources conflict, resolve by precedence (highest wins):
1) Runtime evidence (tests/tool output)
2) Current source code
3) Git state/diff
4) Docs/comments only if present and consistent; otherwise ignore as stale/noise
5) Memory/assumptions

Proceed with the highest-precedence evidence and note the conflict + chosen source in baton/docs.

## Step 1: Read Existing Insights

Before testing, read accumulated knowledge:

```bash
# Check if insights file exists
cat docs/core-insights.md 2>/dev/null || echo "No insights yet"
```

**Parse insights for:**
- Critical features (must test)
- Known gotchas (watch for regressions)
- Core user flows (golden paths)

## Step 2: Identify What Changed

Summarize current session:
- What files were modified?
- What new features/fixes were added?
- Is this UI work? (triggers UAT)
- Does this touch any critical features from insights?

## Step 3: Browser UAT (UI Work)

If UI work detected AND `--skip-uat` not set:

### 3a. Test Critical Paths (from insights)

For each critical feature in `docs/core-insights.md`:

```bash
agent-browser open <base_url>/<critical_route>
agent-browser snapshot -i
# Quick smoke test of critical flow
agent-browser screenshot -o critical-<name>.png
```

### 3b. Test New Changes

```bash
agent-browser open <base_url>/<new_route>
agent-browser snapshot -i
# Full golden path test
agent-browser fill @e2 "test@example.com"
agent-browser click @e1
agent-browser wait --load
agent-browser screenshot -o new-feature.png
```

### UAT Checklist

- [ ] All critical paths still work (from insights)
- [ ] New feature works end-to-end
- [ ] No visual regressions
- [ ] Error states handled

**Output:** `✓ UAT: [N] critical paths + new feature verified`

## Step 4: Documentation Update

Update `./docs` with changes. See `references/doc-templates.md`.

## Step 5: Capture New Insights (CRITICAL)

After each task, ask:
- **What's core here?** What would break the app if it failed?
- **What's essential?** What must future sessions verify?
- **What gotchas exist?** What's non-obvious?

### Update Insights File

Append to `docs/core-insights.md`:

```markdown
## [Feature Name] (YYYY-MM-DD)

**Critical Path:** `/route` → action → expected result
**Why Critical:** [why this matters]
**Test Command:**
\`\`\`bash
agent-browser open <url>
agent-browser snapshot -i
agent-browser click @element
\`\`\`
**Gotchas:**
- [non-obvious thing to watch for]
```

### Insights File Structure

```markdown
# Core Insights

Accumulated knowledge for future sessions. Each `/baton` reads this file
and tests critical paths before completing.

---

## Auth Flow (2024-01-15)
**Critical Path:** `/login` → enter credentials → redirect to `/dashboard`
**Why Critical:** All features require auth
**Test Command:**
\`\`\`bash
agent-browser open http://localhost:3000/login
agent-browser fill @email "test@test.com"
agent-browser fill @password "password"
agent-browser click @submit
agent-browser wait --url "/dashboard"
\`\`\`

## Payment Flow (2024-01-20)
**Critical Path:** `/checkout` → enter card → confirm → success page
**Why Critical:** Revenue-critical
**Gotchas:**
- Stripe test mode requires specific card numbers
- 3D Secure flow different in prod
```

## Step 6: Confirm Baton

```
✓ Baton Complete (v2.0)
  - Insights read: [N] critical paths
  - Critical paths tested: [N] passed
  - New changes tested: [summary]
  - Docs: updated [file].md
  - New insights: captured [feature]
```

## Quick Reference

| Scenario | Command |
|----------|---------|
| Full baton | `/baton` |
| Non-UI task | `/baton --skip-uat` |
| Quick (no insights) | `/baton --skip-insights` |

## Anti-Rationalization

| Thought | Reality |
|---------|---------|
| "No insights to capture" | Every task has something core. Find it. |
| "Critical paths take too long" | 30 sec per path prevents hour-long debugging. |
| "This isn't critical" | If it broke, would users notice? Then it's critical. |
| "I'll add insights later" | You won't. Capture now while context is fresh. |

## References

- `references/uat-checklists.md` — UAT checklists by component
- `references/doc-templates.md` — Documentation templates
- `references/insights-examples.md` — Example insights for common patterns
