---
id: "01a18349-1902-7971-975b-c3b268427998"
title: "Set up the GitHub environments and signing keys"
type: "runbook"
tags:
  - "runbook"
  - "setup"
  - "signing"
created: "2026-10-28T11:12:48-05:00"
timestamp: "2026-10-28T11:12:48-05:00"
description: "Make the three cosign keypairs, the three GitHub environments, their secrets, reviewers and ref policies, and the main ruleset, as SETUP-ENVIRONMENTS.md tells."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/SETUP-ENVIRONMENTS.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:48-05:00"
status: "draft"
---

# Set up the GitHub environments and signing keys

This runbook points to `SETUP-ENVIRONMENTS.md`. That file has the full commands. Do this procedure one time for a new repository, and again for each key rotation.

## Prerequisites

* `gh` with the scopes `admin:org`, `repo` and `write:packages`.
* cosign v2.6.1. Do not use cosign v3 to sign. It writes a different attestation layout.
* `opa` v1.19.1 and `jq`.

## Procedure

1. Make three cosign keypairs (`build`, `review`, `release`) in a directory in `/dev/shm`.

   WARNING: Do not make keys in a git working tree.
2. Copy `build.pub`, `review.pub` and `release.pub` to `.github/pdp/public-keys/`. Commit them.
3. Create the environments `Build-Actor`, `Review-Actor` and `Release-Actor`.
4. Set `COSIGN_PRIVATE_KEY` and `COSIGN_PASSWORD` in each environment.
5. Remove the key directory in `/dev/shm`.
6. Add the required reviewer to `Review-Actor` and `Release-Actor`.

   WARNING: Do not set "Prevent self-review" while the organization has one member. It stops all releases.
7. Limit `Release-Actor` to the tag pattern `v*`.

   WARNING: The environment `PUT` call replaces the environment. Send `reviewers` and `prevent_self_review` again in each call.
8. Add the branch `main` to the `Release-Actor` policies (step 4c).
9. After the first promotion of a feature, make its production package public (step 4d). Keep the staging packages private.
10. Set the `main` ruleset: require a pull request and the checks `repo-gate`, `build/gate` and `review/cve-policy`.
11. Run `make check`. Then open a test pull request that changes `src/python/`.

## Current state

The file records this state on 2026-08-23. The last column shows a check on 2026-10-28.

| Step | State in the file | Check on 2026-10-28 |
|---|---|---|
| 1. Three keypairs | done | not checked |
| 2. Public keys committed | done, `8d8d7d3` | four `.pub` files exist |
| 3. Environments and secrets | done | not checked |
| 4. Reviewers | done, `ryancraig` | not checked |
| 4b. `Release-Actor` tag `v*` | done | not checked |
| 4c. `Release-Actor` branch `main` | done 2026-09-25 | `release-features.yml` succeeded on 2026-10-09 |
| 4d. Feature packages public | not done | all eight production feature packages are public |
| 5. Teams | none, on purpose | not checked |
| 6. Ruleset `main` | done | requires `repo-gate`, `build/gate`, `review/cve-policy` |

## Work that is not done

* Step 5: teams, Code Owners review, "Prevent self-review" and one required approval. Do these together when a second maintainer joins.
* `test-features/gate` is not a required check.

## Analysis

The file is out of date in two places. The table says that step 4d is not done, but the packages are public. The text of step 6 says that `build/gate` and `review/cve-policy` are not required yet, but the ruleset requires them.

## Related

* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [Issue: the three-actor model needs GitHub settings](/issues/the-three-actor-model-needs-github-settings-that-only-a-human-can-apply--01a183461f5e.md)
* [Issue: CODEOWNERS and the human gate](/issues/codeowners-and-the-human-gate-assume-a-multi-person-org--01a183461fbb.md)
* [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md)
