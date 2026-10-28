---
id: "01a18349-1b30-72f0-8b55-b5203a0a8cf2"
title: "Verify a published template"
type: "runbook"
tags:
  - "runbook"
  - "verify"
  - "signing"
created: "2026-10-28T11:12:48-05:00"
timestamp: "2026-10-28T11:12:48-05:00"
description: "Verify a template signature and its attestations with release.pub, the evidence files with build.pub, and the verdict with review.pub."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/publish-attest.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/trust/verification.md"
    title: "Docs verification page (names the wrong key)"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:48-05:00"
status: "draft"
---

# Verify a published template

Verify the signature and the three attestations of a published template with `release.pub`. Verify the evidence files on the GitHub release with `build.pub`, and the verdict with `review.pub`.

## Which key to use

| What you verify | Key |
|---|---|
| The template signature and its attestations | `release.pub` |
| `<template>-<file>.sig` assets, except the verdict | `build.pub` |
| `<template>-review-verdict.json.sig` | `review.pub` |

Do not use `cosign-release.pub`. On 2026-10-28 it did not verify `python:1.0.4`. The documentation site and `README.md` name it in error. See the [issue](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md).

## Procedure

1. Install cosign. CI pins v2.6.1. Verification also worked with v3.0.4 on 2026-10-28.
2. Download the key:

   ```sh
   curl -fsSLO https://raw.githubusercontent.com/infrashift/trusted-devcontainer-templates/main/.github/pdp/public-keys/release.pub
   ```
3. Set the reference to a version, not to `latest`:

   ```sh
   REF=ghcr.io/infrashift/trusted-devcontainer-templates/python:1.0.4
   ```
4. Verify the keyed signature:

   ```sh
   cosign verify --key release.pub "$REF"
   ```
5. Verify the three attestations:

   ```sh
   for t in spdxjson vuln slsaprovenance1; do
     cosign verify-attestation --key release.pub --type "$t" "$REF" > /dev/null
   done
   ```
6. Verify the keyless signature:

   ```sh
   cosign verify \
     --certificate-identity "https://github.com/infrashift/trusted-devcontainer-templates/.github/workflows/release.yml@refs/tags/v1.0.4" \
     --certificate-oidc-issuer https://token.actions.githubusercontent.com "$REF"
   ```
7. Read the source commit from the provenance:

   ```sh
   cosign verify-attestation --key release.pub --type slsaprovenance1 "$REF" \
     | jq -r .payload | base64 -d | jq .predicate.buildDefinition.externalParameters.source
   ```
8. Download the evidence files of the template:

   ```sh
   gh release download v1.0.4 --repo infrashift/trusted-devcontainer-templates -p 'python-*'
   ```
9. Verify one evidence file with `build.pub`:

   ```sh
   cosign verify-blob --key build.pub --signature python-sbom.json.sig python-sbom.json
   ```
10. Verify the verdict with `review.pub`:

    ```sh
    cosign verify-blob --key review.pub --signature python-review-verdict.json.sig python-review-verdict.json
    ```

## Result on 2026-10-28

All ten steps passed for `python:1.0.4`. The digest was `sha256:8b62e6bd…2164`. The provenance named commit `0ce2c16`.

## Related

* [Release evidence: SBOM, attestations and provenance](/supply-chain/release-evidence-sbom-attestations-and-provenance--01a18348dca7.md)
* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [Issue: the docs name the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md)
