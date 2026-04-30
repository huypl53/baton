---
name: catalyst:scout
description: "Analyze target project structure, stack, and patterns. Detects language, framework, test runner, existing conventions, and recommends workflows for the project."
argument-hint: "[project-path]"
metadata:
  author: vtit
  version: "1.0.0"
---

# Scout - Project Analysis

Analyzes target project to prepare for flow plugin generation.

## Usage

```bash
/catalyst:scout           # Analyze current directory
/catalyst:scout ./myapp   # Analyze specific path
```

## Output

Generates `plans/catalyst-analysis.md` containing:
- Detected stack (language, framework, DB, test runner)
- Directory structure analysis
- Existing patterns (naming, architecture)
- Critical paths identified
- Recommended workflows

## Process

### 1. Stack Detection

```bash
# Package managers / dependency files
package.json     → Node.js ecosystem
requirements.txt → Python
Cargo.toml       → Rust
go.mod           → Go
pom.xml          → Java/Maven
build.gradle     → Java/Gradle
composer.json    → PHP
Gemfile          → Ruby
```

### 2. Framework Detection

From dependencies:
| Dependency | Framework |
|------------|-----------|
| next | Next.js |
| react | React |
| vue | Vue |
| express | Express |
| fastapi | FastAPI |
| django | Django |
| flask | Flask |
| actix-web | Actix |
| gin | Gin |
| spring-boot | Spring Boot |

### 3. Test Runner Detection

| File/Dep | Test Runner |
|----------|-------------|
| vitest.config | Vitest |
| jest.config | Jest |
| pytest.ini | Pytest |
| Cargo.toml [dev-dependencies] | Cargo test |
| *_test.go | Go test |

### 4. Directory Structure Analysis

```
src/
├── components/  → Component-based architecture
├── services/    → Service layer
├── models/      → Data models
├── routes/      → Route handlers
├── api/         → API layer
├── lib/         → Utilities
└── tests/       → Test files
```

### 5. Pattern Detection

**Naming conventions:**
- camelCase vs snake_case vs PascalCase
- File naming (kebab-case, etc.)

**Architecture patterns:**
- MVC
- Clean architecture
- Feature-based
- Domain-driven

### 6. Existing Docs Scan

Check for:
- README.md
- CLAUDE.md
- docs/ directory
- CONTRIBUTING.md
- Architecture decision records

### 7. CI/CD Detection

| File | System |
|------|--------|
| .github/workflows/ | GitHub Actions |
| .gitlab-ci.yml | GitLab CI |
| Jenkinsfile | Jenkins |
| .circleci/ | CircleCI |

## Analysis Report Template

```markdown
# Catalyst Analysis: {project-name}

Generated: {date}

## Stack

| Component | Detected | Confidence |
|-----------|----------|------------|
| Language | TypeScript | High |
| Framework | Next.js | High |
| Test Runner | Vitest | High |
| Package Manager | pnpm | High |
| Database | PostgreSQL (prisma) | Medium |

## Directory Structure

\`\`\`
{tree output}
\`\`\`

## Patterns

- **Naming**: camelCase (variables), PascalCase (components)
- **Architecture**: Feature-based (src/features/)
- **State**: Zustand
- **Styling**: Tailwind CSS

## Critical Paths

1. `/` - Landing page
2. `/dashboard` - Main app
3. `/api/auth/*` - Auth endpoints

## Existing Documentation

- README.md ✓
- CLAUDE.md ✗
- docs/ ✗

## CI/CD

- GitHub Actions (.github/workflows/ci.yml)

## Recommended Workflows

Based on analysis, recommend these workflows for {project}-flow:

1. **crud** - Standard CRUD operations (detected: models/, services/)
2. **auth** - Authentication flow (detected: auth/ or similar)
3. **api** - API endpoint development (detected: api/, routes/)

## Next Steps

Run `/catalyst:scaffold` to generate {project}-flow plugin.
```

## Implementation

```bash
#!/bin/bash
PROJECT_PATH="${1:-.}"

# Detect stack
detect_stack() {
    local path="$1"
    
    if [[ -f "$path/package.json" ]]; then
        echo "nodejs"
        # Check for specific frameworks
        if grep -q '"next"' "$path/package.json"; then
            echo "framework:nextjs"
        elif grep -q '"express"' "$path/package.json"; then
            echo "framework:express"
        fi
        
        # Check test runner
        if grep -q '"vitest"' "$path/package.json"; then
            echo "test:vitest"
        elif grep -q '"jest"' "$path/package.json"; then
            echo "test:jest"
        fi
    elif [[ -f "$path/requirements.txt" ]] || [[ -f "$path/pyproject.toml" ]]; then
        echo "python"
        if grep -q 'fastapi' "$path/requirements.txt" 2>/dev/null; then
            echo "framework:fastapi"
        elif grep -q 'django' "$path/requirements.txt" 2>/dev/null; then
            echo "framework:django"
        fi
    elif [[ -f "$path/Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "$path/go.mod" ]]; then
        echo "go"
    fi
}

# Detect package manager
detect_package_manager() {
    local path="$1"
    
    if [[ -f "$path/pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "$path/yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "$path/bun.lockb" ]]; then
        echo "bun"
    elif [[ -f "$path/package-lock.json" ]]; then
        echo "npm"
    elif [[ -f "$path/uv.lock" ]]; then
        echo "uv"
    elif [[ -f "$path/poetry.lock" ]]; then
        echo "poetry"
    fi
}

# Main
echo "Analyzing: $PROJECT_PATH"
detect_stack "$PROJECT_PATH"
detect_package_manager "$PROJECT_PATH"
```

## Notes

- Always confirm detection with user in scaffold step
- Allow manual override for edge cases
- High confidence = exact match, Medium = heuristic, Low = guess

## CRITICAL: Output Requirements

**ALWAYS write the analysis to a file.** Do not just output to chat.

1. Create `plans/` directory if it doesn't exist
2. Write analysis to `plans/catalyst-analysis.md`
3. Then display a summary to the user

```bash
# MUST DO: Create directory and write file
mkdir -p plans
# Then use Write tool to create plans/catalyst-analysis.md
```

The file output is required for `/catalyst:scaffold` to work properly.
