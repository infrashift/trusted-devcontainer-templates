---
id: "01a18346-ef2b-7541-9898-834d6fad86bf"
title: "The remediation distinction cut blocking findings to 6 or 7 per template"
type: "finding"
tags:
  - "finding"
  - "cve"
  - "pdp"
created: "2026-10-28T11:10:26-05:00"
timestamp: "2026-10-28T11:10:26-05:00"
description: "On 2026-08-23 the vendored-finding rule cut blocking findings to 6 per template, 7 for dotnet-node, and the waivers from 41 CVEs to 8."
x:
  todo: 21
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/pdp/policies.rego"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/9b2f9a7"
    title: "Commit 9b2f9a7 — Distinguish findings we can fix from findings we cannot"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:26-05:00"
status: "draft"
---

# The remediation distinction cut blocking findings to 6 or 7 per template

The remediation distinction in the PDP cut blocking findings to 6 per template, and to 7 for `dotnet-node`. Every remaining blocker except `sqlite-libs` is a package that this org pins.

## Record

Measured on 2026-08-23 (the date of the commit) with the policy from commit `9b2f9a7`, on the scans of [Stale tool binaries, not Fedora RPMs, caused most CVE findings after the migration](/findings/stale-tool-binaries-not-fedora-rpms-caused-most-cve-findings-after-the-migration--01a18346ee9b.md).

| Template | Before | After | What blocks |
|---|---:|---:|---|
| `python`, `java`, `ansible-cue`, `go-cue` | 15–18 | 6 | `ansible-core`, `python`, `sqlite-libs` |
| `dotnet-node` | 32 | 7 | the same, plus npm's bundled `tar` (Critical) |

* The waiver register went from 41 CVEs in two entries to 8 CVEs in one entry. The `fzf` entry was deleted, because the policy now records all its findings.
* `sqlite-libs` is a base-image RPM. The base image was on its newest digest.

## Analysis

The gate now blocks on findings that this org can fix. This is correct only while the pinned tools stay current. See [No check asserts that pinned tool versions are current](/issues/no-check-asserts-that-pinned-tool-versions-are-current--01a183462092.md).

## Related

* [The CVE gate blocked findings that only an upstream builder can fix](/issues/the-cve-gate-blocked-findings-that-only-an-upstream-builder-can-fix--01a183461eaa.md)
* [Stale tool binaries, not Fedora RPMs, caused most CVE findings after the migration](/findings/stale-tool-binaries-not-fedora-rpms-caused-most-cve-findings-after-the-migration--01a18346ee9b.md)
* [Waiver EXC-2026-0001 accepts Critical Go findings in git-lfs until 2026-11-22](/findings/waiver-exc-2026-0001-accepts-critical-go-findings-in-git-lfs-until-2026-11-22--01a18346edbb.md)
* [No check asserts that pinned tool versions are current](/issues/no-check-asserts-that-pinned-tool-versions-are-current--01a183462092.md)
* [Findings overview](/findings/findings-overview--01a1833f2f52.md)
* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
