---
title: "ADR-006: Trusted Features Only"
description: Decision to exclusively use features from the InfraShift trusted-devcontainer-features collection.
---

**Status:** Accepted — amended

## Context

Dev container features are installed into the container at build time. They run arbitrary scripts with elevated privileges. Using community or third-party features introduces supply-chain risk:

- Features could be modified after initial review (mutable tags)
- Feature authors may not follow security best practices
- No guarantee of vulnerability scanning or signing
- Dependency chains may pull in untrusted code

## Decision

All templates exclusively use features from [`infrashift/trusted-devcontainer-features`](https://github.com/infrashift/trusted-devcontainer-features). No third-party or community features are permitted.

Every feature reference uses the `ghcr.io/infrashift/trusted-devcontainer-features/` prefix:

```json
{
    "features": {
        "ghcr.io/infrashift/trusted-devcontainer-features/python": { "target_version": "3.12" },
        "ghcr.io/infrashift/trusted-devcontainer-features/git": {},
        "ghcr.io/infrashift/trusted-devcontainer-features/grype": {}
    }
}
```

## Consequences

**Positive:**
- Complete control over the feature supply chain
- Features go through the same build/test/sign pipeline
- Audit scope is limited to one repository
- Consistent quality, testing, and documentation standards

**Negative:**
- New features must be built before they can be used in templates
- Cannot leverage the community feature ecosystem directly
- Increases maintenance burden for the features repository
- Feature gaps compared to the broader `devcontainers/features` collection

## Alternatives Considered

| Alternative | Why not |
|---|---|
| **Community features (`devcontainers/features`)** | No signing, no SBOM, mutable tags, third-party trust |
| **Allowlist of approved third-party features** | Ongoing review burden; trust model is per-feature, not per-org |
| **Feature vendoring (fork + rebuild)** | Maintenance overhead; version tracking becomes complex |
| **No features (bake everything into Containerfile)** | Loses composability; massive Containerfiles; no feature reuse |

## Amendment: transitive resolution via `dependsOn`

This ADR assumes the feature list in `devcontainer.json` is the complete, auditable set. Under
[ADR-008](/trusted-devcontainer-templates/decisions/adr-008-ansible-bootstrap-contract/) that is no longer strictly true: every trusted feature
declares `dependsOn` the `bootstrap` feature, so the runtime may install a feature the template did not
name.

The trust boundary is unchanged. `dependsOn` targets are absolute OCI references, and every one resolves
inside `ghcr.io/infrashift/trusted-devcontainer-features/` — the same namespace, pipeline, and signing keys
as any directly listed feature. No third-party feature can enter this way.

Two practices keep the audit surface honest:

- Our templates list `bootstrap` explicitly even though `dependsOn` makes it redundant, so reading a
  `devcontainer.json` still shows what will be installed.
- Reviewing a feature means reviewing its `dependsOn` block, since that is now part of what a template
  transitively pulls in.
