---
id: "01a18348-db0d-7ce6-a0fc-b98772135e78"
title: "Deploy Documentation workflow"
type: "component"
tags:
  - "supply-chain"
  - "workflow"
  - "docs"
created: "2026-10-28T11:12:32-05:00"
timestamp: "2026-10-28T11:12:32-05:00"
description: "The deploy-docs.yaml workflow builds the documentation site with Bun and deploys it to GitHub Pages when a push to main changes docs/."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/deploy-docs.yaml"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:32-05:00"
status: "draft"
---

# Deploy Documentation workflow

The `Deploy Documentation` workflow (`deploy-docs.yaml`) builds the documentation site in `docs/` and deploys it to GitHub Pages. It is the only workflow file with the `.yaml` extension.

## Trigger

* A push to `main` that changes `docs/**`.
* `workflow_dispatch` (manual start).

## Jobs

| Job | Environment | What it does |
|---|---|---|
| `build` | none | Installs Bun 1.4.0, runs `bun install --frozen-lockfile` and `bun run build` in `docs/`, and uploads `docs/dist`. |
| `deploy` | `github-pages` | Deploys the artifact with `actions/deploy-pages`. |

## Signing actor

None. The `deploy` job has `id-token: write` only for GitHub Pages.

## Output

The documentation site on GitHub Pages.

## Blocks on

A failed site build. No pull request check runs this build. Use `make docs-build` to build the site locally.

## Analysis

The site is partly out of date. Some pages in `docs/src/content/docs/pipeline/` and `docs/src/content/docs/trust/` name workflows that do not exist and a wrong public key. See the [issue about the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md) and the [issues overview](/issues/issues-overview--01a1833f2fb9.md).

## Related

* [Verify a published template](/operations/verify-a-published-template--01a183491b30.md)
* [Roadmap](/plans/roadmap--01a183491bf1.md)
* [Supply chain overview](/supply-chain/supply-chain-overview--01a1833f2f1f.md)
