---
id: "01a18348-db6c-77ad-930b-5f6b690c458e"
title: "Signing actors"
type: "component"
tags:
  - "supply-chain"
  - "signing"
  - "actors"
created: "2026-10-28T11:12:32-05:00"
timestamp: "2026-10-28T11:12:32-05:00"
description: "Three GitHub environments, Build-Actor, Review-Actor and Release-Actor, hold different cosign keys, so no one job can build, grade and publish."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/.github/pdp/public-keys"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/SETUP-ENVIRONMENTS.md"
    title: "SETUP-ENVIRONMENTS.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:32-05:00"
status: "draft"
---

# Signing actors

The pipeline uses three signing actors. Each actor is a GitHub environment that holds a different cosign private key. Thus no one job can build a template, grade it and publish it.

## The actors

| Signing actor | Public key | Signs | Used by |
|---|---|---|---|
| `Build-Actor` | `build.pub` | The six evidence files of each template | `build.yml`, the build job of `release.yml`, the stage job of `release-features.yml` (no signing) |
| `Review-Actor` | `review.pub` | `review-verdict.json`, `staging-verdict.json` | `review.yml`, the review jobs of `release.yml` and `release-features.yml` |
| `Release-Actor` | `release.pub` | The published templates and their three attestations, the promoted features | The publish job of `release.yml`, the promote job of `release-features.yml` |

The public keys are in `.github/pdp/public-keys/`. A maintainer committed them on 2026-08-23 (`8d8d7d3`).

## Keys and secrets

* `cosign generate-key-pair` makes each key. The key type is ECDSA P-256.
* Each environment holds two secrets: `COSIGN_PRIVATE_KEY` and `COSIGN_PASSWORD`.
* The pipeline pins cosign v2.6.1 in `tools.lock`.

## Chain of verification

1. The Review-Actor verifies the build evidence against `build.pub`.
2. The Release-Actor verifies each verdict against `review.pub`.
3. The Release-Actor verifies its own published output against `release.pub`.

## Environment protection

| Environment | Required reviewer | Allowed refs |
|---|---|---|
| `Build-Actor` | none | all |
| `Review-Actor` | `ryancraig` | all |
| `Release-Actor` | `ryancraig` | tag `v*`, branch `main` |

`Build-Actor` and `Review-Actor` accept all refs, because they run on pull request branches. Neither key can push to a registry.

## What the separation gives

* A compromised build job cannot make a passing verdict.
* A compromised build job cannot push a signed release.

## What the separation does not give

The organization has one member. An approval on `Review-Actor` or `Release-Actor` is a self-approval. It is a stop before a release, not separation of duties between two persons.

## The fourth key file

`.github/pdp/public-keys/cosign-release.pub` came from commit `cef9f89` (2026-02-17), before the three-actor model. No workflow or script reads it. On 2026-10-28 it did not verify `python:1.0.4`. Use `release.pub`. See the [issue about the wrong key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md).

## Related

* [Set up the GitHub environments and signing keys](/operations/set-up-the-github-environments-and-signing-keys--01a183491902.md)
* [Verify a published template](/operations/verify-a-published-template--01a183491b30.md)
* [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md)
* [ADR-005: Dual signing of templates](/decisions/adr-005-dual-signing-of-templates--01a18346a62e.md)
* [Issue: the three-actor model needs GitHub settings](/issues/the-three-actor-model-needs-github-settings-that-only-a-human-can-apply--01a183461f5e.md)
* [Issue: the docs name the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md)
