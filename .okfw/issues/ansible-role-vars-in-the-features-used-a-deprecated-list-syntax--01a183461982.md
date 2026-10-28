---
id: "01a18346-1982-7e66-953f-ab0d118d2144"
title: "Ansible role vars in the features used a deprecated list syntax"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "ansible"
created: "2026-10-28T11:09:31-05:00"
timestamp: "2026-10-28T11:09:31-05:00"
description: "The features repo Ansible roles declared vars as a list; commit 1e0157f changed all 20 files to dict syntax in v1.0.1."
x:
  todo: 1
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-features"
    title: "infrashift/trusted-devcontainer-features"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:31-05:00"
status: "deprecated"
---

# Ansible role vars in the features used a deprecated list syntax

The Ansible roles of the trusted features used the deprecated list syntax for `vars`. This issue is in the features repository.

## Problem

Each `activate-feature.yml` file declared role `vars` as a list. Current Ansible versions deprecate this syntax and show warnings or fail.

## Context

* Repository: `infrashift/trusted-devcontainer-features`.
* Scope: all 20 `activate-feature.yml` files.
* The templates install these features, so the defect affected every template build.

## Acceptance criteria

- [x] All 20 `activate-feature.yml` files use the dict syntax for `vars`.
- [x] A features release publishes the change.

## Resolution

* Commit: `1e0157f` in the features repository. Date: not recorded.
* Change: the list-style `vars` became dict-style `vars` in all 20 files.
* Release: features v1.0.1.

## Related

* [The ansible-core feature failed because the uv environment was not active](/issues/the-ansible-core-feature-failed-because-the-uv-environment-was-not-active--01a1834619c9.md)
* [The npm feature failed because Node.js was not on the PATH](/issues/the-npm-feature-failed-because-node-js-was-not-on-the-path--01a183461a0d.md)
* [The features needed sudo in the base image](/issues/the-features-needed-sudo-in-the-base-image--01a183461a52.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
