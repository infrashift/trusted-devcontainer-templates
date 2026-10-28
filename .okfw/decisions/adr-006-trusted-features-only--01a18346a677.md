---
id: "01a18346-a677-7a41-8f2d-6bc26bf191ae"
title: "ADR-006: Trusted features only"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "features"
  - "supply-chain"
created: "2026-10-28T11:10:07-05:00"
timestamp: "2026-10-28T11:10:07-05:00"
description: "ADR-006 permits only features that InfraShift builds, tests, signs and publishes, from two registry prefixes after its amendments."
x:
  adr: 6
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-006-trusted-features-only.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:07-05:00"
status: "draft"
---

# ADR-006: Trusted features only

ADR-006 permits only features that InfraShift builds, tests, signs and publishes. No third-party or community feature is permitted.

**Status:** Accepted, amended two times.

## Decision

Each feature reference starts with `ghcr.io/infrashift/trusted-devcontainer-features/`. The first amendment (from ADR-008) accepts `dependsOn` on `bootstrap`, because its target is in the same namespace. The second amendment (from ADR-009) adds the prefix `ghcr.io/infrashift/trusted-devcontainer-templates/features/`.

## Reason

* A feature runs scripts with high privileges at build time.
* A community feature can change after review (mutable tags), and has no signature or SBOM.
* One organization controls the full feature supply chain.

## Consequences

* A new tool needs a new trusted feature before a template can use it.
* The templates list `bootstrap` explicitly, so `devcontainer.json` shows what installs.
* A review of a feature includes its `dependsOn` block. There are two collections to audit.

## Related

* [Feature pinning](/architecture/feature-pinning--01a183457520.md) — how the templates pin the two collections.
* [Repo-local features](/architecture/repo-local-features--01a183450227.md) — the second collection.
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md) — the `dependsOn` target.
* [ADR-008: Bootstrap feature supplies uv and Ansible](/decisions/adr-008-bootstrap-feature-supplies-uv-and-ansible--01a18346a716.md)
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md)
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
