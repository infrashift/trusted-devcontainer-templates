# pyrefly

pyrefly -- Meta's Python type checker and language server, written in Rust --
on `PATH`, pinned to an exact version. The lazyvim feature's python extra
(`extras=lang.python`) starts it as `pyrefly lsp` when `python_lsp=pyrefly`,
its default.

| Tool | From | How |
|---|---|---|
| pyrefly | PyPI | `uv tool install pyrefly==<version> --python <python_version>` |

Installed userland: its own virtualenv under `~/.local/share/uv/tools`, the
`pyrefly` entry point in `~/.local/bin`. uv runs without a cache, so no second
copy stays in `~/.cache/uv`.

## Why pyrefly, and not basedpyright

The wheel is the native binary with no dependencies: **no Node**. basedpyright
(the `python-tools` feature) is a Node program; its dependency
`nodejs-wheel-binaries` ships Node together with npm, and npm's own dependencies
are what CVE scans flag (tar, GHSA-23hp-3jrh-7fpw, 2026-09-26). python-tools
removes that npm; pyrefly never has it.

ruff (lint + format) comes from the trusted `uv-ruff` feature.

## Requirements

- uv: the bootstrap feature's `/usr/local/bin/uv`, or `~/.local/bin/uv`.
- The Python named by `python_version` already installed (the trusted `python`
  feature). `UV_PYTHON_DOWNLOADS=never`.

## Options

| Option | Default | |
|---|---|---|
| `pyrefly_version` | `1.3.1` | exact PyPI version |
| `python_version` | `3.14` | interpreter for the tool's virtualenv |
