---
id: "01a18348-d8cc-78e0-9858-ea7a38cd34c2"
title: "PR Gate workflow"
type: "component"
tags:
  - "supply-chain"
  - "workflow"
  - "pr-gate"
created: "2026-10-28T11:12:31-05:00"
timestamp: "2026-10-28T11:12:31-05:00"
description: "The pr-gate.yml workflow runs on every pull request, evaluates the repository half of the PDP, and seeds two required statuses."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/pr-gate.yml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/repo-gate.sh"
    title: "scripts/repo-gate.sh"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:31-05:00"
status: "draft"
---

# PR Gate workflow

The `PR Gate` workflow (`pr-gate.yml`) runs on every pull request to `main`. It has no path filter, so its required check always reports, also on a pull request that changes only documentation.

## Trigger

* `pull_request` to `main`.
* No `paths:` filter. `scripts/lint-workflows.sh` makes sure that nobody adds one.

## Jobs

| Job | Environment | What it does |
|---|---|---|
| `repo-gate` | none | Runs the static checks and evaluates `data.tdt.pdp.repo_decision`. Publishes the `repo-gate` check. |
| `Seed Review Status` | none | Sets the `review/cve-policy` status. Sets the `build/gate` status when no build path changed. |

## Steps of the `repo-gate` job

1. Install the pinned `opa` and `gitleaks` from `tools.lock`.
2. Make sure that `.gitleaks.toml` has 64 bytes or more and sets `useDefault = true`.
3. Run `scripts/check-no-orphan-rego.sh`. Only one policy can exist.
4. Run `scripts/lint-workflows.sh`.
5. Run `scripts/pin-features.sh --check`. Each feature reference must have a digest.
6. Run `scripts/check-test-assertions.sh`.
7. Run `make check-sync`. Each managed Containerfile must be identical to the shared Containerfile.
8. Run the static checks of the repo-local features in `features/scripts/`.
9. Run `shellcheck` on the shell scripts.
10. Run `opa check --strict`, `opa fmt --list` and `opa test`. The coverage floor is 85%.
11. Run `scripts/repo-gate.sh`. It writes `repo-decision.json`.

The checkout uses `fetch-depth: 0`, because `gitleaks` scans the full history.

## Seeded statuses

The [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md) runs on `workflow_run`, so it cannot report a check against the pull request. The `Seed Review Status` job sets the start value:

| Build path changed? | `review/cve-policy` | `build/gate` |
|---|---|---|
| Yes | `pending` | not set (`build.yml` sets it) |
| No | `success` | `success` |

The regular expression `BUILD_PATHS` in this job must agree with the `paths:` filter in [`build.yml`](/supply-chain/ci-build-audit-workflow--01a18348d928.md). If they do not agree, a required check never reports and the pull request stays blocked.

The job does not run on a pull request from a fork. A fork token cannot write commit statuses.

## Signing actor

None. This workflow does not sign.

## Output

* The `repo-gate` check and the `repo-decision` artifact.
* The `review/cve-policy` and `build/gate` commit statuses.

## Related

* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [CI Build & Audit workflow](/supply-chain/ci-build-audit-workflow--01a18348d928.md)
* [Run the static checks and the repo gate locally](/operations/run-the-static-checks-and-the-repo-gate-locally--01a1834919aa.md)
* [Supply chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [The docs site describes the old pipeline and trust model](/issues/the-docs-site-describes-the-old-pipeline-and-trust-model--01a1834bba2d.md)
