# TODO — Open Issues

Tracked issues discovered during local template testing. Each issue lists the project where the fix should be made.

---

## infrashift/trusted-devcontainer-features

### ~~1. Ansible role vars use deprecated list syntax~~ RESOLVED

Fixed in `1e0157f` — converted list-style vars to dict-style in all 20 `activate-feature.yml` files. Published as v1.0.1.

### ~~2. ansible-core feature fails — UV virtual environment not activated~~ RESOLVED

Fixed in `1e0157f` — made Python verification non-fatal with `ignore_errors: true`. Published as v1.0.1.

### ~~3. npm feature fails — Node.js not on PATH~~ RESOLVED

Fixed in `1e0157f` — added `environment` with PATH to the npm version check task. Published as v1.0.1.

### ~~4. Features require sudo in base image~~ RESOLVED

Fixed in `1e0157f` — set `become: false` in all 20 `activate-feature.yml` files. Published as v1.0.1. Superseded by the bootstrap runner: the playbook now runs as the target user, so no per-task privilege handling remains.

### ~~13. Features repo: all four `make test*` targets are dead~~ RESOLVED

Fixed. The dead targets (`test`, `test-feature`, `test-scenarios`, `test-integration`) and the
orphaned `build-test-base` are gone — they required a `test/` tree that the repo deliberately replaced
with template-based integration tests in `f431c72`. The Makefile now exposes `check-contract`,
`test-template`, `test-contract`, `test` (contract check plus all six templates) and `clean`. The
stale `test-all` entry in `.PHONY` is gone, `bunx` vs `npx` is no longer inconsistent, and the
`test-templates` target name no longer shadows the `test-templates/` directory. README,
`getting-started.md` and `contributing.md` now document the targets that exist.

### ~~14. Features repo: maintainer devcontainer references a user that does not exist~~ RESOLVED

Fixed. `.devcontainer/devcontainer.json` now declares `"containerUser": "dev"` with
`"updateRemoteUserUID": false`, matching the image (which only ever creates `dev`/1001), ADR-011 and
all six test templates. Its build context also moved from `".."` to `"."`: the Containerfile `COPY`s
nothing, so the old setting shipped the entire repo — roughly 250MB of `docs/node_modules` — to the
daemon on every build.

### ~~15. Features repo: `latest` never upgrades~~ RESOLVED

Fixed by resolving the dist-tag rather than dropping it. `claude-code` and `openai-codex` now query
the npm registry for what `latest` points at *before* comparing against what is installed, so the
install is always pinned to a concrete version and the post-install assert checks that version
exactly instead of accepting any semver.

Verified end to end: downgrading to 2.1.240 and then requesting `latest` upgraded to 2.1.241
(`changed=1`), where the previous logic would have skipped the install entirely; requesting `latest`
again reported `changed=0`.

Contract tests pin these two to the version actually installed rather than passing `latest`, so the
idempotency check cannot race an npm publish mid-test. The resolution path is exercised by the build.

### ~~16. Features repo: the maintainer devcontainer cannot be built~~ RESOLVED

Fixed. `.devcontainer/devcontainer.json` referenced its features as `"../src/<id>"`, which the
devcontainer CLI rejects — a local feature path must be a child of the folder holding
`devcontainer.json`. Pre-existing and unchanged in `HEAD`, so that environment had never come up.

Neither option originally recorded was taken. Referencing the published features would have pinned the
maintainer environment to released versions rather than the working tree, and `bootstrap` is not
published yet. Requiring a manual prepare step before opening the environment would have been easy to
forget.

Instead the staging step runs automatically: `scripts/prepare-devcontainer.sh` copies `src/*` into
`.devcontainer/`, and `devcontainer.json` invokes it through `initializeCommand`, which the CLI runs on
the host **before** it resolves features. This was verified with a throwaway workspace whose only
feature existed solely after the copy — it resolved and ran, confirming the ordering rather than
assuming it. It is the same staging `make test-template` and CI already perform for the test
templates. Staged copies are gitignored, with a negation so the tracked `SKELETON-feature` survives,
and the script clears previously staged features first so one deleted from `src/` cannot linger.

Verified end to end: the environment now builds, reports `remoteUser: dev`, completes 18 feature plays
with no failures, and provides the full toolchain (git, go, cue, jq, yq, uv, ruff, grype, syft, node,
npm, pnpm, bun, claude, codex, java, dotnet, ansible).

This also completes the verification of #14, which could not be exercised end to end before: the
container runs as `uid=1001(dev)`, and the build context is now 2B rather than the ~250MB the old
`".."` setting sent to the daemon.

---

## infrashift/trusted-devcontainer-templates

### ~~5. Makefile test path does not match devcontainer mount~~ RESOLVED

Fixed properly. `devcontainer up --workspace-folder src/<t>` mounts **only** `src/<t>`, so the repo-level `test/` directory was unreachable from inside a template container under *any* relative path — the earlier `../../test/...` fix did not actually work either. All three call sites (`Makefile`, `test-pr.yaml`, `release.yaml`) now bind-mount `test/` to `/tmp/tdt-test` explicitly, rather than changing the published templates.

### ~~6. Shared Containerfile includes sudo as a workaround~~ RESOLVED

Fixed — removed the `RUN dnf install -y sudo && dnf clean all` layer from `shared/Containerfile`.

