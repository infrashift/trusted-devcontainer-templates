---
title: Containerfile Sync
description: How the shared Containerfile is kept in sync across all templates.
---

All templates share a single canonical Containerfile at `shared/Containerfile`. Each template has a copy at `src/<template>/.devcontainer/Containerfile` that must be identical.

## Why a Shared Containerfile?

See [ADR-002: Shared Containerfile](/trusted-devcontainer-templates/decisions/adr-002-shared-containerfile/) for the full rationale. In summary:

- **Consistency** — every template starts from the exact same foundation
- **Auditability** — one file to review for the base layer
- **Maintenance** — updates only need to be made in one place

## CI Enforcement

The `sync-containerfile.yaml` workflow runs on PRs and pushes that touch Containerfile paths:

```yaml
on:
  pull_request:
    paths:
      - 'shared/Containerfile'
      - 'src/*/.devcontainer/Containerfile'
```

It compares every template's Containerfile against `shared/Containerfile` using `diff`. If any copy has drifted, the job fails with:

```
DRIFT DETECTED: src/python/.devcontainer/Containerfile
```

## Local Commands

### Check for drift

```bash
make check-sync
```

Runs the same diff check locally. Exits non-zero if any template has drifted.

### Fix drift

```bash
make sync-containerfiles
```

Copies `shared/Containerfile` to all template directories.

## Workflow

1. Edit `shared/Containerfile` with your changes
2. Run `make sync-containerfiles` to propagate
3. Commit all changed files together
4. CI verifies the sync on your PR
