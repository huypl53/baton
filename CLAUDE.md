# CLAUDE.md

Project: Claude Code Plugin Marketplace (Baton)

## Skill Naming Convention

All skills MUST use a namespace prefix in their `name` field (SKILL.md frontmatter) matching the plugin name:

```yaml
# In plugins/{plugin}/skills/{skill-name}/SKILL.md
---
name: {plugin}:{short-name}
description: "..."
---
```

**Pattern:** `{plugin-name}:{skill-short-name}`

**Examples:**
- `catalyst:scout` (folder: `plugins/catalyst/skills/scout/`)
- `daily:baton` (folder: `plugins/daily/skills/baton/`)
- `nextjs:hooks` (folder: `plugins/nextjs/skills/react-hooks-advanced/`)

**Why:** This makes skills discoverable in the TUI - users can type `catalyst:` to find all catalyst skills, similar to how `ck:` finds Claude Kit skills.

## Plugin Structure

```
plugins/{name}/
├── .claude-plugin/plugin.json
├── README.md
└── skills/
    └── {skill-name}/
        └── SKILL.md
```

## Commands

```bash
# Marketplace install
/plugin marketplace add huypl53/baton
/plugin install {plugin}@huypl53

# Local development
./setup.sh --plugins daily,nextjs,catalyst
```
