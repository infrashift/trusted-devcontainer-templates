---
title: "ADR-001: UBI9 Base Image"
description: Decision to use Red Hat Universal Base Image 9 as the foundation for all templates.
---

**Status:** Superseded by [ADR-007](/trusted-devcontainer-templates/decisions/adr-007-fedora43-base-image/)

## Context

Dev container templates need a base image that provides:
- A stable, well-maintained foundation
- Broad enterprise acceptance
- Regular security patches
- Multi-architecture support (amd64, arm64)
- Compatibility with RHEL-based production environments

## Decision

Use Red Hat Universal Base Image 9 (UBI9) as the base image for all templates, pinned by SHA256 digest.

The image is sourced from InfraShift's trusted base images registry:

```dockerfile
FROM ghcr.io/infrashift/trusted-base-images/trusted/ubi9-standard@sha256:f938c070dc5906b9915a0c056e85a002a00900af17a08bfa4783fb80a45ad889
```

## Consequences

**Positive:**
- Enterprise-grade base with Red Hat's patch cadence
- Free to use and redistribute (UBI license)
- Consistent with production RHEL environments
- Digest pinning ensures reproducibility
- Multi-arch support for amd64 and arm64

**Negative:**
- Larger image size than Alpine or distroless alternatives
- `dnf`/`rpm` package manager instead of the more common `apt`
- Some developer tools may not have RPM packages available
- Requires periodic digest updates as new UBI9 versions are released

## Alternatives Considered

| Alternative | Why not |
|---|---|
| **Ubuntu** | No enterprise support commitment; floating tag risk |
| **Alpine** | musl libc incompatibilities with many language runtimes |
| **Debian** | Slower security patch cadence than UBI |
| **Distroless** | Too minimal for dev containers; no shell or package manager |
