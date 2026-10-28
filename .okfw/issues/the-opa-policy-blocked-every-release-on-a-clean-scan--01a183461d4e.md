---
id: "01a18346-1d4e-7b32-ba69-27d26540e603"
title: "The OPA policy blocked every release on a clean scan"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "resolved"
  - "pdp"
  - "opa"
  - "ci"
created: "2026-10-28T11:09:32-05:00"
timestamp: "2026-10-28T11:09:32-05:00"
description: "Rego v1 read the violation rule as a partial object, so a clean scan gave {} and the gate blocked; commit 7cd9b4e fixed it."
x:
  todo: 10
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/pdp/policies.rego"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/7cd9b4e"
    title: "Commit 7cd9b4e — Fix the release gate policy and pin OPA"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:32-05:00"
status: "deprecated"
---

# The OPA policy blocked every release on a clean scan

The OPA policy returned `{}` for a clean scan, and the gate read `{}` as a violation, so it blocked every release.

## Problem

The policy used `violation_security_threshold[msg] if { … }`. OPA 1.x accepts this syntax, but Rego v1 reads it as a partial object, not a partial set. The release gate compared the output with the string `[]`.

| `cve_summary` | Old policy output | Correct output |
|---|---|---|
| 2 Critical, 1 High | `{"…1 high CVEs":true,"…2 critical CVEs":true}` | `["…","…"]` |
| 0 / 0 (clean) | `{}` | `[]` |

A clean scan gave `{}`. That value is not `[]` and is not empty, so the gate blocked the release.

## Context

* The first diagnosis said that OPA 1.x rejects the syntax. That was wrong: `opa check --strict` passes it.
* No tag was pushed before the fix, so no release was blocked in practice.

## Acceptance criteria

- [x] A clean scan gives `[]`, and the gate allows the release.
- [x] A scan with 2 Critical and 1 High findings is blocked.
- [x] A test fails if the rule changes back to a partial object.
- [x] The OPA version is pinned and checksum-verified.

## Resolution

* Commit: `7cd9b4e` (2026-08-23).
* The rules use `contains msg if`. A replay of the gate logic with OPA 1.19.1 confirmed the fix.
* `.github/pdp/policies_test.rego` asserts that a clean scan gives exactly `"[]"`.
* The gate counts violations with `jq 'length'`, not a string compare.
* The `repo-gate` job in `pr-gate.yml` runs `opa check --strict` and `opa test` on every PR. `make check-policy` runs the same checks locally, with an 85% coverage floor.
* OPA is pinned to `v1.19.1` and verified against the published sha256 `c9f985ce…c0839` (asset size 60,535,858 bytes).

## Related

* [The workflows did not match the hardened org reference pipeline](/issues/the-workflows-did-not-match-the-hardened-org-reference-pipeline--01a183461d9e.md)
* [The CVE gate blocked findings that only an upstream builder can fix](/issues/the-cve-gate-blocked-findings-that-only-an-upstream-builder-can-fix--01a183461eaa.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
