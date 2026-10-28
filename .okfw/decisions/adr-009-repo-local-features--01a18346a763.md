---
id: "01a18346-a763-7a93-9b58-17795ecc3d12"
title: "ADR-009: Repo-local features"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "features"
  - "repo-local-features"
  - "neovim"
created: "2026-10-28T11:10:08-05:00"
timestamp: "2026-10-28T11:10:08-05:00"
description: "ADR-009 builds, tests and publishes the editor features from features/ in this repository, under the trusted feature contract."
x:
  adr: 9
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-009-repo-local-features.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:08-05:00"
status: "draft"
---

# ADR-009: Repo-local features

ADR-009 builds, tests and publishes the editor features from this repository, in `features/`, under the same contract and release model as `trusted-devcontainer-features`.

**Status:** Accepted.

## Decision

Keep the first version of the features in `features/src/<id>` and publish them to `ghcr.io/infrashift/trusted-devcontainer-templates/features/<id>`. Use the role contract of the features repository (its ADR-012) and a stage, review and promote release. `dependsOn` names `bootstrap` by an absolute digest, and the release runs on a push to `main`.

## Reason

* `neovim-go` needed features that did not exist: `tmux`, `neovim`, `lazyvim` and `go-tools`.
* Two repositories for one change would need a feature release, a re-pin and a template rebuild for each editor change.
* The hand-built image that the template replaces fetched tools without checksums or pins.

## Consequences

* The template and its features change together in one repository.
* There are two feature collections to audit, and the pipeline copy can drift from the features repository.
* `make lazy-lock` is the one unpinned step. Its output is a diff of plugin commits.

## Analysis

The ADR describes four features for one template. On 2026-10-28 `features/src/` has eight features, and four neovim templates use them. No template uses `python-tools`.

## Related

* [Repo-local features](/architecture/repo-local-features--01a183450227.md) — the features, tests and release now.
* [Feature pinning](/architecture/feature-pinning--01a183457520.md) — how the templates pin them.
* [ADR-006: Trusted features only](/decisions/adr-006-trusted-features-only--01a18346a677.md) — amended for the second collection.
* [Template: neovim-go](/templates/template-neovim-go--01a18347f160.md)
* [Template: neovim-ansible-cue](/templates/template-neovim-ansible-cue--01a18347f0f7.md)
* [Template: neovim-java](/templates/template-neovim-java--01a18347f1c9.md)
* [Template: neovim-python](/templates/template-neovim-python--01a18347f232.md)
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
* [Release Features workflow](/supply-chain/release-features-workflow--01a18348da61.md)
* [Three ADRs no longer match the code](/issues/three-adrs-no-longer-match-the-code--01a1834bba80.md)
