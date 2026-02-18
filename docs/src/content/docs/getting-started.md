---
title: Getting Started
description: How to use InfraShift trusted dev container templates in your projects.
---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [cosign](https://docs.sigstore.dev/cosign/system_config/installation/) (for verification)

## Apply a Template

Use the devcontainer CLI to apply a template to your project:

```bash
devcontainer templates apply \
  --template-id ghcr.io/infrashift/trusted-devcontainer-templates/python
```

This creates a `.devcontainer/` directory in your project with:

- **`devcontainer.json`** — feature declarations and container user configuration
- **`Containerfile`** — UBI9 base image (pinned by digest), non-root `dev` user, uv bootstrap

## What You Get

Every template provides:

| Layer | What it does |
|---|---|
| **UBI9 base image** | Enterprise-grade RHEL 9 foundation, pinned by SHA256 digest |
| **Non-root `dev` user** | UID 1001, ready for rootless container workflows |
| **Trusted features** | Language runtimes, CLI tools, and security scanners from InfraShift |
| **Security tooling** | Grype (CVE scanning) and Syft (SBOM generation) pre-installed |

## Verify the Template

Before using a template in a regulated environment, verify its signature:

```bash
# Download the public key
curl -fsSL -o cosign-release.pub \
  https://raw.githubusercontent.com/infrashift/trusted-devcontainer-templates/main/.github/pdp/public-keys/cosign-release.pub

# Verify the template signature
cosign verify --key cosign-release.pub \
  ghcr.io/infrashift/trusted-devcontainer-templates/python:latest
```

See the [Verification guide](/trusted-devcontainer-templates/trust/verification/) for all verification commands.

## Customizing

Templates are a starting point. After applying, you can:

1. **Add features** — append entries to the `features` block in `devcontainer.json`
2. **Change options** — override feature options (e.g., language versions)
3. **Extend the Containerfile** — add packages or configuration below the existing layers
4. **Add VS Code settings** — include `customizations.vscode` in `devcontainer.json`

:::caution
If you modify the Containerfile, your local copy will diverge from the shared canonical Containerfile. The `check-sync` CI job only validates templates within this repository.
:::
