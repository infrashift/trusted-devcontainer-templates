# Ansible + CUE (Trusted) Template

This template provides a hardened Ansible and CUE development environment built on a trusted UBI9 base image, optimized for infrastructure-as-code workflows.

## Included Tools

- **Ansible Core 2.18.2** with Python 3.12
- **Python 3.12** via trusted devcontainer feature
- **CUE** for configuration and validation
- **Git** and **Git LFS** for version control
- **Grype** and **Syft** for vulnerability scanning and SBOM generation
- **jq** and **yq** for structured data processing

## Usage

After creating your devcontainer from this template, you can optionally add features like `claude-code`, `openai-codex`, or `bun` to customize your environment further.
