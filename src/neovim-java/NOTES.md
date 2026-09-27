# tmux + Neovim + Java (Trusted) Template

A terminal-first Java environment built on the trusted Fedora 43 base image. Log in and you land in a tmux session with Neovim on the left and a shell on the right. Log in again and you re-attach to the same session.

## Included Tools

- **tmux** with the `dev-session` layout (editor | shell)
- **Neovim** with a pinned **LazyVim** configuration (core plus the Java extra, `extras: lang.java`). Every plugin is at a locked commit, and the tree-sitter parsers are built at image build time.
- **OpenJDK 21**, **Maven** and **Gradle**
- **jdtls** 1.61.0 (the Eclipse JDT Language Server) with **lombok**, installed userland by the `java-tools` feature, with a shell launcher on `PATH` that always adds the lombok agent
- **sshd** on port 2222: public-key only, and only the `dev` user may log in
- **Git** and **Git LFS**, **make**
- **Grype** and **Syft** for vulnerability scanning and SBOM generation
- **jq** and **yq** for structured data processing

After the build, the editor downloads nothing. Mason and blink.cmp's native matcher are switched off, and jdtls comes from `PATH`. See the `lazyvim` feature's notes. jdtls keeps its per-project configuration and workspace under `~/.cache/jdtls/`; the first open of a project takes a while as it indexes.

## Connecting

**Over SSH.** No key is baked into the image. Mount your public key where the `sshd` feature looks for it, and publish the port:

```jsonc
// .devcontainer/devcontainer.json, in the project that uses this template
"mounts": [
    "source=${localEnv:HOME}/.ssh/id_ed25519.pub,target=/run/secrets/authorized_keys,type=bind,readonly"
],
"appPort": ["2222:2222"]
```

```sh
ssh -p 2222 dev@localhost
```

Host keys are generated at build time, so they change on every rebuild. Point `StrictHostKeyChecking` and `UserKnownHostsFile` for this host accordingly in your `~/.ssh/config`.

**Without SSH.** `devpod ssh`, or an interactive `devcontainer exec --workspace-folder . bash -l`, lands in the same layout. You can also run `dev-session` yourself from any shell.

## When the layout starts, and how to skip it

The layout starts automatically on interactive terminal logins only. `ssh host cmd`, VS Code's server and its integrated terminal, and scripted probes get a plain shell. Detaching (`C-b d`) ends the login.

```sh
ssh -t -p 2222 dev@localhost DEV_SESSION=off bash -l                    # one login
mkdir -p ~/.config/dev-session && touch ~/.config/dev-session/disabled   # always
```

## Customising

- **Neovim:** add your own specs under `~/.config/nvim/lua/plugins/`. The feature only overwrites the files it ships. Plugins you add this way, or through `:LazyExtras`, install at runtime and are not pinned by this image.
- **tmux:** `~/.tmux.conf` is read after the system-wide `/etc/tmux.conf`.
- **Feature options:** pass them in `devcontainer.json`, e.g. `"…/features/tmux": { "autostart": "ssh" }` to start the layout only on ssh logins.

## Usage

After creating your devcontainer from this template, you can add features such as `claude-code`, `openai-codex` or `cuelang` in the same way as the other templates.
