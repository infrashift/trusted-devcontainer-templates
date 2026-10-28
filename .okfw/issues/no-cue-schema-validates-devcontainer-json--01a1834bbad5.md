---
id: "01a1834b-bad5-79bb-abf7-34e044408007"
title: "No CUE schema validates devcontainer.json"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "cue"
  - "drift"
created: "2026-10-28T11:15:40-05:00"
timestamp: "2026-10-28T11:15:40-05:00"
description: "CLAUDE.md requires CUE validation of devcontainer.json, but the repository has no CUE file and no check."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/CLAUDE.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:15:40-05:00"
status: "draft"
---

# No CUE schema validates devcontainer.json

## Problem

No CUE schema validates the `devcontainer.json` files. `CLAUDE.md` requires "CUE First" validation to prevent drift between the templates.

## Context

The repository has no `*.cue` file and no `Makefile` target for this check. The templates now number 9, so drift between them is more likely. The architecture overview also listed "CUE validation" as a component; that text was removed because the component does not exist.

## Acceptance criteria

- [ ] A CUE schema defines the shared shape of `devcontainer.json`: `remoteUser`, pinned feature references, labels.
- [ ] A `make` target runs `cue vet` on all 9 templates, and the PR gate runs it.
- [ ] Or: `CLAUDE.md` removes the requirement, with the reason.

## Related

* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
