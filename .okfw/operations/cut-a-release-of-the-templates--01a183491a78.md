---
id: "01a18349-1a78-7625-a1f3-a54d45378d2f"
title: "Cut a release of the templates"
type: "runbook"
tags:
  - "runbook"
  - "release"
created: "2026-10-28T11:12:48-05:00"
timestamp: "2026-10-28T11:12:48-05:00"
description: "Set one version in every template, merge, and push a matching vX.Y.Z tag; approve the Review-Actor and Release-Actor deployments."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/release.yml"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:48-05:00"
status: "draft"
---

# Cut a release of the templates

To release the templates, set the same version in each template, merge, and push a matching `v` tag. The [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md) does the rest.

## Prerequisites

* Write access to the repository.
* You are the required reviewer of `Review-Actor` and `Release-Actor`.

## Procedure

1. Choose the next version, for example `1.0.5`.
2. Set `"version": "1.0.5"` in each `src/*/devcontainer-template.json`.

   WARNING: If one template keeps the old version, `devcontainers/action` skips it and the publish job fails.
3. Open a pull request. Merge it when `repo-gate`, `build/gate` and `review/cve-policy` pass.
4. Update your local `main` to the merge commit.
5. Run `git tag v1.0.5`.
6. Run `git push origin v1.0.5`.
7. Run `gh run watch` and select the `Release Templates` run.
8. Approve the `Review-Actor` deployment when the run stops.
9. Approve the `Release-Actor` deployment when the run stops again.
10. Make sure that the GitHub release has 14 assets for each template.
11. Verify one template. See [Verify a published template](/operations/verify-a-published-template--01a183491b30.md).

## Tag format

The tag must match `^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$`. For a pre-release tag such as `v1.0.5-rc.1`, set the template versions to `1.0.5-rc.1`.

## If the release fails

* A `FAIL` verdict stops the run before the publish job. The registry does not change.
* Fix the cause on `main`, set a new version, and push a new tag.

## Related

* [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md)
* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md)
