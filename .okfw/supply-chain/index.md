# supply-chain

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [CI Build & Audit workflow](ci-build-audit-workflow--01a18348d928.md) - The build.yml workflow builds, tests and scans each changed template on a pull request, and signs the evidence with the build key.
* [CVE gate and waivers](cve-gate-and-waivers--01a18348dc3e.md) - The CVE gate puts each finding into one class: blocking, waived or recorded. A waiver needs an owner, a justification and an expiry.
* [Deploy Documentation workflow](deploy-documentation-workflow--01a18348db0d.md) - The deploy-docs.yaml workflow builds the documentation site with Bun and deploys it to GitHub Pages when a push to main changes docs/.
* [PR Gate workflow](pr-gate-workflow--01a18348d8cc.md) - The pr-gate.yml workflow runs on every pull request, evaluates the repository half of the PDP, and seeds two required statuses.
* [Policy decision point (PDP)](policy-decision-point-pdp--01a18348dbcd.md) - The PDP is one OPA policy in .github/pdp/policies.rego with two entry points: repo_decision for the repository and decision for one template.
* [Release Features workflow](release-features-workflow--01a18348da61.md) - The release-features.yml workflow publishes the repo-local features on a push to main: stage, review, then promote by digest.
* [Release Templates workflow](release-templates-workflow--01a18348d9eb.md) - The release.yml workflow runs on a v* tag, builds and reviews all templates again, then publishes, attests and signs them as the Release-Actor.
* [Release evidence: SBOM, attestations and provenance](release-evidence-sbom-attestations-and-provenance--01a18348dca7.md) - Each released template has SBOM, CVE and SLSA provenance attestations signed by the release key, and signed evidence files on the GitHub release.
* [Review Attestations workflow](review-attestations-workflow--01a18348d986.md) - The review.yml workflow verifies pull request build evidence, evaluates the CVE gate, signs a verdict with the review key, and sets review/cve-policy.
* [Signing actors](signing-actors--01a18348db6c.md) - Three GitHub environments, Build-Actor, Review-Actor and Release-Actor, hold different cosign keys, so no one job can build, grade and publish.
* [Supply chain overview](supply-chain-overview--01a1833f2f1f.md) - How the pipeline builds, scans, signs, attests and releases the templates, and how the PDP decides.
* [Test Features workflow](test-features-workflow--01a18348dabd.md) - The test-features.yml workflow builds the feature test templates on amd64 and arm64 for a pull request, and runs smoke and contract tests.

