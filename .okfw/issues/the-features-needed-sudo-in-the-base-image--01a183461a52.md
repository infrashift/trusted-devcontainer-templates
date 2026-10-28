---
id: "01a18346-1a52-7e57-b014-f5d33c26833a"
title: "The features needed sudo in the base image"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "ansible"
  - "privileges"
created: "2026-10-28T11:09:31-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "The feature Ansible tasks used become and needed sudo; v1.0.1 set become false, and the bootstrap runner later removed privilege handling."
x:
  todo: 4
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-features"
    title: "infrashift/trusted-devcontainer-features"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The features needed sudo in the base image

The trusted features needed `sudo` in the base image because their Ansible tasks used privilege escalation. This issue is in the features repository.

## Problem

The `activate-feature.yml` files used `become` for their tasks. The base image has no `sudo`, so the tasks failed. The templates added `sudo` to the shared Containerfile as a workaround.

## Context

* Repository: `infrashift/trusted-devcontainer-features`.
* Scope: all 20 `activate-feature.yml` files.
* The workaround in this repository is [The shared Containerfile installed sudo as a workaround](/issues/the-shared-containerfile-installed-sudo-as-a-workaround--01a183461c57.md).

## Acceptance criteria

- [x] No feature task uses `become`.
- [x] The base image does not need `sudo` for a feature install.

## Resolution

* Commit: `1e0157f` in the features repository. Date: not recorded.
* Change: all 20 files set `become: false`. Release: features v1.0.1.
* Later change: the bootstrap runner (ADR-008) runs the playbook as the target user. No per-task privilege handling remains.

## Related

* [The shared Containerfile installed sudo as a workaround](/issues/the-shared-containerfile-installed-sudo-as-a-workaround--01a183461c57.md)
* [Ansible role vars in the features used a deprecated list syntax](/issues/ansible-role-vars-in-the-features-used-a-deprecated-list-syntax--01a183461982.md)
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
* [ADR-008: Bootstrap feature supplies uv and Ansible](/decisions/adr-008-bootstrap-feature-supplies-uv-and-ansible--01a18346a716.md)
