# Documentation Templates

## New Feature Entry

Add to `docs/architecture.md`:

```markdown
## [Feature Name] (YYYY-MM-DD)

**What:** One-line description of the feature
**Where:** `path/to/main/file.ts:startLine-endLine`
**Data flow:** Component → API → Database (or similar)

### Key Components
- `ComponentName` - purpose
- `useHookName` - purpose
- `apiEndpoint` - purpose

### Usage
\`\`\`typescript
// Example usage
import { feature } from './path';
feature.doSomething();
\`\`\`

### Extending
To add X, modify `file.ts` and add Y.
```

## Bug Fix Entry

Add to `docs/architecture.md` under "Known Issues / Gotchas":

```markdown
### [Issue Summary] (YYYY-MM-DD)

**Symptom:** What the user saw
**Root cause:** Why it happened
**Fix:** What was changed (`file.ts:line`)
**Prevention:** Guard/test added to prevent recurrence
```

## API Endpoint Entry

Add to `docs/architecture.md` under "API Reference":

```markdown
### `METHOD /api/endpoint`

**Purpose:** What this endpoint does
**Auth:** Required/Optional, role required
**Request:**
\`\`\`json
{ "field": "type", "optional?": "type" }
\`\`\`
**Response:**
\`\`\`json
{ "data": "type", "error?": "string" }
\`\`\`
**Errors:** 400 (validation), 401 (unauth), 404 (not found)
```

## Component Entry

Add to `docs/architecture.md` under "UI Components":

```markdown
### `ComponentName`

**Location:** `src/components/path/ComponentName.tsx`
**Purpose:** What it renders and when to use
**Props:**
| Prop | Type | Required | Description |
|------|------|----------|-------------|
| prop1 | string | Yes | Description |
| prop2 | boolean | No | Description |

**Usage:**
\`\`\`tsx
<ComponentName prop1="value" />
\`\`\`
```

## Config/Env Change

Add to `docs/deployment-guide.md`:

```markdown
### `ENV_VAR_NAME`

**Added:** YYYY-MM-DD
**Purpose:** What this config controls
**Required:** Yes/No
**Default:** value or "none"
**Example:** `ENV_VAR_NAME=example_value`
```

## Session Summary

Add to `docs/architecture.md` under "Session Log" or create separate file:

```markdown
### Session: YYYY-MM-DD - [Brief Task]

**Implemented:**
- Feature/fix 1
- Feature/fix 2

**Key Files:**
- `path/to/file.ts` - what was changed
- `path/to/other.ts` - what was changed

**Quick Reference:**
- To extend: modify X
- Watch out for: Y edge case
- Related: see `other-doc.md`
```

## Code Pattern Entry

Add to `docs/code-standards.md`:

```markdown
## [Pattern Name]

**When to use:** Scenario where this pattern applies
**Location:** Where this pattern is used (`path/to/example.ts`)

**Pattern:**
\`\`\`typescript
// Pattern example
export function patternExample() {
  // Key implementation detail
}
\`\`\`

**Why:** Explanation of why this pattern is preferred
```
