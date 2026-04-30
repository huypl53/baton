# System Architecture

## Overview

`claude_setup` is a plugin distribution repo for Claude Code. It delivers reusable skills via marketplace or local symlinks. Personal configurations (settings.json, CLAUDE.md, shell) are managed separately.

```
┌─────────────────────────────────────────────────────────────┐
│  git repository  (claude_setup/)                            │
│                                                             │
│  .claude-plugin/  ───────────────────────┐                  │
│  plugins/daily/skills/*  ──────────┐     │                  │
│  plugins/nextjs/skills/*  ─────┐   │     │                  │
│  plugins/catalyst/skills/* ─┐  │   │     │                  │
└─────────────────────────────┼──┼───┼─────┼──────────────────┘
                              │  │   │     │
         setup.sh creates     │  │   │     │
         symlinks             ▼  ▼   ▼     ▼
┌─────────────────────────────────────────────────────────────┐
│  host filesystem (~/)                                        │
│                                                             │
│  ~/.claude/                                                 │
│    .claude-plugin-marketplace  ──► .claude-plugin/         │
│    skills/<name>  ──► plugins/*/skills/<name>/             │
│                                                             │
│  ~/.claude-glm/   (same shape)                              │
│  ~/.claude-api-proxy/ (same shape)                          │
└─────────────────────────────────────────────────────────────┘
```

---

## setup.sh Flow

```
setup.sh --plugins <csv>
│
├── 1. verify ~/.claude*/skills/ directories exist
│       (exits with error if missing — run personal config setup first)
│
├── 2. symlink marketplace manifest into every config dir
│       .claude-plugin/ → ~/.claude/.claude-plugin-marketplace
│       .claude-plugin/ → ~/.claude-glm/.claude-plugin-marketplace
│       .claude-plugin/ → ~/.claude-api-proxy/.claude-plugin-marketplace
│
└── 3. [conditional] --plugins flag
    ├── Parse CSV of requested plugin names
    ├── Look up root path in PLUGIN_PATHS associative array
    └── For each skill dir under that root:
            plugins/<p>/skills/<skill>/ → ~/.claude/skills/<skill>
            plugins/<p>/skills/<skill>/ → ~/.claude-glm/skills/<skill>
            plugins/<p>/skills/<skill>/ → ~/.claude-api-proxy/skills/<skill>
```

The `symlink()` helper is idempotent: re-running `setup.sh` is safe.

---

## Plugin Loading Mechanism

```
Register marketplace (once per machine):
  /plugin marketplace add huypl53
  └── reads ~/.claude/.claude-plugin-marketplace/marketplace.json
      (which is a symlink to .claude-plugin/marketplace.json in the repo)

Install a plugin:
  /plugin install daily@huypl53
  └── reads marketplace.json → finds source: ./plugins/daily
      → registers skills in plugins/daily/skills/

Invoke a skill:
  /baton
  └── Claude Code scans ~/.claude/skills/ for matching SKILL.md frontmatter
      (skill dirs are symlinked from plugins/daily/skills/baton/)
```

Because the `skills/` entries are symlinks to the repo, any edit to a `SKILL.md` in the working tree is immediately reflected in all config profiles without re-running setup.

---

## Directory Layout

```
claude_setup/
├── .claude-plugin/
│   └── marketplace.json          # marketplace registry for "huypl53"
├── plugins/
│   ├── catalyst/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/               # project workflow generation
│   ├── daily/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   │       ├── baton/            # post-task checklist + insight accumulation
│   │       ├── debug-with-logging/  # instrumentation-first debugging
│   │       └── tmux/             # tmux remote-control patterns
│   └── nextjs/
│       ├── .claude-plugin/plugin.json
│       └── skills/               # Next.js ecommerce patterns
├── docs/                         # project documentation
├── setup.sh                      # plugin installer
└── test-setup.sh                 # sandbox-based installer test
```
