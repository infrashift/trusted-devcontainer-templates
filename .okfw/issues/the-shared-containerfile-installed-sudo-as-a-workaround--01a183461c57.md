---
id: "01a18346-1c57-7544-a499-2185f1098368"
title: "The shared Containerfile installed sudo as a workaround"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "containerfile"
  - "privileges"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "The shared Containerfile installed sudo only for feature privilege escalation; commit b4ae498 removed it on 2026-02-18."
x:
  todo: 6
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/shared/Containerfile"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/b4ae498"
    title: "Commit b4ae498"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The shared Containerfile installed sudo as a workaround

The shared Containerfile installed `sudo` only to let the trusted features run their privileged tasks.

## Problem

The features used `become` in their Ansible tasks, see [The features needed sudo in the base image](/issues/the-features-needed-sudo-in-the-base-image--01a183461a52.md). As a workaround, `shared/Containerfile` added the layer `RUN dnf install -y sudo && dnf clean all`. This layer put `sudo` in every template image without a product need.

## Context

* The shared Containerfile is copied into each template (ADR-002).
* The root cause is in the features repository.

## Acceptance criteria

- [x] `shared/Containerfile` does not install `sudo`.
- [x] The templates build without `sudo`.

## Resolution

* Commit: `b4ae498` (2026-02-18).
* Change: the `sudo` layer is removed from `shared/Containerfile`. The features stopped using `become` in features v1.0.1.

## Related

* [The features needed sudo in the base image](/issues/the-features-needed-sudo-in-the-base-image--01a183461a52.md)
* [The root dev container Containerfile was outside the drift check](/issues/the-root-dev-container-containerfile-was-outside-the-drift-check--01a183461cfa.md)
* [Architecture overview](/architecture/architecture-overview--01a1833f2e83.md)
* [ADR-002: One shared Containerfile](/decisions/adr-002-one-shared-containerfile--01a18346a548.md)
