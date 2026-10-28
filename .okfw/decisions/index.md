# decisions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [ADR-001: UBI 9 base image](adr-001-ubi-9-base-image--01a18346a4fa.md) - ADR-001 chose UBI 9 Standard as the base image; ADR-007 supersedes it with Fedora 43 minimal.
* [ADR-002: One shared Containerfile](adr-002-one-shared-containerfile--01a18346a548.md) - ADR-002 makes shared/Containerfile the one source; each template copy must be byte-identical, and make check-sync enforces it.
* [ADR-003: Non-root dev user](adr-003-non-root-dev-user--01a18346a598.md) - ADR-003 makes all templates run as the non-root user dev, UID 1001 and GID 1001, with updateRemoteUserUID false.
* [ADR-004: OPA policy gate for CVEs](adr-004-opa-policy-gate-for-cves--01a18346a5e4.md) - ADR-004 makes an OPA Rego policy, the PDP, the release gate that blocks Critical and High CVE findings.
* [ADR-005: Dual signing of templates](adr-005-dual-signing-of-templates--01a18346a62e.md) - ADR-005 signs each published template two times: with a sovereign cosign key and keylessly through Sigstore.
* [ADR-006: Trusted features only](adr-006-trusted-features-only--01a18346a677.md) - ADR-006 permits only features that InfraShift builds, tests, signs and publishes, from two registry prefixes after its amendments.
* [ADR-007: Fedora 43 minimal base image](adr-007-fedora-43-minimal-base-image--01a18346a6c7.md) - ADR-007 moves all templates from UBI 9 to the digest-pinned trusted fedora43-minimal image, and supersedes ADR-001.
* [ADR-008: Bootstrap feature supplies uv and Ansible](adr-008-bootstrap-feature-supplies-uv-and-ansible--01a18346a716.md) - ADR-008 removes uv from the Containerfile; the bootstrap feature supplies pinned uv, Python, ansible-core and run-feature.sh.
* [ADR-009: Repo-local features](adr-009-repo-local-features--01a18346a763.md) - ADR-009 builds, tests and publishes the editor features from features/ in this repository, under the trusted feature contract.
* [Decisions overview](decisions-overview--01a1833f2eec.md) - One pointer concept for each architecture decision record (ADR) in the documentation site.

