---
id: "01a18346-20e0-792c-b001-756dc3061e19"
title: "The release failed when it attached SLSA provenance"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "signing"
  - "release"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "publish-attest.sh gave cosign a full in-toto Statement as the predicate; PR #8 passes the predicate body and reads the registry back."
x:
  todo: 23
  github:
    - 8
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/publish-attest.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/8a97e65"
    title: "Commit 8a97e65 — Hand cosign a predicate, not a whole statement"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/pull/8"
    title: "PR #8 — fix/provenance-predicate-shape"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "deprecated"
---

# The release failed when it attached SLSA provenance

The release could not complete, because `publish-attest.sh` gave cosign a full in-toto Statement where cosign expects only the predicate body.

## Problem

`build-template.sh` writes `provenance.json` as a full in-toto Statement (`_type`, `subject`, `predicateType`, `predicate`). `publish-attest.sh` passed that file to `cosign attest --type slsaprovenance1 --predicate`. The `--predicate` flag takes the predicate body only. cosign rejected the file:

```
Error: provenance predicate: required field buildDefinition missing
```

## Context

* No tag existed. `Release Templates` had zero runs, and GHCR held zero packages. The first `v*` tag would stop in the publish job.
* `build/gate` runs `build-template.sh` on each PR. No check ran `publish-attest.sh`.
* Two more defects had the same cause, because nothing read the registry back:
  1. The attested digest came from `:latest`, not from the released version. `devcontainers/action` skips a template whose version exists, so a release could attest the previous artifact and pass.
  2. Nothing verified that the attestations were in the registry.

## Acceptance criteria

- [x] `cosign attest` gets the `.predicate` body, and cosign binds the subject to the published digest.
- [x] The script resolves the digest of `:${VERSION#v}` and fails if it is missing.
- [x] The script verifies the signature and all three attestations with `release.pub`.

## Resolution

* Commit: `8a97e65`, PR #8 (2026-08-31).
* `publish-attest.sh` extracts `.predicate`. `build-template.sh` also records the image digest in `predicate.runDetails.byproducts`.
* The script reads each artifact back and verifies it with `.github/pdp/public-keys/release.pub`. It asserts `.predicate.buildDefinition` and the subject digest. A count guard rejects "attested 0 of 5".

## Related

* [The v1.0.0 release attached 13 evidence assets instead of 70](/issues/the-v1-0-0-release-attached-13-evidence-assets-instead-of-70--01a18346222c.md)
* [The attestations have no Rekor transparency-log entry](/issues/the-attestations-have-no-rekor-transparency-log-entry--01a183462140.md)
* [The docs tell users to verify releases with the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md)
