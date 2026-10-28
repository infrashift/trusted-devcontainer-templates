---
id: "01a18346-1baf-71b9-a31d-31cf54712394"
title: "The features repo maintainer dev container could not be built"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "dev-container"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "The features repo maintainer dev container used parent-folder feature paths; initializeCommand now stages the features before the CLI resolves them."
x:
  todo: 16
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-features"
    title: "infrashift/trusted-devcontainer-features"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/74d224b"
    title: "Commit 74d224b — Mark TODO 16 resolved"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The features repo maintainer dev container could not be built

The maintainer dev container of the features repository could not be built, because it referenced its features by a path outside its folder.

## Problem

`.devcontainer/devcontainer.json` referenced features as `"../src/<id>"`. The devcontainer CLI rejects this path: a local feature must be a child of the folder that holds `devcontainer.json`. The environment never started.

## Context

* Repository: `infrashift/trusted-devcontainer-features`.
* Two options were rejected:
  * A reference to the published features pins the environment to released versions, not to the working tree. Also, `bootstrap` was not published at that time.
  * A manual prepare step before each start is easy to forget.

## Acceptance criteria

- [x] The maintainer dev container builds and runs as `dev`.
- [x] All features apply with no failure.

## Resolution

* Commit: `74d224b` in this repository marks the item resolved (2026-08-23). The fix is in the features repository.
* `scripts/prepare-devcontainer.sh` copies `src/*` into `.devcontainer/`. `devcontainer.json` runs it through `initializeCommand`, which the CLI runs on the host before it resolves features.
* A test workspace with a feature that existed only after the copy confirmed this order.
* Git ignores the staged copies, except the tracked `SKELETON-feature`. The script removes old staged copies first.
* Result: the environment builds, reports `remoteUser: dev` and completes 18 feature plays with no failure.

## Related

* [The features repo maintainer dev container named a missing user](/issues/the-features-repo-maintainer-dev-container-named-a-missing-user--01a183461af7.md)
* [The make test targets in the features repo did not work](/issues/the-make-test-targets-in-the-features-repo-did-not-work--01a183461a9e.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
