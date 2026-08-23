---
title: Supply Chain
description: Provenance details for every layer in the trusted template stack.
---

Each layer of a trusted template has explicit provenance controls.

## Base Image Digest

The shared Containerfile pins the Fedora 43 base image by SHA256 digest:

```dockerfile
FROM ghcr.io/infrashift/trusted-base-images/trusted/fedora43-minimal@sha256:1ed67eb14da57087e206e45bba67a84264e213e8c545d64a9683fbc38bca3a65
```

This means:
- **No floating tags** — `latest` or `9.4` tags can be mutated; digests cannot
- **Bit-for-bit reproducibility** — the same digest always resolves to the same image layers
- **Audit trail** — the digest is committed to version control and visible in every build

## Feature Provenance

All dev container features come from a single source: [`infrashift/trusted-devcontainer-features`](https://github.com/infrashift/trusted-devcontainer-features).

Each feature reference in `devcontainer.json` uses the `ghcr.io/infrashift/trusted-devcontainer-features/<feature>` prefix. No third-party or community features are used.

See [ADR-006: Trusted Features Only](/trusted-devcontainer-templates/decisions/adr-006-trusted-features-only/) for the rationale.

## Containerfile Integrity

A single canonical Containerfile lives at `shared/Containerfile`. Every template's `.devcontainer/Containerfile` must be an exact copy. This is enforced by:

- **CI check** — the `sync-containerfile.yaml` workflow compares all copies on every PR
- **Local check** — `make check-sync` runs the same diff locally
- **Sync action** — `make sync-containerfiles` copies the canonical file to all templates

See [Containerfile Sync](/trusted-devcontainer-templates/pipeline/containerfile-sync/) for details.

## Evidence Artifacts

The release pipeline produces four signed artifacts per template:

| Artifact | Format | Purpose |
|---|---|---|
| `sbom.json` | SPDX JSON | Software bill of materials |
| `cve-report.json` | Grype JSON | Vulnerability scan results |
| `provenance.json` | SLSA v1 | Build provenance statement |
| `checksums.sha256` | SHA256 sums | Integrity of all artifacts |

Each artifact is signed with cosign using the repository's sovereign key. The `.sig` files are included alongside the artifacts.

## SLSA Provenance Format

The provenance statement follows the [SLSA v1 specification](https://slsa.dev/provenance/v1):

```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [{ "name": "<template>", "digest": { "sha256": "..." } }],
  "predicateType": "https://slsa.dev/provenance/v1",
  "predicate": {
    "buildDefinition": {
      "buildType": "https://github.com/infrashift/trusted-devcontainer-templates/build/v1",
      "externalParameters": {
        "source": { "uri": "git+...@refs/tags/v...", "digest": { "sha1": "..." } },
        "templateId": "<template>"
      }
    },
    "runDetails": {
      "builder": { "id": "https://github.com/.../actions/runs/..." }
    }
  }
}
```
