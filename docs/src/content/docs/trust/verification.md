---
title: Verification
description: How to verify template signatures and attestations using cosign.
---

All published templates can be verified using [cosign](https://docs.sigstore.dev/cosign/system_config/installation/). Three keys sign different things, so use the key that matches what you verify.

## Which Key Verifies What

| Key | Held by | Verifies |
|---|---|---|
| `release.pub` | Release-Actor | The published template: its signature and its SBOM, CVE and SLSA provenance attestations |
| `build.pub` | Build-Actor | The evidence files attached to a GitHub Release (`<template>-sbom.json`, …) |
| `review.pub` | Review-Actor | The review verdict attached to a GitHub Release (`<template>-review-verdict.json`) |

All three are in [`.github/pdp/public-keys/`](https://github.com/infrashift/trusted-devcontainer-templates/tree/main/.github/pdp/public-keys).

## Get the Release Key

```bash
curl -fsSL -o release.pub \
  https://raw.githubusercontent.com/infrashift/trusted-devcontainer-templates/main/.github/pdp/public-keys/release.pub
```

## Verify Template Signature

Each template is dual-signed. Verify the release key signature:

```bash
cosign verify --key release.pub \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## Verify SBOM Attestation

```bash
cosign verify-attestation --key release.pub \
  --type spdxjson \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## Verify CVE Attestation

```bash
cosign verify-attestation --key release.pub \
  --type vuln \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## Verify SLSA Provenance

```bash
cosign verify-attestation --key release.pub \
  --type slsaprovenance1 \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## All Templates

Replace `python` with any template ID. To verify one release rather than the newest, replace `latest` with its version, for example `1.0.4`.

| Template | OCI Reference |
|---|---|
| ansible-cue | `ghcr.io/infrashift/trusted-devcontainer-templates/ansible-cue:latest` |
| dotnet-node | `ghcr.io/infrashift/trusted-devcontainer-templates/dotnet-node:latest` |
| go-cue | `ghcr.io/infrashift/trusted-devcontainer-templates/go-cue:latest` |
| java | `ghcr.io/infrashift/trusted-devcontainer-templates/java:latest` |
| python | `ghcr.io/infrashift/trusted-devcontainer-templates/python:latest` |
| neovim-ansible-cue | `ghcr.io/infrashift/trusted-devcontainer-templates/neovim-ansible-cue:latest` |
| neovim-go | `ghcr.io/infrashift/trusted-devcontainer-templates/neovim-go:latest` |
| neovim-java | `ghcr.io/infrashift/trusted-devcontainer-templates/neovim-java:latest` |
| neovim-python | `ghcr.io/infrashift/trusted-devcontainer-templates/neovim-python:latest` |

## Keyless (OIDC) Verification

Templates are also signed via Sigstore's keyless flow (Fulcio + Rekor). To verify without a key:

```bash
cosign verify \
  --certificate-identity-regexp="https://github.com/infrashift/trusted-devcontainer-templates" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

## Release Evidence

Each [GitHub Release](https://github.com/infrashift/trusted-devcontainer-templates/releases) carries signed evidence for every template, named `<template>-<file>`: `sbom.json`, `cve-report.json`, `scan-input.json`, `provenance.json`, `checksums.sha256` and `evidence-manifest.json`, each with a `.sig`, plus `review-verdict.json` and its `.sig`.

The Build-Actor signs the evidence files. Verify them with `build.pub`:

```bash
curl -fsSL -o build.pub \
  https://raw.githubusercontent.com/infrashift/trusted-devcontainer-templates/main/.github/pdp/public-keys/build.pub

gh release download v1.0.4 --repo infrashift/trusted-devcontainer-templates \
  -p 'python-sbom.json*' -p 'python-review-verdict.json*'

cosign verify-blob --key build.pub \
  --signature python-sbom.json.sig \
  python-sbom.json
```

The Review-Actor signs the verdict. Verify it with `review.pub`:

```bash
curl -fsSL -o review.pub \
  https://raw.githubusercontent.com/infrashift/trusted-devcontainer-templates/main/.github/pdp/public-keys/review.pub

cosign verify-blob --key review.pub \
  --signature python-review-verdict.json.sig \
  python-review-verdict.json
```
