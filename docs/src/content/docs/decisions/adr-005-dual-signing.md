---
title: "ADR-005: Dual Signing"
description: Decision to sign templates with both a sovereign key and keyless OIDC signing.
---

**Status:** Accepted

## Context

Published OCI artifacts need cryptographic signatures for verification. Two signing approaches exist:

1. **Sovereign key** — a self-managed cosign key pair stored as repository secrets
2. **Keyless OIDC** — Sigstore's Fulcio issues short-lived certificates based on GitHub Actions OIDC identity, with signatures recorded in the Rekor transparency log

Each has trade-offs. Sovereign keys work offline and don't depend on external infrastructure. Keyless signing provides a public transparency log and doesn't require key management.

## Decision

Use both signing methods for every published template:

```bash
# Sovereign key signing
cosign sign --yes --key env://COSIGN_PRIVATE_KEY "${uri}"

# Keyless OIDC signing (Sigstore Fulcio/Rekor)
cosign sign --yes "${uri}"
```

The sovereign public key is published at `.github/pdp/public-keys/cosign-release.pub`.

## Consequences

**Positive:**
- **Defense in depth** — compromise of one method doesn't invalidate the other
- **Offline verification** — sovereign key works without Sigstore infrastructure
- **Transparency** — keyless signatures are recorded in Rekor's public transparency log
- **Compliance flexibility** — organizations can choose which verification method fits their requirements

**Negative:**
- Two signatures per artifact doubles the signing step time
- Sovereign key requires secret management (rotation, access control)
- Keyless signing depends on Sigstore infrastructure availability at publish time
- Consumers need to understand which verification method to use

## Alternatives Considered

| Alternative | Why not |
|---|---|
| **Sovereign key only** | No transparency log; no defense in depth |
| **Keyless OIDC only** | Depends on Sigstore availability; no offline verification |
| **GPG signing** | Not natively supported by OCI registries; poor UX with cosign |
| **Notation (Notary v2)** | Less mature ecosystem; cosign is the de facto standard |
