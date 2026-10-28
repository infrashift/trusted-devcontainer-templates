---
id: "01a18349-1acc-7d71-ad05-55de1e2db2dc"
title: "Release the repo-local features"
type: "runbook"
tags:
  - "runbook"
  - "release"
  - "features"
created: "2026-10-28T11:12:48-05:00"
timestamp: "2026-10-28T11:12:48-05:00"
description: "Bump the feature version and merge to main; release-features.yml stages, reviews and promotes it; then pin the new digest in a second pull request."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/release-features.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/features/README.md"
    title: "features/README.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:48-05:00"
status: "draft"
---

# Release the repo-local features

To release a repo-local feature, bump its `version` and merge the change to `main`. The [Release Features workflow](/supply-chain/release-features-workflow--01a18348da61.md) stages, reviews and promotes it. Then pin the new digest in a second pull request.

## Procedure

1. Change the feature in `features/src/<id>/`.
2. Increase `version` in `features/src/<id>/devcontainer-feature.json`.

   WARNING: If the source changes and the version does not, the `repo-gate` check fails.
3. Run `make check-features`.
4. Run `make test-feature-template`.
5. Open a pull request. Merge it when `repo-gate` and `test-features/gate` pass.
6. Run `gh run watch` and select the `Release Features` run.
7. Approve the `Review-Actor` deployment and then the `Release-Actor` deployment.
8. Read the digests in the artifact `features-release-manifest`.
9. If the feature is new, make its production package public in the GHCR package settings. Keep the staging package private.
10. Create a new branch and run `make pin-features`.
11. Open a pull request with the new pins. See [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md).

## Verify a promoted feature

```sh
cosign verify --key .github/pdp/public-keys/release.pub \
  ghcr.io/infrashift/trusted-devcontainer-templates/features/<id>:<version>
```

## Example

On 2026-10-09, run `37990798900` released `lazyvim` 1.2.3. Commit `5cda33e` then pinned it in the four neovim templates.

## Related

* [Release Features workflow](/supply-chain/release-features-workflow--01a18348da61.md)
* [Test Features workflow](/supply-chain/test-features-workflow--01a18348dabd.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md)
