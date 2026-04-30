# Baton

Claude Code plugins distributed via marketplace.

## Structure

```
├── .claude-plugin/           # marketplace manifest
├── plugins/
│   ├── catalyst/             # meta-plugin for project workflows
│   ├── daily/                # daily productivity skills
│   └── nextjs/               # Next.js development skills
└── setup.sh
```

## Setup

### Prerequisites

Ensure `~/.claude/skills/` directory exists before running setup.

### Marketplace install (recommended)

```bash
# GitHub marketplace
/plugin marketplace add huypl53/baton

# Install plugins
/plugin install daily@huypl53
/plugin install nextjs@huypl53
/plugin install catalyst@huypl53
```

### Local symlink install (development)

```bash
# Symlink one plugin's skills into ~/.claude*/skills
./setup.sh --plugins daily

# Symlink multiple plugins
./setup.sh --plugins daily,nextjs,catalyst
```

## Adding a New Skill

1. Choose a plugin: `plugins/daily`, `plugins/nextjs`, or `plugins/catalyst`
2. Create `plugins/<plugin>/skills/<name>/SKILL.md`
3. Add scripts in `plugins/<plugin>/skills/<name>/scripts/` if needed
4. Update `.claude-plugin/marketplace.json` plugin entry when catalog changes
5. Validate marketplace: `claude plugin validate .`
6. Install via official flow: `/plugin marketplace add ./` then `/plugin install <plugin>@huypl53`

