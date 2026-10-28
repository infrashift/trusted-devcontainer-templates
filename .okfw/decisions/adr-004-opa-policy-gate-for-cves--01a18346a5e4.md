---
id: "01a18346-a5e4-7f3c-b965-8064a3a4741a"
title: "ADR-004: OPA policy gate for CVEs"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "pdp"
  - "opa"
  - "cve"
created: "2026-10-28T11:10:07-05:00"
timestamp: "2026-10-28T11:10:07-05:00"
description: "ADR-004 makes an OPA Rego policy, the PDP, the release gate that blocks Critical and High CVE findings."
x:
  adr: 4
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-004-opa-policy-gate.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:07-05:00"
status: "draft"
---

# ADR-004: OPA policy gate for CVEs

ADR-004 makes an Open Policy Agent (OPA) policy the gate of the release pipeline for CVE findings. This policy is the PDP.

**Status:** Accepted, amended.

## Decision

Use OPA with Rego policies in `.github/pdp/policies.rego`. The pipeline builds a JSON input from the scan, asks OPA for a result, and stops if the policy reports violations. The amendment keeps the zero-tolerance rule for Critical and High findings after the move to Fedora 43. It says that a time-boxed exception mechanism needs a new ADR.

## Reason

* A scan report alone does not stop a release.
* A Rego policy is declarative, in version control, and can have unit tests.
* OPA gives structured output that is easy to audit.

## Consequences

* CI needs the `opa` binary, and contributors must read Rego.
* The Fedora base has more findings, so base re-pins occur more frequently.
* The gate has no budget for findings. Each Critical or High finding blocks.

## Analysis

* The ADR names the rule set `violation_security_threshold`. No file in the repository uses that name. The policy package is `tdt.pdp`, with `template_violations`, `blocking_findings` and a signed verdict (`PASS` or `FAIL`).
* The repository now has a waiver register, `.github/pdp/exceptions.yaml`, with ids `EXC-YYYY-NNNN` and expiry dates. The amendment says that such a mechanism needs a new ADR. There is no ADR for it.

## Related

* [ADR-007: Fedora 43 minimal base image](/decisions/adr-007-fedora-43-minimal-base-image--01a18346a6c7.md) — the base image change that caused the amendment.
* [ADR-005: Dual signing of templates](/decisions/adr-005-dual-signing-of-templates--01a18346a62e.md) — signing, which follows the gate.
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md) — the PDP and the waivers.
* [Findings overview](/findings/findings-overview--01a1833f2f52.md)
* [The remediation distinction cut blocking findings to 6 or 7 per template](/findings/the-remediation-distinction-cut-blocking-findings-to-6-or-7-per-template--01a18346ef2b.md)
* [Waiver EXC-2026-0001 accepts Critical Go findings in git-lfs until 2026-11-22](/findings/waiver-exc-2026-0001-accepts-critical-go-findings-in-git-lfs-until-2026-11-22--01a18346edbb.md)
* [Waiver EXC-2026-0002 accepts two Go advisories in grype, syft, cue and shfmt until 2026-11-27](/findings/waiver-exc-2026-0002-accepts-two-go-advisories-in-grype-syft-cue-and-shfmt-until-2026-11-27--01a18346ee2f.md)
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
* [Three ADRs no longer match the code](/issues/three-adrs-no-longer-match-the-code--01a1834bba80.md)
