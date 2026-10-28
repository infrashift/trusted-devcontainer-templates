---
id: "01a18347-f232-7acd-97a0-407acb78ce3c"
title: "Template: neovim-python"
type: "template"
tags:
  - "template"
  - "neovim-python"
  - "neovim"
created: "2026-10-28T11:11:32-05:00"
timestamp: "2026-10-28T11:11:32-05:00"
description: "The neovim-python template gives tmux, Neovim with LazyVim 1.2.3 and its Python extra, pyrefly, ruff and sshd."
x:
  template: "neovim-python"
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/src/neovim-python"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/neovim-python.mdx"
    title: "Template page: neovim-python"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/neovim-python/test.sh"
    title: "Smoke test: neovim-python"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:11:32-05:00"
status: "draft"
---

# Template: neovim-python

The `neovim-python` template gives a terminal-first Python environment: tmux, Neovim with LazyVim and its Python extra, pyrefly, ruff, and an SSH server. It is template version 1.0.4, for `linux/amd64` and `linux/arm64`.

## Features

| Feature | Collection | Version | Digest | Options |
|---|---|---|---|---|
| `bootstrap` | trusted | 1.6.1 | `5f7d508100f8…` | defaults |
| `python` | trusted | 1.7.2 | `006f39a7558c…` | `target_version: 3.14` |
| `uv-ruff` | trusted | 1.7.0 | `614ff3c6af8f…` | defaults |
| `git` | trusted | 1.4.2 | `b0376331c9c6…` | defaults |
| `git-lfs` | trusted | 1.4.2 | `23fbc69b4e73…` | defaults |
| `grype` | trusted | 1.6.0 | `d3763305a4fe…` | defaults |
| `syft` | trusted | 1.6.0 | `2643a9b3cb80…` | defaults |
| `jq` | trusted | 1.5.3 | `d5dabb81c904…` | defaults |
| `yq` | trusted | 1.6.0 | `c4417457d1d3…` | defaults |
| `make` | trusted | 1.0.2 | `efaa619faa00…` | defaults |
| `sshd` | trusted | 1.1.2 | `8cf3aa2fd16a…` | defaults |
| `tmux` | repo-local | 1.0.1 | `e52d9c61c9b7…` | defaults |
| `neovim` | repo-local | 1.0.1 | `e7b45cdaa177…` | defaults |
| `pyrefly` | repo-local | 1.0.1 | `acdf34e4bee1…` | defaults |
| `lazyvim` | repo-local | 1.2.3 | `df2fb9e76e41…` | `extras: lang.python` |

The `pyrefly` feature installs pyrefly 1.3.1 with `uv tool install`. pyrefly is a native binary, so the image has no Node.js.

## User

The template runs as the dev user `dev` (UID 1001). `devcontainer.json` sets `containerUser: "dev"` and `updateRemoteUserUID: false`. It does not set `remoteUser`, so the remote user is also `dev`. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Test

`test/neovim-python/test.sh` runs `checkCommon`, then checks Python 3.14, `python3.14` and `ruff`, pyrefly 1.3.1 in a uv tool venv, and that there is no `node` binary or npm tree under `~/.local`. It checks that `extras.lua` names only `lang.python`, that the Python extra uses pyrefly, that Mason installed nothing, and that pyrefly and ruff attach to a Python buffer.

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
* The repo-local feature `python-tools` (basedpyright) is not in this template. The template uses `pyrefly`.

## Related

* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md)
* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the test framework.
* [Template: python](/templates/template-python--01a18347f091.md) — Python without the terminal editor.
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
