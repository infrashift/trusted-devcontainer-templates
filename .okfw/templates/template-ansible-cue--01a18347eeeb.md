---
id: "01a18347-eeeb-78e1-9dbc-6ddfa06e76b8"
title: "Template: ansible-cue"
type: "template"
tags:
  - "template"
  - "ansible-cue"
created: "2026-10-28T11:11:31-05:00"
timestamp: "2026-10-28T11:11:32-05:00"
description: "The ansible-cue template gives Ansible 2.21.5 on Python 3.14 and CUE, with the common scanning and data tools."
x:
  template: "ansible-cue"
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/src/ansible-cue"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/ansible-cue.mdx"
    title: "Template page: ansible-cue"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/ansible-cue/test.sh"
    title: "Smoke test: ansible-cue"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:11:32-05:00"
status: "draft"
---

# Template: ansible-cue

The `ansible-cue` template gives an Ansible and CUE environment for infrastructure-as-code work. It is template version 1.0.4, for `linux/amd64` and `linux/arm64`.

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

All features are trusted features. The `ansible-core` feature installs `ansible-core` 2.21.5 on Python 3.14.

## User

The template runs as the dev user `dev` (UID 1001). `devcontainer.json` sets `containerUser: "dev"` and `updateRemoteUserUID: false`. It does not set `remoteUser`, so the remote user is also `dev`. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Test

`test/ansible-cue/test.sh` runs `checkCommon`, then checks that `ansible` and `ansible-playbook` are on `PATH`, that Python 3.14 is installed and `python3.14` is on `PATH`, and that `cue` is on `PATH`.

## Notes

* `ansible-cue` and `neovim-ansible-cue` give the `ansible-core` option `target_version` explicitly. `pin-features.sh --check` warns if it is not the default of the pinned feature. On 2026-10-28 they are equal (2.21.5).
* `src/ansible-cue/NOTES.md` says "Ansible Core 2.18.2 with Python 3.12". This is out of date. The template installs 2.21.5 on Python 3.14.

## Related

* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the test framework.
* [Template: neovim-ansible-cue](/templates/template-neovim-ansible-cue--01a18347f0f7.md) — the same stack with a terminal editor.
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
* [Template NOTES and a lock file give old versions](/issues/template-notes-and-a-lock-file-give-old-versions--01a1834bbb8b.md)
