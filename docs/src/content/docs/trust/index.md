---
title: Trust & Security Overview
description: How InfraShift trusted templates establish a verifiable chain of trust from base image to published artifact.
---

Trusted DevContainer Templates implement a layered trust model. Every layer in the stack is independently verifiable, creating a chain of trust from the base image through to the published OCI artifact.

## Trust Layers

| Layer | Trust Mechanism |
|---|---|
| **Base image** | Fedora 43 pinned by SHA256 digest — no floating tags |
| **Containerfile** | Single canonical source with automated drift detection |
| **Features** | Exclusively from `infrashift/trusted-devcontainer-features` |
| **Build evidence** | Signed SBOM, CVE report, and SLSA provenance per template |
| **Policy gate** | OPA Rego policy enforces CVE thresholds before publish |
| **Signing** | Dual signing: sovereign key + keyless OIDC (Sigstore) |

## How It Works

1. **Base image pinning** — The shared Containerfile references a Fedora 43 image by `@sha256:` digest, not by tag. This ensures reproducibility and prevents supply-chain attacks via tag mutation.

2. **Feature provenance** — All features are sourced from a single InfraShift-controlled repository. Each feature is itself built, tested, and signed through a similar pipeline.

3. **Build-time evidence** — During the release pipeline, each template image is scanned. The scan produces three signed artifacts: an SPDX SBOM, a Grype CVE report, and a SLSA provenance statement.

4. **Policy enforcement** — Before publishing, an OPA policy evaluates CVE counts. Critical or high vulnerabilities cause the pipeline to fail.

5. **Dual signing** — Published templates receive both a sovereign key signature and a keyless OIDC signature via Sigstore Fulcio and Rekor transparency log.

## Learn More

- [Supply Chain](/trusted-devcontainer-templates/trust/supply-chain/) — detailed provenance for each layer
- [Verification](/trusted-devcontainer-templates/trust/verification/) — cosign commands for every attestation type
- [OPA Policy Gate](/trusted-devcontainer-templates/trust/opa-policy/) — the Rego policy and how it's enforced
