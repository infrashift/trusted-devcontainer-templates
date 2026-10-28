---
id: "01a18346-1c03-749a-b218-ae8566e151ff"
title: "The Makefile test path was outside the dev container mount"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "testing"
  - "makefile"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "A template dev container mounts only its folder, so the test scripts were not reachable; the build now bind-mounts test to /tmp/tdt-test."
x:
  todo: 5
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/build-template.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/3e3ea1c"
    title: "Commit 3e3ea1c"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The Makefile test path was outside the dev container mount

The `make test` target could not find the test scripts, because the template dev container mounts only its own template folder.

## Problem

`devcontainer up --workspace-folder src/<t>` mounts only `src/<t>`. The repository-level `test/` directory is outside that mount, so no relative path from inside the container can reach it. An earlier fix with `../../test/...` did not work either.

## Context

* Three call sites ran the tests: the `Makefile`, `test-pr.yaml` and `release.yaml`.
* The supply-chain hardening later replaced both workflows. See [The workflows did not match the hardened org reference pipeline](/issues/the-workflows-did-not-match-the-hardened-org-reference-pipeline--01a183461d9e.md).

## Acceptance criteria

- [x] The tests run inside each template container from all call sites.
- [x] The published templates do not change for the test.

## Resolution

* Commits: `9ec6a59` (2026-02-18, first attempt) and `3e3ea1c` (2026-08-23, final fix).
* All call sites bind-mount `test/` to `/tmp/tdt-test`.
* The bind mount is now in `scripts/build-template.sh`. Both `build.yml` and `release.yml` call that script.

## Related

* [Local tests used cached containers after a feature update](/issues/local-tests-used-cached-containers-after-a-feature-update--01a183461ca9.md)
* [The workflows did not match the hardened org reference pipeline](/issues/the-workflows-did-not-match-the-hardened-org-reference-pipeline--01a183461d9e.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
