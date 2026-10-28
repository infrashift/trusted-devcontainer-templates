---
id: "01a1833f-2f52-76ca-a8df-4bad5f40d842"
title: "Findings overview"
type: "overview"
tags:
  - "hub"
  - "finding"
created: "2026-10-28T11:01:58-05:00"
timestamp: "2026-10-28T11:01:58-05:00"
description: "Measured facts and accepted risks that have a date: scan results, CVE counts and waivers."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:58-05:00"
status: "draft"
---

# Findings overview

This bundle holds one concept for each measurement or waiver. Each has a date, a source, and a `stale_after` date when it can expire.

Do not put problems to fix. Put them in `issues/` and link the finding.

## Find concepts

* List this bundle: read `.okfw/findings/index.md`.
* Search this bundle: `okfw search "<words>" --type finding`.

## Add a concept

1. Search the wiki first. Update a concept that exists, if possible.
2. Run `okfw create "<Title>" --path findings -d "<one sentence>" --tags finding`.
3. Set `type: finding` in the frontmatter.
4. Add a link to the new concept in the list below.
5. Obey the [wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md) and [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md).

## Concepts

### Waivers

* [Waiver EXC-2026-0001 accepts Critical Go findings in git-lfs until 2026-11-22](/findings/waiver-exc-2026-0001-accepts-critical-go-findings-in-git-lfs-until-2026-11-22--01a18346edbb.md)
* [Waiver EXC-2026-0002 accepts two Go advisories in grype, syft, cue and shfmt until 2026-11-27](/findings/waiver-exc-2026-0002-accepts-two-go-advisories-in-grype-syft-cue-and-shfmt-until-2026-11-27--01a18346ee2f.md)

### Measurements

* [Stale tool binaries, not Fedora RPMs, caused most CVE findings after the migration](/findings/stale-tool-binaries-not-fedora-rpms-caused-most-cve-findings-after-the-migration--01a18346ee9b.md)
* [The remediation distinction cut blocking findings to 6 or 7 per template](/findings/the-remediation-distinction-cut-blocking-findings-to-6-or-7-per-template--01a18346ef2b.md)

## Related

* [Wiki map](/wiki-map--01a1833f67c2.md)
