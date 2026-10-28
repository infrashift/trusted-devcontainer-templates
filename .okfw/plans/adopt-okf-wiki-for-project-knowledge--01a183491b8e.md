---
id: "01a18349-1b8e-7ec9-8351-6d74b04cf6d8"
title: "Adopt OKF Wiki for project knowledge"
type: "plan"
tags:
  - "plan"
  - "active"
  - "okfw"
created: "2026-10-28T11:12:48-05:00"
timestamp: "2026-10-28T11:12:48-05:00"
description: "Move the project knowledge from TODO.md, docs and agent memory into one OKF wiki in .okfw/, written in Simplified Technical English."
sources:
  - resource: "https://github.com/infrashift/okf-wiki"
    title: "okf-wiki (okfw)"
  - resource: "https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md"
    title: "OKF specification"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:12:48-05:00"
status: "draft"
---

# Adopt OKF Wiki for project knowledge

This plan moves the project knowledge into one OKF wiki in `.okfw/`. Humans and AI agents read and write the same wiki. The maintainer approved this plan.

## Goal

One wiki in `.okfw/` holds the project knowledge that the code does not show. The wiki shows a small amount first and more on request. All prose obeys [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md).

## Context

* The knowledge is in many places: `TODO.md` (27 issues), `.claude.md`, `SETUP-ENVIRONMENTS.md`, the documentation site (nine ADRs) and agent memory.
* Claude Code reads `CLAUDE.md`, not `.claude.md`. Thus the project rules do not get to the agents.
* No place exists for plans, or for findings with an end date. An example is the waivers for GO-2026-6604 and GO-2026-6612, which expire in November 2026.

Decisions of the maintainer:

1. Move all issues from `TODO.md`, open and resolved. Then change `TODO.md` into a pointer.
2. Rename `.claude.md` to `CLAUDE.md`. Run `okfw install --platform claude`. Add `.mcp.json`.
3. Make pointer concepts for the ADRs and the templates. The documentation site stays the source of truth.

## Disclosure levels

| Level | The reader reads |
|---|---|
| 0 | The `okfw` block in `CLAUDE.md`, the root `index.md` and the wiki map |
| 1 | The `index.md` and the overview of one bundle |
| 2 | One concept, with one idea and a one-sentence description |
| 3 | The `resource` and `sources` of a concept |

## Steps

1. Create the branch `chore/okf-wiki-init`.
2. Run `okfw init` and `okfw connect`.
3. Rename `.claude.md` to `CLAUDE.md` with `git mv`. Run `okfw install --platform claude`. Add a line about the STE guide.
4. Add `.mcp.json`. It starts `okfw mcp` from the repository root.
5. Create the wiki map, the nine bundle overviews and the concepts in `guides/`.
6. Give the content to three agents. Each agent writes only its own bundles:
   * Agent A: `issues/` and `findings/`.
   * Agent B: `decisions/`, `templates/` and `architecture/`.
   * Agent C: `supply-chain/`, `operations/` and `plans/`.
7. Run `okfw index-md`. Add the links between bundles. Link each open issue to the concept that it affects.
8. Change `TODO.md` into a pointer. Add `/.okfw/`, `/CLAUDE.md` and `/.mcp.json` to `.github/CODEOWNERS`.
9. Add a short section "Project knowledge" to `README.md`.
10. Show the result to the maintainer. Commit and open a pull request only on request.

## Verification

1. `okfw validate --all` and `okfw validate --okf` pass.
2. `okfw connect` shows about 85 concepts.
3. `okfw search --kind issue --tag open` returns the open issues from `TODO.md` and the release key issue.
4. `okfw search --kind issue --tag resolved` returns 19 issues with `status: deprecated`.
5. `okfw search --stale` returns nothing today. The waiver concepts have `stale_after` 2026-11-22 and 2026-11-27.
6. `okfw graph --ascii` reaches each bundle overview from the wiki map.
7. Each line in `.okfw/index.md` and in two bundle `index.md` files has a description.
8. `make repo-gate` finds no secret in `.okfw/`.
9. A check of 10 concepts finds no STE errors.
10. In a new Claude Code session, `CLAUDE.md` loads, the `okfw` skill shows, and an MCP search answers "why fedora43-minimal".

## Related

* [Plan workflow](/guides/plan-workflow--01a1833ed461.md)
* [Wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md)
* [Wiki map](/wiki-map--01a1833f67c2.md)
* [Roadmap](/plans/roadmap--01a183491bf1.md)
