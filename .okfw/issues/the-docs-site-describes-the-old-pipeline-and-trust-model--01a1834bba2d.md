---
id: "01a1834b-ba2d-7129-9035-83c5e0569b16"
title: "The docs site describes the old pipeline and trust model"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "docs"
  - "ci"
created: "2026-10-28T11:15:40-05:00"
timestamp: "2026-10-28T11:15:40-05:00"
description: "Pipeline, trust, architecture and roadmap pages name workflows, policy inputs and keys that the code no longer has."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/pipeline/index.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:15:40-05:00"
status: "draft"
---

# The docs site describes the old pipeline and trust model

## Problem

The documentation site describes the pipeline and the trust model from before the three-actor rewrite. A reader who follows these pages runs workflows and policy inputs that do not exist.

## Context

Agents B and C compared the pages with the workflows and the policy on 2026-10-28.

| Page | What is wrong |
|---|---|
| `pipeline/index.md`, `pipeline/pr-validation.md` | They describe `test-pr.yaml`, `release.yaml` with Test, Scan and Publish jobs, and `sync-containerfile.yaml`. |
| `pipeline/release.md` | It describes one job with `COSIGN_PRIVATE_KEY` and `contents: write`. Three environments hold three keys. Only `github-release` has `contents: write`. |
| `trust/opa-policy.md`, `trust/index.md` | They document `cve_summary` and `violation_security_threshold`. The real entry points are `data.tdt.pdp.decision` and `repo_decision`, with the classes blocking, waived and recorded. A High finding blocks only when it has a fix and is not vendored. |
| `trust/supply-chain.md` | It shows the old base digest `1ed67eb1…` (current: `27dbbbb9…`), one "sovereign key", 4 evidence files (there are 6 and the verdict), and `sync-containerfile.yaml`. |
| `reference/architecture.md` | It shows the old workflows, 5 templates (there are 9) and only `cosign-release.pub`. It omits `features/`, `scripts/`, `tools.lock` and `exceptions.yaml`. |
| `reference/contributing.md`, `README.md` (Contributing) | They name `test-pr.yaml`. |
| `reference/roadmap.md` | It lists digest pinning of features and matrix scanning as planned. Both are done. |

The real workflows are `pr-gate.yml`, `build.yml`, `review.yml`, `release.yml`, `release-features.yml`, `test-features.yml` and `deploy-docs.yaml`. The Containerfile sync check runs in the repo gate (`make check-sync`).

## Acceptance criteria

- [ ] No page under `docs/src/content/docs/` names `test-pr.yaml`, `release.yaml` or `sync-containerfile.yaml`.
- [ ] The trust pages describe the PDP entry points and finding classes that `policies.rego` implements.
- [ ] The architecture page lists the 9 templates and the current directory layout.
- [ ] The roadmap page shows digest pinning and matrix scanning as done.

## Related

* [PR Gate workflow](/supply-chain/pr-gate-workflow--01a18348d8cc.md)
* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md)
* [Roadmap](/plans/roadmap--01a183491bf1.md)
* [The docs tell users to verify releases with the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
