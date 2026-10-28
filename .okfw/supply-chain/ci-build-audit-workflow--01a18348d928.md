---
id: "01a18348-d928-73aa-9683-fa4648b9e8c1"
title: "CI Build & Audit workflow"
type: "component"
tags:
  - "supply-chain"
  - "workflow"
  - "build"
created: "2026-10-28T11:12:31-05:00"
timestamp: "2026-10-28T11:12:31-05:00"
description: "The build.yml workflow builds, tests and scans each changed template on a pull request, and signs the evidence with the build key."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/build.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/build-template.sh"
    title: "scripts/build-template.sh"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:31-05:00"
status: "draft"
---

# CI Build & Audit workflow

The `CI Build & Audit` workflow (`build.yml`) builds each affected template on a pull request. It tests and scans each template, and the Build-Actor signs the evidence. This workflow does not grade the evidence and does not publish.

## Trigger

`pull_request` to `main`, with this `paths:` filter:

* `src/**`, `shared/**`, `test/**`, `scripts/**`, `.github/pdp/**`
* `tools.lock`
* `.github/workflows/build.yml`, `review.yml` and `release.yml`

This list must agree with `BUILD_PATHS` in the [PR Gate workflow](/supply-chain/pr-gate-workflow--01a18348d8cc.md).

## Jobs

| Job | Environment | What it does |
|---|---|---|
| `Compute Matrix` | none | Selects the templates to build. Writes `build-matrix.json`. |
| `Build <template>` | `Build-Actor` | Runs `scripts/build-template.sh` for one template. |
| `build/gate` | none | Combines the matrix legs into one required check. |

## Matrix selection

* A change in `shared/`, `scripts/`, `tools.lock`, `test/`, `.github/pdp/`, `review.yml` or `release.yml` selects all templates.
* Other changes select only the changed templates in `src/`. If no template changed, the matrix holds all templates.
* A schema check rejects each template name that does not match `^[a-z0-9][a-z0-9-]{0,63}$`. This check stops shell injection through a directory name.

## What `scripts/build-template.sh` does

1. Builds the template image with `devcontainer build`.
2. Starts the container and runs `test/<template>/test.sh`.
3. Makes the SBOM with Syft and the CVE report with Grype.
4. Changes the Grype report into `scan-input.json`, the PDP input.
5. Writes the SLSA v1 provenance for the image.
6. Writes `checksums.sha256` and `evidence-manifest.json`.
7. Signs the six files with the build key (`cosign sign-blob`).

The script fails if the Grype report has no `matches` array, or if Grype reports an unknown fix state. A missing report is not a clean scan.

## Signing actor

`Build-Actor`. See [Signing actors](/supply-chain/signing-actors--01a18348db6c.md).

## Output

* The artifact `evidence-<template>`: six files and six `.sig` files.
* The artifact `build-matrix`.
* The `build/gate` check.

## Blocks on

A failed build, smoke test or scan in one or more legs. This workflow does not block on findings. The [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md) grades them.

Do not make one matrix leg a required check. Its name changes with the matrix. `build/gate` is the one required context.

## Related

* [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md)
* [Release evidence: SBOM, attestations and provenance](/supply-chain/release-evidence-sbom-attestations-and-provenance--01a18348dca7.md)
* [Issue: a fork PR fails the build check](/issues/a-fork-pr-fails-the-build-check-instead-of-skipping-it--01a18346218e.md)
* [Build and test one template locally](/operations/build-and-test-one-template-locally--01a183491958.md)
* [Supply chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
