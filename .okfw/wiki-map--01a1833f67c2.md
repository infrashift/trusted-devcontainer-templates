---
id: "01a1833f-67c2-7d2d-9282-8ebea083a285"
title: "Wiki map"
type: "map"
tags:
  - "hub"
  - "map"
created: "2026-10-28T11:02:13-05:00"
timestamp: "2026-10-28T11:02:13-05:00"
description: "Start here: what this wiki holds, the bundles, and the commands for common questions."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:02:13-05:00"
status: "draft"
---

# Wiki map

This wiki holds the knowledge about the trusted devcontainer templates that the code does not show: reasons, findings, issues, plans and runbooks.

The project publishes signed dev container templates. Each template uses a pinned Fedora 43 minimal base image, a shared Containerfile, and pinned trusted features.

## Start here

1. Read this map. Choose the bundle for your question.
2. Read the overview of that bundle.
3. Open only the concepts whose description matches your question.
4. Follow `resource` and `sources` to the repository only when necessary.

## Bundles

| Bundle | Use it for |
|---|---|
| [guides/](/guides/guides-overview--01a1833f2e4d.md) | Read first. Writing rules, words, and how to track issues and plans. |
| [architecture/](/architecture/architecture-overview--01a1833f2e83.md) | The parts of the system and how they connect. |
| [templates/](/templates/templates-overview--01a1833f2eb9.md) | One concept for each published template. |
| [decisions/](/decisions/decisions-overview--01a1833f2eec.md) | One pointer for each ADR. |
| [supply-chain/](/supply-chain/supply-chain-overview--01a1833f2f1f.md) | Build, scan, sign, attest, release, and the PDP. |
| [findings/](/findings/findings-overview--01a1833f2f52.md) | Dated measurements and waivers. |
| [operations/](/operations/operations-overview--01a1833f2f85.md) | Runbooks for setup, tests, re-pins, releases and verification. |
| [issues/](/issues/issues-overview--01a1833f2fb9.md) | Open and resolved problems and tasks. |
| [plans/](/plans/plans-overview--01a1833f2fed.md) | Multi-step work and its state. |

## Common questions

| Question | Command |
|---|---|
| What is open? | `okfw search --kind issue --tag open` |
| What work is in progress? | `okfw search --type plan --tag active` |
| Which facts are out of date? | `okfw search --stale` |
| What is not reviewed? | `okfw search --status draft` |
| What links to a concept? | `okfw backlinks <id>` |
