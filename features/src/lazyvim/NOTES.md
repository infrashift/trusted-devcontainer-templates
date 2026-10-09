# lazyvim

A LazyVim configuration -- core plus the language extras you name (Go by
default) -- that is fully installed at build time. After the build, Neovim
fetches nothing.

## Language extras (`extras`, 1.1.0)

One word, comma-separated, **no spaces** (the bootstrap runner passes each
option as `key=value`, which splits on whitespace):

| Value | Imports | Language server / linter, and the feature that installs it |
|---|---|---|
| `lang.go` (default) | LazyVim's go extra | gopls, gofumpt, goimports, dlv, golangci-lint -- `go-tools` |
| `lang.python` | LazyVim's python extra | pyrefly -- `pyrefly` (`python_lsp=pyrefly`, default) or basedpyright -- `python-tools` (`python_lsp=basedpyright`); ruff -- trusted `uv-ruff` |
| `lang.java` | LazyVim's java extra + `infrashift.extras.java` | jdtls (+ lombok) -- `java-tools` |
| `infrashift.cue` | `infrashift.extras.cue` | `cue lsp` -- trusted `cuelang` |
| `infrashift.ansible_lint` | `infrashift.extras.ansible_lint` | ansible-lint through nvim-lint -- `ansible-tools` |

```jsonc
"ghcr.io/infrashift/trusted-devcontainer-templates/features/lazyvim@sha256:…": {
    "extras": "lang.python"
}
```

The role renders `~/.config/nvim/lua/config/extras.lua` from the option.
`infrashift.*` extras ship under `lua/infrashift/extras/`:

- `java` replaces the java extra's jdtls command, which would add a lombok agent
  from Mason's directory (absent here), with `jdtls` -- java-tools' launcher adds
  lombok itself.
- `cue` is the whole of a CUE extra: the tree-sitter parser and `cue lsp`.
- `ansible_lint` gives playbooks, roles and task files the filetype
  `yaml.ansible`, runs ansible-lint on them through nvim-lint, and keeps YAML
  highlighting -- diagnostics without a language server, so without Node.

`python_lsp` (1.2.0) picks the python extra's language server: `pyrefly` (default;
a native binary, the `pyrefly` feature) or `basedpyright` (a Node program, the
`python-tools` feature). It is rendered into `extras.lua` as
`vim.g.lazyvim_python_lsp`, which the extra reads when its spec loads.

**One lockfile covers every extra** (`files/extras.json` lists them; `make
lazy-lock` resolves over all of them). An image installs only the plugins its
own spec names, so the pin checks ask lazy.nvim for that spec and check exactly
those plugins -- a plugin only `lang.java` needs is absent from a Go image by
design. Every plugin the spec names must be in the lockfile, or the build fails.

## What is pinned, and how

| Input | Pinned by | Checked by |
|---|---|---|
| every plugin, lazy.nvim included | `files/nvim/lazy-lock.json` | `git rev-parse HEAD` of each plugin equals its locked commit; the build fails otherwise |
| tree-sitter parsers | the grammar revisions pinned by the locked nvim-treesitter commit | every parser LazyVim asks for is installed |
| tree-sitter CLI, stylua, shfmt | SHA256 per version and architecture | exact version output |
| language servers and formatters | the language's tools feature (see above) | — |

The hand-built image ran `Lazy! sync` against branch heads and ignored its exit
status (`|| true`). Here `Lazy! restore` installs from the lockfile, and the
role then checks every plugin's commit itself, because headless Neovim exits 0
after most plugin errors.

## The parser build reports what happened (1.2.1)

nvim-treesitter keeps its log in memory and only echoes it, so a parser that
failed to download or compile never reached a CI log. A cold build lost bash,
tsx, typescript and vim with the build step reporting success after 61 s, and
the cause could not be read anywhere. Since 1.2.1 the build step prints one
line in every build:

```
PARSERS_INSTALLED ok=<install()'s verdict> seconds=<n> wanted=<n> attempts=<n> missing_at_return=<parsers>
```

(`attempts` since 1.2.3.)

When the re-check still finds a parser missing, the task before the failing
assert prints that line, every `error`/`warn` nvim-treesitter logged, and every
log line about each missing parser. The log covers every installer in that
Neovim, LazyVim's startup install included. A parser with an `error` line
failed. A parser with `Compiling parser` and no outcome was still compiling
when `install()` returned. The pass/fail rule is unchanged.

## The build waits out LazyVim's own parser install (1.2.3)

That report named the cause on gcloud-dc's 1-core CI runners (2026-10-09, three
builds alike): `ok=false seconds=60 missing_at_return=vim`, with one download
of `tree-sitter-vim` and `Compiling parser` as its last log line.

LazyVim's treesitter config installs every missing parser when the plugin
loads, in the same Neovim the build step runs, and it started `vim` first.
nvim-treesitter lets a second install of a language that is already being built
wait at most 60 s (`INSTALL_TIMEOUT` in `install_lang`, main `f603a2f4`), then
return false. `vim` is the one parser whose `tree-sitter build` takes longer
than that on one core. The step then ended, Neovim exited, and the unfinished
build went with it. A faster machine finishes `vim` inside the 60 s, which is
why it passed elsewhere and on retries.

Since 1.2.3 the build step calls `install()` again with the parsers still
missing, until none is missing. Each call waits out the build in progress. An
attempt that fails in under 55 s cannot be that wait, because the wait always
lasts the full 60 s: the parser failed on its own, so the step stops calling.
1800 s bounds all attempts together.

## No runtime downloads

`lua/plugins/offline.lua`:

- empties Mason's `ensure_installed`
- sets `mason = false` on every LSP server, so gopls comes from `PATH`
- disables `lua_ls`, which is not installed
- switches blink.cmp to its Lua matcher instead of its downloaded native one

`lua/config/lazy.lua` turns off the update checker, change detection and
luarocks. It refuses to clone an unpinned lazy.nvim if the pinned one is
missing.

A developer can still add plugins in their own `~/.config/nvim/lua/plugins/*.lua`,
or extras through `:LazyExtras`. Those install at runtime, unpinned, by that
developer's choice. This feature only overwrites the files it ships.

## Two lanes

`install.sh` runs two roles:

- `ansible-role-system` (privileged) installs `gcc` (nvim-treesitter compiles
  parsers), `git`, `ripgrep` and `fd-find`.
- `ansible-role-feature` (userland) does everything under `$HOME`.

## Updating plugins

`make lazy-lock` regenerates `lazy-lock.json` over every extra in
`files/extras.json`, then you bump this feature's version. See
`features/README.md`. Adding an extra wants `LAZY_LOCK_EXTEND=1 make lazy-lock`:
every existing pin is kept (and checked to be unchanged) and only the plugins
the lockfile does not have yet are resolved. `DOCKER=podman` runs it with podman.

| Option | Default | |
|---|---|---|
| `extras` | `lang.go` | comma-separated language extras, no spaces (see above) |
| `python_lsp` | `pyrefly` | `pyrefly` or `basedpyright`, for `lang.python` |
| `tree_sitter_version` / `tree_sitter_checksum` | `0.27.0` / `""` | tree-sitter CLI |
| `stylua_version` / `stylua_checksum` | `2.5.2` / `""` | Lua formatter |
| `shfmt_version` / `shfmt_checksum` | `3.14.1` / `""` | shell formatter |
