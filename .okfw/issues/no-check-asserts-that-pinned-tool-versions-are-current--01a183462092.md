---
id: "01a18346-2092-78cf-80d9-c276a89e4779"
title: "No check asserts that pinned tool versions are current"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "pinning"
  - "cve"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "Nothing measures whether pinned tools are current, so drift is found only when someone reads a CVE report."
x:
  todo: 22
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "draft"
---

# No check asserts that pinned tool versions are current

No check asserts that the pinned tool versions are current, so drift shows only when someone reads a CVE report.

## Problem

[The CVE gate blocked findings that only an upstream builder can fix](/issues/the-cve-gate-blocked-findings-that-only-an-upstream-builder-can-fix--01a183461eaa.md) records vendored High findings instead of blocking them. That is correct only while the tools stay current. No check measures currency. So a future drift causes no red build.

## Context

* Two refresh rounds found tools far behind: `syft` 1.42 against 1.51, `grype` 0.108 against 0.117, `cue` 0.15.4 against 0.17.1. A CVE report showed each gap. No check showed it.
* A block on any drift is too strict: a release that is hours old must not fail a build.
* `scripts/check-version-pins.sh` in the features repository parses every declared default. It is a possible place for the check.

## Acceptance criteria

- [ ] A check compares each pinned tool version with the newest upstream release.
- [ ] The check warns when the gap is more than a set threshold.
- [ ] The PR summary shows the list of tools that are behind.

## Related

* [Waiver EXC-2026-0002 accepts two Go advisories in grype, syft, cue and shfmt until 2026-11-27](/findings/waiver-exc-2026-0002-accepts-two-go-advisories-in-grype-syft-cue-and-shfmt-until-2026-11-27--01a18346ee2f.md)
* [Stale tool binaries, not Fedora RPMs, caused most CVE findings after the migration](/findings/stale-tool-binaries-not-fedora-rpms-caused-most-cve-findings-after-the-migration--01a18346ee9b.md)
* [The remediation distinction cut blocking findings to 6 or 7 per template](/findings/the-remediation-distinction-cut-blocking-findings-to-6-or-7-per-template--01a18346ef2b.md)
* [The CVE gate blocked findings that only an upstream builder can fix](/issues/the-cve-gate-blocked-findings-that-only-an-upstream-builder-can-fix--01a183461eaa.md)
* [Stale tool binaries cause most CVE findings after the Fedora migration](/issues/stale-tool-binaries-cause-most-cve-findings-after-the-fedora-migration--01a183461e53.md)
* [Features with the version latest did not upgrade](/issues/features-with-the-version-latest-did-not-upgrade--01a183461b57.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
