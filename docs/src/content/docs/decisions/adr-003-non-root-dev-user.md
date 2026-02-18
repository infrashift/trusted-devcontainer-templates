---
title: "ADR-003: Non-Root dev User"
description: Decision to create a non-root user named 'dev' with UID 1001 for container development.
---

**Status:** Accepted

## Context

Running as root inside dev containers is a security risk, even in development. The container user needs:
- A predictable UID/GID for file permission consistency
- A home directory for tooling configuration
- A shell for interactive use
- Compatibility with rootless container runtimes

The related features repository uses a `vscode` user with UID 1000, following the VS Code convention.

## Decision

Create a non-root user named `dev` with UID 1001 and GID 1001. Set `containerUser: "dev"` and `updateRemoteUserUID: false` in `devcontainer.json`.

```dockerfile
ARG USERNAME=dev
ARG USER_UID=1001
ARG USER_GID=1001

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -m -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} ${USERNAME}
```

## Consequences

**Positive:**
- Non-root by default reduces attack surface
- `updateRemoteUserUID: false` ensures consistent UID across rebuilds
- Named `dev` (not `vscode`) — template-neutral, not tied to one editor
- UID 1001 avoids conflict with system users (UID < 1000) and the common UID 1000

**Negative:**
- UID 1001 differs from the features repo's UID 1000 (`vscode` user)
- Some bind-mounted files may have permission mismatches on the host
- `updateRemoteUserUID: false` means the container UID won't match the host user's UID

## Alternatives Considered

| Alternative | Why not |
|---|---|
| **`vscode` user (UID 1000)** | Couples templates to VS Code; UID 1000 often conflicts with host user |
| **Root user** | Security risk; features may install to wrong locations |
| **Dynamic UID** | `updateRemoteUserUID: true` causes inconsistent file ownership across rebuilds |
