---
id: "01a18346-1a0d-784d-930e-71cdaf09c746"
title: "The npm feature failed because Node.js was not on the PATH"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "ansible"
created: "2026-10-28T11:09:31-05:00"
timestamp: "2026-10-28T11:09:31-05:00"
description: "The npm feature version check could not find Node.js; v1.0.1 sets PATH in that task."
x:
  todo: 3
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

# The npm feature failed because Node.js was not on the PATH

The `npm` trusted feature failed because Node.js was not on the `PATH` of the version check task. This issue is in the features repository.

## Problem

The `npm` feature ran an `npm --version` check. The task did not have the Node.js directory on its `PATH`, so the check failed.

## Context

* Repository: `infrashift/trusted-devcontainer-features`.
* Every template that declares `npm` could not build.

## Acceptance criteria

- [x] The `npm` version check finds Node.js and passes.

## Resolution

* Commit: `1e0157f` in the features repository. Date: not recorded.
* Change: the version check task got an `environment` block that sets `PATH`.
* Release: features v1.0.1.

## Related

* [Ansible role vars in the features used a deprecated list syntax](/issues/ansible-role-vars-in-the-features-used-a-deprecated-list-syntax--01a183461982.md)
* [The ansible-core feature failed because the uv environment was not active](/issues/the-ansible-core-feature-failed-because-the-uv-environment-was-not-active--01a1834619c9.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
