# Insights Examples

Common patterns for capturing core insights.

## Authentication

```markdown
## Auth Flow (YYYY-MM-DD)

**Critical Path:** `/login` → credentials → `/dashboard`
**Why Critical:** Gates all protected features
**Test Command:**
\`\`\`bash
agent-browser open http://localhost:3000/login
agent-browser snapshot -i
agent-browser fill @email "test@example.com"
agent-browser fill @password "password123"
agent-browser click @submit
agent-browser wait --url "/dashboard"
agent-browser snapshot -i
\`\`\`
**Gotchas:**
- Session expires after 24h
- OAuth redirects differ by provider
```

## Form Submission

```markdown
## Contact Form (YYYY-MM-DD)

**Critical Path:** `/contact` → fill form → submit → success message
**Why Critical:** Primary lead capture
**Test Command:**
\`\`\`bash
agent-browser open http://localhost:3000/contact
agent-browser fill @name "Test User"
agent-browser fill @email "test@test.com"
agent-browser fill @message "Test message"
agent-browser click @submit
agent-browser wait --text "Thank you"
\`\`\`
**Gotchas:**
- Honeypot field must stay empty
- Rate limited to 5/min
```

## E-commerce / Checkout

```markdown
## Checkout Flow (YYYY-MM-DD)

**Critical Path:** `/cart` → `/checkout` → payment → `/confirmation`
**Why Critical:** Revenue-critical
**Test Command:**
\`\`\`bash
agent-browser open http://localhost:3000/cart
agent-browser click @checkout
agent-browser fill @card "4242424242424242"
agent-browser fill @expiry "12/25"
agent-browser fill @cvc "123"
agent-browser click @pay
agent-browser wait --url "/confirmation"
\`\`\`
**Gotchas:**
- Use Stripe test cards only
- 3D Secure modal in some regions
```

## Navigation

```markdown
## Main Navigation (YYYY-MM-DD)

**Critical Path:** All nav links resolve correctly
**Why Critical:** Site usability
**Test Command:**
\`\`\`bash
agent-browser open http://localhost:3000
agent-browser snapshot -i
agent-browser click @nav-about
agent-browser wait --url "/about"
agent-browser click @nav-contact
agent-browser wait --url "/contact"
\`\`\`
**Gotchas:**
- Mobile menu has different selectors
```

## Data Display

```markdown
## User Dashboard (YYYY-MM-DD)

**Critical Path:** `/dashboard` loads user data correctly
**Why Critical:** Core user value
**Test Command:**
\`\`\`bash
agent-browser open http://localhost:3000/dashboard
agent-browser wait --load
agent-browser snapshot -i
# Verify data elements present
agent-browser get text @user-stats
\`\`\`
**Gotchas:**
- Empty state when no data
- Pagination after 10 items
```

## API Integration

```markdown
## External API (YYYY-MM-DD)

**Critical Path:** API call returns expected data
**Why Critical:** Feature depends on external service
**Where:** `src/services/api-client.ts:45`
**Gotchas:**
- Rate limited to 100/day in dev
- Mock responses in test env
- Timeout set to 5s
```

## File Upload

```markdown
## Document Upload (YYYY-MM-DD)

**Critical Path:** `/upload` → select file → progress → success
**Why Critical:** Core feature for document management
**Test Command:**
\`\`\`bash
agent-browser open http://localhost:3000/upload
agent-browser upload @file-input test.pdf
agent-browser wait --text "Upload complete"
\`\`\`
**Gotchas:**
- Max 10MB per file
- Only PDF, DOCX allowed
- Progress bar can stall on slow connection
```

## Real-time Features

```markdown
## Live Chat (YYYY-MM-DD)

**Critical Path:** Messages send and receive in real-time
**Why Critical:** Core communication feature
**Gotchas:**
- WebSocket reconnects on network change
- Message queue if offline
- Typing indicator has 3s debounce
```

## Template

```markdown
## [Feature Name] (YYYY-MM-DD)

**Critical Path:** [route] → [action] → [expected result]
**Why Critical:** [business reason]
**Test Command:**
\`\`\`bash
agent-browser open <url>
agent-browser snapshot -i
# ... test steps
\`\`\`
**Gotchas:**
- [non-obvious behavior]
- [edge case to watch]
```
