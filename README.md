# Trusted DevContainer Templates

Security-hardened [dev container templates](https://containers.dev/implementors/templates/) built on Red Hat UBI9 base images with full supply-chain attestations.

Every template ships with SBOM, CVE scan results, SLSA v1.0 provenance, and dual-signed OCI artifacts so you can verify exactly what you're running.

## Available Templates

| Template | Description | Key Tooling |
|---|---|---|
| `ansible-cue` | Ansible + CUE for IaC workflows | ansible-core 2.18, Python 3.12, CUE |
| `dotnet-node` | .NET + Node.js full-stack development | .NET SDK, Node.js, npm, pnpm |
| `go-cue` | Go + CUE for CLI/TUI development | Go, CUE |
| `java` | Java development | OpenJDK |
| `python` | Python development | Python 3.12, uv, ruff |

All templates include: git, git-lfs, grype, syft, jq, yq.

All templates support `linux/amd64` and `linux/arm64`.

## Trust Model

Every layer in the stack is controlled and auditable:

- **Base image** — [`infrashift/trusted-base-images/trusted/ubi9-standard`](https://ghcr.io/infrashift/trusted-base-images/trusted/ubi9-standard) pinned by digest
- **Features** — installed from [`infrashift/trusted-devcontainer-features`](https://github.com/infrashift/trusted-devcontainer-features) via the dev container feature mechanism
- **Containerfile drift detection** — all templates share a canonical `shared/Containerfile`; the [`sync-containerfile.yaml`](.github/workflows/sync-containerfile.yaml) workflow fails if any template's copy diverges
- **Non-root user** — containers run as the `dev` user (UID 1001)

## Usage

Apply a template to your project with the devcontainer CLI:

```sh
devcontainer templates apply \
  --template-id ghcr.io/infrashift/trusted-devcontainer-templates/python
```

Replace `python` with any template ID from the table above.

## Release Pipeline

Every tagged release (`v*`) runs a 3-job pipeline defined in [`release.yaml`](.github/workflows/release.yaml):

1. **test** — builds each template with `devcontainer up` and runs its functional test suite
2. **scan** — generates an SBOM (Syft), runs a CVE scan (Grype), enforces an OPA policy gate (critical and high CVEs block the release), generates SLSA v1.0 provenance, cosign-signs all evidence artifacts, and computes checksums
3. **publish** — publishes templates to GHCR via `devcontainers/action`, attaches SBOM/CVE/provenance attestations to each OCI artifact, and dual-signs every artifact (sovereign cosign key + Sigstore OIDC keyless)

All evidence artifacts (SBOMs, CVE reports, provenance statements, signatures, checksums) are attached to the GitHub Release.

## Verification

Verify published templates using [cosign](https://github.com/sigstore/cosign).

**Sovereign key verification:**

```sh
cosign verify \
  --key .github/pdp/public-keys/cosign-release.pub \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

**Keyless OIDC verification (Sigstore):**

```sh
cosign verify \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp "github\.com/infrashift/trusted-devcontainer-templates" \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

**SBOM attestation verification:**

```sh
cosign verify-attestation \
  --key .github/pdp/public-keys/cosign-release.pub \
  --type spdxjson \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

Replace `python` with any template ID.

## Contributing

Pull requests trigger the [`test-pr.yaml`](.github/workflows/test-pr.yaml) workflow which runs functional tests for changed templates and an informational CVE scan (warnings only, does not block merging).
