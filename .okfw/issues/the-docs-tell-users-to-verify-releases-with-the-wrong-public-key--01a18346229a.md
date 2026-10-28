---
id: "01a18346-229a-793c-9139-129cac49a42c"
title: "The docs tell users to verify releases with the wrong public key"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "signing"
  - "docs"
created: "2026-10-28T11:09:34-05:00"
timestamp: "2026-10-28T11:09:34-05:00"
description: "README and the docs site cite cosign-release.pub, but the Release-Actor signs with the key whose public half is release.pub."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/.github/pdp/public-keys"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/publish-attest.sh"
    title: "scripts/publish-attest.sh"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/trust/verification.md"
    title: "verification.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/README.md"
    title: "README.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:34-05:00"
status: "draft"
---

# The docs tell users to verify releases with the wrong public key

The README and the docs site tell users to verify releases with `cosign-release.pub`, but the Release-Actor signs with the key whose public half is `release.pub`.

## Problem

A user who follows the docs runs `cosign verify --key cosign-release.pub`. `cosign-release.pub` is a different key from `release.pub`, so the verification of a current release fails. The docs never name `release.pub`.

## Context

### Keys in `.github/pdp/public-keys/` (verified 2026-10-28)

| File | Added | sha256 of the file |
|---|---|---|
| `build.pub` | `8d8d7d3` (2026-08-23) | `212720ce…` |
| `review.pub` | `8d8d7d3` (2026-08-23) | `1f2c1752…` |
| `release.pub` | `8d8d7d3` (2026-08-23) | `3288ad2a…` |
| `cosign-release.pub` | `cef9f89` (2026-02-17), the old single-key pipeline | `41e4f612…` |

### What signs a release

* The `publish` job of `release.yml` runs in `environment: Release-Actor` and calls `scripts/publish-attest.sh` with that environment's `COSIGN_PRIVATE_KEY`.
* `publish-attest.sh` sets `RELEASE_PUB=".github/pdp/public-keys/release.pub"`. It verifies the signature and the `spdxjson`, `vuln` and `slsaprovenance1` attestations with that key. The `v1.0.0` artifacts verified with `release.pub` (see [The v1.0.0 release attached 13 evidence assets instead of 70](/issues/the-v1-0-0-release-attached-13-evidence-assets-instead-of-70--01a18346222c.md)).
* The evidence blobs (`<template>-sbom.json.sig` and others) are signed in `build-template.sh` with the Build-Actor key. `review-template.sh` verifies them with `build.pub`. The `review-verdict.json.sig` blob is signed with the Review-Actor key.

### Files that cite `cosign-release.pub`

| File | Lines |
|---|---|
| `README.md` | 63, 80 |
| `docs/src/content/docs/getting-started.md` | 43–47 |
| `docs/src/content/docs/trust/verification.md` | 11–12, 20, 27, 35, 43, 76 |
| `docs/src/content/docs/decisions/adr-005-dual-signing.md` | 29 |
| `docs/src/content/docs/reference/architecture.md` | 35 (the tree shows only this key) |
| `docs/src/components/VerifyCommand.astro` | 15, 22, 29 |

* `verification.md` line 76 runs `verify-blob` on `sbom.json` with `cosign-release.pub`. The correct key for evidence blobs is `build.pub`. Since `b331c45` the asset name is `<template>-sbom.json`.
* Only `SETUP-ENVIRONMENTS.md` (line 96) names `release.pub`.

## Live check (2026-10-28)

Agent C ran cosign v3.0.4 against the published `python:1.0.4` template.

| Check | Key | Result |
|---|---|---|
| Template signature and the 3 attestations | `release.pub` | Pass |
| Template signature | `cosign-release.pub` | Fail |
| `python-sbom.json.sig` | `build.pub` | Pass |
| `python-review-verdict.json.sig` | `review.pub` | Pass |

Other errors on the same pages:

* ADR-005 also cites `cosign-release.pub`.
* `trust/verification.md` and `getting-started.md` verify the `:latest` tag. `publish-attest.sh` attests `:<version>`.
* The same pages list 5 templates. There are 9.
* The evidence assets have a `<template>-` prefix, for example `python-sbom.json`.

## Acceptance criteria

- [ ] All files in the table above tell users to verify artifacts and attestations with `release.pub`.
- [ ] `verification.md` tells users to verify evidence blobs with `build.pub` and verdicts with `review.pub`, with the current asset names.
- [ ] `cosign-release.pub` is removed, or a comment marks it as retired.
- [ ] A check fails when a doc cites a key that the release does not use.

## Related

* [The release failed when it attached SLSA provenance](/issues/the-release-failed-when-it-attached-slsa-provenance--01a1834620e0.md)
* [The v1.0.0 release attached 13 evidence assets instead of 70](/issues/the-v1-0-0-release-attached-13-evidence-assets-instead-of-70--01a18346222c.md)
* [The attestations have no Rekor transparency-log entry](/issues/the-attestations-have-no-rekor-transparency-log-entry--01a183462140.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md)
* [ADR-005: Dual signing of templates](/decisions/adr-005-dual-signing-of-templates--01a18346a62e.md)
* [Verify a published template](/operations/verify-a-published-template--01a183491b30.md)
* [The docs site describes the old pipeline and trust model](/issues/the-docs-site-describes-the-old-pipeline-and-trust-model--01a1834bba2d.md)
