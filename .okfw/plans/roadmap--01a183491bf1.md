---
id: "01a18349-1bf1-762a-b4a2-a72a76eb949d"
title: "Roadmap"
type: "plan"
tags:
  - "plan"
  - "proposed"
  - "roadmap"
created: "2026-10-28T11:12:49-05:00"
timestamp: "2026-10-28T11:12:49-05:00"
description: "Pointer to the roadmap page: planned templates and security, pipeline and documentation work; two items are already done in the code."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/reference/roadmap.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:49-05:00"
status: "draft"
---

# Roadmap

This concept points to the roadmap page of the documentation site. The page lists planned templates and planned work. Some items on the page are already done in the code.

## Items

The "State on 2026-10-28" column shows a check against the code.

| Area | Item | State on 2026-10-28 |
|---|---|---|
| Templates | Rust template | Not done |
| Templates | Node.js template | Not done. `dotnet-node` has Node.js. |
| Templates | C/C++ template | Not done |
| Security | Automated base image digest updates (Dependabot or Renovate) | Not done. No `dependabot.yml` or `renovate.json` exists. |
| Security | Feature version pinning by digest | Done. `scripts/pin-features.sh`, checked in each pull request. |
| Security | SLSA Build Level 3 | Not done. `build-template.sh` writes the provenance itself. |
| Security | Verify feature attestations before the build | Not done. `pin-features.sh` does not run `cosign verify`. |
| Pipeline | Parallel template scanning in a matrix | Done. `build.yml` and `release.yml` use a matrix. |
| Pipeline | Bundle all provenance into one release attestation | Not done |
| Pipeline | Automated CVE threshold tuning | Not done. The CVE gate uses fix state and type, not thresholds. |
| Docs | Template comparison matrix | Not done |
| Docs | Migration guides | Not done |
| Docs | Video walkthroughs | Not done |

## Analysis

The roadmap page is out of date. It shows two done items as planned. The "Feature version pinning" item also says that the features use tag references now. That statement is false.

## Related

* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
* [Release evidence: SBOM, attestations and provenance](/supply-chain/release-evidence-sbom-attestations-and-provenance--01a18348dca7.md)
* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Adopt OKF Wiki for project knowledge](/plans/adopt-okf-wiki-for-project-knowledge--01a183491b8e.md)
* [Plans overview](/plans/plans-overview--01a1833f2fed.md)
* [The docs site describes the old pipeline and trust model](/issues/the-docs-site-describes-the-old-pipeline-and-trust-model--01a1834bba2d.md)
