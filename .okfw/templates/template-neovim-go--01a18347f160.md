---
id: "01a18347-f160-7e68-ba4a-7ddf14fb34ec"
title: "Template: neovim-go"
type: "template"
tags:
  - "template"
  - "neovim-go"
  - "neovim"
created: "2026-10-28T11:11:32-05:00"
timestamp: "2026-10-28T11:11:32-05:00"
description: "The neovim-go template gives tmux, Neovim with LazyVim 1.2.3, Go with pinned Go tools, and sshd on port 2222."
x:
  template: "neovim-go"
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/src/neovim-go"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/neovim-go.mdx"
    title: "Template page: neovim-go"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/neovim-go/test.sh"
    title: "Smoke test: neovim-go"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:11:32-05:00"
status: "draft"
---

# Template: neovim-go

The `neovim-go` template gives a terminal-first Go environment: tmux, Neovim with a pinned LazyVim, pinned Go tools, and an SSH server. It is template version 1.0.4, for `linux/amd64` and `linux/arm64`.

## Features

| Feature | Collection | Version | Digest | Options |
|---|---|---|---|---|
| `bootstrap` | trusted | 1.6.1 | `5f7d508100f8…` | defaults |
| `git` | trusted | 1.4.2 | `b0376331c9c6…` | defaults |
| `git-lfs` | trusted | 1.4.2 | `23fbc69b4e73…` | defaults |
| `golang` | trusted | 1.5.4 | `618328f92ee5…` | defaults |
| `make` | trusted | 1.0.2 | `efaa619faa00…` | defaults |
| `grype` | trusted | 1.6.0 | `d3763305a4fe…` | defaults |
| `syft` | trusted | 1.6.0 | `2643a9b3cb80…` | defaults |
| `jq` | trusted | 1.5.3 | `d5dabb81c904…` | defaults |
| `yq` | trusted | 1.6.0 | `c4417457d1d3…` | defaults |
| `sshd` | trusted | 1.1.2 | `8cf3aa2fd16a…` | defaults |
| `tmux` | repo-local | 1.0.1 | `e52d9c61c9b7…` | defaults |
| `neovim` | repo-local | 1.0.1 | `e7b45cdaa177…` | defaults |
| `go-tools` | repo-local | 1.0.1 | `fd4abd3c75a1…` | defaults |
| `lazyvim` | repo-local | 1.2.3 | `df2fb9e76e41…` | defaults |

`lazyvim` has no `extras` option here, so it uses its default extra, `lang.go`. The `go-tools` feature installs gopls 0.23.0, gofumpt, goimports, gomodifytags, impl, dlv 1.27.2 and golangci-lint 2.14.0.

## User

The template runs as the dev user `dev` (UID 1001). `devcontainer.json` sets `containerUser: "dev"` and `updateRemoteUserUID: false`. It does not set `remoteUser`, so the remote user is also `dev`. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Test

`test/neovim-go/test.sh` runs `checkCommon`, then checks that `go` and each Go tool (`gopls`, `gofumpt`, `goimports`, `gomodifytags`, `impl`, `dlv`, `golangci-lint`) are on `PATH`.

Each neovim test also does these checks:

* `make`, `nvim`, `tmux`, `dev-session` and its login hook are installed.
* lazy.nvim has no plugin left to install.
* LazyVim has no tree-sitter parser left to download.
* `dev-session` builds a two-pane layout.
* `sshd -t` accepts the rootless sshd configuration.

## Notes

* The four neovim templates pin `lazyvim` 1.2.3 (`df2fb9e76e41…`). Commit `5cda33e` (2026-10-09) set this pin and changed only the `lazyvim` reference.
* Every plugin installs at the commit in the `lazy-lock.json` of the `lazyvim` feature. After the build, the editor downloads nothing: Mason is off, and the language servers come from `PATH`.
* `tmux`, `neovim`, `lazyvim` and the language tool feature are repo-local features. See [Repo-local features](/architecture/repo-local-features--01a183450227.md).
* The `sshd` feature listens on port 2222 and accepts only public keys for the `dev` user. No key is in the image. Mount a public key at `/run/secrets/authorized_keys`.
* `containerEnv` sets `EDITOR` and `VISUAL` to `nvim`. A login lands in the `dev-session` tmux layout: Neovim on the left and a shell on the right. `DEV_SESSION=off` stops it for one login.
* This is the first template that ADR-009 made. `features/test/neovim-go` is the test template for the repo-local features.

## Related

* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md)
* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the test framework.
* [Template: go-cue](/templates/template-go-cue--01a18347efb8.md) — Go without the terminal editor.
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
