---
id: "01a18346-a598-7dd7-ae54-422cc85b17d3"
title: "ADR-003: Non-root dev user"
type: "decision"
tags:
  - "adr"
  - "decision"
  - "dev-user"
  - "security"
created: "2026-10-28T11:10:07-05:00"
timestamp: "2026-10-28T11:10:07-05:00"
description: "ADR-003 makes all templates run as the non-root user dev, UID 1001 and GID 1001, with updateRemoteUserUID false."
x:
  adr: 3
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/docs/src/content/docs/decisions/adr-003-non-root-dev-user.md"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:10:07-05:00"
status: "draft"
---

# ADR-003: Non-root dev user

ADR-003 makes all templates run as the non-root user `dev`, with UID 1001 and GID 1001.

**Status:** Accepted, amended.

## Decision

Create the user `dev` (UID 1001, GID 1001) in the shared Containerfile. Set `containerUser: "dev"` and `updateRemoteUserUID: false` in each `devcontainer.json`. The amendment records that the features repository now uses `dev`/1001 too (its ADR-011), and that features read the user from `_REMOTE_USER`.

## Reason

* A root user in a dev container is a security risk.
* A fixed UID gives the same file owner after each rebuild.
* The name `dev` is not specific to one editor, and UID 1001 does not conflict with the usual host UID 1000.

## Consequences

* The UID in the container does not follow the UID on the host. A bind-mounted file can have a different owner.
* Features do not hardcode the user. A feature stops with an error if `_REMOTE_USER` is empty.

The code agrees with the ADR on 2026-10-28: `shared/Containerfile` sets UID and GID 1001, and all nine templates set `containerUser` and `updateRemoteUserUID` as the ADR says.

## Related

* [Dev user](/architecture/dev-user--01a1834532b5.md) — where the user is set and tested.
* [Bootstrap contract](/architecture/bootstrap-contract--01a18344b8d3.md) — features install as the target user.
* [Decisions overview](/decisions/decisions-overview--01a1833f2eec.md)