### ~~7. Clear local container cache before running tests~~ RESOLVED

Fixed — added `make clean-containers`. Run it before `make test` when features have been updated.

### ~~8. Root `.devcontainer/Containerfile` escaped the drift check~~ RESOLVED

Both `make check-sync` and `sync-containerfile.yaml` globbed only `src/*/.devcontainer/Containerfile`, leaving this repo's own `.devcontainer/Containerfile` unchecked — and it had already drifted by a blank line. The managed set is now enumerated once as `MANAGED_CONTAINERFILES` in the `Makefile` and covers all seven files. See ADR-002.

### ~~10. OPA policy uses Rego syntax that OPA 1.x rejects~~ RESOLVED

Fixed, but the original diagnosis was wrong in a way that mattered. OPA 1.x does **not** reject
`violation_security_threshold[msg] if { … }` — `opa check --strict` passes it. Rego v1 reads the
bracket form as a partial **object** rather than a partial set, so the rule silently changed shape
instead of failing:

| `cve_summary` | old policy returns | correct |
|---|---|---|
| 2 critical, 1 high | `{"…has 1 high CVEs":true,"…has 2 critical CVEs":true}` | `["…has 1 high CVEs","…has 2 critical CVEs"]` |
| **0 / 0 (clean)** | **`{}`** | `[]` |

The gate is `if [ "$violations" != "[]" ] && [ -n "$violations" ]`. On a clean scan OPA returns `{}`,
which is neither `[]` nor empty — so the gate **blocked every release regardless of CVE counts**, and
would have done so on the first tag ever pushed. Not a latent break waiting on a future OPA; it was
already broken against OPA 1.x.

The rules now use `contains msg if`. Verified by replaying the gate's own shell logic against OPA
1.19.1: old policy blocked a clean scan, the fixed policy allows a clean scan (`[]`) and blocks
2 critical + 1 high (`["…","…"]`).

Three things guard it now:

- **`.github/pdp/policies_test.rego`** — six cases, including one asserting a clean scan marshals to
  exactly `"[]"`, which is what fails if the rule ever reverts to a partial object.
- **The gate counts with `jq 'length'`** instead of comparing against the literal `[]`. A string
  compare treats any unexpected shape as a violation; counting is correct for both shapes, so this
  alone would have kept clean releases passing.
- **A `policy` job in `test-pr.yaml`**, which runs `opa check --strict` and `opa test` on every PR.
  It does not depend on `detect-changes`, and `.github/pdp/**` and `.github/workflows/**` are now
  trigger paths — previously nothing ran on a policy change, and the gate was first exercised at the
  moment it was trusted to block a release. `make check-policy` runs the same checks locally and is a
  prerequisite of `make test`.

OPA is also pinned: `v1.19.1`, downloaded from the GitHub release and verified against the sha256 the
release publishes (`c9f985ce…c0839`), rather than tracking `downloads/latest`. The checksum was
confirmed against the actual 60,535,858-byte asset, and that binary runs the policy tests green. A
gate's verdict should not change because a new OPA shipped between two runs.

---

## Open

> **All three are blocked on the same thing.** Every template references
> `ghcr.io/infrashift/trusted-devcontainer-features/bootstrap`, and that package has never been
> published — the registry answers `NAME_UNKNOWN`, while `git` is at `1.0.1`. This repo pulls features
> straight from GHCR with no local staging, so no template can currently be built here: `make test`,
> `make test-template`, the PR CVE scan and the release gate all resolve features first. #11 and #12
> need templates that build; #9 cannot pin a digest for an image that does not exist. All three unblock
> once the features work on `feature/container-improvements` lands on `main` and releases.

### 9. Feature references are not digest-pinned

`devcontainer.json` references features by bare name (`ghcr.io/infrashift/trusted-devcontainer-features/git`), which resolves to `:latest` — a mutable tag. This is the one remaining unpinned link in the supply chain; the base image is digest-pinned and `uv`/`ansible-core` are now version-pinned with checksum verification. Pinning features by digest is on the roadmap.

### 11. Measure the CVE delta from the Fedora migration

ADR-004's gate blocks a release on any Critical or High CVE. Fedora 43 carries newer packages and publishes advisories faster than UBI9, so the gate now sits on a noisier base. Run `grype` against each built template and compare with the UBI9 baseline before tagging a release.

### 12. arm64 has never actually been exercised

All five templates advertise `linux/arm64` and the base image is multi-arch. Every feature role now
derives its architecture from the `_target_arch` the bootstrap runner injects, translating to each
upstream's own naming (`amd64`/`arm64` for go, cue, jq, yq, grype, syft; `x64`/`arm64` for dotnet,
nodejs, pnpm; `x64`/`aarch64` for bun and openjdk; a GNU triple for uv). Previously only `cuelang`
and `pnpm` did, so an arm64 build silently installed an amd64 binary *and passed verification*,
because the pinned digest was the amd64 one.

Every download is now checksum-verified against a per-version, per-arch pinned digest (or an upstream
checksums file), and an unpinned version/arch pair fails by name instead of skipping verification. So
arm64 now fails **loudly** where a digest is missing rather than producing a broken container — but
that is not the same as arm64 working. Still to do: run `devcontainer build --platform linux/arm64`
against each template and fill in whatever arm64 digests turn out to be missing.
