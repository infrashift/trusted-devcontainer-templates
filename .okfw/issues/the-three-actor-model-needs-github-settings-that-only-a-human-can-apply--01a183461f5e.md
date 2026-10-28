---
id: "01a18346-1f5e-772c-948c-6a6c86fd4773"
title: "The three-actor model needs GitHub settings that only a human can apply"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "signing"
  - "github-settings"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "The signing actors need keys, environments and a ruleset set by a human; as of 2026-10-28 only a key-storage check remains."
x:
  todo: 18
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/SETUP-ENVIRONMENTS.md"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/8d8d7d3"
    title: "Commit 8d8d7d3 — Add build, review and release public keys"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/actions/runs/32684073015"
    title: "Run 32684073015"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "draft"
---

# The three-actor model needs GitHub settings that only a human can apply

The three-actor signing model needs GitHub settings that only a human can apply. As of 2026-10-28, all recorded steps appear complete.

## Problem

The signing actors need keys, environment secrets, environment rules and a ruleset on `main`. A workflow cannot set these items.

## Context

State that `TODO.md` recorded:

| Step | State |
|---|---|
| Three keypairs with three different keys | done |
| `build.pub`, `review.pub`, `release.pub` committed | done, commit `8d8d7d3` |
| Build-Actor, Review-Actor, Release-Actor with their own secrets | done |
| Environment reviewers | done: `ryancraig` on Review-Actor and Release-Actor |
| Release-Actor ref restriction | done: one `tag v*` policy |
| Ruleset on `main` | done: requires a PR and `repo-gate` |

Add the required status checks in sequence:

1. Add `repo-gate`. It runs static checks only.
2. Add `build/gate`. Run `32684073015` built, tested, scanned and signed all five templates.
3. Add `review/cve-policy` only after a PR resolved it. A `workflow_run` workflow does not start until its file is on the default branch.

The retired `Sync Containerfile Check` context is not on the ruleset.

### Verified state on 2026-10-28

* The ruleset `main` (id `21259925`) requires `repo-gate`, `build/gate` and `review/cve-policy`, with `strict_required_status_checks_policy: true`.
* Review-Actor and Release-Actor have the required reviewer `ryancraig`. Build-Actor has no rules.
* No `cosign.key` file is in the working tree. `.gitignore` ignores `**/*.key`.

## Acceptance criteria

- [x] The three status checks are required on `main`.
- [ ] A human confirms that the old `cosign.key` is stored outside the working tree, or destroyed.

## Analysis

All criteria except the human confirmation are met. Close this issue after that confirmation.

## Related

* [The workflows did not match the hardened org reference pipeline](/issues/the-workflows-did-not-match-the-hardened-org-reference-pipeline--01a183461d9e.md)
* [CODEOWNERS and the human gate assume a multi-person org](/issues/codeowners-and-the-human-gate-assume-a-multi-person-org--01a183461fbb.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
