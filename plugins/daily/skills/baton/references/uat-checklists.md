# UAT Checklists by Component Type

## Form Components

```bash
# 1. Open form page
agent-browser open <url>
agent-browser snapshot -i

# 2. Test empty submission
agent-browser click @submit_btn
agent-browser snapshot -i  # Check: validation errors shown

# 3. Test valid submission
agent-browser fill @email "test@example.com"
agent-browser fill @password "ValidPass123!"
agent-browser click @submit_btn
agent-browser wait --load

# 4. Verify success
agent-browser snapshot -i  # Check: success state/redirect
agent-browser screenshot -o form-success.png
```

**Checklist:**
- [ ] Required field validation works
- [ ] Error messages display correctly
- [ ] Submit button disabled during loading
- [ ] Success state/redirect works
- [ ] Form clears or redirects after submit

## Navigation/Menu

```bash
agent-browser open <url>
agent-browser snapshot -i

# Test menu items
agent-browser click @menu_item_1
agent-browser wait --load
agent-browser get url  # Verify correct route

# Test mobile menu (if applicable)
agent-browser viewport 375 667
agent-browser snapshot -i
agent-browser click @mobile_menu_toggle
agent-browser snapshot -i
```

**Checklist:**
- [ ] All nav links work
- [ ] Active state shows correctly
- [ ] Mobile menu toggles properly
- [ ] Dropdown/submenu works

## Modal/Dialog

```bash
agent-browser open <url>
agent-browser snapshot -i

# Open modal
agent-browser click @modal_trigger
agent-browser wait @modal_content
agent-browser snapshot -i

# Test close
agent-browser click @modal_close
agent-browser snapshot -i  # Modal should be gone

# Test backdrop click
agent-browser click @modal_trigger
agent-browser click @modal_backdrop
agent-browser snapshot -i
```

**Checklist:**
- [ ] Modal opens on trigger
- [ ] Close button works
- [ ] Backdrop click closes (if applicable)
- [ ] ESC key closes (if applicable)
- [ ] Focus trapped inside modal

## Table/List

```bash
agent-browser open <url>
agent-browser snapshot -i

# Test pagination
agent-browser click @next_page
agent-browser wait --load
agent-browser snapshot -i

# Test sorting (if applicable)
agent-browser click @sort_header
agent-browser wait --load
agent-browser snapshot -i

# Test row action
agent-browser click @row_action
agent-browser snapshot -i
```

**Checklist:**
- [ ] Data loads correctly
- [ ] Pagination works
- [ ] Sorting works
- [ ] Row actions work
- [ ] Empty state shows when no data

## Authentication Flow

```bash
# Login
agent-browser open <login_url>
agent-browser snapshot -i
agent-browser fill @email "test@example.com"
agent-browser fill @password "password123"
agent-browser click @login_btn
agent-browser wait --url "/dashboard"
agent-browser snapshot -i

# Verify session
agent-browser get cookies  # Check auth cookie

# Logout
agent-browser click @logout
agent-browser wait --url "/login"
```

**Checklist:**
- [ ] Login works with valid credentials
- [ ] Invalid credentials show error
- [ ] Redirect to dashboard after login
- [ ] Session persists on refresh
- [ ] Logout clears session
