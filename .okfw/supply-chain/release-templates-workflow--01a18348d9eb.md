---
id: "01a18348-d9eb-738e-87d2-f7f984ebdf84"
title: "Release Templates workflow"
type: "component"
tags:
  - "supply-chain"
  - "workflow"
  - "release"
created: "2026-10-28T11:12:32-05:00"
timestamp: "2026-10-28T11:12:32-05:00"
description: "The release.yml workflow runs on a v* tag, builds and reviews all templates again, then publishes, attests and signs them as the Release-Actor."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/release.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/verify-verdicts.sh"
    title: "scripts/verify-verdicts.sh"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/publish-attest.sh"
    title: "scripts/publish-attest.sh"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/actions/runs/40712246746"
    title: "Release run for v1.0.4 (2026-10-28)"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:32-05:00"
status: "draft"
---

# Release Templates workflow

The `Release Templates` workflow (`release.yml`) publishes all templates when a maintainer pushes a `v*` tag. It runs the full chain again on the tagged commit: build, review, publish. It does not use the verdict from the pull request, because a squash merge makes a different commit.

## Trigger

* A push of a tag that matches `v*`.
* The `Gate` job rejects a tag that does not match `^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$`.

## Jobs

| Job | Environment | What it does |
|---|---|---|
| `Gate` | none | Checks the tag. Makes the matrix of all templates. |
| `Build <template>` | `Build-Actor` | Runs `scripts/build-template.sh`. |
| `Review <template>` | `Review-Actor` | Runs `scripts/review-template.sh`. Fails on a `FAIL` verdict. |
| `Publish` | `Release-Actor` | Verifies the verdicts, publishes the templates, attaches the attestations and signs. |
| `GitHub Release` | none | Attaches the evidence files to the GitHub release. |
| `Release Summary` | none | Writes one row for each stage. |

A release always includes all templates. A partial release is not possible.

## Steps of the `Publish` job

1. `scripts/verify-verdicts.sh` verifies each verdict against `review.pub` and requires `PASS`. If one verdict fails, the job publishes nothing.
2. `devcontainers/action` publishes each template to `ghcr.io/infrashift/trusted-devcontainer-templates/<template>`. The OCI tag is the `version` in `devcontainer-template.json`.
3. `scripts/publish-attest.sh` finds the digest of `<template>:<version>`. It attaches three attestations and signs the digest two times: with the release key and keyless.
4. `scripts/publish-attest.sh` reads each artifact back and verifies it against `release.pub`.

The tag without `v` must be equal to the `version` of each template. If a template keeps an old version, `devcontainers/action` skips it, and step 3 fails.

## Signing actors

All three. `Review-Actor` and `Release-Actor` have a required reviewer, so the run stops two times for an approval. `Release-Actor` accepts only `v*` tags and the `main` branch. See [Signing actors](/supply-chain/signing-actors--01a18348db6c.md).

## Output

* One OCI artifact for each template, with two signatures and three attestations.
* A GitHub release with 14 assets for each template. See [Release evidence](/supply-chain/release-evidence-sbom-attestations-and-provenance--01a18348dca7.md).
* The artifact `release-evidence`, kept for 90 days.

## Blocks on

* A tag that is not a semver `v` tag.
* A failed build, smoke test or scan.
* A `FAIL` verdict, or a verdict that the review key did not sign.
* A template version that is not equal to the tag.
* An attestation that the job cannot read back and verify.

## Recent runs

On 2026-10-28, run `40712246746` released `v1.0.4` with nine templates and 126 assets.

## Related

* [Cut a release of the templates](/operations/cut-a-release-of-the-templates--01a183491a78.md)
* [Verify a published template](/operations/verify-a-published-template--01a183491b30.md)
* [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md)
* [Supply chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
