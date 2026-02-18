---
title: Release Workflow
description: The three-job release pipeline that tests, scans, signs, and publishes templates.
---

The release workflow (`release.yaml`) is triggered when a version tag (`v*`) is pushed. It runs three sequential jobs.

## Job 1: Test

Functional validation of every template.

- Installs `@devcontainers/cli`
- Logs in to GHCR (for pulling trusted features)
- For each template:
  - `devcontainer up` builds and starts the container
  - `devcontainer exec` runs the template's test script (`test/<template>/test.sh`)

All five templates are tested sequentially. If any test fails, the pipeline stops.

## Job 2: Scan

Security scanning, evidence generation, and policy enforcement.

For each template:

1. **Build** the full devcontainer image with `devcontainer build`
2. **SBOM** — generate SPDX JSON with Syft, sign with cosign
3. **CVE scan** — scan with Grype, sign the report with cosign
4. **OPA policy** — extract CVE counts, evaluate against Rego policy
5. **SLSA provenance** — generate in-toto/SLSA v1 statement, sign with cosign
6. **Checksums** — SHA256 of all artifacts, signed with cosign

Evidence is uploaded as a GitHub Actions artifact (`release-evidence`).

### Policy Gate

The OPA evaluation is a hard gate. If any template has policy violations (e.g., critical CVEs), the scan job fails and the publish job never runs.

## Job 3: Publish

Template publishing, attestation, and signing.

1. **Download evidence** from the scan job
2. **Publish templates** using `devcontainers/action@v1` to GHCR
3. For each template:
   - Resolve the OCI digest with `crane digest`
   - Attach SBOM attestation (`cosign attest --type spdxjson`)
   - Attach CVE attestation (`cosign attest --type vuln`)
   - Attach SLSA provenance (`cosign attest --type slsaprovenance1`)
   - **Sovereign key signing** (`cosign sign --key`)
   - **Keyless OIDC signing** (`cosign sign` via Fulcio/Rekor)
4. **GitHub Release** — create release with all evidence files attached

## Required Secrets

| Secret | Purpose |
|---|---|
| `COSIGN_PRIVATE_KEY` | Sovereign signing key (PEM-encoded) |
| `COSIGN_PASSWORD` | Passphrase for the private key |
| `GITHUB_TOKEN` | Automatic — used for GHCR and release creation |

## Required Permissions

```yaml
permissions:
  contents: write    # GitHub Release creation
  packages: write    # GHCR push
  id-token: write    # Sigstore OIDC keyless signing
```
