---
id: "01a18346-222c-753b-9d2e-5cc905fb5e60"
title: "The v1.0.0 release attached 13 evidence assets instead of 70"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "release"
  - "evidence"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:34-05:00"
description: "Every template produces files with the same names, so v1.0.0 attached one file for each name; PR #9 adds the template prefix."
x:
  todo: 27
  github:
    - 9
    - 10
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/release.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/b331c45"
    title: "Commit b331c45 — Qualify release assets by template"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/pull/9"
    title: "PR #9 — fix/release-asset-name-collision"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/pull/10"
    title: "PR #10 — release/v1.0.1"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:34-05:00"
status: "deprecated"
---

# The v1.0.0 release attached 13 evidence assets instead of 70

The `v1.0.0` release attached 13 evidence assets instead of 70, because every template produces files with the same names.

## Problem

The `github-release` job uploaded evidence with globs such as `staged/*/*/sbom.json`. A release asset name must be unique in the release. Each template produces `sbom.json`, so one file for each name was attached. `softprops/action-gh-release` then failed:

```
error updating release asset metadata for sbom.json: HttpError: Not Found
```

## Context

* `v1.0.0` published and attested all five templates correctly. Only `github-release` failed.
* Each attached file came from an unknown template. If the action had accepted the collisions, the release would show evidence for one template as evidence for all.
* The packages and attestations were not affected. All five verify with `release.pub`, with `.predicate.buildDefinition` present and the subject bound to each template digest.
* The lost files can be made again from the run artifacts.

## Acceptance criteria

- [x] Each asset name has the template as a prefix.
- [x] The job fails if the asset count differs from the staged file count.
- [x] The job fails if a glob matches no file.

## Resolution

* Commit: `b331c45`, PR #9 (2026-08-31). Release `v1.0.1` followed (PR #10).
* A step renames each file, for example `python-sbom.json`, and asserts the count.
* `fail_on_unmatched_files: true` is set.

## Related

* [The release failed when it attached SLSA provenance](/issues/the-release-failed-when-it-attached-slsa-provenance--01a1834620e0.md)
* [The docs tell users to verify releases with the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
