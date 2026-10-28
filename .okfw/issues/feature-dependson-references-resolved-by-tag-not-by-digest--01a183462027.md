---
id: "01a18346-2027-70a0-ad6c-c03d427f5d3c"
title: "Feature dependsOn references resolved by tag, not by digest"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "pinning"
  - "bootstrap"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "Each feature's dependsOn named bootstrap without a digest; a two-phase publish in the features repo now pins it."
x:
  todo: 20
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-features"
    title: "infrashift/trusted-devcontainer-features"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/71134df"
    title: "Commit 71134df"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/9beab87"
    title: "Commit 9beab87 — Mark TODO 20 resolved"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "deprecated"
---

# Feature dependsOn references resolved by tag, not by digest

The `dependsOn` references between trusted features resolved by tag, so a digest-pinned template still pulled `bootstrap:latest`.

## Problem

[The templates referenced trusted features by tag, not by digest](/issues/the-templates-referenced-trusted-features-by-tag-not-by-digest--01a183461df0.md) pinned the references that the templates declare. Each feature's `dependsOn` named `ghcr.io/infrashift/trusted-devcontainer-features/bootstrap` with no digest. The devcontainer CLI resolved it to `:latest` at build time. A template pinned to `python@sha256:f041…` still pulled the current `bootstrap:latest`.

## Context

* The fix is in the features repository: `scripts/rewrite-feature-refs.sh` already rewrote `./bootstrap` to a registry reference.
* The publish order is important. `bootstrap` must be published before another feature can reference its digest.

## Acceptance criteria

- [x] Each published `dependsOn` reference has a digest.
- [x] A check reads the metadata back from the registry and requires a digest.

## Resolution

* Commits in this repository: `71134df` (re-pin, 2026-08-24) and `9beab87` (marks it resolved, 2026-08-24).
* The graph has two levels: every feature depends on `bootstrap`, and `bootstrap` depends on nothing. A two-phase publish is sufficient.
* Only `dependsOn` is pinned. `installsAfter` is an ordering hint that matches by id, so a digest there could fail to match.
* Cost: a `bootstrap` fix reaches a dependent only when that dependent publishes again. `scripts/check-bootstrap-fanout.sh` stops a `bootstrap`-only release.
* Two errors occurred during the change:
  1. The first release after the change failed at verification. The metadata changed, but no version changed, so nothing was published again. The fix was 19 version bumps.
  2. `verify-published-refs.sh` checked only for relative references. It now requires a digest.

## Related

* [The templates referenced trusted features by tag, not by digest](/issues/the-templates-referenced-trusted-features-by-tag-not-by-digest--01a183461df0.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
