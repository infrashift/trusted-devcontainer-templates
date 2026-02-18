---
title: Roadmap
description: Planned templates and enhancements for the trusted dev container templates project.
---

## Planned Templates

| Template | Category | Primary Features | Status |
|---|---|---|---|
| Rust | Systems | rust, cargo | Planned |
| Node.js | Web | nodejs, npm, pnpm | Planned |
| C/C++ | Systems | gcc, cmake | Planned |

## Security Enhancements

- **Automated base image digest updates** — Dependabot or Renovate bot to propose PRs when new UBI9 digests are available
- **Feature version pinning** — pin feature references by digest in addition to the current tag-based references
- **SLSA Build Level 3** — move to a reusable workflow pattern to achieve SLSA L3 isolation requirements
- **Attestation verification in CI** — verify feature attestations before building templates

## Pipeline Improvements

- **Parallel template scanning** — run scan jobs in a matrix for faster releases
- **Provenance bundling** — bundle all per-template provenance into a single release attestation
- **Automated CVE threshold tuning** — adjust OPA thresholds based on base image CVE trends

## Documentation

- **Template comparison matrix** — feature-by-feature comparison table across all templates
- **Migration guides** — instructions for moving from community templates to trusted templates
- **Video walkthroughs** — recorded demonstrations of verification and customization workflows
