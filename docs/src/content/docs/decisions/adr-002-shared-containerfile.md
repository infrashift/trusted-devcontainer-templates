---
title: "ADR-002: Shared Containerfile"
description: Decision to use a single canonical Containerfile shared across all templates.
---

**Status:** Accepted — amended

## Context

With multiple templates, each having its own `.devcontainer/Containerfile`, there is a risk of drift. Templates might end up with different base images, different user configurations, or different bootstrap steps. This makes auditing difficult and increases maintenance burden.

## Decision

Maintain a single canonical Containerfile at `shared/Containerfile`. Each template's `.devcontainer/Containerfile` must be an exact byte-for-byte copy. Enforce this with:

1. A CI workflow (`sync-containerfile.yaml`) that diffs all copies
2. A local `make check-sync` target for developer convenience
3. A `make sync-containerfiles` target to propagate changes

**Amendment.** Both checks originally globbed only `src/*/.devcontainer/Containerfile`, which left this
repository's own `.devcontainer/Containerfile` — a seventh copy — outside the drift gate. It had already
diverged. The managed set is now enumerated once, as `MANAGED_CONTAINERFILES` in the `Makefile`, and
covers all seven files.

## Consequences

**Positive:**
- One file to audit for the base layer
- All templates start from an identical foundation
- Changes are intentional and visible in a single diff
- CI catches accidental drift immediately

**Negative:**
- Templates cannot customize the Containerfile (e.g., install additional system packages)
- Updating the base requires touching `N + 1` files (shared + all templates)
- The sync mechanism adds process overhead

## Alternatives Considered

| Alternative | Why not |
|---|---|
| **Shared base image** | Would require maintaining a separate image build pipeline |
| **Template inheritance** | devcontainer spec doesn't support Containerfile inheritance |
| **Symlinks** | OCI template publishing flattens directories; symlinks break |
| **Per-template freedom** | Too much drift risk; auditing becomes per-template |
