---
id: "01a1833e-d3fc-797e-9fb5-50bacd376970"
title: "Wiki conventions"
type: "guide"
tags:
  - "guide"
  - "okfw"
created: "2026-10-28T11:01:35-05:00"
timestamp: "2026-10-28T11:01:35-05:00"
description: "The structure rules for the wiki: disclosure levels, bundles, types, tags, pointer concepts, trust and lifecycle."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:35-05:00"
status: "draft"
---

# Wiki conventions

This concept gives the rules for the structure of the wiki. Read it before you add or change a concept.

## Disclosure levels

The wiki shows a small amount first. The reader opens more only when necessary.

| Level | What the reader reads | When |
|---|---|---|
| 0 | The root `index.md` and the [wiki map](/wiki-map--01a1833f67c2.md) | Always first |
| 1 | The `index.md` and the overview of one bundle | To choose concepts |
| 2 | One concept | When the description shows that it is relevant |
| 3 | The `resource` and `sources` of a concept | Only when the concept is not sufficient |

To make this work, obey these rules:

1. Give each concept a `description` of one sentence. The `index.md` listings show it.
2. Put one idea in one concept. If a concept has two ideas, divide it.
3. Put the most important fact in the first paragraph.
4. Link each concept to one or more other concepts.
5. Link each concept from the overview of its bundle.

## Bundles

| Bundle | Holds |
|---|---|
| `guides/` | Rules for the wiki and for writing |
| `architecture/` | The parts of the system and how they connect |
| `templates/` | One concept for each template |
| `decisions/` | One pointer concept for each ADR |
| `supply-chain/` | Workflows, signing, the PDP, SBOMs and attestations |
| `findings/` | Measured facts and waivers that have a date |
| `operations/` | Runbooks |
| `issues/` | Problems and tasks |
| `plans/` | Steps for one piece of work |
| `daily/` | Daily notes from `okfw daily` |

Each bundle has an overview concept with the tag `hub`.

## Types

Set `type` to one of these values: `overview`, `guide`, `component`, `template`, `decision`, `finding`, `runbook`, `issue`, `plan`, `map`. Issues also have `kind: issue`.

## Tags

* Use lowercase words with hyphens, for example `supply-chain`.
* Use the template name as a tag when a concept is about one template, for example `go-cue`.
* Use the state tags only for issues and plans. See [Issue workflow](/guides/issue-workflow--01a1833ed42f.md) and [Plan workflow](/guides/plan-workflow--01a1833ed461.md).

## Pointer concepts

The documentation site in `docs/` is the source of truth for ADRs and template pages. A concept in `decisions/` or `templates/` is a pointer:

1. Give a summary of five sentences or fewer.
2. Set `resource` to the GitHub URL of the source file.
3. Link to the concepts that the source affects.

Do not copy the full source text into the wiki.

## Links to the repository

Set `resource` and `sources` to GitHub URLs on the `main` branch, for example `https://github.com/infrashift/trusted-devcontainer-templates/blob/main/shared/Containerfile`. A URL stays correct when a concept moves.

## Trust and lifecycle

1. When an agent writes a concept, set `generated.by` to the agent, for example `claude-code/opus-5-5`.
2. Set `status` to `draft` until a human reviews the concept.
3. When a human reviews a concept, run `okfw verify <id> --by human:<login>`.
4. After the review, run `okfw set-lifecycle <id> stable`.
5. When a concept has a known end date, run `okfw set-stale-after <id> <datetime>`.
6. When a concept is no longer correct, run `okfw set-lifecycle <id> deprecated`. Do not delete it.

## Custom fields

Put custom metadata under `x:`. The schema rejects all other unknown keys. Examples: `x.todo` (the old `TODO.md` number) and `x.github` (an issue or PR number).

## Commands to use

* Use `okfw move` to rename or move a concept. Do not use `mv`.
* Use `okfw delete` to remove a concept. Do not use `rm`.
* Do not edit `index.md` or `log.md`. okfw makes them.
* After you edit a concept by hand, run `okfw index-md --no-adopt` and `okfw validate --all`.

## Related

* [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md)
* [Terminology](/guides/terminology--01a1833e4dc1.md)
