---
title: ADR Index
description: Architecture Decision Records for the trusted dev container templates project.
---

This project documents significant architectural decisions as Architecture Decision Records (ADRs). Each ADR captures the context, decision, consequences, and alternatives considered.

## Decisions

| ADR | Title | Status |
|---|---|---|
| [ADR-001](/trusted-devcontainer-templates/decisions/adr-001-ubi9-base-image/) | UBI9 Base Image | Superseded by ADR-007 |
| [ADR-002](/trusted-devcontainer-templates/decisions/adr-002-shared-containerfile/) | Shared Containerfile | Accepted (amended) |
| [ADR-003](/trusted-devcontainer-templates/decisions/adr-003-non-root-dev-user/) | Non-Root dev User | Accepted (amended) |
| [ADR-004](/trusted-devcontainer-templates/decisions/adr-004-opa-policy-gate/) | OPA Policy Gate | Accepted (amended) |
| [ADR-005](/trusted-devcontainer-templates/decisions/adr-005-dual-signing/) | Dual Signing | Accepted |
| [ADR-006](/trusted-devcontainer-templates/decisions/adr-006-trusted-features-only/) | Trusted Features Only | Accepted (amended) |
| [ADR-007](/trusted-devcontainer-templates/decisions/adr-007-fedora43-base-image/) | Fedora 43 Minimal Base Image | Accepted |
| [ADR-008](/trusted-devcontainer-templates/decisions/adr-008-ansible-bootstrap-contract/) | Ansible Bootstrap Contract | Accepted |

## ADR Format

Each ADR follows the standard format:

- **Status** — Proposed, Accepted, Deprecated, or Superseded
- **Context** — The problem or situation that prompted the decision
- **Decision** — What was decided
- **Consequences** — The resulting effects, both positive and negative
- **Alternatives Considered** — Other approaches that were evaluated
