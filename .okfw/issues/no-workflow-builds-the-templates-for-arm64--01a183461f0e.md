---
id: "01a18346-1f0e-7d7b-8fa7-8b0dd0718dce"
title: "No workflow builds the templates for arm64"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "arm64"
  - "ci"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "All templates declare linux/arm64, but no workflow builds a template in src/ for arm64, so arm64 support is not proven."
x:
  todo: 12
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/test-features.yml"
    title: "test-features.yml"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "draft"
---

# No workflow builds the templates for arm64

All templates declare `linux/arm64`, but no workflow builds the templates for arm64.

## Problem

Each template declares `linux/arm64` in `devcontainer-template.json`, and the base image is multi-arch. `build.yml` and `release.yml` build only on amd64 runners. So no template build proves that arm64 works.

## Context

* Every feature role derives its architecture from `_target_arch`, which the bootstrap runner sets. Each role maps it to the upstream name: `amd64`/`arm64` (go, cue, jq, yq, grype, syft), `x64`/`arm64` (dotnet, nodejs, pnpm), `x64`/`aarch64` (bun, openjdk), or a GNU triple (uv).
* Before this change, only `cuelang` and `pnpm` did this. An arm64 build installed an amd64 binary and passed verification, because the pinned digest was the amd64 digest.
* Each download is now checksum-verified per version and architecture. A missing arm64 digest fails by name. This is a loud failure, but it does not prove that arm64 works.
* `test-features.yml` builds the repo-local feature test templates `neovim-go` and `neovim-langs` on an `ubuntu-24.04-arm` runner (commit `fbd9d1a`, 2026-09-26). It does not build the templates in `src/`.
* `TODO.md` said that a `bootstrap` blocker stopped this item. That blocker was not real. See [The templates referenced trusted features by tag, not by digest](/issues/the-templates-referenced-trusted-features-by-tag-not-by-digest--01a183461df0.md).

## Acceptance criteria

- [ ] `devcontainer build --platform linux/arm64` passes for each template in `src/`.
- [ ] Each missing arm64 digest is added to the feature pins.
- [ ] A workflow builds each template on arm64, or the templates stop declaring `linux/arm64`.

## Related

* [The templates referenced trusted features by tag, not by digest](/issues/the-templates-referenced-trusted-features-by-tag-not-by-digest--01a183461df0.md)
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [CI Build & Audit workflow](/supply-chain/ci-build-audit-workflow--01a18348d928.md)
* [Base image](/architecture/base-image--01a183441025.md)
