---
id: "01a18344-b8d3-70f5-9b41-91b217273486"
title: "Bootstrap contract"
type: "component"
tags:
  - "architecture"
  - "bootstrap"
  - "ansible"
  - "features"
created: "2026-10-28T11:08:01-05:00"
timestamp: "2026-10-28T11:08:01-05:00"
description: "Every feature installs through /opt/bootstrap/run-feature.sh, which applies one idempotent Ansible role with pinned uv, Python and ansible-core."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-008-ansible-bootstrap-contract.md"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/features/README.md"
    title: "Repo-local features README"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/features/test/shared/contract-tests.sh"
    title: "contract-tests.sh"
  - resource: "https://github.com/infrashift/trusted-devcontainer-features"
    title: "trusted-devcontainer-features"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:08:01-05:00"
status: "draft"
---

# Bootstrap contract

Every feature installs itself through one runner, `/opt/bootstrap/run-feature.sh`. The `bootstrap` feature from `trusted-devcontainer-features` supplies the runner, uv, a pinned Python and a pinned `ansible-core` (ADR-008).

## What the bootstrap feature installs

```
/opt/bootstrap/                  root-owned, world-readable
├── .bootstrap/                  uv venv: pinned Python + pinned ansible-core
├── inventory.yml                OS variant, read once from /etc/os-release
├── site.yml                     generic playbook that applies one role
└── run-feature.sh               the entrypoint for every feature
```

Root owns `/opt/bootstrap`. The dev user can run the environment but cannot change it.

## Current pin

| Feature | Version | Digest | Option defaults |
|---|---|---|---|
| `bootstrap` | 1.6.1 | `sha256:5f7d508100f8…` | uv 0.12.24, Python 3.14, ansible-core 2.21.3 |

All nine templates pin this digest. Each other pinned feature declares `dependsOn` this digest. The templates also list `bootstrap` explicitly, so that `devcontainer.json` shows it. See [Feature pinning](/architecture/feature-pinning--01a183457520.md).

## The feature contract

The features repository defines this contract in its ADR-012. The repo-local features obey it too. See [Repo-local features](/architecture/repo-local-features--01a183450227.md).

1. `install.sh` is a thin wrapper. It stops on an empty mandatory option with `${VAR:?}`, then calls `/opt/bootstrap/run-feature.sh --role ansible-role-feature`.
2. `devcontainer-feature.json` holds every option default. The role `defaults/main.yml` is empty.
3. The role first asserts the runner contract: `_target_username`, `_target_user_home` and `_target_arch`.
4. The role then asserts each parameter by name and by shape.
5. Each download has a SHA256 for each version and each architecture.
6. The role verifies the exact version that it installed.
7. A second run of the role reports `changed=0`.

## Lanes

* **Userland lane**: the role runs as the target user and writes only below the home directory. The runner drops from root to that user with `util-linux` tools.
* **Privileged lane**: the role runs as root and writes root-owned files, for example `/etc/tmux.conf`.

The target user comes from `_REMOTE_USER` and `_REMOTE_USER_HOME`. The devcontainer CLI sets these variables. A feature does not hardcode the user. See [Dev user](/architecture/dev-user--01a1834532b5.md).

## Tests

`features/test/shared/contract-tests.sh` runs each repo-local role a second time and requires `changed=0`. It also checks that a missing, empty or incorrect parameter fails by name. It runs on the host with `docker exec -u 0`, because the runner needs root.

## Analysis

* A template cannot build when the bootstrap digest does not resolve. The runner stops with an error. It does not fall back to a different method.
* The uv pin is in the features repository. A uv update is a release of that repository, then a re-pin here.
* The image is larger, because it holds a CPython runtime and `ansible-core`.

## Related

* [ADR-008: Bootstrap feature supplies uv and Ansible](/decisions/adr-008-bootstrap-feature-supplies-uv-and-ansible--01a18346a716.md) — the decision for this contract.
* [ADR-006: Trusted features only](/decisions/adr-006-trusted-features-only--01a18346a677.md) — the trust rule, amended for `dependsOn`.
* [Feature pinning](/architecture/feature-pinning--01a183457520.md)
* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [Base image](/architecture/base-image--01a183441025.md) — why a pinned Python is necessary.
* [Architecture overview](/architecture/architecture-overview--01a1833f2e83.md)
