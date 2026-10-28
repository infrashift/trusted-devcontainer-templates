---
id: "01a18347-f091-73a5-8f68-36577f0fde6f"
title: "Template: python"
type: "template"
tags:
  - "template"
  - "python"
created: "2026-10-28T11:11:32-05:00"
timestamp: "2026-10-28T11:11:32-05:00"
description: "The python template gives Python 3.14 with uv and ruff, with the common scanning and data tools."
x:
  template: "python"
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/src/python"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/python.mdx"
    title: "Template page: python"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/python/test.sh"
    title: "Smoke test: python"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:11:32-05:00"
status: "draft"
---

# Template: python

The `python` template gives a Python environment with uv and ruff. It is template version 1.0.4, for `linux/amd64` and `linux/arm64`.

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

All features are trusted features. The defaults of the pinned features give Python 3.14, uv 0.13.6 and ruff 0.17.3.

## User

The template runs as the dev user `dev` (UID 1001). `devcontainer.json` sets `containerUser: "dev"` and `updateRemoteUserUID: false`. It does not set `remoteUser`, so the remote user is also `dev`. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Test

`test/python/test.sh` runs `checkCommon`, then checks that `uv python find 3.14` succeeds, that `python3.14` is on `PATH`, and that `ruff` is on `PATH`. The `python3.14` check exists because `uv python find` passed on an image with no executable (trusted-devcontainer-features#22).

## Notes

* `src/python/.devcontainer/devcontainer-lock.json` is the only lock file in `src/`. It is out of date: it names bootstrap 1.1.0 (`0bb69a6a2da1…`), not the pinned 1.6.1. See [Feature pinning](/architecture/feature-pinning--01a183457520.md).
* `src/python/NOTES.md` says "Python 3.12". This is out of date. The template installs Python 3.14.

## Related

* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the test framework.
* [Template: neovim-python](/templates/template-neovim-python--01a18347f232.md) — Python with a terminal editor.
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
* [Template NOTES and a lock file give old versions](/issues/template-notes-and-a-lock-file-give-old-versions--01a1834bbb8b.md)
