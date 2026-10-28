---
id: "01a18346-a62e-7b64-97da-85619d18da83"
title: "ADR-005: Dual signing of templates"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "signing"
  - "cosign"
  - "supply-chain"
created: "2026-10-28T11:10:07-05:00"
timestamp: "2026-10-28T11:10:07-05:00"
description: "ADR-005 signs each published template two times: with a sovereign cosign key and keylessly through Sigstore."
x:
  adr: 5
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-005-dual-signing.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:07-05:00"
status: "draft"
---

# ADR-005: Dual signing of templates

ADR-005 signs each published template two times: with a sovereign cosign key, and keylessly with Sigstore OIDC.

**Status:** Accepted.

## Decision

Run `cosign sign --key env://COSIGN_PRIVATE_KEY` and then `cosign sign` (keyless, Fulcio and Rekor) on each template URI. Publish the public key in `.github/pdp/public-keys/`.

## Reason

* If one method is compromised, the other signature stays valid.
* The sovereign key works without Sigstore infrastructure.
* The keyless signature puts an entry in the public Rekor transparency log.

## Consequences

* Signing takes two steps, and the key needs secret management.
* The keyless step needs Sigstore at publish time.
* Consumers must choose a verification method.

## Analysis

* `scripts/publish-attest.sh` does sign two times, as the ADR says.
* The ADR says that the public key is `.github/pdp/public-keys/cosign-release.pub`. `publish-attest.sh` uses `.github/pdp/public-keys/release.pub`. The two files hold different keys. The getting-started and verification pages of the docs also use `cosign-release.pub`.

## Related

* [ADR-004: OPA policy gate for CVEs](/decisions/adr-004-opa-policy-gate-for-cves--01a18346a5e4.md) — the gate before signing.
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md) — repo-local features use the same keyed and keyless signing.
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md) — signing actors and verification.
* [The docs tell users to verify releases with the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md)
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [Verify a published template](/operations/verify-a-published-template--01a183491b30.md)
