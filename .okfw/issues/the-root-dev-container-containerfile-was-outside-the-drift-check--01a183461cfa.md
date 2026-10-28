---
id: "01a18346-1cfa-7c12-aa7c-76876f4fc1bd"
title: "The root dev container Containerfile was outside the drift check"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "containerfile"
  - "ci"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "The Containerfile drift check skipped the root .devcontainer/Containerfile; the Makefile now lists all managed files in MANAGED_CONTAINERFILES."
x:
  todo: 8
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/Makefile"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/3e3ea1c"
    title: "Commit 3e3ea1c"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The root dev container Containerfile was outside the drift check

The drift check for the shared Containerfile did not include the root `.devcontainer/Containerfile`, and that file had drifted.

## Problem

`make check-sync` and the workflow `sync-containerfile.yaml` matched only `src/*/.devcontainer/Containerfile`. The root `.devcontainer/Containerfile` of this repository was not checked. It differed from the shared Containerfile by one blank line.

## Context

* ADR-002 requires each managed Containerfile to be identical to `shared/Containerfile`.
* The workflow `sync-containerfile.yaml` is retired. The check now runs in the `repo-gate` job of `pr-gate.yml`.

## Acceptance criteria

- [x] The drift check includes the root `.devcontainer/Containerfile`.
- [x] One list defines the managed files for all checks.

## Resolution

* Commit: `3e3ea1c` (2026-08-23).
* The `Makefile` defines `MANAGED_CONTAINERFILES` once. It holds `.devcontainer/Containerfile` and the Containerfile of each template. At the fix it held seven files.

## Related

* [The shared Containerfile installed sudo as a workaround](/issues/the-shared-containerfile-installed-sudo-as-a-workaround--01a183461c57.md)
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
* [Architecture overview](/architecture/architecture-overview--01a1833f2e83.md)
* [ADR-002: One shared Containerfile](/decisions/adr-002-one-shared-containerfile--01a18346a548.md)
