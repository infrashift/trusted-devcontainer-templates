---
title: Architecture
description: System architecture of the trusted dev container templates project.
---

## Layer Model

```
┌─────────────────────────────────────────┐
│           Published OCI Artifact        │  ← Signed + attested
├─────────────────────────────────────────┤
│         Dev Container Features          │  ← From trusted-devcontainer-features
│   (language runtimes, tools, scanners)  │
├─────────────────────────────────────────┤
│         Shared Containerfile            │  ← Non-root dev user, uv bootstrap
├─────────────────────────────────────────┤
│      UBI9 Base Image (digest-pinned)    │  ← Enterprise RHEL 9 foundation
└─────────────────────────────────────────┘
```

Each layer builds on the previous one. The base image is immutable (digest-pinned). The Containerfile adds the user and bootstrap tooling. Features add language-specific tools. The published artifact captures the complete stack.

## Directory Layout

```
├── .github/
│   ├── pdp/
│   │   ├── policies.rego              # OPA Rego policy
│   │   └── public-keys/
│   │       └── cosign-release.pub     # Cosign public key
│   └── workflows/
│       ├── release.yaml               # Tag-triggered release pipeline
│       ├── test-pr.yaml               # PR validation pipeline
│       └── sync-containerfile.yaml    # Containerfile drift detection
├── shared/
│   └── Containerfile                  # Canonical Containerfile
├── src/
│   ├── ansible-cue/
│   │   ├── devcontainer-template.json # Template metadata
│   │   └── .devcontainer/
│   │       ├── devcontainer.json      # Features + config
│   │       └── Containerfile          # Copy of shared/Containerfile
│   ├── dotnet-node/
│   ├── go-cue/
│   ├── java/
│   └── python/
├── test/
│   ├── ansible-cue/
│   │   └── test.sh
│   ├── dotnet-node/
│   ├── go-cue/
│   ├── java/
│   └── python/
├── docs/                              # This documentation site
└── Makefile                           # Developer workflow targets
```

## Template Structure

Each template in `src/<template>/` contains:

| File | Purpose |
|---|---|
| `devcontainer-template.json` | OCI metadata: id, name, version, platforms, keywords |
| `.devcontainer/devcontainer.json` | Feature declarations, container user, build config |
| `.devcontainer/Containerfile` | Exact copy of `shared/Containerfile` |

## Test Framework

Each template has a corresponding test script at `test/<template>/test.sh`. Tests run inside the built devcontainer using `devcontainer exec`.

Tests validate:
- Primary language runtimes are installed and functional
- CLI tools are available on the PATH
- Security scanners (grype, syft) are operational
- The `dev` user is active with correct UID/GID

## Evidence Artifacts

The release pipeline produces per-template evidence:

```
evidence/
└── <template>/
    ├── sbom.json              # SPDX SBOM
    ├── sbom.json.sig          # Cosign signature
    ├── cve-report.json        # Grype CVE report
    ├── cve-report.json.sig    # Cosign signature
    ├── provenance.json        # SLSA v1 provenance
    ├── provenance.json.sig    # Cosign signature
    ├── checksums.sha256       # SHA256 of all artifacts
    └── checksums.sha256.sig   # Cosign signature
```
