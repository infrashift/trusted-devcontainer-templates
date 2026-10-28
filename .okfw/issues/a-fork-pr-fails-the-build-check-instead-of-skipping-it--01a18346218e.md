---
id: "01a18346-218e-78b9-bc0e-e0364dca8eb9"
title: "A fork PR fails the build check instead of skipping it"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "ci"
  - "forks"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "The build-and-audit job in build.yml has no fork guard, so a fork PR gets no signing secret and fails build/gate."
x:
  todo: 25
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/build.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "draft"
---

# A fork PR fails the build check instead of skipping it

The `build-and-audit` job in `build.yml` has no fork guard, so a fork PR fails the required check instead of skipping it.

## Problem

A fork PR reaches `environment: Build-Actor`. GitHub does not give environment secrets to a fork, so `build-template.sh` stops at `: "${COSIGN_PRIVATE_KEY:?}"`. The required check `build/gate` becomes red.

## Context

* `pr-gate.yml` skips its status job for forks with `github.event.pull_request.head.repo.full_name == github.repository`.
* Verified on 2026-10-28: the `build-and-audit` job in `build.yml` has only `if: needs.matrix-setup.outputs.build_matrix != '[]'`.
* No PR came from a fork until now. The failure looks like a broken build, not a policy decision.

## Acceptance criteria

- [ ] `build-and-audit` skips a fork PR with the same condition as `pr-gate.yml`.
- [ ] A fork PR shows a clear skip or a clear policy message, not a red build.

## Related

* [The review workflow has no concurrency group](/issues/the-review-workflow-has-no-concurrency-group--01a1834621dd.md)
* [The workflows did not match the hardened org reference pipeline](/issues/the-workflows-did-not-match-the-hardened-org-reference-pipeline--01a183461d9e.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [CI Build & Audit workflow](/supply-chain/ci-build-audit-workflow--01a18348d928.md)
