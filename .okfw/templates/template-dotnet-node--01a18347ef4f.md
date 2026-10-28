---
id: "01a18347-ef4f-75db-823f-1f6d587aa7d7"
title: "Template: dotnet-node"
type: "template"
tags:
  - "template"
  - "dotnet-node"
created: "2026-10-28T11:11:32-05:00"
timestamp: "2026-10-28T11:11:32-05:00"
description: "The dotnet-node template gives the .NET 8 SDK, Node.js 22 with npm 12.2.1, and pnpm, with the common tools."
x:
  template: "dotnet-node"
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/src/dotnet-node"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/dotnet-node.mdx"
    title: "Template page: dotnet-node"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/dotnet-node/test.sh"
    title: "Smoke test: dotnet-node"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:11:32-05:00"
status: "draft"
---

# Template: dotnet-node

The `dotnet-node` template gives a .NET and Node.js environment for C#, TypeScript and JavaScript work. It is template version 1.0.4, for `linux/amd64` and `linux/arm64`.

## Features

| Feature | Collection | Version | Digest | Options |
|---|---|---|---|---|
| `bootstrap` | trusted | 1.6.1 | `5f7d508100f8…` | defaults |
| `dotnet` | trusted | 1.5.4 | `cc1ead46a617…` | defaults |
| `nodejs` | trusted | 1.6.0 | `975994dbd4d7…` | defaults |
| `pnpm` | trusted | 1.5.0 | `88cdfd5a947c…` | defaults |
| `git` | trusted | 1.4.2 | `b0376331c9c6…` | defaults |
| `git-lfs` | trusted | 1.4.2 | `23fbc69b4e73…` | defaults |
| `grype` | trusted | 1.6.0 | `d3763305a4fe…` | defaults |
| `syft` | trusted | 1.6.0 | `2643a9b3cb80…` | defaults |
| `jq` | trusted | 1.5.3 | `d5dabb81c904…` | defaults |
| `yq` | trusted | 1.6.0 | `c4417457d1d3…` | defaults |

All features are trusted features. The defaults of the pinned features give .NET SDK 8.0.427, Node.js 22.23.4 with npm 12.2.1, and pnpm 10.34.9.

## User

The template runs as the dev user `dev` (UID 1001). `devcontainer.json` sets `containerUser: "dev"` and `updateRemoteUserUID: false`. It does not set `remoteUser`, so the remote user is also `dev`. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Test

`test/dotnet-node/test.sh` runs `checkCommon`, then checks that `dotnet`, `node`, `npm` and `pnpm` are on `PATH`, and that `npm --version` is 12.2.1.

## Notes

* Commit `13608f2` (2026-10-28) removed the `npm` feature. The `nodejs` feature 1.6.0 replaces the npm in the Node.js tarball with `npm_version` (default 12.2.1). The upstream `npm` feature is deprecated.
* The shared Containerfile installs `libicu` and `openssl-libs` for the .NET SDK. See [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md).

## Related

* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the test framework.
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
