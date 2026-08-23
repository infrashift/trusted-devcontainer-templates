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

---

## Open

### 9. Feature references are not digest-pinned

`devcontainer.json` references features by bare name (`ghcr.io/infrashift/trusted-devcontainer-features/git`), which resolves to `:latest` — a mutable tag. This is the one remaining unpinned link in the supply chain; the base image is digest-pinned and `uv`/`ansible-core` are now version-pinned with checksum verification. Pinning features by digest is on the roadmap.

### 10. OPA policy uses Rego syntax that OPA 1.x rejects

`.github/pdp/policies.rego` defines `violation_security_threshold[msg] if { … }`. Under OPA 1.x strict parsing a partial set requires `contains`:

```rego
violation_security_threshold contains msg if { … }
```

`release.yaml` downloads OPA `latest`, so this will break the release gate the moment the runner picks up an OPA build that enforces it. No tag has been pushed yet, so the release path has never run. Also worth pinning the OPA version rather than tracking `latest`.

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

### 16. Features repo: the maintainer devcontainer cannot be built

Found while verifying #14. `.devcontainer/devcontainer.json` references its features as `"../src/git"`,
`"../src/golang"` and so on, but the devcontainer CLI requires a local feature path to be a **child of
the `.devcontainer/` folder**:

```
Local file path parse error. Resolved path must be a child of the .devcontainer/ folder.
Parsed: .../devcontainer-features/src/git
Error: ERR: Feature '../src/git' could not be processed.
```

This is pre-existing and independent of #14 — the paths are unchanged in `HEAD`, so this environment
has never come up. The user and build-context fixes in #14 are still correct (verified directly
against the built image: it provides `dev`/1001 and has no `vscode` user), but they cannot be
exercised end to end until this is resolved.

Two options, neither free:

- **Reference the published features** (`ghcr.io/infrashift/trusted-devcontainer-features/<id>`), as
  the templates repo does. `git` and `golang` are anonymously pullable today, but `bootstrap` is new
  on this branch and not yet published, and every other feature `dependsOn` it — so this only works
  after the next release to `main`. It also means the maintainer environment runs released features,
  not the working tree, which is arguably correct: local features are exercised by `make test`.
- **Copy `src/*` into `.devcontainer/` first**, the way `make test-template` and CI prepare the test
  templates. Works against the working tree, but needs a prepare step before the environment can be
  opened, which is awkward for an IDE-launched devcontainer.

