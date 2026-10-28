---
id: "01a18348-dabd-7c27-864e-b9dc94bd86d2"
title: "Test Features workflow"
type: "component"
tags:
  - "supply-chain"
  - "workflow"
  - "features"
  - "test"
created: "2026-10-28T11:12:32-05:00"
timestamp: "2026-10-28T11:12:32-05:00"
description: "The test-features.yml workflow builds the feature test templates on amd64 and arm64 for a pull request, and runs smoke and contract tests."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/test-features.yml"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:32-05:00"
status: "draft"
---

# Test Features workflow

The `Test Features` workflow (`test-features.yml`) tests the repo-local features on a pull request. It builds the feature test templates from the working tree on `amd64` and `arm64`, and runs the smoke tests and the contract tests.

## Trigger

* `pull_request` to `main`.
* No `paths:` filter. The `Compute Matrix` job decides at run time.

## Matrix selection

| Changed paths | Matrix |
|---|---|
| `features/`, `shared/Containerfile`, `tools.lock` or `test-features.yml` | Four legs: `neovim-go` and `neovim-langs`, each on `amd64` (`ubuntu-latest`) and `arm64` (`ubuntu-24.04-arm`) |
| Other paths | Empty |

## Jobs

| Job | Environment | What it does |
|---|---|---|
| `Compute Matrix` | none | Selects the legs. |
| `Test features (<template>, <arch>)` | none | Copies `features/src/` into the test template, runs `devcontainer up`, `tests.sh` and `features/test/shared/contract-tests.sh`. |
| `test-features/gate` | none | Combines the legs into one check. Reports success when the matrix is empty. |

The contract tests run each role two times to show idempotency. They also make sure that each parameter fails with its name.

## Signing actor

None. This workflow does not sign and does not publish.

## Output

The `test-features/gate` check.

## Required check

On 2026-10-28, the `main` ruleset does not require `test-features/gate`. It requires `repo-gate`, `build/gate` and `review/cve-policy`.

## Related

* [Release Features workflow](/supply-chain/release-features-workflow--01a18348da61.md)
* [Release the repo-local features](/operations/release-the-repo-local-features--01a183491acc.md)
* [Issue: no workflow builds the templates for arm64](/issues/no-workflow-builds-the-templates-for-arm64--01a183461f0e.md)
* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [Build and test one template locally](/operations/build-and-test-one-template-locally--01a183491958.md)
* [Supply chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [The main ruleset does not require the test-features gate](/issues/the-main-ruleset-does-not-require-the-test-features-gate--01a1834bbc41.md)
