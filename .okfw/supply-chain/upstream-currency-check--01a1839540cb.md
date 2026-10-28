---
id: "01a18395-40cb-7f11-aa48-1fc9e7b6e9d3"
title: "Upstream currency check"
type: "component"
tags:
  - "supply-chain"
  - "pinning"
  - "currency"
created: "2026-10-28T12:35:59-05:00"
timestamp: "2026-10-28T12:35:59-05:00"
description: "A weekly and per-PR report of each installed tool and CI tool that is behind its newest upstream release by 7 days or more."
resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/scripts/check-upstream-currency.py"
sources:
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/upstream-tools.json"
    title: "Tool registry"
  - resource: "https://github.com/infrashift/trusted-devcontainer-templates/blob/main/.github/workflows/upstream-currency.yml"
    title: "Weekly workflow"
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T12:35:59-05:00"
status: "draft"
---

# Upstream currency check

The upstream currency check compares the installed version of each tool with the newest upstream release. It reports a tool as behind when a newer release in the same line has been out for 7 days or more. It is a report, not a gate: it never fails a build.

## What it checks

* **Template tools.** The installed versions come from the template SBOMs. The SBOM is the one record of what the trusted features, the repo-local features and the Fedora base image actually installed.
* **CI tools.** The versions come from `tools.lock`: cosign, syft, grype, opa, gitleaks and the devcontainer CLI.

`.github/upstream-tools.json` lists each tool with its SBOM package URL and its upstream source. To add a tool, add one entry.

| Source kind | Tools |
|---|---|
| Go module proxy | grype, syft, cue, yq, shfmt, golangci-lint, gopls, gofumpt, delve, and the Go-based CI tools |
| PyPI | uv, ansible-core, ansible-lint, ruff, pyrefly, yamllint |
| npm | npm, the devcontainer CLI |
| Fedora 43 (Bodhi) | git-lfs, git, tmux, fzf, ripgrep |
| nodejs.org, python.org, Microsoft release metadata | Node, Python, the .NET runtime |
| endoflife.date | Go, OpenJDK (newest release of each line only) |

A runtime is compared only inside its installed line: Node 22 against the newest 22.x, Python 3.14 against the newest 3.14.x.

## Where it runs

| Where | Input | Output |
|---|---|---|
| `review.yml`, after each build of a PR | The build's SBOMs and the PR's `tools.lock` | A "Tools behind upstream" table in the review comment on the PR |
| `upstream-currency.yml`, Mondays 06:17 UTC | The SBOMs of the latest release | One GitHub issue with the label `upstream-currency` |
| `make currency`, on a workstation | The SBOMs of the latest release | The table on the terminal |

The weekly run opens the issue when a tool falls behind. It updates the issue each week, and it adds a comment when a tool newly falls behind, because an edit alone sends no notification. It closes the issue when every tool is current.

## Safety

* In `review.yml` the script and its registry come from `main`, not from the PR, because that job can write to the PR and set commit statuses. The PR supplies data only.
* If a source cannot be reached, the tool shows as "unknown". The run continues.
* `make check-currency` and the PR gate run `--self-test`. It checks version ordering, the threshold and the shape of the registry, with no network access.

## First result (2026-10-28)

12 tools were behind. The most important: the CI scanners in `tools.lock` were syft 1.51.0 and grype 0.117.0, four releases behind the versions inside the templates (1.55.0 and 0.121.0).

## Related

* [No check asserts that pinned tool versions are current](/issues/no-check-asserts-that-pinned-tool-versions-are-current--01a183462092.md)
* [After the 2026-10-28 re-pin, no template has a blocking CVE finding](/findings/after-the-2026-10-28-re-pin-no-template-has-a-blocking-cve-finding--01a18379270b.md)
* [CVE gate and waivers](/supply-chain/cve-gate-and-waivers--01a18348dc3e.md)
* [Review Attestations workflow](/supply-chain/review-attestations-workflow--01a18348d986.md)
* [Re-pin the trusted features and the base image](/operations/re-pin-the-trusted-features-and-the-base-image--01a183491a09.md)
