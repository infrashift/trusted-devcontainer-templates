---
id: "01a18346-a4fa-7060-9776-bd8ab50b7f4d"
title: "ADR-001: UBI 9 base image"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "base-image"
  - "ubi9"
created: "2026-10-28T11:10:07-05:00"
timestamp: "2026-10-28T11:10:07-05:00"
description: "ADR-001 chose UBI 9 Standard as the base image; ADR-007 supersedes it with Fedora 43 minimal."
x:
  adr: 1
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-001-ubi9-base-image.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:07-05:00"
status: "deprecated"
---

# ADR-001: UBI 9 base image

ADR-001 chose the Red Hat Universal Base Image 9 (`ubi9-standard`) as the base image of all templates. ADR-007 supersedes it. The templates do not use UBI 9 now.

**Status:** Superseded by ADR-007. This pointer is deprecated.

## Decision

Use `ghcr.io/infrashift/trusted-base-images/trusted/ubi9-standard`, pinned by digest (`sha256:f938c070dc59…`), as the base image of all templates.

## Reason

* UBI 9 had a stable Red Hat patch schedule and enterprise acceptance.
* UBI 9 was multi-arch (`amd64`, `arm64`) and free to redistribute.
* UBI 9 matched RHEL production environments.

## Consequences

* The image was larger than Alpine or distroless images.
* The digest pin became old. ADR-007 reports that the pin was the oldest build, about six months of patches behind `latest`.
* Some developer tools had no RPM package.

## Analysis

The template pages in `docs/src/content/docs/templates/*.mdx` still show the UBI 9 digest prefix `f938c…` after the `fedora43-minimal` name. The current pin is in [Base image](/architecture/base-image--01a183441025.md).

## Related

* [ADR-007: Fedora 43 minimal base image](/decisions/adr-007-fedora-43-minimal-base-image--01a18346a6c7.md) — supersedes this ADR.
* [Base image](/architecture/base-image--01a183441025.md) — the current base image.
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
