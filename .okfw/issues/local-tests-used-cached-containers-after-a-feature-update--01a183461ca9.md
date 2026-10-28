---
id: "01a18346-1ca9-7008-bffe-fcb6e86f4029"
title: "Local tests used cached containers after a feature update"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "testing"
  - "makefile"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "Local test runs used old containers after a feature update; make clean-containers removes them."
x:
  todo: 7
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/Makefile"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/b4ae498"
    title: "Commit b4ae498"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# Local tests used cached containers after a feature update

Local test runs used cached containers and images, so a feature update did not show in the next `make test` run.

## Problem

After a feature update, the devcontainer CLI used the old local containers and image cache. The tests ran against the old feature versions.

## Context

* This affects only local runs. CI starts from a clean runner.

## Acceptance criteria

- [x] One `make` target removes the dev container containers and caches.

## Resolution

* Commit: `b4ae498` (2026-02-18).
* Change: the `Makefile` has the target `make clean-containers`.
* Procedure: run `make clean-containers` before `make test` after a feature update.

## Related

* [The Makefile test path was outside the dev container mount](/issues/the-makefile-test-path-was-outside-the-dev-container-mount--01a183461c03.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md)
* [Build and test one template locally](/operations/build-and-test-one-template-locally--01a183491958.md)
