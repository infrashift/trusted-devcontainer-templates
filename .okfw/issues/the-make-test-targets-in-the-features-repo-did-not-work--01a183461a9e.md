---
id: "01a18346-1a9e-7e92-bedb-bae7640d0e1e"
title: "The make test targets in the features repo did not work"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "testing"
  - "makefile"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "Four make test targets in the features repo needed a removed test tree; the Makefile now has only working targets."
x:
  todo: 13
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

# The make test targets in the features repo did not work

All four `make test*` targets of the features repository did not work, because they needed a `test/` tree that the repository had removed.

## Problem

The targets `test`, `test-feature`, `test-scenarios` and `test-integration`, and the target `build-test-base`, needed a `test/` tree. Commit `f431c72` in the features repository replaced that tree with template-based integration tests.

## Context

* Repository: `infrashift/trusted-devcontainer-features`.
* Other defects in the same `Makefile`:
  * `.PHONY` listed a `test-all` target that did not exist.
  * Some targets used `bunx` and some used `npx`.
  * The target `test-templates` had the same name as the directory `test-templates/`.
* The README, `getting-started.md` and `contributing.md` documented the dead targets.

## Acceptance criteria

- [x] Each `make` target in the features repository runs.
- [x] The docs name only the targets that exist.

## Resolution

* Commit: `55322be` in this repository marks the item resolved (2026-08-23). The fix is in the features repository.
* The `Makefile` now has `check-contract`, `test-template`, `test-contract`, `test` (contract check plus all test templates) and `clean`.
* The dead targets, `build-test-base`, the `test-all` entry and the name conflict are gone. The docs name the new targets.

## Related

* [The features repo maintainer dev container named a missing user](/issues/the-features-repo-maintainer-dev-container-named-a-missing-user--01a183461af7.md)
* [The features repo maintainer dev container could not be built](/issues/the-features-repo-maintainer-dev-container-could-not-be-built--01a183461baf.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
