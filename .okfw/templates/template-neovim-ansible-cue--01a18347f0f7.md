---
id: "01a18347-f0f7-73de-9a69-ddf885eef395"
title: "Template: neovim-ansible-cue"
type: "template"
tags:
  - "template"
  - "neovim-ansible-cue"
  - "neovim"
created: "2026-10-28T11:11:32-05:00"
timestamp: "2026-10-28T11:11:32-05:00"
description: "The neovim-ansible-cue template gives tmux, Neovim with LazyVim 1.2.3, Ansible, ansible-lint, the CUE language server and sshd."
x:
  template: "neovim-ansible-cue"
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/src/neovim-ansible-cue"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/neovim-ansible-cue.mdx"
    title: "Template page: neovim-ansible-cue"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/neovim-ansible-cue/test.sh"
    title: "Smoke test: neovim-ansible-cue"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:11:32-05:00"
status: "draft"
---

# Template: neovim-ansible-cue

The `neovim-ansible-cue` template gives a terminal-first Ansible and CUE environment: tmux, Neovim with LazyVim, ansible-lint diagnostics, the CUE language server, and an SSH server. It is template version 1.0.4, for `linux/amd64` and `linux/arm64`.

## Features

| Feature | Collection | Version | Digest | Options |
|---|---|---|---|---|
| `bootstrap` | trusted | 1.6.1 | `5f7d508100f8…` | defaults |
| `ansible-core` | trusted | 1.7.2 | `098cba20902d…` | `target_version: 2.21.5`, `target_python_version: 3.14` |
| `python` | trusted | 1.7.2 | `006f39a7558c…` | `target_version: 3.14` |
| `cuelang` | trusted | 1.5.3 | `4ac7c4061478…` | defaults |
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
| `ansible-tools` | repo-local | 1.0.2 | `86608fd1c650…` | defaults |
| `lazyvim` | repo-local | 1.2.3 | `df2fb9e76e41…` | `extras: infrashift.cue,infrashift.ansible_lint` |

The `ansible-tools` feature installs ansible-lint 26.9.0 in its own uv tool venv. The `ansible` from the `ansible-core` feature (2.21.5 on Python 3.14) does not change. The `lazyvim` extras `infrashift.cue` and `infrashift.ansible_lint` are extras of this project, not upstream LazyVim extras.

## User

The template runs as the dev user `dev` (UID 1001). `devcontainer.json` sets `containerUser: "dev"` and `updateRemoteUserUID: false`. It does not set `remoteUser`, so the remote user is also `dev`. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Test

`test/neovim-ansible-cue/test.sh` runs `checkCommon`, then checks `ansible`, `ansible-playbook`, Python 3.14, `cue` and `cue help lsp`. It checks ansible-lint 26.9.0 in a uv tool venv, that `ansible --version` shows core 2.21.5, and that ansible-lint lints a playbook. It checks the extras, the tree-sitter parsers, the `yaml.ansible` file type, that Mason installed nothing, and that `cue lsp` attaches to a CUE buffer.

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
* There is no language server for YAML or Ansible, because both need Node.js. ansible-lint gives the diagnostics.

## Related

* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md)
* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the test framework.
* [Template: ansible-cue](/templates/template-ansible-cue--01a18347eeeb.md) — the same stack without the terminal editor.
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
