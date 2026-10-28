---
id: "01a1833f-2e83-70e0-badf-226e066c9373"
title: "Architecture overview"
type: "overview"
tags:
  - "hub"
  - "architecture"
created: "2026-10-28T11:01:58-05:00"
timestamp: "2026-10-28T11:01:58-05:00"
description: "The parts of the template system and how they connect, from the base image to the published artifact."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:58-05:00"
status: "draft"
---

# Architecture overview

This bundle holds one concept for each part of the system: the base image, the shared Containerfile, bootstrap, repo-local features, the dev user, feature pinning, and the repository layout.

Do not put the reasons for a design. Put them in `decisions/`. Do not put one template here; use `templates/`.

## Find concepts

* List this bundle: read `.okfw/architecture/index.md`.
* Search this bundle: `okfw search "<words>" --type component`.

## Add a concept

1. Search the wiki first. Update a concept that exists, if possible.
2. Run `okfw create "<Title>" --path architecture -d "<one sentence>" --tags architecture`.
3. Set `type: component` in the frontmatter.
4. Add a link to the new concept in the list below.
5. Obey the [wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md) and [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md).

## Concepts

### Build layers
* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)

### Features
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)

### Repository
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md)

## Related

* [Wiki map](/wiki-map--01a1833f67c2.md)
