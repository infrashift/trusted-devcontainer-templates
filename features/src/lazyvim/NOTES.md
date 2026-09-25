# lazyvim

A LazyVim configuration (core plus the Go language extra) that is fully
installed at build time. After the build, Neovim fetches nothing.

## What is pinned, and how

| Input | Pinned by | Checked by |
|---|---|---|
| every plugin, lazy.nvim included | `files/nvim/lazy-lock.json` | `git rev-parse HEAD` of each plugin equals its locked commit; the build fails otherwise |
| tree-sitter parsers | the grammar revisions pinned by the locked nvim-treesitter commit | every parser LazyVim asks for is installed |
| tree-sitter CLI, stylua, shfmt | SHA256 per version and architecture | exact version output |
| language servers and formatters for Go | the `go-tools` feature | — |

The hand-built image ran `Lazy! sync` against branch heads and ignored its exit
status (`|| true`). Here `Lazy! restore` installs from the lockfile, and the
role then checks every plugin's commit itself, because headless Neovim exits 0
after most plugin errors.

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

`make lazy-lock` regenerates `lazy-lock.json`, then you bump this feature's
version. See `features/README.md`.

| Option | Default | |
|---|---|---|
| `tree_sitter_version` / `tree_sitter_checksum` | `0.27.0` / `""` | tree-sitter CLI |
| `stylua_version` / `stylua_checksum` | `2.5.2` / `""` | Lua formatter |
| `shfmt_version` / `shfmt_checksum` | `3.14.1` / `""` | shell formatter |
