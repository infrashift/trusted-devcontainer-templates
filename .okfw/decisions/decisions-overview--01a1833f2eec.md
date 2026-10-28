---
id: "01a1833f-2eec-7abf-8931-ac398eaa8c14"
title: "Decisions overview"
type: "overview"
tags:
  - "hub"
  - "adr"
created: "2026-10-28T11:01:58-05:00"
timestamp: "2026-10-28T11:01:58-05:00"
description: "One pointer concept for each architecture decision record (ADR) in the documentation site."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:58-05:00"
status: "draft"
---

# Decisions overview

This bundle holds one pointer concept for each ADR in `docs/src/content/docs/decisions/`. The ADR file is the source of truth.

Do not put a new decision. Write the ADR in `docs/` first, then add the pointer here.

## Find concepts

* List this bundle: read `.okfw/decisions/index.md`.
* Search this bundle: `okfw search "<words>" --type decision`.

## Add a concept

1. Search the wiki first. Update a concept that exists, if possible.
2. Run `okfw create "<Title>" --path decisions -d "<one sentence>" --tags adr`.
3. Set `type: decision` in the frontmatter.
4. Add a link to the new concept in the list below.
5. Obey the [wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md) and [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md).

## Concepts

### Current
* [ADR-002: One shared Containerfile](/decisions/adr-002-one-shared-containerfile--01a18346a548.md)
* [ADR-003: Non-root dev user](/decisions/adr-003-non-root-dev-user--01a18346a598.md)
* [ADR-004: OPA policy gate for CVEs](/decisions/adr-004-opa-policy-gate-for-cves--01a18346a5e4.md)
* [ADR-005: Dual signing of templates](/decisions/adr-005-dual-signing-of-templates--01a18346a62e.md)
* [ADR-006: Trusted features only](/decisions/adr-006-trusted-features-only--01a18346a677.md)
* [ADR-007: Fedora 43 minimal base image](/decisions/adr-007-fedora-43-minimal-base-image--01a18346a6c7.md)
* [ADR-008: Bootstrap feature supplies uv and Ansible](/decisions/adr-008-bootstrap-feature-supplies-uv-and-ansible--01a18346a716.md)
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md)

### Superseded
* [ADR-001: UBI 9 base image](/decisions/adr-001-ubi-9-base-image--01a18346a4fa.md)

## Related

* [Wiki map](/wiki-map--01a1833f67c2.md)
