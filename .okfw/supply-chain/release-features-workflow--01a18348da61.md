---
id: "01a18348-da61-76da-ac57-5d0730bfb755"
title: "Release Features workflow"
type: "component"
tags:
  - "supply-chain"
  - "workflow"
  - "features"
  - "release"
created: "2026-10-28T11:12:32-05:00"
timestamp: "2026-10-28T11:12:32-05:00"
description: "The release-features.yml workflow publishes the repo-local features on a push to main: stage, review, then promote by digest."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/release-features.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/actions/runs/37990798900"
    title: "Feature release run (2026-10-09)"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:32-05:00"
status: "draft"
---

# Release Features workflow

The `Release Features` workflow (`release-features.yml`) publishes the repo-local features in `features/src/` on a push to `main`. It stages the features, reviews them, and then promotes the reviewed digests to production.

## Trigger

A push to `main` that changes one of these paths:

* `features/src/**`
* `features/scripts/**`
* `.github/workflows/release-features.yml`

The trigger is a push to `main`, not a tag. A template pins a feature by digest, and the digest exists only after the feature is published. Thus a feature release must occur before the template change that pins it.

## Namespaces

| Namespace | Visibility |
|---|---|
| `ghcr.io/infrashift/trusted-devcontainer-templates/features/<id>` (production) | public |
| `ghcr.io/infrashift/trusted-devcontainer-templates-staging/features/<id>` (staging) | private |

## Jobs

| Job | Environment | What it does |
|---|---|---|
| `contract` | none | Checks the role contract and the bootstrap pin. Makes sure that `review.pub` exists. Makes the feature list. |
| `Stage features` | `Build-Actor` | Rewrites references to production, seeds unchanged versions from production, and publishes to staging. Uses no signing key. |
| `Review staged features` | `Review-Actor` | Runs `features/scripts/review-staged-features.sh`. Signs `staging-verdict.json`. |
| `Promote features` | `Release-Actor` | Signs the staged digests (keyed and keyless), then copies them to production with `features/scripts/promote-features.sh`. |
| `Release Summary` | none | Writes one row for each stage. |

The promote job signs before it copies. Thus production never holds an unsigned digest.

## Versions

The `version` in `devcontainer-feature.json` controls the publish. A feature whose version is already in production is copied from production into staging, so its digest does not change. If the source changed but the version did not, the release fails.

## Signing actors

All three. `Release-Actor` must accept the `main` branch (step 4c in `SETUP-ENVIRONMENTS.md`). See [Signing actors](/supply-chain/signing-actors--01a18348db6c.md).

## Output

* The promoted features in the production namespace.
* The artifacts `features-verdict` and `features-release-manifest`.

## Recent runs

On 2026-10-09, run `37990798900` released `lazyvim` 1.2.3.

## Related

* [Release the repo-local features](/operations/release-the-repo-local-features--01a183491acc.md)
* [Test Features workflow](/supply-chain/test-features-workflow--01a18348dabd.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md)
