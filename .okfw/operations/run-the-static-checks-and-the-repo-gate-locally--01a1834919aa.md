---
id: "01a18349-19aa-79f7-b7e4-e10fdeb23dde"
title: "Run the static checks and the repo gate locally"
type: "runbook"
tags:
  - "runbook"
  - "pdp"
  - "make"
created: "2026-10-28T11:12:48-05:00"
timestamp: "2026-10-28T11:12:48-05:00"
description: "Run make check before a push. It runs the static checks of the repo-gate CI job, including the PDP, without container builds."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/repo-gate.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/Makefile"
    title: "Makefile"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:48-05:00"
status: "draft"
---

# Run the static checks and the repo gate locally

Run `make check` before you push. It runs the same static checks as the `repo-gate` job of the [PR Gate workflow](/supply-chain/pr-gate-workflow--01a18348d8cc.md), without container builds.

## Prerequisites

* `jq`, `curl` and network access to `ghcr.io`.
* The pinned tools from `tools.lock`.

## Procedure

1. Run `BIN=~/.local/bin make tools`. It installs `opa`, `gitleaks`, `syft` and `grype`.
2. Run `make check`.
3. If a check fails, use the fix in the table below.
4. To run only the PDP, run `make repo-gate`. Read `repo-decision.json`.

## Checks in `make check`

| Target | Script or command | Fix when it fails |
|---|---|---|
| `check-sync` | `diff` of each managed Containerfile | `make sync-containerfiles` |
| `check-pins` | `scripts/pin-features.sh --check` | `make pin-features` |
| `check-assertions` | `scripts/check-test-assertions.sh` | Change the smoke test to the requested version. |
| `check-workflows` | `scripts/lint-workflows.sh` | Pin the action to a commit SHA with a version comment. |
| `check-features` | `features/scripts/check-*.sh` | Bump the feature `version`. |
| `check-policy` | `opa check`, `opa fmt`, `opa test`, coverage 85% | `opa fmt -w .github/pdp/`, or add tests. |
| `repo-gate` | `scripts/repo-gate.sh` | Read the violation codes. |

`repo-decision.json` is in `.gitignore`.

## Differences from CI

* CI also runs `shellcheck -S warning` on the shell scripts. `make check` does not.
* CI clones the full history, so `gitleaks` scans all commits. A local shallow clone scans fewer commits.

## Related

* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
* [Issue: no check asserts that pinned tool versions are current](/issues/no-check-asserts-that-pinned-tool-versions-are-current--01a183462092.md)
* [Build and test one template locally](/operations/build-and-test-one-template-locally--01a183491958.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md)
