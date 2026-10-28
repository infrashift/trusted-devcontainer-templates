---
id: "01a18346-1af7-7018-a554-05e2e1865f55"
title: "The features repo maintainer dev container named a missing user"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "dev-user"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "The features repo maintainer dev container did not run as dev and sent 250 MB of build context; both are fixed."
x:
  todo: 14
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-features"
    title: "infrashift/trusted-devcontainer-features"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/55322be"
    title: "Commit 55322be — Mark TODO 13-15 resolved"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The features repo maintainer dev container named a missing user

The maintainer dev container of the features repository named a user that the image does not create, and it sent the full repository as build context.

## Problem

`.devcontainer/devcontainer.json` in the features repository did not declare the dev user. The image creates only the user `dev` (UID 1001). The build context was `".."`, so each build sent the full repository to the daemon.

## Context

* Repository: `infrashift/trusted-devcontainer-features`.
* The old build context was approximately 250 MB, mostly `docs/node_modules`. The Containerfile copies no files.
* The dev user rule is ADR-011 in the features repository and ADR-003 in this repository.

## Acceptance criteria

- [x] The maintainer dev container runs as `uid=1001(dev)`.
- [x] The build context holds only the necessary files.

## Resolution

* Commit: `55322be` in this repository marks the item resolved (2026-08-23). The fix is in the features repository.
* `devcontainer.json` declares `"containerUser": "dev"` and `"updateRemoteUserUID": false`.
* The build context changed from `".."` to `"."`. It is now 2 B.
* The end-to-end check came with [The features repo maintainer dev container could not be built](/issues/the-features-repo-maintainer-dev-container-could-not-be-built--01a183461baf.md): the container runs as `uid=1001(dev)`.

## Related

* [The features repo maintainer dev container could not be built](/issues/the-features-repo-maintainer-dev-container-could-not-be-built--01a183461baf.md)
* [The make test targets in the features repo did not work](/issues/the-make-test-targets-in-the-features-repo-did-not-work--01a183461a9e.md)
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
* [ADR-003: Non-root dev user](/decisions/adr-003-non-root-dev-user--01a18346a598.md)
