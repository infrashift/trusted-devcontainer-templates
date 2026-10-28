---
id: "01a18346-1fbb-75e8-8c22-733744ef8cc8"
title: "CODEOWNERS and the human gate assume a multi-person org"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "github-settings"
  - "governance"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "The org has one member, so required approvals and code owner review block every merge; approvals stay at 0 until a second maintainer joins."
x:
  todo: 19
  github:
    - 6
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/CODEOWNERS"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/e4ac93e"
    title: "Commit e4ac93e"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/a08eed0"
    title: "Commit a08eed0"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/pull/6"
    title: "PR #6 — Record why approvals stay at 0"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "draft"
---

# CODEOWNERS and the human gate assume a multi-person org

The CODEOWNERS file and the human gate came from a multi-person org, but `infrashift` has one member and no teams. Approvals stay at 0 until a second maintainer joins.

## Problem

The hardening in [The workflows did not match the hardened org reference pipeline](/issues/the-workflows-did-not-match-the-hardened-org-reference-pipeline--01a183461d9e.md) copied a team structure from `trusted-service-containers`. Single-member teams give no dual control. GitHub does not let a user approve the user's own PR. So "Require review from Code Owners", a required approval or *Prevent self-review* blocks every merge, or forces an admin bypass on every merge.

## Context

* `gh api orgs/infrashift/teams` returns an empty list.
* `CODEOWNERS` names `@ryancraig`. Its header says that it assigns reviewers and gates nothing.
* `SETUP-ENVIRONMENTS.md` steps 4 and 5 explain what key separation gives at one member, and what to change when a second maintainer joins.

### Test on 2026-08-24

1. The ruleset was set to `required_approving_review_count: 1`, with a `RepositoryRole` 5 bypass and `bypass_mode: always`.
2. Three PRs in two repositories then showed `reviewDecision: REVIEW_REQUIRED` and `mergeStateStatus: BLOCKED`. The bypass did not clear this state.
3. The count went back to 0, and two PRs became `CLEAN`.
4. The bypass actor was removed. `bypass_mode: always` covers the full ruleset, so an admin could merge past `repo-gate`, `build/gate` and `review/cve-policy`.

Record: commit `a08eed0`, PR #6.

### Verified state on 2026-10-28

`required_approving_review_count: 0`, `require_code_owner_review: false`, `bypass_actors: []`, `current_user_can_bypass: never`.

### Other observations

* `trusted-service-containers` has no `required_reviewers` on its three environments. Only Release-Actor has a `branch_policy`.
* On GitHub Free, deployment protection rules and branch protection work only on public repositories. If a repository becomes private without a Team plan, these protections stop.

## Acceptance criteria

- [ ] When a second maintainer joins: create the teams, update `CODEOWNERS`, set approvals to 1 and turn on code owner review in one change.

## Related

* [The workflows did not match the hardened org reference pipeline](/issues/the-workflows-did-not-match-the-hardened-org-reference-pipeline--01a183461d9e.md)
* [The three-actor model needs GitHub settings that only a human can apply](/issues/the-three-actor-model-needs-github-settings-that-only-a-human-can-apply--01a183461f5e.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
