---
id: "01a1833f-2f1f-7161-a988-41bdadd882fc"
title: "Supply chain overview"
type: "overview"
tags:
  - "hub"
  - "supply-chain"
created: "2026-10-28T11:01:58-05:00"
timestamp: "2026-10-28T11:01:58-05:00"
description: "How the pipeline builds, scans, signs, attests and releases the templates, and how the PDP decides."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:58-05:00"
status: "draft"
---

# Supply chain overview

This bundle holds one concept for each workflow, for the three signing actors, for the PDP, and for SBOMs and attestations.

Do not put dated measurements and waivers. Put them in `findings/`. Do not put step-by-step procedures here; use `operations/`.

## Find concepts

* List this bundle: read `.okfw/supply-chain/index.md`.
* Search this bundle: `okfw search "<words>" --type component`.

## Add a concept

1. Search the wiki first. Update a concept that exists, if possible.
2. Run `okfw create "<Title>" --path supply-chain -d "<one sentence>" --tags supply-chain`.
3. Set `type: component` in the frontmatter.
4. Add a link to the new concept in the list below.
5. Obey the [wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md) and [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md).

## Concepts

### Workflows

* [PR Gate workflow](/supply-chain/pr-gate-workflow--01a18348d8cc.md)
* [CI Build & Audit workflow](/supply-chain/ci-build-audit-workflow--01a18348d928.md)
* [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md)
* [Release Templates workflow](/supply-chain/release-templates-workflow--01a18348d9eb.md)
* [Release Features workflow](/supply-chain/release-features-workflow--01a18348da61.md)
* [Test Features workflow](/supply-chain/test-features-workflow--01a18348dabd.md)
* [Deploy Documentation workflow](/supply-chain/deploy-documentation-workflow--01a18348db0d.md)

### Signing, policy and evidence

* [Signing actors](/supply-chain/signing-actors--01a18348db6c.md)
* [Policy decision point (PDP)](/supply-chain/policy-decision-point-pdp--01a18348dbcd.md)
* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Release evidence: SBOM, attestations and provenance](/supply-chain/release-evidence-sbom-attestations-and-provenance--01a18348dca7.md)

## Related

* [Wiki map](/wiki-map--01a1833f67c2.md)
