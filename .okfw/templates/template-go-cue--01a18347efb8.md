---
id: "01a18347-efb8-7d90-91f6-13c9c17cef7e"
title: "Template: go-cue"
type: "template"
tags:
  - "template"
  - "go-cue"
created: "2026-10-28T11:11:32-05:00"
timestamp: "2026-10-28T11:11:32-05:00"
description: "The go-cue template gives Go 1.27 and CUE for CLI and TUI development, with the common scanning and data tools."
x:
  template: "go-cue"
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/src/go-cue"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/go-cue.mdx"
    title: "Template page: go-cue"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/go-cue/test.sh"
    title: "Smoke test: go-cue"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:11:32-05:00"
status: "draft"
---

# Template: go-cue

The `go-cue` template gives a Go and CUE environment for CLI and TUI development. It is template version 1.0.4, for `linux/amd64` and `linux/arm64`.

## Features

| Feature | Collection | Version | Digest | Options |
|---|---|---|---|---|
| `bootstrap` | trusted | 1.6.1 | `5f7d508100f8…` | defaults |
| `golang` | trusted | 1.5.4 | `618328f92ee5…` | defaults |
| `cuelang` | trusted | 1.5.3 | `4ac7c4061478…` | defaults |
| `git` | trusted | 1.4.2 | `b0376331c9c6…` | defaults |
| `git-lfs` | trusted | 1.4.2 | `23fbc69b4e73…` | defaults |
| `grype` | trusted | 1.6.0 | `d3763305a4fe…` | defaults |
| `syft` | trusted | 1.6.0 | `2643a9b3cb80…` | defaults |
| `jq` | trusted | 1.5.3 | `d5dabb81c904…` | defaults |
| `yq` | trusted | 1.6.0 | `c4417457d1d3…` | defaults |

All features are trusted features. The defaults of the pinned features give Go 1.27.3 and CUE 0.17.1.

## User

The template runs as the dev user `dev` (UID 1001). `devcontainer.json` sets `containerUser: "dev"` and `updateRemoteUserUID: false`. It does not set `remoteUser`, so the remote user is also `dev`. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Test

`test/go-cue/test.sh` runs `checkCommon`, then checks that `go` and `cue` are on `PATH`. It does not check versions.

## Notes

* `CLAUDE.md` asks for `gopls` and the CUE language server in a Go and CUE template. This template has no `go-tools` feature, and its test does not check `gopls`. [Template: neovim-go](/templates/template-neovim-go--01a18347f160.md) installs `gopls` through `go-tools`.
* The waiver `EXC-2026-0002` covers Go toolchain findings in `cue`, `grype` and `syft` until 2026-11-27. `EXC-2026-0001` covers `git-lfs` until 2026-11-22. See [Waiver EXC-2026-0002 accepts two Go advisories in grype, syft, cue and shfmt until 2026-11-27](/findings/waiver-exc-2026-0002-accepts-two-go-advisories-in-grype-syft-cue-and-shfmt-until-2026-11-27--01a18346ee2f.md) and [Waiver EXC-2026-0001 accepts Critical Go findings in git-lfs until 2026-11-22](/findings/waiver-exc-2026-0001-accepts-critical-go-findings-in-git-lfs-until-2026-11-22--01a18346edbb.md).

## Related

* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the test framework.
* [Template: neovim-go](/templates/template-neovim-go--01a18347f160.md) — Go with a terminal editor.
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
* [The go-cue template does not supply gopls](/issues/the-go-cue-template-does-not-supply-gopls--01a1834bbbec.md)
