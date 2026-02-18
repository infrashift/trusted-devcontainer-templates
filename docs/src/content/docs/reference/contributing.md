---
title: Contributing
description: How to add new templates and contribute to the project.
---

## Adding a New Template

### 1. Create the template directory

```bash
mkdir -p src/<template-name>/.devcontainer
```

### 2. Copy the shared Containerfile

```bash
cp shared/Containerfile src/<template-name>/.devcontainer/Containerfile
```

Or use the Makefile target:

```bash
make sync-containerfiles
```

### 3. Create devcontainer-template.json

```json
{
    "id": "<template-name>",
    "version": "1.0.0",
    "name": "<Display Name> (Trusted)",
    "description": "A trusted <language> development environment based on UBI9.",
    "publisher": "InfraShift",
    "options": {},
    "platforms": ["linux/amd64", "linux/arm64"],
    "keywords": ["<language>", "ubi9", "trusted", "secure"]
}
```

### 4. Create devcontainer.json

```json
{
    "build": {
        "dockerfile": "./Containerfile"
    },
    "containerUser": "dev",
    "updateRemoteUserUID": false,
    "features": {
        "ghcr.io/infrashift/trusted-devcontainer-features/<primary-feature>": {},
        "ghcr.io/infrashift/trusted-devcontainer-features/git": {},
        "ghcr.io/infrashift/trusted-devcontainer-features/git-lfs": {},
        "ghcr.io/infrashift/trusted-devcontainer-features/grype": {},
        "ghcr.io/infrashift/trusted-devcontainer-features/syft": {},
        "ghcr.io/infrashift/trusted-devcontainer-features/jq": {},
        "ghcr.io/infrashift/trusted-devcontainer-features/yq": {}
    }
}
```

:::caution
Only use features from `infrashift/trusted-devcontainer-features`. See [ADR-006](/trusted-devcontainer-templates/decisions/adr-006-trusted-features-only/).
:::

### 5. Create a test script

```bash
mkdir -p test/<template-name>
```

Create `test/<template-name>/test.sh`:

```bash
#!/bin/bash
set -euo pipefail

echo "=== Testing <template-name> ==="

# Verify primary tool
<tool> --version

# Verify common tools
git --version
jq --version
yq --version
grype version
syft version

# Verify user
[ "$(whoami)" = "dev" ]
[ "$(id -u)" = "1001" ]

echo "=== All tests passed ==="
```

### 6. Add to TEMPLATES list

Edit `Makefile` and add the new template ID to the `TEMPLATES` variable.

Add the template ID to the `TEMPLATES` env var in `.github/workflows/release.yaml`.

### 7. Test locally

```bash
make test-template TEMPLATE=<template-name>
```

### 8. Update documentation

1. Add an entry to `docs/src/data/templates.json`
2. Create a template page at `docs/src/content/docs/templates/<template-name>.mdx`
3. Add the template to the sidebar in `docs/astro.config.mjs`

## Development Setup

```bash
# Install docs dependencies
cd docs && bun install

# Start dev server
make docs-dev

# Build docs
make docs-build
```

## Code Review Checklist

- [ ] Containerfile matches `shared/Containerfile` (`make check-sync`)
- [ ] All features are from `infrashift/trusted-devcontainer-features`
- [ ] `containerUser: "dev"` and `updateRemoteUserUID: false` are set
- [ ] Test script verifies all primary tools and the dev user
- [ ] Template metadata (name, description, keywords) is complete
- [ ] Documentation is updated (template page, catalog, sidebar)
