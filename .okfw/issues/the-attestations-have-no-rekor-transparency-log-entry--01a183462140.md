---
id: "01a18346-2140-7813-85c0-7d64f950f10c"
title: "The attestations have no Rekor transparency-log entry"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "signing"
  - "rekor"
created: "2026-10-28T11:09:33-05:00"
timestamp: "2026-10-28T11:09:33-05:00"
description: "The SBOM, vulnerability and provenance attestations have a keyed signature only, so a third party cannot audit them in Rekor."
x:
  todo: 24
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/publish-attest.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/TODO.md"
    title: "TODO.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:09:33-05:00"
status: "draft"
---

# The attestations have no Rekor transparency-log entry

The SBOM, vulnerability and provenance attestations have a keyed signature only, so Rekor has no entry for them.

## Problem

`publish-attest.sh` signs each artifact twice: with `cosign sign --key` and with a keyless `cosign sign`. The keyless signature puts an entry in the Rekor transparency log. The three `cosign attest` calls use `--key` only. So a third party can audit the artifact signature in Rekor, but not the attached evidence.

## Context

* The script header says that the keyless signature gives a transparency-log entry that a third party can audit. That claim covers the artifact signature only.
* The fix adds one `cosign attest --yes` without `--key` for each type. Rekor entries for each release go from 5 to 15 for five templates.
* `tools.lock` lines 14–18 say to change attestation formats in all org repositories at the same time.

## Acceptance criteria

- [ ] Each attestation type has a keyless attestation with a Rekor entry.
- [ ] The read-back verification checks the keyless attestations.
- [ ] The change is coordinated with the other org repositories.

## Analysis (2026-10-28) — not part of the recorded issue

Agent C ran `cosign verify-attestation --key release.pub` on `python:1.0.4`. cosign printed "Existence of the claims in the transparency log was verified offline". cosign uploads keyed attestations to Rekor by default, so the keyed attestations seem to have Rekor entries. What is possibly missing is only a keyless, identity-bound attestation. Do this check again before you do work on this issue, and change the problem statement if the check agrees.

## Related

* [The release failed when it attached SLSA provenance](/issues/the-release-failed-when-it-attached-slsa-provenance--01a1834620e0.md)
* [The docs tell users to verify releases with the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
