# auth Test Flows

Test commands for auth workflow.

## Unit Tests

```bash
vitest run auth
```

## Integration Tests

```bash
vitest run auth --integration
```

## E2E Tests

```bash
agent-browser open http://localhost:3000/login
agent-browser fill @email "test@test.com"
agent-browser fill @password "password"
agent-browser click @submit
agent-browser wait --url "/dashboard"
```
