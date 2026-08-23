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

### 13. Features repo: all four `make test*` targets are dead

`test`, `test-feature`, `test-scenarios` and `test-integration` in
`infrashift/trusted-devcontainer-features` all shell out to `devcontainers/cli features test`, which
requires a `test/<feature>/test.sh` tree that does not exist in that repo. `README.md` still documents
them as the testing story. The working path is now `make test-templates` (build + smoke tests +
contract tests over all six templates). Either build the `test/` tree or delete the dead targets and
point the README at the new ones. `.PHONY` also lists a `test-all` target that does not exist, and the
Makefile uses `bunx` while CI uses `npx`.

### 14. Features repo: maintainer devcontainer references a user that does not exist

`.devcontainer/devcontainer.json` declares `"containerUser": "vscode"` with
`"updateRemoteUserUID": true`, but `.devcontainer/Containerfile` only ever creates `dev` (1001) —
there is no `vscode` user in the image. A missed spot in the ADR-011 dev-user alignment. Its
`"build": {"context": ".."}` also disagrees with `make build-test-base`, which builds with
`.devcontainer/` as the context.

### 15. Features repo: `latest` never upgrades

`claude-code` and `openai-codex` default `target_version` to the npm dist-tag `latest`. Their install
task is gated on `rc != 0 or (version != "latest" and version not in stdout)`, so once anything is
installed, a request for `latest` skips the install forever — an old build satisfies `latest`
indefinitely. Contract tests assert this is idempotent, which it is; the question is whether
idempotent is the right behaviour for a floating tag. Either resolve the dist-tag to a concrete
version before comparing, or drop `latest` as an option value.

