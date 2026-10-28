---
id: "01a18348-d986-7294-8cda-746696ee5d4a"
title: "Review Attestations workflow"
type: "component"
tags:
  - "supply-chain"
  - "workflow"
  - "review"
created: "2026-10-28T11:12:32-05:00"
timestamp: "2026-10-28T11:12:32-05:00"
description: "The review.yml workflow verifies pull request build evidence, evaluates the CVE gate, signs a verdict with the review key, and sets review/cve-policy."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/review.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/review-template.sh"
    title: "scripts/review-template.sh"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:32-05:00"
status: "draft"
---

# Review Attestations workflow

The `Review Attestations` workflow (`review.yml`) grades the build evidence of a pull request. The Review-Actor verifies the build signatures, evaluates the CVE gate and signs a verdict for each template. The workflow then sets the `review/cve-policy` status.

## Trigger

* `workflow_run` of `CI Build & Audit`, type `completed`.
* The jobs run only when that run succeeded and came from a `pull_request` event.

A `workflow_run` workflow starts only when its file is on the default branch. Thus it cannot run on the pull request that adds it.

## Jobs

| Job | Environment | What it does |
|---|---|---|
| `Resolve PR` | none | Finds the pull request number and the head commit. |
| `Load Matrix` | none | Downloads `build-matrix.json` and does the schema check again. |
| `Review <template>` | `Review-Actor` | Runs `scripts/review-template.sh` for one template. |
| `Review Summary` | none | Adds a comment to the pull request and sets `review/cve-policy`. |

## What `scripts/review-template.sh` does

1. Verifies each of the six evidence files against `.github/pdp/public-keys/build.pub`.
2. Verifies the files against `checksums.sha256`.
3. Makes sure that `evidence-manifest.json` names this commit, this build run and this template.
4. Sets `evaluated_at` and evaluates `data.tdt.pdp.decision`.
5. Writes `review-verdict.json` and signs it with the review key.

The script exits with 0 on a `FAIL` verdict. The summary job reports the `FAIL`.

## Status result

| Condition | `review/cve-policy` |
|---|---|
| All verdicts are `PASS` | `success` |
| One or more verdicts are `FAIL` | `failure` |
| The review job did not complete | `error` |

The comment shows one row for each template, with the counts of blocking, waived and recorded findings. It also shows a table of the waived CVEs, with the waiver id, the expiry and the owner.

## Signing actor

`Review-Actor`. The environment has a required reviewer. The organization has one member, so an approval is a self-approval, not separation of duties. See [Signing actors](/supply-chain/signing-actors--01a18348db6c.md).

## Output

* The artifact `review-<template>`: `review-verdict.json` and its `.sig` file.
* A comment on the pull request.
* The `review/cve-policy` status.

## Related

* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
* [Issue: the review workflow has no concurrency group](/issues/the-review-workflow-has-no-concurrency-group--01a1834621dd.md)
* [CI Build & Audit workflow](/supply-chain/ci-build-audit-workflow--01a18348d928.md)
* [Supply chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
