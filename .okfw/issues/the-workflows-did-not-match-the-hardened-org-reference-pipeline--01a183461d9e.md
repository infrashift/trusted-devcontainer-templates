---
id: "01a18346-1d9e-7e7c-b4db-1362fcc23fa2"
title: "The workflows did not match the hardened org reference pipeline"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "ci"
  - "pinning"
  - "signing"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "The release job installed unpinned tools next to the signing key; commit dd89603 added pins, least privilege and three signing actors."
x:
  todo: 17
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/.github/workflows"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/dd89603"
    title: "Commit dd89603 — Align the pipeline with the hardened reference"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The workflows did not match the hardened org reference pipeline

The release workflow installed unpinned tools in the job that held the signing key, and it did not match the hardened org reference pipeline.

## Problem

The `scan` job of `release.yaml` set `COSIGN_PRIVATE_KEY` and `COSIGN_PASSWORD`. In the same job it installed the devcontainer CLI from npm without a pin, syft through `anchore/sbom-action/download-syft@v0` and grype through `anchore/scan-action/download-grype@v6`. The workflows had 13 mutable references. All three jobs had `contents: write`, `packages: write` and `id-token: write`.

## Context

* The reference is `infrashift/trusted-service-containers`. Its `tools.lock` names this pattern as a remote code execution path into the most privileged step.
* This repository releases on a version tag. A squash merge makes the commit on `main` differ from the PR head that the gate checked. Thus the release runs the full chain again on the tagged commit.

## Acceptance criteria

- [x] `tools.lock` pins every tool with a sha256 for each version and architecture.
- [x] Every action is pinned to a full commit SHA with a `# vN` comment.
- [x] Each workflow starts with `permissions: {}` and grants write access only per job.
- [x] Three signing actors hold three different keys.
- [x] A linter rejects unpinned actions and workflow-level write grants.

## Resolution

* Commit: `dd89603` (2026-08-23). Linter fix: `3124751`.
* Pinning: `scripts/install-tools.sh` installs from `tools.lock` and fails by name on an unpinned pair. The two anchore actions are removed.
* Least privilege: `contents: write` exists in one job only.
* Three actors: Build-Actor signs the evidence. Review-Actor verifies it with the build public key and signs a verdict. Release-Actor verifies the verdict with the review public key before it publishes.
* Secret scanning: `.gitleaks.toml` extends the default rules with five repository rules. The PDP checks that the config is not empty and that the defaults are on.
* CVE policy: Critical blocks. High with a fix blocks. High with no fix is recorded. Waivers are in `.github/pdp/exceptions.yaml`.
* Guards: `scripts/lint-workflows.sh` and `scripts/check-no-orphan-rego.sh`. The policy suite had 38 tests at 99% coverage.
* A bug of the same type as [The OPA policy blocked every release on a clean scan](/issues/the-opa-policy-blocked-every-release-on-a-clean-scan--01a183461d4e.md): the unpinned-action `grep` returned exit code 1 when no action was unpinned. With `set -o pipefail`, this stopped the gate on a clean repository. The fix adds `|| true`.

## Analysis

The environment approval is not separation of duties at one org member. See [CODEOWNERS and the human gate assume a multi-person org](/issues/codeowners-and-the-human-gate-assume-a-multi-person-org--01a183461fbb.md).

## Related

* [The three-actor model needs GitHub settings that only a human can apply](/issues/the-three-actor-model-needs-github-settings-that-only-a-human-can-apply--01a183461f5e.md)
* [CODEOWNERS and the human gate assume a multi-person org](/issues/codeowners-and-the-human-gate-assume-a-multi-person-org--01a183461fbb.md)
* [The OPA policy blocked every release on a clean scan](/issues/the-opa-policy-blocked-every-release-on-a-clean-scan--01a183461d4e.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
