---
id: "01a18348-dca7-7d82-bb8b-360f868bd155"
title: "Release evidence: SBOM, attestations and provenance"
type: "component"
tags:
  - "supply-chain"
  - "sbom"
  - "attestation"
  - "slsa"
created: "2026-10-28T11:12:32-05:00"
timestamp: "2026-10-28T11:12:32-05:00"
description: "Each released template has SBOM, CVE and SLSA provenance attestations signed by the release key, and signed evidence files on the GitHub release."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/publish-attest.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/build-template.sh"
    title: "scripts/build-template.sh"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/releases/tag/v1.0.4"
    title: "GitHub release v1.0.4"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:32-05:00"
status: "draft"
---

# Release evidence: SBOM, attestations and provenance

Each released template has three cosign attestations on its OCI artifact: an SPDX SBOM, a Grype CVE report and SLSA v1 provenance. The GitHub release also holds the signed evidence files of each template.

## On the OCI artifact

The publish job of the [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md) attaches these to the digest of `<template>:<version>`:

| Item | cosign type | Signed by |
|---|---|---|
| SBOM | `spdxjson` | release key |
| CVE report | `vuln` | release key |
| SLSA v1 provenance | `slsaprovenance1` | release key |
| Signature | none | release key |
| Signature | none | keyless (Fulcio and Rekor) |

The keyless certificate identity is `https://github.com/infrashift/trusted-devcontainer-templates/.github/workflows/release.yml@refs/tags/<tag>`. The issuer is `https://token.actions.githubusercontent.com`.

## On the GitHub release

Each template has 14 assets, named `<template>-<file>`:

| File | Content | Signature key |
|---|---|---|
| `sbom.json` | SPDX JSON from Syft | build |
| `cve-report.json` | Grype JSON | build |
| `scan-input.json` | The PDP input | build |
| `provenance.json` | An in-toto Statement with SLSA v1 provenance | build |
| `checksums.sha256` | The SHA-256 of the first four files | build |
| `evidence-manifest.json` | Template, commit, build run and checksums | build |
| `review-verdict.json` | The PDP verdict | review |

Each file has a `.sig` file next to it.

## Provenance

`scripts/build-template.sh` writes the provenance itself. It does not use a SLSA generator. The subject of `provenance.json` is the local image. At publish time, `scripts/publish-attest.sh` gives cosign only the predicate, and cosign binds it to the published digest. The predicate keeps the image digest in `runDetails.byproducts`.

## Format

cosign v2.6.1 writes the old `sha256-<digest>.att` layout. cosign v3 writes OCI referrers. The sibling repositories read the v2 layout, so the organization must change all repositories at the same time.

## Transparency log

On 2026-10-28, `cosign verify-attestation` for `python:1.0.4` reported that the attestation claims exist in the transparency log. This result does not agree with the [issue about Rekor entries](/issues/the-attestations-have-no-rekor-transparency-log-entry--01a183462140.md).

## Related

* [Verify a published template](/operations/verify-a-published-template--01a183491b30.md)
* [ADR-005: Dual signing of templates](/decisions/adr-005-dual-signing-of-templates--01a18346a62e.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [CI Build & Audit workflow](/supply-chain/ci-build-audit-workflow--01a18348d928.md)
* [Supply chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
