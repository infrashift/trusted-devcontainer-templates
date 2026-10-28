This `.claude.md` file is designed to provide the necessary context, standards, and architectural constraints to ensure the devcontainer templates align with the security and automation patterns established in the `infrashift` ecosystem.

---

# Project Instructions: Trusted DevContainer Templates

## Context & Vision

This project involves creating a suite of highly secure, standardized, and "trusted" devcontainer templates. These templates must leverage the pre-existing **Trusted Base OCI Images** (Fedora- and UBI-based, multi-arch, and signed) and incorporate **Trusted DevContainer Features** to provide a consistent, hardened environment for various development stacks.

### Key Repositories

* **Features:** `https://github.com/infrashift/trusted-devcontainer-features`
* **Base Images:** `https://github.com/infrashift/trusted-base-images`

## Technical Constraints & Standards

### 1. Base Image Strategy

* **Origin:** Always use images from `ghcr.io/infrashift/trusted-base-images`. Templates are based on
  `trusted/fedora43-minimal` (see ADR-007). Note this is a *minimal* image: it ships no `tar`, `gzip`,
  `su`/`runuser`, or `python3`, so anything a feature relies on must be added explicitly in
  `shared/Containerfile`.
* **Security:** Images must be referenced by specific tags or digests. Assume all images have been signed with **Cosign** and contain **SBOMs** (Syft/Grype).
* **Architecture:** Templates must support multi-arch (amd64/arm64) to maintain compatibility with modern workstations (e.g., Apple Silicon and x86_64 servers).

### 2. Feature Integration

* Utilize features from `ghcr.io/infrashift/trusted-devcontainer-features`.
* Prioritize local tool installation via the `quvr` package manager where applicable.
* Features install themselves through the shared Ansible runner at `/opt/bootstrap/run-feature.sh`,
  provided by the `bootstrap` feature (see ADR-008). Feature roles run as the target user and must be
  idempotent — a second run reports `changed=0`.
* Enforce "least privilege" by ensuring the `remoteUser` is the non-root `dev` user (UID 1001). Both this repo and the features repo standardize on `dev`; the older `vscode`/1000 convention is superseded.

### 3. Configuration & Validation

* **CUE First:** All devcontainer configurations should be validated against a CUE schema to ensure compliance with `infrashift` standards before being committed.
* **Metadata:** Every template must include `com.visualstudio.code.devcontainers.id` and proper labels for SLSA compliance tracking.

## Workspace Specifications

| Workspace | Primary Runtimes | Specific Requirements |
| --- | --- | --- |
| **Java** | OpenJDK (Latest LTS) | Maven/Gradle support, SBOM generation tools. |
| **DotNET + Node** | .NET SDK + Node.js | Support for C#, TypeScript, and JS; integrated `npm`/`dotnet` telemetry disabled. |
| **Go + CUE** | Go, CUE, Cobra, Bubbletea | Specialized for CLI/TUI development; include `gopls` and `cue` LSP. |
| **Python** | Python 3.x, Pipenv/Poetry | Focus on hermetic builds and venv isolation. |
| **Ansible + CUE** | Ansible, CUE, OpenSpec | Optimized for `tenet` (OpsCUE) and infrastructure-as-code workflows. |

## Development Workflow for Claude

1. **Analyze Features:** Before proposing a `devcontainer.json`, check the `trusted-devcontainer-features` repo to see if a custom feature exists for that specific tool (e.g., a specific CUE or Go installer).
2. **Layering:** Structure the Dockerfile stages to maximize layer caching while ensuring that security scanners (Grype) can easily parse the final artifact.
3. **Validation:** Use CUE to define the `devcontainer.json` structure to prevent "configuration drift" across the five templates.
4. **Security:** Always include a step for mounting the GPG/SSH agent to allow for cryptographic signing of commits within the container.

## Quality Definition

* **Zero Root:** No process should run as root unless strictly required for a specific system-level feature.
* **Provenance:** Every tool installed must have a traceable source.
* **Minimalism:** Avoid bloat; if a tool isn't core to the specific workspace language, it should be an optional "feature" rather than in the base template.

## Writing in the wiki

* Write all prose in `.okfw/` in Simplified Technical English (ASD-STE100). The rules and examples are in the wiki: run `okfw search "simplified technical english"`.
* Start at the wiki map (`okfw search "wiki map"`). Open a bundle overview before you open the concepts in that bundle.
* Track issues and plans in the wiki, not in `TODO.md`. List the open issues with `okfw search --kind issue --tag open`.

<!-- BEGIN okfw -->
## Project knowledge base (okfw)

trusted-devcontainer-templates keeps a local-first OKF wiki in `.okfw/`: markdown concepts with
YAML frontmatter, linked to each other. The files are the whole database —
search and the link graph are computed from them on demand, so there is no
index to build and nothing to sync. Each directory's `index.md` is generated
and gives a cheap overview before you open anything (OKF section 8).

- **Search before you derive.** `okfw search "<query>"` / `okfw_search`. The
  wiki holds what the code does not say — why things are built the way they
  are, what was considered and rejected, dependency and security findings,
  operational context, open work. Check it before explaining a design,
  assessing risk, or running an analysis someone may already have recorded and
  adjudicated.
- **Browse top-down.** Each directory's `index.md` lists its concepts with
  their descriptions (`okfw_read {"ref":"<dir>/"}` over MCP). Open only what fits.
- **Search before you write**, too, so a new concept links to what already
  exists instead of duplicating it.
- **Link actively** — `[Title](/dir/file.md)` from the wiki root, or
  `./file.md`. Links are what makes the wiki more than a folder.
- **One idea per concept**, with a one-sentence `description`.
- **Use `okfw move` / `okfw delete`, never `mv` / `rm`.** `move` repairs every
  link to the concept and its own relative links, and both keep the `index.md`
  listings current; the shell commands break the links and leave the listings
  stale.
- **`status` is the OKF lifecycle field** (`draft`/`stable`/`deprecated`), not
  task state. Mark superseded knowledge rather than deleting it.
- **Custom metadata goes under `x:`** — the schema is closed and rejects any
  other unrecognized key.
- Don't edit `index.md` or `log.md`; okfw generates them.

Results are capped and say so: `truncated`, or `… N more`, means you did not
see everything — raise the limit or page with `--offset`/`"offset"`.

`okfw mcp` serves all of this as MCP stdio tools named `okfw_*`.
<!-- END okfw -->
