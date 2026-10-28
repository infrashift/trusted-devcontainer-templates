---
id: "01a18346-a6c7-78c0-99b9-b0ffc3c9fbc8"
title: "ADR-007: Fedora 43 minimal base image"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "base-image"
  - "fedora"
created: "2026-10-28T11:10:07-05:00"
timestamp: "2026-10-28T11:10:07-05:00"
description: "ADR-007 moves all templates from UBI 9 to the digest-pinned trusted fedora43-minimal image, and supersedes ADR-001."
x:
  adr: 7
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-007-fedora43-base-image.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:07-05:00"
status: "draft"
---

# ADR-007: Fedora 43 minimal base image

ADR-007 moves all templates from UBI 9 to the trusted Fedora 43 minimal base image. It supersedes ADR-001.

**Status:** Accepted. Supersedes ADR-001.

## Decision

Base all templates on `ghcr.io/infrashift/trusted-base-images/trusted/fedora43-minimal`, pinned by digest. Install a curated package baseline in the shared Containerfile. Remove the `curl | sh` install of uv; the bootstrap feature supplies uv.

## Reason

* The UBI 9 pin was old, and Fedora gives current compilers, interpreters and CLI tools.
* The organization publishes a trusted, signed Fedora image. `fedora43-minimal` is the only Fedora variant in the trusted namespace.
* An unpinned `curl | sh` was the weakest step in the build.

## Consequences

* The minimal image has no `tar`, `gzip`, `xz`, `su`, `runuser`, `sudo`, `python3` or `gpg`. The Containerfile must add what features need.
* Fedora 43 reaches end of life sooner than UBI 9. The base must move to Fedora 44 or later on the Fedora schedule.
* Newer packages give more CVE findings, and the RHEL production parity is lost.

## Analysis

The ADR shows the first Fedora digest, `sha256:1ed67eb14da5…`. The current pin is `sha256:27dbbbb9470a…` (2026-10-28). The Containerfile now also runs `dnf5 upgrade` and installs `unzip`, `libicu` and `openssl-libs`, which the ADR does not list.

## Related

* [Base image](/architecture/base-image--01a183441025.md) — the current pin and the missing tools.
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md) — the package baseline.
* [ADR-001: UBI 9 base image](/decisions/adr-001-ubi-9-base-image--01a18346a4fa.md) — the superseded decision.
* [ADR-008: Bootstrap feature supplies uv and Ansible](/decisions/adr-008-bootstrap-feature-supplies-uv-and-ansible--01a18346a716.md) — moves uv and Ansible to the bootstrap feature.
* [ADR-004: OPA policy gate for CVEs](/decisions/adr-004-opa-policy-gate-for-cves--01a18346a5e4.md) — amended for the Fedora CVE rate.
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
