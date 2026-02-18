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

Fixed in `1e0157f` — set `become: false` in all 20 `activate-feature.yml` files. Published as v1.0.1. The sudo workaround in the shared Containerfile has been removed (see #6).

---

## infrashift/trusted-devcontainer-templates

### ~~5. Makefile test path does not match devcontainer mount~~ RESOLVED

Fixed — Makefile exec now uses `../../test/$(TEMPLATE)/test.sh` (relative to the remote workspace folder) instead of the absolute `/workspace/test/...` path. The CI workflows (`release.yaml`, `test-pr.yaml`) may also need the same fix depending on the GitHub Actions runner's checkout directory name.

### ~~6. Shared Containerfile includes sudo as a workaround~~ RESOLVED

Fixed — removed the `RUN dnf install -y sudo && dnf clean all` layer from `shared/Containerfile` now that issue #4 is resolved upstream (features v1.0.1 use `become: false`).

### ~~7. Clear local container cache before running tests~~ RESOLVED

Fixed — added `make clean-containers` target that removes devcontainer containers, prunes Docker build cache, and clears the devcontainers CLI OCI cache. Run `make clean-containers` before `make test` when features have been updated.
