---
id: "01a18345-bbe3-7ed8-8641-5cad8806efd0"
title: "Repository layout and tests"
type: "component"
tags:
  - "architecture"
  - "layout"
  - "tests"
  - "workflows"
created: "2026-10-28T11:09:07-05:00"
timestamp: "2026-10-28T11:09:07-05:00"
description: "A map of the repository: src/ templates, test/ smoke tests and test-utils, the seven workflows, and the Makefile check and test targets."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/Makefile"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/.github/workflows"
    title: "Workflows"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/test-utils/test-utils.sh"
    title: "test-utils.sh"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:07-05:00"
status: "draft"
---

# Repository layout and tests

This concept is a short map of the repository, its workflows and its test framework. Each template is a directory in `src/` with a smoke test in `test/`.

## Directories

| Path | Holds |
|---|---|
| `src/<template>/` | `devcontainer-template.json`, `NOTES.md`, and `.devcontainer/` with `devcontainer.json` and a copy of the shared Containerfile |
| `test/<template>/test.sh` | The smoke test of one template |
| `test/test-utils/test-utils.sh` | The test functions `check`, `checkCommon` and `reportResults` |
| `shared/Containerfile` | The one source for all Containerfiles. See [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md). |
| `features/` | Repo-local features: `src/`, `test/` (`neovim-go`, `neovim-langs`, `shared`) and `scripts/`. See [Repo-local features](/architecture/repo-local-features--01a183450227.md). |
| `scripts/` | Build, review, publish, pin and gate scripts |
| `.github/pdp/` | The PDP: `policies.rego`, `policies_test.rego`, `exceptions.yaml` and `public-keys/` |
| `.github/workflows/` | Seven workflows (below) |
| `tools.lock` | CI tool versions with SHA256 values |
| `repo-decision.json` | The last output of `make repo-gate` |
| `docs/` | The documentation site, with the ADRs and the template pages |
| `.okfw/` | This wiki |

The nine templates are [Template: ansible-cue](/templates/template-ansible-cue--01a18347eeeb.md), [Template: dotnet-node](/templates/template-dotnet-node--01a18347ef4f.md), [Template: go-cue](/templates/template-go-cue--01a18347efb8.md), [Template: java](/templates/template-java--01a18347f023.md), [Template: python](/templates/template-python--01a18347f091.md), [Template: neovim-ansible-cue](/templates/template-neovim-ansible-cue--01a18347f0f7.md), [Template: neovim-go](/templates/template-neovim-go--01a18347f160.md), [Template: neovim-java](/templates/template-neovim-java--01a18347f1c9.md) and [Template: neovim-python](/templates/template-neovim-python--01a18347f232.md).

## Workflows

| File | Name | Trigger |
|---|---|---|
| `pr-gate.yml` | PR Gate | pull request to `main` |
| `build.yml` | CI Build & Audit | pull request to `main` that changes build paths |
| `review.yml` | Review Attestations | `workflow_run` after CI Build & Audit |
| `release.yml` | Release Templates | push of a `v*` tag |
| `test-features.yml` | Test Features | pull request to `main` |
| `release-features.yml` | Release Features | push to `main` that changes `features/` |
| `deploy-docs.yaml` | Deploy Documentation | push to `main` that changes `docs/`, or manual |

## Test framework

`test-utils.sh` gives three functions:

* `check <label> <command>` runs the command and records PASS or FAIL.
* `checkCommon` checks the dev user (`dev`, UID 1001, GID 1001) and that `git`, `git-lfs`, `grype`, `syft`, `jq`, `yq` and `uv` are on `PATH`.
* `reportResults` prints the results and exits with 1 if one check failed.

To test one template, `make test-template TEMPLATE=<name>` does these steps:

1. It runs `devcontainer up` on `src/<name>`.
2. It mounts `test/` at `/tmp/tdt-test`, because `devcontainer up` mounts only `src/<name>`.
3. It runs `test/<name>/test.sh` in the container with `devcontainer exec`.

## Makefile targets

| Target | What it does |
|---|---|
| `make check` | Runs all static checks: `check-sync`, `check-pins`, `check-assertions`, `check-workflows`, `check-features`, `check-policy`, `repo-gate` |
| `make test` | Runs `make check`, then tests all nine templates one after the other |
| `make test-template TEMPLATE=<name>` | Builds and tests one template |
| `make test-feature-template` | Builds and tests the repo-local features |
| `make pin-features` | Pins all features by digest. See [Feature pinning](/architecture/feature-pinning--01a183457520.md). |
| `make sync-containerfiles` | Copies the shared Containerfile |
| `make tools` | Installs the pinned CI tools: `opa`, `gitleaks`, `syft`, `grype` |

## Analysis

`docs/src/content/docs/reference/architecture.md` is out of date:

* It names the workflows `release.yaml`, `test-pr.yaml` and `sync-containerfile.yaml`. These files do not exist.
* It shows five templates. There are nine.
* It does not show `features/`, `scripts/`, `tools.lock` or `.github/pdp/exceptions.yaml`.

## Related

* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md) — one concept for each template.
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md) — the build, review and release workflows.
* [Architecture overview](/architecture/architecture-overview--01a1833f2e83.md)
* [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md)
* [CI Build & Audit workflow](/supply-chain/ci-build-audit-workflow--01a18348d928.md)
* [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md)
* [No CUE schema validates devcontainer.json](/issues/no-cue-schema-validates-devcontainer-json--01a1834bbad5.md)
