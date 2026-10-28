---
id: "01a18346-19c9-774e-b5fc-89c09bdebd0a"
title: "The ansible-core feature failed because the uv environment was not active"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "ansible"
created: "2026-10-28T11:09:31-05:00"
timestamp: "2026-10-28T11:09:31-05:00"
description: "The ansible-core feature failed its Python check without an active uv environment; v1.0.1 made the check non-fatal."
x:
  todo: 2
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

# The ansible-core feature failed because the uv environment was not active

The `ansible-core` trusted feature failed because the uv virtual environment was not active when the Python check ran. This issue is in the features repository.

## Problem

The `ansible-core` feature ran a Python verification task. The uv virtual environment was not active in that task, so the task failed and stopped the feature install.

## Context

* Repository: `infrashift/trusted-devcontainer-features`.
* Every template that declares `ansible-core` could not build.

## Acceptance criteria

- [x] The `ansible-core` feature installs without a failure in a template build.

## Resolution

* Commit: `1e0157f` in the features repository. Date: not recorded.
* Change: the Python verification task became non-fatal with `ignore_errors: true`.
* Release: features v1.0.1.

## Analysis

The fix hides the failed check. It does not activate the environment. The later bootstrap runner (ADR-008) replaced this install path.

## Related

* [Ansible role vars in the features used a deprecated list syntax](/issues/ansible-role-vars-in-the-features-used-a-deprecated-list-syntax--01a183461982.md)
* [The npm feature failed because Node.js was not on the PATH](/issues/the-npm-feature-failed-because-node-js-was-not-on-the-path--01a183461a0d.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
* [ADR-008: Bootstrap feature supplies uv and Ansible](/decisions/adr-008-bootstrap-feature-supplies-uv-and-ansible--01a18346a716.md)
