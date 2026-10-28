---
id: "01a18346-edbb-7bac-aa46-7695552e60bb"
title: "Waiver EXC-2026-0001 accepts Critical Go findings in git-lfs until 2026-11-22"
type: "finding"
tags:
  - "finding"
  - "waiver"
  - "cve"
  - "git-lfs"
created: "2026-10-28T11:10:26-05:00"
timestamp: "2026-10-28T11:10:26-05:00"
description: "EXC-2026-0001 waives 10 Critical Go advisories inside /usr/bin/git-lfs in every template until Fedora rebuilds it; it expires 2026-11-22."
x:
  waiver: "EXC-2026-0001"
  github:
    - 32
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/pdp/exceptions.yaml"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/59a25dc"
    title: "Commit 59a25dc — Waive GO-2026-6604/6612 until a rebuild"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/da9c0f6"
    title: "Commit da9c0f6 — Waive the git-lfs and fzf findings"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/pull/32"
    title: "PR #32"
stale_after: "2026-11-22T00:00:00Z"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:26-05:00"
status: "draft"
---

# Waiver EXC-2026-0001 accepts Critical Go findings in git-lfs until 2026-11-22

Waiver `EXC-2026-0001` accepts Critical findings in the Go code vendored inside `/usr/bin/git-lfs`. It applies to every template and expires on 2026-11-22.

## Record

| Field | Value |
|---|---|
| id | `EXC-2026-0001` |
| templates | `[]` (every template, because every template installs `git-lfs`) |
| locations | `/usr/bin/git-lfs` only |
| issued | 2026-08-24T00:00:00Z |
| expires | 2026-11-22T00:00:00Z |
| owner | `@ryancraig` |

Waived ids (10): `GHSA-5cgq-3rg8-m6cv`, `GHSA-89gr-r52h-f8rx`, `GHSA-f5wc-c3c7-36mc`, `GHSA-jppx-rxg9-jmrx`, `GHSA-rm3j-f69w-wqmq`, `GHSA-vgwf-h737-ff37`, `GHSA-x527-x647-q7gg`, `GO-2026-4337`, `GO-2026-6604`, `GO-2026-6612`.

## What it covers

* Critical findings in `golang.org/x/crypto` and the Go standard library inside `git-lfs`.
* `git-lfs` is a Fedora RPM. As of the 2026-10-28 base image, Fedora built it with `go1.25.12`.
* The location scope keeps the same ids blocking in every other Go binary.

## Why

* The fix that grype names is a Go toolchain version. Only a Fedora rebuild of `git-lfs` clears it. The templates install `git-lfs` with `dnf`.
* The base image is on the newest published digest, so no base bump is available.
* `GO-2026-6604` is a Windows-only `os.Root` junction escape. `GO-2026-6612` is HTTP/2 server flow control, and `git-lfs` is a client. Both were added on 2026-10-28.

## History

* `da9c0f6` (2026-08-23): first `git-lfs` and `fzf` waivers.
* `b919911` (2026-08-23): waivers scoped to the artifact.
* `9b2f9a7` (2026-08-23): the remediation distinction removed the vendored High entries. The register went from 41 CVEs in two entries to 8 CVEs in this entry. See [The CVE gate blocked findings that only an upstream builder can fix](/issues/the-cve-gate-blocked-findings-that-only-an-upstream-builder-can-fix--01a183461eaa.md).
* `59a25dc` (2026-10-28, PR #32): added `GO-2026-6604` and `GO-2026-6612`.

## What removes the need

1. Fedora ships a `git-lfs` built with a fixed Go toolchain, and the base image includes it.
2. Or the templates install `git-lfs` from upstream release binaries. This gives version control but loses distro packaging and signing.

Before 2026-11-22, renew the waiver with a new review, or remove it. An expired waiver suppresses nothing, and the PDP reports `WAIVER_EXPIRED`.

## Related

* [Waiver EXC-2026-0002 accepts two Go advisories in grype, syft, cue and shfmt until 2026-11-27](/findings/waiver-exc-2026-0002-accepts-two-go-advisories-in-grype-syft-cue-and-shfmt-until-2026-11-27--01a18346ee2f.md)
* [The CVE gate blocked findings that only an upstream builder can fix](/issues/the-cve-gate-blocked-findings-that-only-an-upstream-builder-can-fix--01a183461eaa.md)
* [Stale tool binaries cause most CVE findings after the Fedora migration](/issues/stale-tool-binaries-cause-most-cve-findings-after-the-fedora-migration--01a183461e53.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Findings overview](/findings/findings-overview--01a1833f2f52.md)
* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
