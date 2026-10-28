---
id: "01a18345-0227-70c9-9bcc-9ea6b30541c6"
title: "Repo-local features"
type: "component"
tags:
  - "architecture"
  - "features"
  - "repo-local-features"
  - "neovim"
created: "2026-10-28T11:08:20-05:00"
timestamp: "2026-10-28T11:08:20-05:00"
description: "This repository builds, tests and releases eight features in features/src/, under the same contract as trusted-devcontainer-features."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/features"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/features/README.md"
    title: "Repo-local features README"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/test-features.yml"
    title: "test-features.yml"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/release-features.yml"
    title: "release-features.yml"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:08:20-05:00"
status: "draft"
---

# Repo-local features

This repository builds, tests and publishes eight features of its own, in `features/src/`. The release publishes them to `ghcr.io/infrashift/trusted-devcontainer-templates/features/<id>` (ADR-009).

## The features

Versions are the pinned versions on 2026-10-28.

| Feature | Version | Lane | Installs | Used by |
|---|---|---|---|---|
| `tmux` | 1.0.1 | privileged | tmux, `/etc/tmux.conf`, the `dev-session` layout and its login hook | the four neovim templates |
| `neovim` | 1.0.1 | userland | the upstream Neovim release build (default 0.12.5) | the four neovim templates |
| `lazyvim` | 1.2.3 | both | LazyVim, each plugin at a locked commit, tree-sitter parsers, `stylua`, `shfmt`, the tree-sitter CLI | the four neovim templates |
| `go-tools` | 1.0.1 | userland | gopls, gofumpt, goimports, gomodifytags, impl, dlv, golangci-lint | [Template: neovim-go](/templates/template-neovim-go--01a18347f160.md) |
| `java-tools` | 1.0.1 | userland | jdtls, lombok, and a `jdtls` launcher that needs no Python | [Template: neovim-java](/templates/template-neovim-java--01a18347f1c9.md) |
| `pyrefly` | 1.0.1 | userland | pyrefly, with `uv tool install` | [Template: neovim-python](/templates/template-neovim-python--01a18347f232.md) |
| `ansible-tools` | 1.0.2 | userland | ansible-lint, with `uv tool install` | [Template: neovim-ansible-cue](/templates/template-neovim-ansible-cue--01a18347f0f7.md) |
| `python-tools` | 1.0.2 | userland | basedpyright, with `uv tool install` | no template |

Each feature obeys the feature contract of `trusted-devcontainer-features`. See [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md).

## Differences from trusted-devcontainer-features

* `dependsOn` names `bootstrap` by an absolute, digest-pinned reference. It must be the same digest that the templates pin. `features/scripts/check-bootstrap-pin.sh` checks this.
* `installsAfter` names a sibling as `./<id>`. The release changes these references to the production namespace (`rewrite-feature-refs.sh`).
* The release runs on a push to `main`, not on a `v*` tag. A template can pin a feature only after the feature is published.

## Tests

| Check | What it does | Where it runs |
|---|---|---|
| `make check-features` | Role contract, bootstrap pin, published-version drift, and a dry run of the reference rewrite | `pr-gate.yml` |
| `make test-feature-template` | Copies `features/src/*` into `features/test/neovim-go`, builds it, runs `tests.sh`, then runs `contract-tests.sh` | local, and `test-features.yml` |

`test-features.yml` runs on each pull request. Its matrix has two test templates, `neovim-go` and `neovim-langs`, on `amd64` and `arm64`. `neovim-langs` tests the language tool features and the Python, Java, CUE and ansible-lint extras. One aggregate job, `gate`, is the required check.

A change to the source of a feature needs a version change in its `devcontainer-feature.json`. If not, `check-published-drift.sh` fails the pull request.

## Release

`release-features.yml` runs on a push to `main` that changes `features/src/**`, `features/scripts/**` or the workflow.

1. **stage** (Build-Actor): publish to the private staging namespace. Unchanged versions come from production, so their digests do not change.
2. **review** (Review-Actor): read the staged artifacts back. Check that no reference is relative and that `dependsOn` equals the bootstrap of the templates. Sign a verdict that names the approved digests.
3. **promote** (Release-Actor): verify the verdict with `review.pub`. Sign the staged digests with the key and keylessly. Copy those digests, with their signatures, to production.

After the release, run `make pin-features` in a different pull request. See [Feature pinning](/architecture/feature-pinning--01a183457520.md).

## LazyVim plugin lock

`features/src/lazyvim/ansible-role-feature/files/nvim/lazy-lock.json` sets the commit of each plugin. `make lazy-lock` makes the file again. It is the one unpinned step, and its output is a diff of commit hashes to review. Change the `lazyvim` version in the same commit.

## Analysis

* ADR-009 describes four features for one template, `neovim-go`. The collection now has eight features, and four templates use them.
* `python-tools` (basedpyright) is published but no template uses it. `neovim-python` uses `pyrefly`.
* ADR-009 says that the features move to `trusted-devcontainer-features` later. The ADR gives the migration steps.

## Related

* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md) — the decision for repo-local features.
* [ADR-006: Trusted features only](/decisions/adr-006-trusted-features-only--01a18346a677.md) — the trust rule, which now permits two feature prefixes.
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md) — signing actors and the release pipeline.
* [Architecture overview](/architecture/architecture-overview--01a1833f2e83.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [Release Features workflow](/supply-chain/release-features-workflow--01a18348da61.md)
