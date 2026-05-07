# Baton

Claude Code plugins distributed via marketplace.

## Plugins

### catalyst

Meta-plugin that generates project-specific workflow plugins.

| Skill | Description |
|-------|-------------|
| `catalyst:scout` | Analyze project structure, stack, patterns. Detects language, framework, test runner, conventions. |
| `catalyst:scaffold` | Generate customized flow plugin from templates based on scout analysis. |
| `catalyst:workflow` | CRUD for feature workflows. Add, edit, remove, list workflows in a flow plugin. |
| `catalyst:review` | Review plugins for coherence, completeness, style compliance. Auto-fix available. |
| `catalyst:validate` | Validate schema compliance, reference integrity, determinism. |

### daily

General productivity and workflow skills.

| Skill | Description |
|-------|-------------|
| `daily:baton` | Post-task checklist with persistent insights. UAT testing, documentation, knowledge compounding. |
| `daily:tmux` | Remote control tmux sessions for interactive CLIs (python, gdb, etc.). |
| `daily:debug` | Debug with logs instead of guessing. Instrument code and run it to get evidence. |

### nextjs

Next.js ecommerce skill bundle.

| Skill | Description |
|-------|-------------|
| `nextjs:hooks` | Design production-grade React hooks. Facade hooks, state machines, TanStack composition. |
| `nextjs:ecommerce` | Build Next.js ecommerce apps. Cart/checkout, Shopify/Stripe/MedusaJS, 4-layer architecture. |
| `nextjs:schema` | Type-safe apps with Drizzle+Zod+TypeScript. Schema-to-type flow, single source of truth. |
| `nextjs:optimistic` | TanStack Query v5 optimistic updates. Instant UI feedback, rollback, dual-cache updates. |

### partner

Collaborative learning and guidance skills.

| Skill | Description |
|-------|-------------|
| `partner:mentor` | Guide users step-by-step instead of doing work. Modes: `--steps`, `--guide`, `--phases`. |

## Structure

```
├── .claude-plugin/           # marketplace manifest
├── plugins/
│   ├── catalyst/             # meta-plugin for project workflows
│   ├── daily/                # daily productivity skills
│   ├── nextjs/               # Next.js development skills
│   └── partner/              # collaborative learning skills
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
/plugin install partner@huypl53
```

### After adding a new Catalyst plugin locally

If you add or change plugin entries in this repo (for example a new plugin under `plugins/`), you still need to re-add this local marketplace before install commands can see updates.

Run this from the repository root (the `./` must point to this repo's root where `.claude-plugin/marketplace.json` exists):

```bash
/plugin marketplace add ./
```

Then install the plugin as usual:

```bash
/plugin install <plugin>@huypl53
```

### Local symlink install (development)

```bash
# Symlink one plugin's skills into ~/.claude*/skills
./setup.sh --plugins daily

# Symlink multiple plugins
./setup.sh --plugins daily,nextjs,catalyst,partner
```

## Adding a New Skill

1. Choose a plugin: `plugins/daily`, `plugins/nextjs`, `plugins/catalyst`, or `plugins/partner`
2. Create `plugins/<plugin>/skills/<name>/SKILL.md`
3. Add scripts in `plugins/<plugin>/skills/<name>/scripts/` if needed
4. Update `.claude-plugin/marketplace.json` plugin entry when catalog changes
5. Validate marketplace: `claude plugin validate .`
6. Install via official flow: `/plugin marketplace add ./` then `/plugin install <plugin>@huypl53`

