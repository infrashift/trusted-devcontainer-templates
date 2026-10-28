---
id: "01a18346-a548-712b-9c5a-9821a651c0a5"
title: "ADR-002: One shared Containerfile"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "containerfile"
  - "drift"
created: "2026-10-28T11:10:07-05:00"
timestamp: "2026-10-28T11:10:07-05:00"
description: "ADR-002 makes shared/Containerfile the one source; each template copy must be byte-identical, and make check-sync enforces it."
x:
  adr: 2
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-002-shared-containerfile.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:07-05:00"
status: "draft"
---

# ADR-002: One shared Containerfile

ADR-002 makes `shared/Containerfile` the one source for the Containerfile of each template. Each managed copy must be byte-identical to it.

**Status:** Accepted, amended.

## Decision

Keep one Containerfile at `shared/Containerfile`. Check all copies in CI and with `make check-sync`, and copy changes with `make sync-containerfiles`. The amendment puts the list of copies in one place, `MANAGED_CONTAINERFILES` in the `Makefile`, and adds the repository's own `.devcontainer/Containerfile` to it.

## Reason

* Separate Containerfiles drift: different base images, users or bootstrap steps.
* One file is easier to audit than one file for each template.
* The devcontainer spec has no Containerfile inheritance, and template publishing breaks symlinks.

## Consequences

* A template cannot add its own system package. A tool must come from a feature.
* A change to the base touches the shared file and every copy.
* CI finds drift on each pull request.

## Analysis

* The ADR names a workflow `sync-containerfile.yaml`. That workflow does not exist. `pr-gate.yml` runs `make check-sync`.
* The amendment says "seven" files. The `Makefile` now manages ten copies: nine templates and `.devcontainer/Containerfile`.

## Related

* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md) — how the rule works now.
* [ADR-007: Fedora 43 minimal base image](/decisions/adr-007-fedora-43-minimal-base-image--01a18346a6c7.md) — the base image in the shared file.
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md) — rejects a template Containerfile for the editor tools because of this ADR.
* [The root dev container Containerfile was outside the drift check](/issues/the-root-dev-container-containerfile-was-outside-the-drift-check--01a183461cfa.md) — the reason for the amendment.
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
* [Three ADRs no longer match the code](/issues/three-adrs-no-longer-match-the-code--01a1834bba80.md)
