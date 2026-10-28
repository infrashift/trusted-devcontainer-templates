---
id: "01a1833f-2f85-7d42-b2a3-72ebc662b8ce"
title: "Operations overview"
type: "overview"
tags:
  - "hub"
  - "runbook"
created: "2026-10-28T11:01:58-05:00"
timestamp: "2026-10-28T11:01:58-05:00"
description: "Runbooks: the steps to set up, test, re-pin, release and verify the templates."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:58-05:00"
status: "draft"
---

# Operations overview

This bundle holds one runbook concept for each procedure. Each runbook points to the script, `make` target or document that it uses.

Do not put the reasons for a procedure. Put them in `decisions/` or `supply-chain/`.

## Find concepts

* List this bundle: read `.okfw/operations/index.md`.
* Search this bundle: `okfw search "<words>" --type runbook`.

## Add a concept

1. Search the wiki first. Update a concept that exists, if possible.
2. Run `okfw create "<Title>" --path operations -d "<one sentence>" --tags runbook`.
3. Set `type: runbook` in the frontmatter.
4. Add a link to the new concept in the list below.
5. Obey the [wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md) and [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md).

## Concepts

### Setup and local checks

* [Set up the GitHub environments and signing keys](/operations/set-up-the-github-environments-and-signing-keys--01a183491902.md)
* [Run the static checks and the repo gate locally](/operations/run-the-static-checks-and-the-repo-gate-locally--01a1834919aa.md)
* [Build and test one template locally](/operations/build-and-test-one-template-locally--01a183491958.md)

### Pins and releases

* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
* [Cut a release of the templates](/operations/cut-a-release-of-the-templates--01a183491a78.md)
* [Release the repo-local features](/operations/release-the-repo-local-features--01a183491acc.md)
* [Verify a published template](/operations/verify-a-published-template--01a183491b30.md)

## Related

* [Wiki map](/wiki-map--01a1833f67c2.md)
