---
id: "01a18344-7e12-7796-bfba-73a18f52168d"
title: "Shared Containerfile"
type: "component"
tags:
  - "architecture"
  - "containerfile"
  - "drift"
created: "2026-10-28T11:07:46-05:00"
timestamp: "2026-10-28T11:07:46-05:00"
description: "shared/Containerfile is the one build file for all templates; make check-sync fails when one of its ten managed copies is different."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/shared/Containerfile"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/Makefile"
    title: "Makefile"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-002-shared-containerfile.md"
    title: "ADR-002: Shared Containerfile"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:07:46-05:00"
status: "draft"
---

# Shared Containerfile

`shared/Containerfile` is the one source for the container build of all templates. Each managed copy must be byte-identical to it (ADR-002).

## What the file does

1. It starts `FROM` the pinned base image. See [Base image](/architecture/base-image--01a183441025.md).
2. It runs `dnf5 -y upgrade`, then installs the package baseline, then runs `dnf5 clean all`. This is one layer.
3. It creates the dev user `dev` with UID 1001 and GID 1001. See [Dev user](/architecture/dev-user--01a1834532b5.md).
4. It sets `USER dev` and `HOME=/home/dev`, and puts `~/.local/bin` on `PATH`.
5. It sets `CMD ["sleep", "infinity"]`.

The file does not install uv or Ansible. The bootstrap feature supplies them. See [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md).

## Package baseline

| Group | Packages | Reason |
|---|---|---|
| Feature prerequisites | `tar`, `gzip`, `curl`, `util-linux` | Ansible `unarchive`, tool downloads, and `runuser` to drop from root. `util-linux-core` does not ship `su` or `runuser`. |
| Shared runtime libraries | `unzip`, `libicu`, `openssl-libs` | `bun`, the .NET SDK and OpenJDK link to them. The features that use them can then stay in the userland lane. |
| Interactive baseline | `procps-ng`, `diffutils`, `findutils`, `less`, `which`, `fzf` | A usable shell. The minimal image has none of them. |

`--allowerasing` replaces `curl-minimal` with the full `curl`.

The `upgrade` step comes first because `dnf5 install` does not upgrade a package that is already installed. Before this step, six `curl` High findings stayed in the images after Fedora fixed them on 2026-08-31. Commit `d01349d` added the step on 2026-09-10.

## Managed copies and the drift rule

The `Makefile` lists the managed copies once, in `MANAGED_CONTAINERFILES`. There are ten copies:

* `.devcontainer/Containerfile`, the dev container of this repository.
* `src/<template>/.devcontainer/Containerfile`, one for each of the nine templates.

| Command | What it does |
|---|---|
| `make check-sync` | Compares each copy with `shared/Containerfile`. If a copy is different, it shows the diff and fails. |
| `make sync-containerfiles` | Copies `shared/Containerfile` over each managed copy. |

The `pr-gate.yml` workflow runs `make check-sync` on each pull request. `make check` also runs it.

## Procedure to change the file

1. Edit `shared/Containerfile`. Do not edit a copy.
2. Run `make sync-containerfiles`.
3. Run `make check-sync`.
4. Commit `shared/Containerfile` and all ten copies in one commit.

## Analysis

* ADR-002 says that a workflow `sync-containerfile.yaml` does the check. That workflow does not exist. `pr-gate.yml` does the check.
* ADR-002 and a comment in `pr-gate.yml` say "seven" managed copies. The `Makefile` now manages ten copies, because there are nine templates.
* A template cannot add a system package. A tool that a template needs must come from a feature.

## Related

* [ADR-002: One shared Containerfile](/decisions/adr-002-one-shared-containerfile--01a18346a548.md) — the decision for one shared Containerfile.
* [Base image](/architecture/base-image--01a183441025.md)
* [Dev user](/architecture/dev-user--01a1834532b5.md)
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md)
* [Repository layout and tests](/architecture/repository-layout-and-tests--01a18345bbe3.md) — the `Makefile` targets and workflows.
* [The root dev container Containerfile was outside the drift check](/issues/the-root-dev-container-containerfile-was-outside-the-drift-check--01a183461cfa.md)
* [Architecture overview](/architecture/architecture-overview--01a1833f2e83.md)
