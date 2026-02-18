---
title: PR Validation
description: How the PR pipeline tests changed templates and runs informational CVE scans.
---

The PR validation workflow (`test-pr.yaml`) provides fast feedback on pull requests.

## Smart Change Detection

The `detect-changes` job determines which templates were modified:

- **On PR** — compares the PR diff to find changed templates under `src/`
- **On push to main** — tests all templates

This avoids testing unchanged templates, keeping PR checks fast.

## Matrix Testing

Changed templates run as a parallel matrix:

```yaml
strategy:
  fail-fast: false
  matrix:
    template: ${{ fromJson(needs.detect-changes.outputs.templates) }}
```

Each matrix job:
1. Builds and starts the devcontainer with `devcontainer up`
2. Executes the template's test script with `devcontainer exec`

`fail-fast: false` ensures all templates are tested even if one fails.

## Informational CVE Scan

On pull requests (not pushes to main), a separate job runs CVE scans:

1. Builds each changed template's devcontainer image
2. Scans with Grype
3. Writes a summary table to the GitHub Actions step summary

```
| Template | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| python   | 0        | 2    | 15     | 8   |
```

The CVE scan is **informational only** — it does not block the PR. The hard policy gate is in the release pipeline.

Warnings are emitted for critical and high CVEs:

```
::warning::python has 2 high CVEs
```

## Trigger Paths

The workflow triggers on changes to:

- `src/**` — template source files
- `shared/**` — shared Containerfile
- `test/**` — test scripts
