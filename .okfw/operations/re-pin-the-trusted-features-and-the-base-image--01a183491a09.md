---
id: "01a18349-1a09-7a0a-872b-9d062a1ec3e8"
title: "Re-pin the trusted features and the base image"
type: "runbook"
tags:
  - "runbook"
  - "pin"
  - "features"
  - "base-image"
created: "2026-10-28T11:12:48-05:00"
timestamp: "2026-10-28T11:12:48-05:00"
description: "Run make pin-features to pin each feature to its newest digest; edit the FROM digest in shared/Containerfile and sync it to move the base image."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/pin-features.sh"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/13608f2"
    title: "Re-pin features and base (2026-10-28)"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/commit/5cda33e"
    title: "Pin lazyvim 1.2.3 (2026-10-09)"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:48-05:00"
status: "draft"
---

# Re-pin the trusted features and the base image

Run `make pin-features` to pin each feature to its newest digest. To move the base image, edit the `FROM` digest in `shared/Containerfile` and copy it to all templates.

## Examples

* Commit `13608f2` (2026-10-28) re-pinned 12 trusted features and moved the base image from `20260824` to `20261028`.
* Commit `5cda33e` (2026-10-09) moved only `lazyvim` to 1.2.3, after a release of the repo-local features.
* Commit `59a25dc` (2026-10-28) added waiver `EXC-2026-0002` for new findings after the re-pin.

## Procedure: features

To see which tools are behind before you start, run `make currency`, or read the open GitHub issue with the label `upstream-currency`.

1. Create a branch from `main`.
2. Run `make pin-features`.

   The script reads the digest of `:latest` for each feature one time. It writes the digest into each `devcontainer.json` in `src/` and `features/test/`. Then it runs `--check`.
3. Read each `::warning::` line. A warning shows that a template sets an option that is not equal to the new default of the feature.
4. For each warning, change the option or keep it on purpose. Change the smoke test in `test/<template>/test.sh` to the same version.
5. Run `make check-assertions`.

WARNING: If two features in one template name different bootstrap digests, `--check` fails. Re-pin all features of that template from the same release.

## Procedure: base image

1. Find the digest of the newest dated tag of `ghcr.io/infrashift/trusted-base-images/trusted/fedora43-minimal`, for example `20261028`.
2. Write the new digest in the `FROM` line of `shared/Containerfile`.
3. Run `make sync-containerfiles`. It copies the file to the nine templates and to `.devcontainer/Containerfile`.
4. Run `make check-sync`.

## Procedure: verify and merge

1. Run `make check`.
2. Run `make test-template TEMPLATE=<name>` for each changed template.
3. Update the documents that show versions, for example `docs/src/data/templates.json`.
4. Open a pull request. A change in `shared/` builds all templates.
5. Read the verdict table in the pull request comment.
6. If a new finding blocks and no fix exists, add a waiver. See [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md).
7. Merge the pull request. Then [cut a release](/operations/cut-a-release-of-the-templates--01a183491a78.md).

## Related

* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Release the repo-local features](/operations/release-the-repo-local-features--01a183491acc.md)
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Base image](/architecture/base-image--01a183441025.md)
* [Shared Containerfile](/architecture/shared-containerfile--01a183447e12.md)
* [Waiver EXC-2026-0002](/findings/waiver-exc-2026-0002-accepts-two-go-advisories-in-grype-syft-cue-and-shfmt-until-2026-11-27--01a18346ee2f.md)
* [Upstream currency check](/supply-chain/upstream-currency-check--01a1839540cb.md)
