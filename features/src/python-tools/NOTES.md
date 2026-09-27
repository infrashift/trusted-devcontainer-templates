# python-tools

The Python language server LazyVim's python extra (`lazyvim` feature,
`extras=lang.python`) expects on `PATH`, pinned to an exact version.

| Tool | From | How |
|---|---|---|
| basedpyright | PyPI | `uv tool install basedpyright==<version> --python <python_version>` |

Installed userland: the tool's own virtualenv under `~/.local/share/uv/tools`,
its entry points (`basedpyright`, `basedpyright-langserver`) in `~/.local/bin`.
basedpyright is a Node program packaged as a Python wheel; its dependency
`nodejs-wheel-binaries` carries the Node runtime, so no Node feature is needed.

**The bundled npm is removed** (1.0.1). `nodejs-wheel-binaries` ships npm beside
Node; basedpyright runs `node` only, and npm's own dependencies are what CVE
scans flag (tar 7.5.16, GHSA-23hp-3jrh-7fpw, 2026-09-26). The role deletes
`nodejs_wheel/lib/node_modules/npm` (and `corepack`) and the `npm`/`npx`
launchers, and asserts none is left. uv runs with its cache off, so no second
copy of the wheels stays in `~/.cache/uv`.

ruff (the extra's linter and formatter) comes from the trusted `uv-ruff` feature.

## Requirements

- uv: the bootstrap feature's `/usr/local/bin/uv`, or `~/.local/bin/uv` from
  `uv-ruff` / `python`.
- The Python named by `python_version` already installed (the trusted `python`
  feature). `UV_PYTHON_DOWNLOADS=never`: a missing interpreter fails the build
  instead of fetching an unpinned one.

## Options

| Option | Default | |
|---|---|---|
| `basedpyright_version` | `1.40.1` | exact PyPI version |
| `python_version` | `3.14` | interpreter for the tool's virtualenv |
