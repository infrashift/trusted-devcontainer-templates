---
id: "01a18346-a716-7149-a3b4-8dbb5a4668c2"
title: "ADR-008: Bootstrap feature supplies uv and Ansible"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "bootstrap"
  - "ansible"
created: "2026-10-28T11:10:08-05:00"
timestamp: "2026-10-28T11:10:08-05:00"
description: "ADR-008 removes uv from the Containerfile; the bootstrap feature supplies pinned uv, Python, ansible-core and run-feature.sh."
x:
  adr: 8
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-008-ansible-bootstrap-contract.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:08-05:00"
status: "draft"
---

# ADR-008: Bootstrap feature supplies uv and Ansible

ADR-008 removes uv from the shared Containerfile. The `bootstrap` feature supplies uv, a pinned Python, a pinned `ansible-core` and the runner `/opt/bootstrap/run-feature.sh`.

**Status:** Accepted.

## Decision

The templates depend on the `bootstrap` feature, which provisions `/opt/bootstrap` as a root-owned environment. Each trusted feature has `dependsOn` this feature, and the templates also list it explicitly. The features repository records the counterpart in its ADR-008 and ADR-012.

## Reason

* The Containerfile installed uv only for the features. That was a dependency of the features repository in the templates repository.
* `uv run --with ansible-core` got `ansible-core` from PyPI without a pin.
* `fedora43-minimal` has no `python3`, so Ansible needs a known interpreter.

## Consequences

* uv and `ansible-core` are pinned and checksum-verified, and they appear in the SBOM.
* A template cannot build if the bootstrap feature does not resolve. The runner stops with an error.
* The image is larger, and a uv update is a release of the features repository.

The code agrees with the ADR on 2026-10-28: `shared/Containerfile` installs no uv, and all nine templates pin bootstrap 1.6.1.

## Related

* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md) — the contract in detail.
* [Feature pinning](/architecture/feature-pinning--01a183457520.md) — the bootstrap digest rule.
* [ADR-007: Fedora 43 minimal base image](/decisions/adr-007-fedora-43-minimal-base-image--01a18346a6c7.md) — the base image change that forced this decision.
* [ADR-006: Trusted features only](/decisions/adr-006-trusted-features-only--01a18346a677.md) — amended for `dependsOn`.
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
