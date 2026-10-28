---
id: "01a1833f-2fb9-7ddd-980f-c38e5e0c7ae7"
title: "Issues overview"
type: "overview"
tags:
  - "hub"
  - "issue"
created: "2026-10-28T11:01:58-05:00"
timestamp: "2026-10-28T11:01:58-05:00"
description: "All problems and tasks for this project, open and resolved. This bundle replaces TODO.md."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:58-05:00"
status: "draft"
---

# Issues overview

This bundle holds one issue concept for each problem or task, with the tag `open` or `resolved`.

Do not put multi-step work. Put it in `plans/` and link the issues.

## Find concepts

* List this bundle: read `.okfw/issues/index.md`.
* Search this bundle: `okfw search "<words>" --type issue`.

## Add a concept

1. Search the wiki first. Update a concept that exists, if possible.
2. Run `okfw create "<Title>" --path issues -d "<one sentence>" --tags issue`.
3. Set `type: issue` in the frontmatter. Also set `kind: issue`.
4. Add a link to the new concept in the list below.
5. Obey the [wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md) and [Simplified Technical English](/guides/simplified-technical-english--01a1833ed3c4.md).

## Concepts

### Open

* [Stale tool binaries cause most CVE findings after the Fedora migration](/issues/stale-tool-binaries-cause-most-cve-findings-after-the-fedora-migration--01a183461e53.md) (TODO 11)
* [No workflow builds the templates for arm64](/issues/no-workflow-builds-the-templates-for-arm64--01a183461f0e.md) (TODO 12)
* [The three-actor model needs GitHub settings that only a human can apply](/issues/the-three-actor-model-needs-github-settings-that-only-a-human-can-apply--01a183461f5e.md) (TODO 18)
* [CODEOWNERS and the human gate assume a multi-person org](/issues/codeowners-and-the-human-gate-assume-a-multi-person-org--01a183461fbb.md) (TODO 19)
* [No check asserts that pinned tool versions are current](/issues/no-check-asserts-that-pinned-tool-versions-are-current--01a183462092.md) (TODO 22)
* [The attestations have no Rekor transparency-log entry](/issues/the-attestations-have-no-rekor-transparency-log-entry--01a183462140.md) (TODO 24)
* [A fork PR fails the build check instead of skipping it](/issues/a-fork-pr-fails-the-build-check-instead-of-skipping-it--01a18346218e.md) (TODO 25)
* [The review workflow has no concurrency group](/issues/the-review-workflow-has-no-concurrency-group--01a1834621dd.md) (TODO 26)
* [The docs site describes the old pipeline and trust model](/issues/the-docs-site-describes-the-old-pipeline-and-trust-model--01a1834bba2d.md) (new)
* [Three ADRs no longer match the code](/issues/three-adrs-no-longer-match-the-code--01a1834bba80.md) (new)
* [No CUE schema validates devcontainer.json](/issues/no-cue-schema-validates-devcontainer-json--01a1834bbad5.md) (new)
* [The template docs pages show an old base digest](/issues/the-template-docs-pages-show-an-old-base-digest--01a1834bbb29.md) (new)
* [Template NOTES and a lock file give old versions](/issues/template-notes-and-a-lock-file-give-old-versions--01a1834bbb8b.md) (new)
* [The go-cue template does not supply gopls](/issues/the-go-cue-template-does-not-supply-gopls--01a1834bbbec.md) (new)
* [The main ruleset does not require the test-features gate](/issues/the-main-ruleset-does-not-require-the-test-features-gate--01a1834bbc41.md) (new)

### Resolved

* [The docs tell users to verify releases with the wrong public key](/issues/the-docs-tell-users-to-verify-releases-with-the-wrong-public-key--01a18346229a.md) (PR #34)
* [Ansible role vars in the features used a deprecated list syntax](/issues/ansible-role-vars-in-the-features-used-a-deprecated-list-syntax--01a183461982.md) (TODO 1)
* [The ansible-core feature failed because the uv environment was not active](/issues/the-ansible-core-feature-failed-because-the-uv-environment-was-not-active--01a1834619c9.md) (TODO 2)
* [The npm feature failed because Node.js was not on the PATH](/issues/the-npm-feature-failed-because-node-js-was-not-on-the-path--01a183461a0d.md) (TODO 3)
* [The features needed sudo in the base image](/issues/the-features-needed-sudo-in-the-base-image--01a183461a52.md) (TODO 4)
* [The Makefile test path was outside the dev container mount](/issues/the-makefile-test-path-was-outside-the-dev-container-mount--01a183461c03.md) (TODO 5)
* [The shared Containerfile installed sudo as a workaround](/issues/the-shared-containerfile-installed-sudo-as-a-workaround--01a183461c57.md) (TODO 6)
* [Local tests used cached containers after a feature update](/issues/local-tests-used-cached-containers-after-a-feature-update--01a183461ca9.md) (TODO 7)
* [The root dev container Containerfile was outside the drift check](/issues/the-root-dev-container-containerfile-was-outside-the-drift-check--01a183461cfa.md) (TODO 8)
* [The templates referenced trusted features by tag, not by digest](/issues/the-templates-referenced-trusted-features-by-tag-not-by-digest--01a183461df0.md) (TODO 9)
* [The OPA policy blocked every release on a clean scan](/issues/the-opa-policy-blocked-every-release-on-a-clean-scan--01a183461d4e.md) (TODO 10)
* [The make test targets in the features repo did not work](/issues/the-make-test-targets-in-the-features-repo-did-not-work--01a183461a9e.md) (TODO 13)
* [The features repo maintainer dev container named a missing user](/issues/the-features-repo-maintainer-dev-container-named-a-missing-user--01a183461af7.md) (TODO 14)
* [Features with the version latest did not upgrade](/issues/features-with-the-version-latest-did-not-upgrade--01a183461b57.md) (TODO 15)
* [The features repo maintainer dev container could not be built](/issues/the-features-repo-maintainer-dev-container-could-not-be-built--01a183461baf.md) (TODO 16)
* [The workflows did not match the hardened org reference pipeline](/issues/the-workflows-did-not-match-the-hardened-org-reference-pipeline--01a183461d9e.md) (TODO 17)
* [Feature dependsOn references resolved by tag, not by digest](/issues/feature-dependson-references-resolved-by-tag-not-by-digest--01a183462027.md) (TODO 20)
* [The CVE gate blocked findings that only an upstream builder can fix](/issues/the-cve-gate-blocked-findings-that-only-an-upstream-builder-can-fix--01a183461eaa.md) (TODO 21)
* [The release failed when it attached SLSA provenance](/issues/the-release-failed-when-it-attached-slsa-provenance--01a1834620e0.md) (TODO 23)
* [The v1.0.0 release attached 13 evidence assets instead of 70](/issues/the-v1-0-0-release-attached-13-evidence-assets-instead-of-70--01a18346222c.md) (TODO 27)

### Guide

* [Issue workflow](/guides/issue-workflow--01a1833ed42f.md)

## Related

* [Wiki map](/wiki-map--01a1833f67c2.md)
