---
id: "01a18346-ee2f-70a7-a50d-203873d4ea1a"
title: "Waiver EXC-2026-0002 accepts two Go advisories in grype, syft, cue and shfmt until 2026-11-27"
type: "finding"
tags:
  - "finding"
  - "waiver"
  - "cve"
created: "2026-10-28T11:10:26-05:00"
timestamp: "2026-10-28T11:10:26-05:00"
description: "EXC-2026-0002 waives GO-2026-6604 and GO-2026-6612 in four Go tools until upstream rebuilds them; it expires 2026-11-27."
x:
  waiver: "EXC-2026-0002"
  github:
    - 32
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/pdp/exceptions.yaml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/59a25dc"
    title: "Commit 59a25dc — Waive GO-2026-6604/6612 until a rebuild"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/pull/32"
    title: "PR #32"
stale_after: "2026-11-27T00:00:00Z"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:26-05:00"
status: "draft"
---

# Waiver EXC-2026-0002 accepts two Go advisories in grype, syft, cue and shfmt until 2026-11-27

Waiver `EXC-2026-0002` accepts `GO-2026-6604` and `GO-2026-6612` in four Go tools that are already on their newest release. It expires on 2026-11-27.

## Record

| Field | Value |
|---|---|
| id | `EXC-2026-0002` |
| templates | `[]` (grype and syft are in every template; cue and shfmt in some) |
| issued | 2026-10-28T00:00:00Z |
| expires | 2026-11-27T00:00:00Z (30 days) |
| owner | `@ryancraig` |
| cves | `GO-2026-6604`, `GO-2026-6612` |

| Location | Tool and version | Go toolchain | Ids |
|---|---|---|---|
| `/home/dev/.local/bin/grype` | grype 0.121.0 | go1.26.8 | both |
| `/home/dev/.local/bin/syft` | syft 1.55.0 | go1.26.8 | both |
| `/home/dev/.local/share/cue/cue` | cue 0.17.1 (`cuelang`) | go1.26.5 | `GO-2026-6612` |
| `/home/dev/.local/share/shfmt/3.14.1/shfmt` | shfmt 3.14.1 (`lazyvim`) | go1.27.1 | `GO-2026-6604` |

## Why

* Both ids are Critical. The fix is a Go toolchain version, so only an upstream rebuild clears it. On 2026-10-28 each tool was on its newest release.
* `GO-2026-6604` is a Windows-only `os.Root` junction escape. The images are Linux.
* `GO-2026-6612` is HTTP/2 server flow control. grype, syft and cue act only as HTTP clients. The cue LSP uses stdio, and its local registry uses plain HTTP.
* The scope is the four exact paths, so the ids keep blocking in every other Go binary. The shfmt path holds its version, so a shfmt bump stops the match.

## Source

Commit `59a25dc` (2026-10-28), merged in PR #32. The same PR re-pinned grype 0.117.0 to 0.121.0 and syft 1.51.0 to 1.55.0 (commit `13608f2`).

## What removes the need

1. Wait for each tool to ship a build on go 1.26.9 or newer, or go 1.27.2 or newer.
2. Re-pin the feature of that tool.
3. Remove its location from the waiver.

When all four locations are gone, delete the waiver.

## Related

* [Waiver EXC-2026-0001 accepts Critical Go findings in git-lfs until 2026-11-22](/findings/waiver-exc-2026-0001-accepts-critical-go-findings-in-git-lfs-until-2026-11-22--01a18346edbb.md)
* [No check asserts that pinned tool versions are current](/issues/no-check-asserts-that-pinned-tool-versions-are-current--01a183462092.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Findings overview](/findings/findings-overview--01a1833f2f52.md)
* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
