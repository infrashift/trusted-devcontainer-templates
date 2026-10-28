---
id: "01a18346-1b57-7574-b80d-8997acf67258"
title: "Features with the version latest did not upgrade"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "features-repo"
  - "pinning"
  - "npm"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "The claude-code and openai-codex features skipped the install for latest; they now resolve the npm dist-tag to a concrete version."
x:
  todo: 15
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-features"
    title: "infrashift/trusted-devcontainer-features"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/55322be"
    title: "Commit 55322be — Mark TODO 13-15 resolved"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# Features with the version latest did not upgrade

The `claude-code` and `openai-codex` trusted features did not upgrade when the requested version was `latest`. This issue is in the features repository.

## Problem

When the requested version was `latest`, the feature compared the string `latest` with the installed version. It found an installed version and skipped the install, so the tool never upgraded. The post-install check accepted any semver.

## Context

* Repository: `infrashift/trusted-devcontainer-features`.
* Affected features: `claude-code`, `openai-codex`.

## Acceptance criteria

- [x] A request for `latest` installs the version that the npm dist-tag `latest` points to.
- [x] The post-install check asserts that exact version.
- [x] A second run reports `changed=0`.

## Resolution

* Commit: `55322be` in this repository marks the item resolved (2026-08-23). The fix is in the features repository.
* The features query the npm registry for the `latest` dist-tag before the compare. The install always pins a concrete version.
* Test: a downgrade to 2.1.240 and then a request for `latest` upgraded to 2.1.241 (`changed=1`). A second request reported `changed=0`.
* The contract tests pin the installed version, not `latest`, so an npm publish during a test cannot cause a race.

## Related

* [No check asserts that pinned tool versions are current](/issues/no-check-asserts-that-pinned-tool-versions-are-current--01a183462092.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
