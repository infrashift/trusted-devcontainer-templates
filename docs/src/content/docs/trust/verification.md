---
title: Verification
description: How to verify template signatures and attestations using cosign.
---

All published templates can be verified using [cosign](https://docs.sigstore.dev/cosign/system_config/installation/). You need the repository's public key for sovereign key verification.

## Get the Public Key

```bash
curl -fsSL -o cosign-release.pub \
  https://raw.githubusercontent.com/infrashift/trusted-devcontainer-templates/main/.github/pdp/public-keys/cosign-release.pub
```

## Verify Template Signature

Each template is dual-signed. Verify the sovereign key signature:

```bash
cosign verify --key cosign-release.pub \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## Verify SBOM Attestation

```bash
cosign verify-attestation --key cosign-release.pub \
  --type spdxjson \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## Verify CVE Attestation

```bash
cosign verify-attestation --key cosign-release.pub \
  --type vuln \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## Verify SLSA Provenance

```bash
cosign verify-attestation --key cosign-release.pub \
  --type slsaprovenance1 \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## All Templates

Replace `python` with any template ID:

| Template | OCI Reference |
|---|---|
| ansible-cue | `ghcr.io/infrashift/trusted-devcontainer-templates/ansible-cue:latest` |
| dotnet-node | `ghcr.io/infrashift/trusted-devcontainer-templates/dotnet-node:latest` |
| go-cue | `ghcr.io/infrashift/trusted-devcontainer-templates/go-cue:latest` |
| java | `ghcr.io/infrashift/trusted-devcontainer-templates/java:latest` |
| python | `ghcr.io/infrashift/trusted-devcontainer-templates/python:latest` |

## Keyless (OIDC) Verification

Templates are also signed via Sigstore's keyless flow (Fulcio + Rekor). To verify without a key:

```bash
cosign verify \
  --certificate-identity-regexp="https://github.com/infrashift/trusted-devcontainer-templates" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## Release Evidence

Signed evidence artifacts (SBOM, CVE report, provenance, checksums) are attached to each [GitHub Release](https://github.com/infrashift/trusted-devcontainer-templates/releases). You can verify any blob signature:

```bash
cosign verify-blob --key cosign-release.pub \
  --signature sbom.json.sig \
  sbom.json
```
