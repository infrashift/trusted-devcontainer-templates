# architecture

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Architecture overview](architecture-overview--01a1833f2e83.md) - The parts of the template system and how they connect, from the base image to the published artifact.
* [Base image](base-image--01a183441025.md) - The templates build on trusted/fedora43-minimal, which shared/Containerfile pins by digest, and which has no tar, gzip, runuser or python3.
* [Bootstrap contract](bootstrap-contract--01a18344b8d3.md) - Every feature installs through /opt/bootstrap/run-feature.sh, which applies one idempotent Ansible role with pinned uv, Python and ansible-core.
* [Dev user](dev-user--01a1834532b5.md) - All templates run as the non-root user dev, UID 1001 and GID 1001, set by shared/Containerfile and containerUser in each devcontainer.json.
* [Feature pinning](feature-pinning--01a183457520.md) - Templates reference every feature by sha256 digest; scripts/pin-features.sh sets the pins and checks that all dependsOn name the pinned bootstrap.
* [Repo-local features](repo-local-features--01a183450227.md) - This repository builds, tests and releases eight features in features/src/, under the same contract as trusted-devcontainer-features.
* [Repository layout and tests](repository-layout-and-tests--01a18345bbe3.md) - A map of the repository: src/ templates, test/ smoke tests and test-utils, the seven workflows, and the Makefile check and test targets.
* [Shared Containerfile](shared-containerfile--01a183447e12.md) - shared/Containerfile is the one build file for all templates; make check-sync fails when one of its ten managed copies is different.

