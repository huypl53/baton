# Stack Detection Reference

Detection rules for languages, frameworks, and tools.

## Language Detection

| Indicator | Language | Confidence |
|-----------|----------|------------|
| package.json | Node.js/TypeScript | High |
| tsconfig.json | TypeScript | High |
| requirements.txt | Python | High |
| pyproject.toml | Python | High |
| Cargo.toml | Rust | High |
| go.mod | Go | High |
| pom.xml | Java | High |
| build.gradle | Java/Kotlin | High |
| composer.json | PHP | High |
| Gemfile | Ruby | High |
| mix.exs | Elixir | High |
| Package.swift | Swift | High |

## Framework Detection

### Node.js

| Dependency | Framework |
|------------|-----------|
| next | Next.js |
| react | React (if no next) |
| vue | Vue.js |
| @angular/core | Angular |
| svelte | Svelte |
| express | Express |
| fastify | Fastify |
| hono | Hono |
| koa | Koa |
| nestjs | NestJS |

### Python

| Dependency | Framework |
|------------|-----------|
| fastapi | FastAPI |
| django | Django |
| flask | Flask |
| starlette | Starlette |
| aiohttp | aiohttp |
| tornado | Tornado |

### Rust

| Dependency | Framework |
|------------|-----------|
| actix-web | Actix Web |
| axum | Axum |
| rocket | Rocket |
| warp | Warp |

### Go

| Import | Framework |
|--------|-----------|
| github.com/gin-gonic/gin | Gin |
| github.com/labstack/echo | Echo |
| github.com/gofiber/fiber | Fiber |
| net/http only | Stdlib |

## Test Runner Detection

### Node.js

| Indicator | Runner |
|-----------|--------|
| vitest.config.* | Vitest |
| jest.config.* | Jest |
| playwright.config.* | Playwright |
| cypress.config.* | Cypress |
| *.test.ts/*.spec.ts | (check package.json) |

### Python

| Indicator | Runner |
|-----------|--------|
| pytest.ini | Pytest |
| conftest.py | Pytest |
| test_*.py | Pytest (default) |
| unittest in imports | Unittest |

### Rust

| Indicator | Runner |
|-----------|--------|
| #[test] | Cargo test |
| #[tokio::test] | Tokio test |

## Package Manager Detection

| Indicator | Manager |
|-----------|---------|
| pnpm-lock.yaml | pnpm |
| yarn.lock | Yarn |
| bun.lockb | Bun |
| package-lock.json | npm |
| uv.lock | uv |
| poetry.lock | Poetry |
| Pipfile.lock | Pipenv |
| Cargo.lock | Cargo |
| go.sum | Go modules |

## Database Detection

| Indicator | Database |
|-----------|----------|
| prisma/ | PostgreSQL (check schema) |
| drizzle/ | (check config) |
| knexfile.* | (check config) |
| .env with DATABASE_URL | (parse URL) |
| docker-compose.yml | (check services) |

## CI/CD Detection

| Path | System |
|------|--------|
| .github/workflows/ | GitHub Actions |
| .gitlab-ci.yml | GitLab CI |
| Jenkinsfile | Jenkins |
| .circleci/ | CircleCI |
| .travis.yml | Travis CI |
| bitbucket-pipelines.yml | Bitbucket |
| azure-pipelines.yml | Azure Pipelines |
| cloudbuild.yaml | Google Cloud Build |

## Confidence Levels

| Level | Meaning | Source |
|-------|---------|--------|
| High | Exact match | Lock file, config file |
| Medium | Dependency match | package.json, requirements.txt |
| Low | Heuristic | File patterns, directory names |

## Override

Always allow user override:

```
Detected: Express
Confirm? [Y/n/other]: other
Enter framework: Fastify
```
