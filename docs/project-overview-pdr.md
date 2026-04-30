# Project Overview — claude_setup

## Problem

Claude Code skills and plugins are scattered across machines. Sharing skills between team members or syncing across machines requires manual copying.

## Solution

A git repository that delivers reusable Claude Code skills via:

1. **Plugin marketplace** manifest — skills can be installed via `/plugin install <name>@huypl53`
2. **Local symlinks** — `setup.sh --plugins <csv>` links skill directories into `~/.claude*/skills/`

## Target Users

Developers who:
- Want to share Claude Code skills across machines or with team members
- Build reusable skill libraries for specific workflows (daily productivity, Next.js, project scaffolding)

## Goals

| Goal | How it is met |
|------|--------------|
| Shareable skill plugins | Marketplace manifest at `.claude-plugin/marketplace.json` |
| Easy plugin installation | `/plugin install daily@huypl53` or `./setup.sh --plugins daily` |
| Multiple plugin bundles | `daily`, `nextjs`, `catalyst` plugins with distinct skill sets |

## Scope

**In scope:**
- Plugin skills: `daily` (baton, debug-with-logging, tmux), `nextjs`, `catalyst`
- Marketplace manifest for distribution
- Local symlink installation for development

**Out of scope:**
- Personal configurations (settings.json, CLAUDE.md, shell aliases) — managed separately
- Claude Code binary installation
