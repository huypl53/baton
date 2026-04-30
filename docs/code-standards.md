# Code Standards

## Bash Scripts

### Safety flags (mandatory)

Every script starts with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- `-e` — exit immediately on any non-zero status
- `-u` — treat unset variables as an error
- `-o pipefail` — a pipe fails if any stage fails (not just the last)

### Variable quoting

Always quote variables to handle paths with spaces:

```bash
# good
ln -s "$src" "$dst"
mkdir -p "$dir"

# bad
ln -s $src $dst
```

### Portable path resolution

Use `BASH_SOURCE[0]` (not `$0`) to get the script's real location, and `cd` + `pwd` to resolve it absolutely:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### Logging helpers

Use two named helpers; do not use bare `echo`:

```bash
log()  { printf '\033[32m[setup]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[warn]\033[0m  %s\n' "$1"; }
```

### Symlink helper pattern

A dedicated `symlink()` function must:
1. Check if a symlink already points to the correct target (no-op).
2. Remove and re-create a stale symlink.
3. Back up (`*.bak`) any real file before replacing it.

See `setup.sh` lines 13–33 for the reference implementation.

### Arrays and loops

Use `declare -A` for associative arrays. Quote array expansions:

```bash
declare -A PLUGIN_PATHS=(
  [daily]="$SCRIPT_DIR/plugins/daily/skills"
)

for config_dir in "${CLAUDE_CONFIGS[@]}"; do
  ...
done
```

### Argument parsing

Use a `while [[ $# -gt 0 ]]; do case "$1" in ...` loop. Always `shift` consumed arguments. Emit a `warn` for unknown flags rather than failing silently.

---

## Plugin / Skill Authoring

### File structure

Every skill must contain at minimum:

```
skills/<skill-name>/
└── SKILL.md       # frontmatter + instructions
```

Optional additions:
```
skills/<skill-name>/
├── SKILL.md
├── scripts/       # helper shell/Python scripts the skill invokes
└── references/    # supplementary doc templates or checklists
```

### SKILL.md frontmatter

Required fields:

```yaml
---
name: <kebab-case-name>
description: "<one-sentence trigger description for the skills catalog>"
---
```

Optional fields: `argument-hint`, `license`, `metadata.author`, `metadata.version`.

The `description` field appears verbatim in the Claude Code skills catalog — write it as a trigger condition so the model knows when to activate the skill.

### Naming conventions

- Skill directories: **kebab-case**, descriptive enough to be self-documenting (e.g., `debug-with-logging`, not `debug`).
- Helper scripts inside `scripts/`: kebab-case with `.sh` or `.py` extension.
- References inside `references/`: kebab-case markdown (e.g., `doc-templates.md`, `uat-checklists.md`).

### Plugin manifest (plugin.json)

Each plugin directory must include `.claude-plugin/plugin.json`:

```json
{
  "name": "<plugin-name>",
  "description": "<short description>",
  "version": "1.0.0"
}
```

Version follows semver. Bump the minor version when adding skills; patch for fixes; major for breaking changes.

### Marketplace manifest (marketplace.json)

The root `.claude-plugin/marketplace.json` registers the marketplace and lists all plugins:

```json
{
  "name": "<marketplace-id>",
  "owner": { "name": "<owner-id>" },
  "description": "...",
  "plugins": [
    { "name": "<plugin>", "source": "./plugins/<plugin>", "description": "..." }
  ]
}
```

`source` is resolved relative to the marketplace.json file.

---

## Configuration Files (settings.json)

- All `settings.json` files are git-crypt encrypted — never commit unencrypted secrets.
- Do not add comments to JSON files (JSON does not support comments).
- Keep security `deny` rules in the default `configs/claude/settings.json` to prevent accidental over-permissioning.

---

## Shell Aliases

Aliases in `shell/zshrc` follow the pattern:

```bash
alias <short-name>="<env-overrides> claude <flags>"
```

Current aliases:

| Alias | Config dir | Notes |
|-------|-----------|-------|
| `cca` | `~/.claude` (default) | Anthropic API |
| `ccg` | `~/.claude-glm` | GLM proxy |
| `ccp` | `~/.claude-api-proxy` | OpenAI-compatible proxy |

All aliases set `SHELL=/bin/bash` and `CLAUDE_CODE_NO_FLICKER=1`.  
`CLAUDE_CODE_MAX_OUTPUT_TOKENS=100000` is exported once at the top of `zshrc`.
