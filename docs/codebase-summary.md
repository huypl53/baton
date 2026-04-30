# Codebase Summary

Quick reference for every file in the repository.

## Root

| File | Purpose |
|------|---------|
| `setup.sh` | Plugin installer — symlinks plugin skills into `~/.claude*/skills/` |
| `test-setup.sh` | Runs setup in a `$SANDBOX=/tmp/claude-setup-test-$$` dir for dry-run testing |

## .claude-plugin/

| File | Purpose |
|------|---------|
| `.claude-plugin/marketplace.json` | Defines the "huypl53" marketplace with `daily`, `nextjs`, `catalyst` plugins; symlinked into each `~/.claude*/.claude-plugin-marketplace` |

## plugins/

### plugins/daily/

| Path | Purpose |
|------|---------|
| `plugins/daily/.claude-plugin/plugin.json` | Plugin manifest (`name: daily`, `version: 1.0.0`) |
| `plugins/daily/skills/baton/SKILL.md` | Baton skill — post-task checklist with persistent insight accumulation |
| `plugins/daily/skills/baton/references/` | Supporting doc templates and UAT checklists for baton |
| `plugins/daily/skills/debug-with-logging/SKILL.md` | Instrumentation-first debugging guide (log→run→narrow) |
| `plugins/daily/skills/debug-with-logging/scripts/` | Helper scripts used by the debug skill |
| `plugins/daily/skills/tmux/SKILL.md` | tmux remote-control skill (isolated sockets, send-keys, wait-for-text) |
| `plugins/daily/skills/tmux/scripts/` | `wait-for-text.sh`, `find-sessions.sh` helper scripts |

### plugins/nextjs/

| Path | Purpose |
|------|---------|
| `plugins/nextjs/.claude-plugin/plugin.json` | Plugin manifest (`name: nextjs`, `version: 1.0.0`) |
| `plugins/nextjs/skills/` | Next.js ecommerce skill bundle (architecture, react-hooks, tanstack, typesafe-schema-flow) |

### plugins/catalyst/

| Path | Purpose |
|------|---------|
| `plugins/catalyst/.claude-plugin/plugin.json` | Plugin manifest (`name: catalyst`) |
| `plugins/catalyst/skills/` | Meta-plugin for project-specific workflow generation |

## docs/

| File | Purpose |
|------|---------|
| `docs/README.md` | Canonical index of all docs files |
| `docs/project-overview-pdr.md` | Project goals and problem statement |
| `docs/codebase-summary.md` | This file — quick file-level reference |
| `docs/code-standards.md` | Bash and plugin authoring conventions |
| `docs/system-architecture.md` | Component diagram, setup flow, plugin loading |
| `docs/project-roadmap.md` | Planned improvements and future work |
| `docs/catalyst-plugin.md` | Catalyst meta-plugin documentation |

