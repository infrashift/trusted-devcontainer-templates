---
title: Pipeline Overview
description: How the release and PR pipelines work for trusted dev container templates.
---

The project uses two GitHub Actions pipelines that form a complete CI/CD system.

## Pipeline Architecture

```
PR Push                          Tag Push (v*)
  │                                  │
  ▼                                  ▼
┌──────────────┐              ┌──────────────┐
│  test-pr.yaml │              │ release.yaml  │
├──────────────┤              ├──────────────┤
│ 1. Detect    │              │ 1. Test       │
│    changes   │              │    (all)      │
│ 2. Test      │              │ 2. Scan       │
│    (changed) │              │    + Sign     │
│ 3. CVE scan  │              │    + Policy   │
│    (info)    │              │ 3. Publish    │
└──────────────┘              │    + Attest   │
                              │    + Release  │
                              └──────────────┘
```

## PR Pipeline (`test-pr.yaml`)

Triggered on PRs and pushes to `main` that touch `src/`, `shared/`, or `test/`.

- **Smart change detection** — only tests templates that changed in the PR
- **Matrix testing** — changed templates run in parallel
- **Informational CVE scan** — reports vulnerabilities without blocking

See [PR Validation](/trusted-devcontainer-templates/pipeline/pr-validation/) for details.

## Release Pipeline (`release.yaml`)

Triggered on version tags (`v*`).

Three sequential jobs with strict dependencies:

1. **Test** — functional validation of all templates
2. **Scan** — SBOM generation, CVE scanning, OPA policy enforcement, SLSA provenance
3. **Publish** — OCI publish, attestation attachment, dual signing, GitHub Release

See [Release Workflow](/trusted-devcontainer-templates/pipeline/release/) for details.

## Containerfile Sync (`sync-containerfile.yaml`)

A separate workflow that verifies all template Containerfiles match the canonical `shared/Containerfile`.

See [Containerfile Sync](/trusted-devcontainer-templates/pipeline/containerfile-sync/) for details.
