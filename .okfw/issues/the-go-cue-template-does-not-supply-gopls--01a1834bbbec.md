---
id: "01a1834b-bbec-727b-8e4b-6ea2f48183a9"
title: "The go-cue template does not supply gopls"
type: "issue"
kind: "issue"
tags:
  - "issue"
  - "open"
  - "go-cue"
created: "2026-10-28T11:15:41-05:00"
timestamp: "2026-10-28T11:15:41-05:00"
description: "CLAUDE.md requires gopls and the CUE language server in go-cue, but only neovim-go installs gopls."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/src/go-cue/.devcontainer/devcontainer.json"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:15:41-05:00"
status: "draft"
---

# The go-cue template does not supply gopls

## Problem

The go-cue template does not supply `gopls` or the CUE language server. `CLAUDE.md` requires both for go-cue.

## Context

go-cue has no `go-tools` feature, and `test/go-cue/` does not check for `gopls`. Only neovim-go installs `gopls`, through the repo-local `go-tools` feature. It is not known if the trusted `golang` feature installs `gopls`.

## Acceptance criteria

- [ ] go-cue supplies `gopls` and the CUE language server, and its test checks both.
- [ ] Or: `CLAUDE.md` removes the requirement, with the reason.

## Related

* [Template: go-cue](/templates/template-go-cue--01a18347efb8.md)
* [Template: neovim-go](/templates/template-neovim-go--01a18347f160.md)
* [Repo-local features](/architecture/repo-local-features--01a183450227.md)
* [Issues overview](/issues/issues-overview--01a1833f2fb9.md)
