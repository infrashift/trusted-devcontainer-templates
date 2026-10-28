---
id: "01a18346-1df0-79a7-a019-6dc4984fb374"
title: "The templates referenced trusted features by tag, not by digest"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "pinning"
  - "features"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "Feature references in the templates had no digest; commit df81891 pinned all 47 references and added a check."
x:
  todo: 9
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/pin-features.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/df81891"
    title: "Commit df81891 — Pin every template's feature references by digest"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/actions/runs/32761905789"
    title: "Run 32761905789 (2026-08-24)"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The templates referenced trusted features by tag, not by digest

The templates referenced their trusted features by tag, not by digest, so a feature could change without a change to this repository.

## Problem

The features install software into a developer's container. Their references in `devcontainer.json` had no `@sha256:` digest. The base image, `uv`, `ansible-core` and the tools in `tools.lock` were already pinned. The features were the last mutable input.

## Context

* The `bootstrap` feature was thought to be unpublished. That blocker was resolved: see the note below.
* Digest references were tested before the change. A test workspace with `bootstrap@sha256:…` and `jq@sha256:…` built.

### Note: the bootstrap blocker (resolved 2026-08-31)

`TODO.md` said that `ghcr.io/infrashift/trusted-devcontainer-features/bootstrap` was not published (`NAME_UNKNOWN`), and that this blocked #9, #11 and #12. That was not true. The package exists (id `14610693`). The pinned digest `sha256:071c527c…` carried the tags `1.4.0`, `1.4`, `1` and `latest`. Run `32761905789` built, tested, scanned and signed all five templates on 2026-08-24, which needs `bootstrap`.

## Acceptance criteria

- [x] Every feature reference in every template has a digest.
- [x] A check in `pr-gate` and `make check` fails on an unpinned reference.
- [x] One run resolves each distinct feature once and applies the same digest everywhere.

## Resolution

* Commit: `df81891` (2026-08-23).
* All 47 references in the five templates have `@sha256:…`.
* `scripts/pin-features.sh` resolves and writes the pins. `--check` asserts them. `make pin-features` re-pins and gives a diff to review.
* A second run replaces a pin. It does not add a second digest.
* Limit: the pin is one level deep. A feature's `dependsOn` still resolved by tag. See [Feature dependsOn references resolved by tag, not by digest](/issues/feature-dependson-references-resolved-by-tag-not-by-digest--01a183462027.md).

## Related

* [Feature dependsOn references resolved by tag, not by digest](/issues/feature-dependson-references-resolved-by-tag-not-by-digest--01a183462027.md)
* [Stale tool binaries cause most CVE findings after the Fedora migration](/issues/stale-tool-binaries-cause-most-cve-findings-after-the-fedora-migration--01a183461e53.md)
* [No workflow builds the templates for arm64](/issues/no-workflow-builds-the-templates-for-arm64--01a183461f0e.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
