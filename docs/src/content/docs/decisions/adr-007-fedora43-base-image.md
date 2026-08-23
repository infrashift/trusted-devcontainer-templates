---
title: "ADR-007: Fedora 43 Minimal Base Image"
description: Decision to migrate all templates from UBI9 Standard to the trusted Fedora 43 Minimal base image.
---

**Status:** Accepted — supersedes [ADR-001](/trusted-devcontainer-templates/decisions/adr-001-ubi9-base-image/)

## Context

[ADR-001](/trusted-devcontainer-templates/decisions/adr-001-ubi9-base-image/) chose UBI9 Standard. Two things prompted the move.

The pin had gone stale. Templates referenced `ubi9-standard@sha256:f938c070…`, the oldest build in that repository, while `:latest` had advanced several builds ahead — roughly six months of unapplied patches on an image whose selling point is Red Hat's patch cadence.

More substantively, the organisation now publishes a trusted Fedora image, and Fedora tracks upstream toolchains far more closely than UBI. For development containers — where the value is current compilers, interpreters, and CLI tooling rather than long-term ABI stability — that trade favours Fedora. Production RHEL parity matters for runtime images; it matters much less for the container a developer edits code in.

## Decision

Base all templates on the trusted Fedora 43 Minimal image, pinned by digest:

```dockerfile
FROM ghcr.io/infrashift/trusted-base-images/trusted/fedora43-minimal@sha256:1ed67eb14da57087e206e45bba67a84264e213e8c545d64a9683fbc38bca3a65
```

`fedora43-minimal` is the **only** Fedora variant published in the trusted namespace — there is no `fedora43-standard`. Minimal is therefore not a preference but a constraint, and it is genuinely minimal. Inspecting the layer, it ships `bash`, `curl`, `useradd`, `dnf5`, and coreutils, and does **not** ship `tar`, `gzip`, `xz`, `su`, `runuser`, `sudo`, `python3`, or `gpg`.

Three things in the previous Containerfile broke outright:

| Breakage | Cause |
|---|---|
| `echo … >> /etc/yum/pluginconf.d/subscription-manager.conf` | The path does not exist; it is UBI-specific |
| `curl -LsSf https://astral.sh/uv/install.sh \| sh` | The installer unpacks a `.tar.gz`, and there is no `tar` |
| Ansible's `unarchive` module, used by ~10 features | Same missing `tar`/`gzip` |

### Curated package baseline

The base layer installs, in a single layer followed by `clean all`:

- **Feature prerequisites** — `tar`, `gzip`, `curl`, `util-linux`. Without these the feature mechanism cannot function.
- **Interactive baseline** — `procps-ng`, `diffutils`, `findutils`, `less`, `which`, `fzf`. A shell without `ps`, `diff`, or a pager is not a usable development environment.

`util-linux`, not `util-linux-core`: the latter does **not** ship `su`/`runuser`/`setpriv` on Fedora, which was only discovered by building the image and checking.

`--allowerasing` is required because `curl` conflicts with the `curl-minimal` that Fedora Minimal ships.

### uv moves out of the Containerfile

The `curl | sh` bootstrap of `uv` is removed. `uv` and the pinned Ansible environment are now provided by the `bootstrap` feature, which installs a pinned release verified against a SHA256 digest. An unpinned, unverified `curl | sh` was the weakest link in a repository that otherwise pins by digest, signs with cosign, and ships SBOMs.

## Consequences

**Positive:**
- Current toolchains and a fast patch cadence.
- Digest-pinned and multi-arch (amd64 + arm64), signed and attested like every trusted base image.
- Smaller starting image than UBI9 Standard.
- Removes an unpinned network fetch from the build.
- The package list is now explicit and auditable, rather than inherited from a large base image.

**Negative:**
- **Fedora's release cadence is the main risk.** Fedora 43 reaches end of life far sooner than UBI9, so the base must be migrated to Fedora 44+ on Fedora's schedule, not Red Hat's.
- More CVE churn. Newer packages mean more advisories, and [ADR-004](/trusted-devcontainer-templates/decisions/adr-004-opa-policy-gate/) blocks releases on any Critical or High.
- Loss of RHEL production parity for teams that deploy on RHEL.
- Minimal means gaps. The curated baseline covers known needs; others will surface in interactive use.
- `dnf5` rather than `dnf`, and Fedora repositories rather than UBI's.

## Alternatives Considered

| Alternative | Why not |
|---|---|
| **Stay on UBI9, bump the digest** | Solves staleness but not toolchain currency, which is what prompted the change |
| **`fedora43-standard`** | Does not exist in the trusted namespace |
| **Untrusted upstream `fedora:43`** | Outside the trust boundary; no signature, SBOM, or attestation |
| **Per-template base choice** | Reintroduces the drift [ADR-002](/trusted-devcontainer-templates/decisions/adr-002-shared-containerfile/) exists to prevent |
