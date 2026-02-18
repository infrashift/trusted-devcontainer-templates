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

### 2. Feature install ordering — dependencies not on PATH

**Affected features:** ansible-core (needs python), npm (needs nodejs)
**Errors:**
```
# ansible-core
error: No interpreter found for Python 3.12 in virtual environments, managed installations, or search path

# npm
env: 'node': No such file or directory
```
**Cause:** Features with soft-dependencies (e.g., ansible-core depends on python, npm depends on nodejs) fail when the dependency is installed but its binary is not yet on the PATH during the dependent feature's install step.
**Fix:** Ensure dependent features source the PATH updates from prior feature installs, or resolve the binary path explicitly rather than relying on PATH.

### 3. Features require sudo in base image

**Affected features:** git (confirmed), likely all features using Ansible roles with `sudo`
**Error:**
```
/bin/sh: line 1: sudo: command not found
```
**Cause:** Ansible roles in features call `sudo` even when already running as root during the Docker build.
**Fix:** Update Ansible roles to skip `sudo` when the effective user is already root (`ansible_user_id == 'root'`).

---

## infrashift/trusted-devcontainer-templates

### 4. Makefile test path does not match devcontainer mount

**Error:**
```
bash: /workspace/test/go-cue/test.sh: No such file or directory
```
**Cause:** The Makefile `test-template` target uses `/workspace/test/...` but `devcontainer up` mounts the repo at `/workspaces/<repo-name>/`. Locally this resolves to `/workspaces/trusted-devcontainer-templates/test/...`.
**Fix:** Update the Makefile exec command to use the correct workspace-relative path. The CI workflows (`release.yaml`, `test-pr.yaml`) may also need the same fix depending on the GitHub Actions runner's checkout directory name.

### 5. Shared Containerfile includes sudo as a workaround

**Location:** `shared/Containerfile`
**Cause:** Workaround for issue #3 above. The `RUN dnf install -y sudo && dnf clean all` layer was added because features require sudo.
**Fix:** Remove this layer once issue #3 is resolved upstream in `infrashift/trusted-devcontainer-features`.
