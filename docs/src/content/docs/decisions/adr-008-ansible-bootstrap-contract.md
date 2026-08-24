---
title: "ADR-008: Ansible Bootstrap Contract"
description: Decision to obtain uv and the pinned Ansible environment from the bootstrap feature rather than the Containerfile.
---

**Status:** Accepted

## Context

The shared Containerfile installed `uv` so that features could bootstrap Ansible with `uv run --with ansible-core`. That placed a build-time dependency of the *features* inside the *templates* repository: the Containerfile installed a tool it never used itself, purely so features would find it on `PATH`.

It also resolved `ansible-core` from PyPI unpinned at image build time — the one unpinned link in a supply chain that is otherwise digest-pinned, signed, and attested.

The migration to `fedora43-minimal` forced the issue: with no system `python3`, Ansible's local connection has no interpreter to discover, so a known-good interpreter path became a requirement rather than a nicety.

## Decision

Templates no longer install `uv`. They depend on the **`bootstrap` feature**, which provisions:

```
/opt/bootstrap/                  root-owned, world-readable
├── .bootstrap/                  uv venv: pinned Python + pinned ansible-core
├── inventory.yml                variant detected once from /etc/os-release
├── site.yml                     generic playbook applying one role
└── run-feature.sh               shared entrypoint for every feature
```

Every trusted feature declares `dependsOn` the bootstrap feature, so it is installed automatically. Our templates also list it explicitly, so the dependency is visible when reading a `devcontainer.json` rather than only at resolution time.

The environment is **root-owned**. The `dev` user runs it but cannot modify it — the account being provisioned cannot rewrite the thing doing the provisioning.

The counterpart decision is recorded in the features repository as ADR-008 (*Pinned .bootstrap UV Environment*) and ADR-012 (*Feature Role Contract*).

## Consequences

**Positive:**
- The templates repository stops carrying a dependency belonging to the features repository.
- `uv` is pinned and checksum-verified rather than fetched by `curl | sh`.
- ansible-core, its dependencies, and the CPython build appear in the SBOM and are scanned by Grype.
- Reproducible: the same commit produces the same Ansible.
- Ansible resolution happens once, not once per feature.

**Negative:**
- Templates cannot build without the bootstrap feature being resolvable. The runner hard-fails with an explanatory error rather than silently falling back.
- The `uv` pin now lives in the features repository, so bumping it is a change there, released on that repository's cadence.
- Image size grows by a CPython runtime plus ansible-core, which the previous ephemeral approach deliberately avoided.

## Alternatives Considered

| Alternative | Why not |
|---|---|
| **Keep `uv` in the Containerfile, pin and verify it there** | Templates keep carrying a dependency they do not use, and it must be repeated by every consumer base image |
| **Provision `/opt/bootstrap` in the Containerfile** | Works for our templates, but makes features unusable on any other base image |
| **Keep ephemeral `uv run --with ansible-core`** | Fails on a base image with no system Python, and leaves resolution unpinned |
