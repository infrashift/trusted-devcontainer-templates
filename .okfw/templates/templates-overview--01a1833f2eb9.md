---
id: "01a1833f-2eb9-7491-8939-640a81d0d4f7"
title: "Templates overview"
type: "overview"
tags:
  - "hub"
  - "template"
created: "2026-10-28T11:01:58-05:00"
timestamp: "2026-10-28T11:01:58-05:00"
description: "One pointer concept for each published template, with its runtimes, features and test script."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:58-05:00"
status: "draft"
---

# Templates overview

This bundle holds one pointer concept for each template in `src/`.

Do not put facts that apply to all templates. Put them in `architecture/`.

## Find concepts

* List this bundle: read `.okfw/templates/index.md`.
* Search this bundle: `okfw search "<words>" --type template`.

## Add a concept

1. Search the wiki first. Update a concept that exists, if possible.
2. Run `okfw create "<Title>" --path templates -d "<one sentence>" --tags template`.
3. Set `type: template` in the frontmatter.
4. Add a link to the new concept in the list below.
5. Obey the [wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md) and [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md).

## Concepts

### Language templates
* [Template: ansible-cue](/templates/template-ansible-cue--01a18347eeeb.md)
* [Template: dotnet-node](/templates/template-dotnet-node--01a18347ef4f.md)
* [Template: go-cue](/templates/template-go-cue--01a18347efb8.md)
* [Template: java](/templates/template-java--01a18347f023.md)
* [Template: python](/templates/template-python--01a18347f091.md)

### Terminal-first (neovim) templates
* [Template: neovim-ansible-cue](/templates/template-neovim-ansible-cue--01a18347f0f7.md)
* [Template: neovim-go](/templates/template-neovim-go--01a18347f160.md)
* [Template: neovim-java](/templates/template-neovim-java--01a18347f1c9.md)
* [Template: neovim-python](/templates/template-neovim-python--01a18347f232.md)

## Related

* [Wiki map](/wiki-map--01a1833f67c2.md)
