---
id: "01a1834b-ba80-7135-8c45-0f6be5ec9c17"
title: "Three ADRs no longer match the code"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "docs"
  - "adr"
created: "2026-10-28T11:15:40-05:00"
timestamp: "2026-10-28T11:15:40-05:00"
description: "ADR-002, ADR-004 and ADR-009 name workflows, policy rules and feature sets that changed after the ADRs were written."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/index.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:15:40-05:00"
status: "draft"
---

# Three ADRs no longer match the code

## Problem

Three ADRs no longer match the code that they describe. A reader cannot tell which part of each ADR is still the decision.

## Context

| ADR | What is wrong |
|---|---|
| ADR-002 | It names `sync-containerfile.yaml`, which does not exist; `pr-gate.yml` runs `make check-sync`. It says "seven" copies; `MANAGED_CONTAINERFILES` in the `Makefile` has 10. A comment in `pr-gate.yml` also says seven. |
| ADR-004 | No file uses `violation_security_threshold`. The policy is package `tdt.pdp`, with `template_violations`, `blocking_findings` and a PASS or FAIL verdict. The waiver register exists, but the new ADR that the amendment asks for does not. |
| ADR-009 | It describes 4 features for neovim-go. There are now 8 repo-local features, used by 4 templates. `python-tools` (basedpyright) is published, but no template uses it. |

## Acceptance criteria

- [ ] Each ADR is amended, or a new ADR supersedes it.
- [ ] An ADR records the waiver register and the remediation distinction.
- [ ] The `pr-gate.yml` comment gives the correct copy count.

## Related

* [ADR-002: One shared Containerfile](/decisions/adr-002-one-shared-containerfile--01a18346a548.md)
* [ADR-004: OPA policy gate for CVEs](/decisions/adr-004-opa-policy-gate-for-cves--01a18346a5e4.md)
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md)
* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
