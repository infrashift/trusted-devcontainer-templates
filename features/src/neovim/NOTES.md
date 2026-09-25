# neovim

Installs the upstream Neovim release build (`nvim-linux-{x86_64,arm64}.tar.gz`)
into `~/.local/share/nvim-dist/<version>/`, linked as `~/.local/bin/nvim`.

- **Verified.** The tarball's SHA256 is pinned per version and architecture in
  `ansible-role-feature/vars/main.yml`. To install any other version, pass
  `target_checksum`; without it the role refuses to download.
- **Version asserted exactly.** `nvim --version` must open with
  `NVIM v<target_version>`.
- **Upgrades replace the tree.** A version change removes the previous
  distribution before extracting, so no stale runtime files linger.
- **Separate from Neovim's own data.** The install directory is deliberately
  not `~/.local/share/nvim`, which is Neovim's `stdpath('data')`: plugins and
  parsers live there.

| Option | Default | |
|---|---|---|
| `target_version` | `0.12.5` | Neovim release |
| `target_checksum` | `""` | SHA256 of the tarball; required for an unpinned version |
