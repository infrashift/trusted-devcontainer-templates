---
id: "01a1834b-bc41-7162-9de5-9dc17dac007b"
title: "The main ruleset does not require the test-features gate"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "ci"
  - "features"
created: "2026-10-28T11:15:41-05:00"
timestamp: "2026-10-28T11:15:41-05:00"
description: "A PR that breaks a repo-local feature can merge, because the main ruleset does not require test-features/gate."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/test-features.yml"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:15:41-05:00"
status: "draft"
---

# The main ruleset does not require the test-features gate

## Problem

The `main` ruleset does not require the `test-features/gate` check. A PR that breaks a repo-local feature can merge.

## Context

On 2026-10-28 the ruleset required `repo-gate`, `build/gate` and `review/cve-policy`. `test-features.yml` is designed to be required: it has no path filter and one aggregate gate job. Step 6 of `SETUP-ENVIRONMENTS.md` does not name it.

## Acceptance criteria

- [ ] The `main` ruleset requires `test-features/gate`.
- [ ] Step 6 of `SETUP-ENVIRONMENTS.md` names it.

## Related

* [Test Features workflow](/supply-chain/test-features-workflow--01a18348dabd.md)
* [Set up the GitHub environments and signing keys](/operations/set-up-the-github-environments-and-signing-keys--01a183491902.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
