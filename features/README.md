# Repo-local features

Trusted devcontainer features built, tested and published from this repository.
Why they live here rather than in
[trusted-devcontainer-features](https://github.com/infrashift/trusted-devcontainer-features),
and how they move there later, is recorded in
[ADR-009](../docs/src/content/docs/decisions/adr-009-repo-local-features.md).

| Feature | Lane | Installs |
|---|---|---|
| [`tmux`](src/tmux/NOTES.md) | privileged | tmux, `/etc/tmux.conf`, the `dev-session` layout (editor \| shell) and its login hook |
| [`neovim`](src/neovim/NOTES.md) | userland | the upstream Neovim release build |
| [`go-tools`](src/go-tools/NOTES.md) | userland | gopls, gofumpt, goimports, gomodifytags, impl, dlv, golangci-lint |
| [`pyrefly`](src/pyrefly/NOTES.md) | userland | pyrefly, a Python type checker + language server in Rust -- no Node (`uv tool install`) |
| [`python-tools`](src/python-tools/NOTES.md) | userland | basedpyright (`uv tool install`; its bundled npm removed) |
| [`java-tools`](src/java-tools/NOTES.md) | userland | Eclipse JDT Language Server + lombok, and a `jdtls` launcher that needs no Python |
| [`ansible-tools`](src/ansible-tools/NOTES.md) | userland | ansible-lint (`uv tool install`) |
| [`lazyvim`](src/lazyvim/NOTES.md) | both | LazyVim with the language extras you name (`extras`: Go by default; python -- pyrefly or basedpyright via `python_lsp` --, java, cue, ansible-lint), every plugin at a locked commit, its tree-sitter parsers, and stylua/shfmt/tree-sitter |

Published as `ghcr.io/infrashift/trusted-devcontainer-templates/features/<id>`, signed
with this repository's release key and keylessly through Sigstore.

## The contract

These follow the feature role contract of trusted-devcontainer-features (its
ADR-012), unchanged, so a feature can move there by copying its directory:

- `install.sh` is a thin wrapper around `/opt/bootstrap/run-feature.sh`, which
  the `bootstrap` feature provides.
- Every option default lives in `devcontainer-feature.json` and nowhere else.
  `defaults/main.yml` is empty, and `install.sh` fails on an empty mandatory
  option with `${VAR:?}`.
- Each role opens by asserting the runner contract, then every parameter by
  name and **shape**.
- Every download carries a per-version, per-architecture SHA256.
- Each role verifies the exact version it asked for.
- A second run reports `changed=0`.

Two differences, both forced by living outside that repository:

- **`dependsOn` is absolute and digest-pinned** —
  `ghcr.io/infrashift/trusted-devcontainer-features/bootstrap@sha256:…`, the
  same digest every template here pins. `make check-features` fails if they
  disagree.
- **`installsAfter` names siblings as `./<id>`.** The devcontainer CLI fetches
  every `installsAfter` reference, so an absolute reference to an unpublished
  sibling would break the local build. The release rewrites them to the
  production namespace.

## Working on a feature

```sh
make check-features          # contract, bootstrap pin, published-version drift
make test-feature-template   # build features/test/neovim-go from the working tree,
                             # run tests.sh, then the contract tests
make test-feature-template FEATURE_TEST=neovim-langs
                             # the same for the language tools features and the
                             # python/java/cue/ansible-lint extras, in one image
make lazy-lock               # re-resolve LazyVim's plugin lockfile (see below)
```

`test-feature-template` copies `features/src/*` into the test template's
`.devcontainer/`, which is gitignored. The test template references them as
`./tmux` etc., so it always builds what is in the working tree.

Any change to a feature's source needs a version bump in its
`devcontainer-feature.json`. Publishing skips a version that already exists, and
`check-published-drift.sh` fails the pull request rather than letting a change
go out as a silent no-op.

### Updating plugins

`features/src/lazyvim/ansible-role-feature/files/nvim/lazy-lock.json` decides
which commit of every plugin is installed. `make lazy-lock` regenerates it by
running `Lazy! sync` in a throwaway container built from the templates' base
image and the pinned Neovim. It is the one deliberately unpinned operation in
the pipeline, and its output is a diff of commit hashes to review. Bump the
`lazyvim` version in the same change.

It resolves over **every** extra in `lazyvim/ansible-role-feature/files/extras.json`,
so the one lockfile covers them all. Adding an extra wants
`LAZY_LOCK_EXTEND=1 make lazy-lock`, which keeps every existing pin (and fails if
one moved) and resolves only the new plugins. `DOCKER=podman` runs it with podman.

## Release

`.github/workflows/release-features.yml` runs on push to `main` when
`features/src/**` changes:

1. **stage** (Build-Actor) — publish to the private
   `…/trusted-devcontainer-templates-staging/features` namespace. Unchanged
   versions are seeded from production, so their digests never move.
2. **review** (Review-Actor) — read the staged artifacts back and check them:
   no relative references, and `dependsOn` exactly equals the templates'
   bootstrap. Then sign a verdict naming the approved digests.
3. **promote** (Release-Actor) — verify the verdict against `review.pub`, sign
   the staged digests (keyed and keyless), then copy exactly those digests,
   with their signatures, to production.

Then pin them into a template in a follow-up PR with `make pin-features`.

Verify a published feature:

```sh
cosign verify --key .github/pdp/public-keys/release.pub \
  ghcr.io/infrashift/trusted-devcontainer-templates/features/tmux:latest
```
