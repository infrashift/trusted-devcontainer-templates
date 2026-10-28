---
id: "01a1834b-bb29-7d33-8b2a-7f04b62cda1e"
title: "The template docs pages show an old base digest"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "docs"
  - "base-image"
created: "2026-10-28T11:15:40-05:00"
timestamp: "2026-10-28T11:15:40-05:00"
description: "All 9 template pages show the old UBI 9 digest prefix and say that uv is pre-installed."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/index.mdx"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:15:40-05:00"
status: "draft"
---

# The template docs pages show an old base digest

## Problem

All 9 template pages in the documentation site show a wrong Containerfile section.

## Context

Each page in `docs/src/content/docs/templates/*.mdx` shows `fedora43-minimal@sha256:f938c…`. That prefix is the old UBI 9 digest. Each page also says "uv pre-installed for feature bootstrap". ADR-008 removed that: the `bootstrap` feature installs uv.

## Acceptance criteria

- [ ] Each template page shows the base digest from `shared/Containerfile`, or no digest.
- [ ] No template page says that uv is pre-installed.

## Related

* [Base image](/architecture/base-image--01a183441025.md)
* [ADR-008: Bootstrap feature supplies uv and Ansible](/decisions/adr-008-bootstrap-feature-supplies-uv-and-ansible--01a18346a716.md)
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
