---
id: "01a18348-dbcd-7ab1-b323-18c4d4bbfae6"
title: "Policy decision point (PDP)"
type: "component"
tags:
  - "supply-chain"
  - "pdp"
  - "opa"
created: "2026-10-28T11:12:32-05:00"
timestamp: "2026-10-28T11:12:32-05:00"
description: "The PDP is one OPA policy in .github/pdp/policies.rego with two entry points: repo_decision for the repository and decision for one template."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/pdp/policies.rego"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/pdp/policies_test.rego"
    title: "policies_test.rego"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/repo-gate.sh"
    title: "scripts/repo-gate.sh"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:32-05:00"
status: "draft"
---

# Policy decision point (PDP)

The PDP is one OPA policy, `.github/pdp/policies.rego`, in package `tdt.pdp`. It has two entry points: `repo_decision` for the repository and `decision` for one template.

## Files

| File | Use |
|---|---|
| `.github/pdp/policies.rego` | The policy |
| `.github/pdp/exceptions.yaml` | The waivers, loaded as data |
| `.github/pdp/policies_test.rego` | The unit tests. The coverage floor is 85%. |

`scripts/check-no-orphan-rego.sh` makes sure that no other policy file exists.

## Entry points

| Entry point | Scope | Caller | Result |
|---|---|---|---|
| `data.tdt.pdp.repo_decision` | The repository | `scripts/repo-gate.sh`, in the `repo-gate` job and `make repo-gate` | `allow`, `violations`, `warnings`, `counts` |
| `data.tdt.pdp.decision` | One template | `scripts/review-template.sh`, in `review.yml` and `release.yml` | `verdict` (`PASS` or `FAIL`), `counts`, `violations`, `blocking`, `waived`, `exceptions_applied` |

## Repository violations

`repo_decision` denies on each of these codes:

* `INPUT_TIMESTAMP_INVALID`
* `GITLEAKS_DID_NOT_RUN`, `GITLEAKS_REPORT_MALFORMED`, `GITLEAKS_CONFIG_UNKNOWN`
* `GITLEAKS_CONFIG_EMPTY` (`.gitleaks.toml` has fewer than 64 bytes)
* `GITLEAKS_DEFAULTS_DISABLED`, `SECRET_DETECTED`
* `TOOLS_LOCK_MISSING`, `TOOL_NOT_PINNED`, `ACTION_NOT_PINNED`
* `WAIVER_NO_EXPIRY`, `WAIVER_NO_JUSTIFICATION`

It shows `WAIVER_EXPIRED` as a warning. It does not deny on a warning.

## Measured input

The scripts make the input from measured facts: the real config size, the real `gitleaks` output, the real `tools.lock` and the real `uses:` lines. They never write a result such as `"gitleaks_passed": true` as a literal.

## Replay with `evaluated_at`

The policy does not read a clock. It does not call `time.now_ns()`. The caller gives `input.evaluated_at`, and all expiry checks use it. Thus the same input gives the same result at a later date.

To replay a template verdict, use the `reviewedAt` value of the verdict as `evaluated_at`. Evaluate `scan-input.json` with the policy and `exceptions.yaml` of the same commit.

## Fail-closed rules

* The default `decision` is `FAIL`. The default `repo_decision` has `allow: false`.
* A missing or non-numeric number is a violation.
* An unknown severity or fix state is a violation.
* Each set uses `contains`, so a clean scan gives `[]`, not `{}`.

## Related

* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [PR Gate workflow](/supply-chain/pr-gate-workflow--01a18348d8cc.md)
* [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md)
* [Run the static checks and the repo gate locally](/operations/run-the-static-checks-and-the-repo-gate-locally--01a1834919aa.md)
