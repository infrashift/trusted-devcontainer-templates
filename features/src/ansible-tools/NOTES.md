# ansible-tools

ansible-lint on `PATH`, pinned to an exact version, for the lazyvim feature's
`infrashift.ansible_lint` extra: nvim-lint runs it on playbooks, roles and task
files (filetype `yaml.ansible`). No language server is involved -- no Node.

| Tool | From | How |
|---|---|---|
| ansible-lint | PyPI | `uv tool install ansible-lint==<version> --python <python_version>` |

Installed userland: its own virtualenv under `~/.local/share/uv/tools`, the
entry point in `~/.local/bin`. ansible-lint depends on ansible-core and gets its
own copy inside that virtualenv, so the `ansible` the trusted ansible-core
feature installs is untouched.

## Requirements

- uv: the bootstrap feature's `/usr/local/bin/uv`, or `~/.local/bin/uv`.
- The Python named by `python_version` already installed (the trusted `python`
  feature). `UV_PYTHON_DOWNLOADS=never`.

## Options

| Option | Default | |
|---|---|---|
| `ansible_lint_version` | `26.9.0` | exact PyPI version |
| `python_version` | `3.14` | interpreter for the tool's virtualenv |
