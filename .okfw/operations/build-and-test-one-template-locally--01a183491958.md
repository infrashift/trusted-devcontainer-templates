---
id: "01a18349-1958-764c-9eae-4faa64aed336"
title: "Build and test one template locally"
type: "runbook"
tags:
  - "runbook"
  - "test"
  - "make"
created: "2026-10-28T11:12:48-05:00"
timestamp: "2026-10-28T11:12:48-05:00"
description: "Run make test-template TEMPLATE=<name> to build one template with the devcontainer CLI and run its smoke test from test/<name>/test.sh."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/Makefile"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:48-05:00"
status: "draft"
---

# Build and test one template locally

Run `make test-template TEMPLATE=<name>` to build one template and run its smoke test. The target uses the devcontainer CLI through `bunx`.

## Prerequisites

* Docker.
* Bun, for `bunx @devcontainers/cli`.

## Templates

`ansible-cue`, `dotnet-node`, `go-cue`, `java`, `neovim-ansible-cue`, `neovim-go`, `neovim-java`, `neovim-python`, `python`. The `TEMPLATES` list in the `Makefile` holds the same names.

## Procedure

1. Optional: run `make clean-containers`. It removes old dev containers, the Docker build cache and the CLI feature cache.
2. Run `make test-template TEMPLATE=python`.
3. Read the output. The target fails if `test/python/test.sh` fails.

The target mounts `test/` at `/tmp/tdt-test` in the container. `devcontainer up` mounts only `src/<name>`, so the test scripts need this mount.

## Other targets

| Target | What it does |
|---|---|
| `make test` | Runs `make check`, then tests all templates one after the other. |
| `make test-feature-template` | Builds `features/test/neovim-go` from the working tree of `features/src/`, then runs its tests and the contract tests. |
| `make lazy-lock` | Updates the LazyVim plugin lockfile. |

## Differences from CI

* CI also runs `devcontainer build`, Syft and Grype, and signs the evidence. See [CI Build & Audit workflow](/supply-chain/ci-build-audit-workflow--01a18348d928.md).
* CI tests the feature test templates `neovim-go` and `neovim-langs` on `amd64` and `arm64`. `make test-feature-template` tests only `neovim-go` on the local architecture. See [Test Features workflow](/supply-chain/test-features-workflow--01a18348dabd.md).

## Related

* [Run the static checks and the repo gate locally](/operations/run-the-static-checks-and-the-repo-gate-locally--01a1834919aa.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md)
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md)
