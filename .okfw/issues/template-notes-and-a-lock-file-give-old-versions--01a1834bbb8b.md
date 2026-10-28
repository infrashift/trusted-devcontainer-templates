---
id: "01a1834b-bb8b-7460-b61e-6c5b62dec992"
title: "Template NOTES and a lock file give old versions"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "pinning"
  - "python"
  - "ansible-cue"
created: "2026-10-28T11:15:40-05:00"
timestamp: "2026-10-28T11:15:40-05:00"
description: "Two NOTES.md files and the python devcontainer-lock.json give versions older than the pins, and no script updates them."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/src/python/.devcontainer/devcontainer-lock.json"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:15:40-05:00"
status: "draft"
---

# Template NOTES and a lock file give old versions

## Problem

Two kinds of template support files give old versions. No script updates them when the pins change.

## Context

1. `src/ansible-cue/NOTES.md` says Ansible Core 2.18.2 and Python 3.12. The template installs Ansible 2.21.5 and Python 3.14.
2. `src/python/NOTES.md` says Python 3.12. The template installs Python 3.14.
3. `src/python/.devcontainer/devcontainer-lock.json` is tracked in git. It names `bootstrap` 1.1.0 (`0bb69a6a2da1`). The template pins 1.6.1. No other template has a lock file.

## Acceptance criteria

- [ ] The `NOTES.md` files give the current versions, or no versions.
- [ ] The lock file is removed, or a script updates it with the pins.

## Related

* [Template: ansible-cue](/templates/template-ansible-cue--01a18347eeeb.md)
* [Template: python](/templates/template-python--01a18347f091.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
