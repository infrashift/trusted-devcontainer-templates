---
id: "01a18347-f023-7178-9a04-1de6eb0411c6"
title: "Template: java"
type: "template"
tags:
  - "template"
  - "java"
created: "2026-10-28T11:11:32-05:00"
timestamp: "2026-10-28T11:11:32-05:00"
description: "The java template gives OpenJDK 21, Maven and Gradle, with the common scanning and data tools."
x:
  template: "java"
resource: "https://github.com/infrashift/trusted-devcontainer-templates/tree/main/src/java"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/templates/java.mdx"
    title: "Template page: java"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/test/java/test.sh"
    title: "Smoke test: java"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:11:32-05:00"
status: "draft"
---

# Template: java

The `java` template gives a Java environment with OpenJDK, Maven and Gradle. It is template version 1.0.4, for `linux/amd64` and `linux/arm64`.

## Features

| Feature | Collection | Version | Digest | Options |
|---|---|---|---|---|
| `bootstrap` | trusted | 1.6.1 | `5f7d508100f8…` | defaults |
| `openjdk` | trusted | 1.5.4 | `29a45b48c092…` | defaults |
| `maven` | trusted | 1.2.0 | `ee6b1eb13de8…` | defaults |
| `gradle` | trusted | 1.2.0 | `d7a7bf247b08…` | defaults |
| `git` | trusted | 1.4.2 | `b0376331c9c6…` | defaults |
| `git-lfs` | trusted | 1.4.2 | `23fbc69b4e73…` | defaults |
| `grype` | trusted | 1.6.0 | `d3763305a4fe…` | defaults |
| `syft` | trusted | 1.6.0 | `2643a9b3cb80…` | defaults |
| `jq` | trusted | 1.5.3 | `d5dabb81c904…` | defaults |
| `yq` | trusted | 1.6.0 | `c4417457d1d3…` | defaults |

All features are trusted features. The defaults of the pinned features give OpenJDK 21.0.13+9, Maven 3.10.0 and Gradle 9.8.2.

## User

The template runs as the dev user `dev` (UID 1001). `devcontainer.json` sets `containerUser: "dev"` and `updateRemoteUserUID: false`. It does not set `remoteUser`, so the remote user is also `dev`. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Test

`test/java/test.sh` runs `checkCommon`, then checks that `java`, `javac`, `mvn` and `gradle` are on `PATH`, and that `mvn --version` and `gradle --version` run with the JDK.

## Notes

* This template was the first to show the double-bootstrap failure: new `maven` and `gradle` features named a newer bootstrap digest than an old `openjdk`. `pin-features.sh --check` now prevents this. See [Feature pinning](/architecture/feature-pinning--01a183457520.md).
* The shared Containerfile installs `libicu` and `openssl-libs` for OpenJDK.

## Related

* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the test framework.
* [Template: neovim-java](/templates/template-neovim-java--01a18347f1c9.md) — Java with a terminal editor.
* [Templates overview](/templates/templates-overview--01a1833f2eb9.md)
