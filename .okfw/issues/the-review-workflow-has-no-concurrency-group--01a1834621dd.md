---
id: "01a18346-21dd-7523-8bc8-f723263ffb07"
title: "The review workflow has no concurrency group"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "ci"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "review.yml has no concurrency group, so two reviews can race and leave an old review/cve-policy verdict visible."
x:
  todo: 26
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/review.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "draft"
---

# The review workflow has no concurrency group

The `review.yml` workflow has no concurrency group, so two reviews can race to write the `review/cve-policy` status.

## Problem

`review.yml` writes the `review/cve-policy` commit status and posts a PR comment. Two quick pushes start two `workflow_run` reviews. The two reviews write the same status on different SHAs, and the older verdict can be the one that shows.

## Context

* Verified on 2026-10-28: `build.yml`, `pr-gate.yml`, `release.yml`, `deploy-docs.yaml`, `release-features.yml` and `test-features.yml` declare `concurrency`. `review.yml` does not.
* Proposed value: `concurrency: { group: review-${{ github.event.workflow_run.head_sha }}, cancel-in-progress: true }`.

## Acceptance criteria

- [ ] `review.yml` declares a concurrency group with `cancel-in-progress: true`.

## Related

* [A fork PR fails the build check instead of skipping it](/issues/a-fork-pr-fails-the-build-check-instead-of-skipping-it--01a18346218e.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md)
