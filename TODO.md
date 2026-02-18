# TODO — Open Issues

Tracked issues discovered during local template testing. Each issue lists the project where the fix should be made.

---

## infrashift/trusted-devcontainer-features

### 1. Ansible role vars use deprecated list syntax

**Affected features:** syft (confirmed), likely others
**Error:**
```
[ERROR]: Vars in a RoleInclude must be specified as a dictionary.
Origin: activate-feature.yml:12:5
```
**Cause:** `activate-feature.yml` passes vars as a list of dicts instead of a dict. Ansible 2.18 enforces the dictionary requirement that was previously a deprecation warning.
**Fix:** Change list-style vars to dict-style in every feature's `activate-feature.yml`:
```yaml
# Before (broken)
vars:
  - _securedevcontainer_variant: "{{ securedevcontainer_variant }}"

# After (correct)
vars:
  _securedevcontainer_variant: "{{ securedevcontainer_variant }}"
```

### 2. ansible-core feature fails — UV virtual environment not activated

**Affected features:** ansible-core
**Error:**
```
error: No interpreter found for Python 3.12 in virtual environments, managed installations, or search path
```
**Cause:** The ansible-core feature depends on UV. UV creates a virtual environment and installs Python 3.x along with the specified version of ansible-core into it. Verification commands (e.g., `ansible --version`, `uv python find 3.12`) fail because the virtual environment is not sourced/activated before they run.
**Fix:** Ensure the ansible-core feature activates the UV virtual environment before running verification steps.

### 3. npm feature fails — Node.js not on PATH

**Affected features:** npm (needs nodejs)
**Error:**
```
env: 'node': No such file or directory
```
**Cause:** The npm feature depends on nodejs, but the Node.js binary is not on the PATH when npm's install step runs.
**Fix:** Ensure the npm feature resolves the Node.js binary path explicitly or sources PATH updates from the nodejs feature install.

### 4. Features require sudo in base image

**Affected features:** git (confirmed), likely all features using Ansible roles with `sudo`
**Error:**
```
/bin/sh: line 1: sudo: command not found
```
**Cause:** Ansible roles in features call `sudo` even when already running as root during the Docker build.
**Fix:** Update Ansible roles to skip `sudo` when the effective user is already root (`ansible_user_id == 'root'`).

---

## infrashift/trusted-devcontainer-templates

### ~~5. Makefile test path does not match devcontainer mount~~ RESOLVED

Fixed — Makefile exec now uses `../../test/$(TEMPLATE)/test.sh` (relative to the remote workspace folder) instead of the absolute `/workspace/test/...` path. The CI workflows (`release.yaml`, `test-pr.yaml`) may also need the same fix depending on the GitHub Actions runner's checkout directory name.

### 6. Shared Containerfile includes sudo as a workaround

**Location:** `shared/Containerfile`
**Cause:** Workaround for issue #4 above. The `RUN dnf install -y sudo && dnf clean all` layer was added because features require sudo.
**Fix:** Remove this layer once issue #4 is resolved upstream in `infrashift/trusted-devcontainer-features`.

### 7. Clear local container cache before running tests

**Location:** `Makefile`
**Cause:** Stale devcontainer containers and Docker build cache can mask feature updates. When features are republished to GHCR (e.g., after a version bump), existing containers still use the old OCI artifacts and old `containerEnv` PATH entries. This caused false test failures for go-cue and java templates even after the v1.0.1 feature publish.
**Fix:** Add a `clean-containers` target to the Makefile that removes existing devcontainer containers, prunes the Docker build cache, and clears the devcontainers CLI OCI cache (`/tmp/devcontainercli-$(USER)/container-features/`) before running tests. Consider making `test` depend on this target or adding a `test-clean` target.
