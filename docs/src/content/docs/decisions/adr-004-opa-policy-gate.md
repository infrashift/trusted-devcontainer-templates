---
title: "ADR-004: OPA Policy Gate"
description: Decision to use Open Policy Agent as a release gate for CVE thresholds.
---

**Status:** Accepted — amended

## Context

CVE scanning produces reports, but without enforcement, high-severity vulnerabilities could be published. The project needs a programmable policy engine that:
- Evaluates CVE severity counts against configurable thresholds
- Integrates into CI without custom scripting
- Produces structured, auditable decisions
- Can be extended with additional policy rules over time

## Decision

Use [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) with Rego policies to gate the release pipeline. The policy lives at `.github/pdp/policies.rego` and evaluates the `violation_security_threshold` rule set.

The scan job extracts CVE counts, builds a JSON input, and queries OPA. If violations are non-empty, the pipeline fails.

## Consequences

**Positive:**
- Declarative policy in Rego — version-controlled, reviewable, testable
- Structured violation output for clear error messages
- Extensible — new rules (e.g., license compliance) can be added without changing the pipeline
- OPA is a CNCF graduated project with broad adoption

**Negative:**
- Adds OPA as a CI dependency (binary download)
- Rego has a learning curve for contributors unfamiliar with it
- Policy changes require understanding both the Rego rules and the input schema

## Alternatives Considered

| Alternative | Why not |
|---|---|
| **Shell script threshold checks** | Not declarative; hard to extend; no structured output |
| **Grype fail-on severity flag** | Binary pass/fail; no configurable thresholds per severity |
| **Custom Go policy tool** | Over-engineered; OPA already provides this capability |
| **GitHub Actions conditions** | Inline `if:` conditions don't scale and aren't auditable |

## Amendment: Fedora base cadence

[ADR-007](/trusted-devcontainer-templates/decisions/adr-007-fedora43-base-image/) moves templates from UBI9 to Fedora 43. Fedora carries newer
packages and publishes advisories faster, so this zero-tolerance gate on Critical and High findings sits on
a noisier base than the one it was written for.

The gate is deliberately unchanged: a Critical or High CVE should block a release regardless of how quickly
the distribution moves. What changes is the expected maintenance load — base digest bumps will be needed
more often, and the absence of any allowlist or severity-budget mechanism (noted above as a consequence) is
felt sooner. If the gate proves too brittle in practice, the fix is an explicit, time-boxed exception
mechanism recorded in a new ADR, not a quiet loosening of the threshold.
