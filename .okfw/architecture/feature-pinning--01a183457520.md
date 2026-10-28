---
id: "01a18345-7520-7bc1-9386-6cde17baf7a8"
title: "Feature pinning"
type: "component"
tags:
  - "architecture"
  - "pinning"
  - "features"
  - "supply-chain"
created: "2026-10-28T11:08:49-05:00"
timestamp: "2026-10-28T11:08:49-05:00"
description: "Templates reference every feature by sha256 digest; scripts/pin-features.sh sets the pins and checks that all dependsOn name the pinned bootstrap."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/pin-features.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-006-trusted-features-only.md"
    title: "ADR-006: Trusted Features Only"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/13608f2480f4ca484d7a40445e64970e61ff9ba2"
    title: "Re-pin trusted features and the fedora43-minimal base (2026-10-28)"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:08:49-05:00"
status: "draft"
---

# Feature pinning

Each template references each feature by digest, in the form `<registry>/<repository>/<id>@sha256:<64 hex>`. `scripts/pin-features.sh` sets these pins and checks them.

## Permitted sources

A template uses features from two prefixes only (ADR-006, amended by ADR-009):

| Prefix | Collection |
|---|---|
| `ghcr.io/infrashift/trusted-devcontainer-features/` | trusted features |
| `ghcr.io/infrashift/trusted-devcontainer-templates/features/` | repo-local features. See [Repo-local features](/architecture/repo-local-features--01a183450227.md). |

`pin-features.sh` tracks both prefixes.

## Commands

| Command | Script | What it does |
|---|---|---|
| `make pin-features` | `pin-features.sh` | Resolves the `latest` digest of each distinct feature one time. Writes that digest into all nine `devcontainer.json` files. Then runs the check. |
| `make check-pins` | `pin-features.sh --check` | Fails if a reference has no digest. Fails if a pinned feature has `dependsOn` a bootstrap digest that is not the template pin. Warns if an explicit option is not the default of the pinned feature. |
| `make check-assertions` | `check-test-assertions.sh` | Checks that each smoke test asserts the versions that its template requests. |

The `pr-gate.yml` workflow runs `pin-features.sh --check` and `check-test-assertions.sh` on each pull request.

## Dependencies between features

* Each trusted feature has `dependsOn` the `bootstrap` feature. The features repository writes the bootstrap digest into this reference when it publishes.
* A release of the features repository makes a new bootstrap digest and moves all its features to it. Thus two features from two releases can name two bootstrap digests.
* When that occurs, the devcontainer CLI installs `bootstrap` two times, and the second install fails. This first occurred in the `java` template, with new `maven` and `gradle` next to an old `openjdk`.
* `--check` prevents this. It reads the metadata of each pinned digest and compares each `dependsOn` with the bootstrap pin of the template.
* The templates list `bootstrap` explicitly, although `dependsOn` adds it.
* A repo-local feature names a sibling in `installsAfter` as `./<id>`.

## State on 2026-10-28

* The nine templates pin 27 distinct feature digests.
* Each of the 26 non-bootstrap features has `dependsOn` bootstrap 1.6.1 (`sha256:5f7d508100f8…`).
* Commit `13608f2` (2026-10-28) re-pinned the trusted features. Commit `5cda33e` (2026-10-09) pinned `lazyvim` 1.2.3.
* The explicit options `ansible-core` `target_version: 2.21.5` and `python` `target_version: 3.14` are equal to the defaults of the pinned features.

## Procedure

1. Wait until the feature release is complete.
2. Run `make pin-features`.
3. Read the diff. Each changed line is one digest.
4. Update the smoke test if a requested version changed.
5. Run `make check-pins` and `make check-assertions`.

## Analysis

* `src/python/.devcontainer/devcontainer-lock.json` is in git, but it is out of date. It names bootstrap 1.1.0 (`sha256:0bb69a6a2da1…`). The template pins bootstrap 1.6.1. No script updates the file, and no other template has one.

## Related

* [ADR-006: Trusted features only](/decisions/adr-006-trusted-features-only--01a18346a677.md) — the trust rule for features.
* [ADR-009: Repo-local features](/decisions/adr-009-repo-local-features--01a18346a763.md) — adds the second prefix.
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md)
* [Supply-chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
* [Operations overview](/operations/operations-overview--01a1833f2f85.md) — the re-pin runbook.
* [Feature dependsOn references resolved by tag, not by digest](/issues/feature-dependson-references-resolved-by-tag-not-by-digest--01a183462027.md)
* [Architecture overview](/architecture/architecture-overview--01a1833f2e83.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
