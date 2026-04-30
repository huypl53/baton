# Project Roadmap

## Current State (v1)

- Single `setup.sh` installs all three config profiles via symlinks.
- git-crypt encrypts all `settings.json` files.
- Plugin marketplace (`huypl53`) with `daily` and `nextjs` plugin bundles.
- Custom `statusline.sh` with context and rate-limit visualisation.
- Shell aliases `cca`, `ccg`, `ccp` for profile switching.

---

## Near-term (v1.x)

### Additional daily skills

| Skill | Description |
|-------|-------------|
| `git-conventional` | Enforce conventional commit message format on `/commit` |
| `pr-review` | Structured pull request review checklist |
| `context-trim` | Guided compaction when context window exceeds 70% |

### Healthcheck command

A `check.sh` (or `setup.sh --check`) mode that:
- Verifies each symlink still points to an existing source.
- Detects broken links caused by moving the repo.
- Reports which config dirs are missing keys/directories.

### statusline: input_tokens display toggle

Add a flag or env var to hide the `ctx:Nk` token display for users who find it noisy.

---

## Medium-term (v2)

### macOS / Linux portability hardening

`statusline.sh` uses `date -j -f` (macOS) with a fallback to `date -d` (GNU). Add a CI job (GitHub Actions) that runs `test-setup.sh` on both `ubuntu-latest` and `macos-latest` to catch regressions.

`time_left()` currently uses `bc` for floating-point division — replace with pure bash integer arithmetic to remove the `bc` dependency.

### Plugin validation CI

On every push to `plugins/`:
- Lint SKILL.md frontmatter (required fields present, `name` matches directory name).
- Validate `plugin.json` against a JSON Schema.
- Run `shellcheck` on any `.sh` files inside `scripts/`.

### Selective profile installation

Allow `setup.sh` to install only a subset of profiles:

```bash
./setup.sh --profiles claude,claude-glm
```

Useful when a machine only needs one or two profiles.

### Encrypted key bootstrap

Document (or script) a `bootstrap.sh` that:
1. Installs `git-crypt` if missing.
2. Accepts a base64-encoded key via environment variable or stdin.
3. Runs `git-crypt unlock` then `setup.sh`.

This enables one-liner onboarding on a new machine via a secrets manager (1Password CLI, AWS SSM, etc.).

---

## Long-term (v3+)

### Cross-platform support (Windows / WSL2)

- Detect WSL2 and resolve `$HOME` correctly.
- Fall back from `ln -s` to junction points on native Windows.
- Add a `setup.ps1` for PowerShell environments.

### Plugin versioning and updates

Currently plugins are always at HEAD. Add:
- Optional pinned versions in `marketplace.json` (`"version": "1.2.0"`).
- An `update.sh` that pulls the repo and re-runs `setup.sh` to refresh symlinks.

### Per-profile skill sets

Today all three profiles share the same installed skills. Allow the marketplace or `setup.sh` to install different skill subsets per profile:

```bash
./setup.sh --plugins daily:claude,nextjs:claude-api-proxy
```

### Automated secret rotation

A `rotate-secrets.sh` that re-encrypts `settings.json` files with a new git-crypt key and revokes the old one, to support periodic key rotation without manual repo surgery.
