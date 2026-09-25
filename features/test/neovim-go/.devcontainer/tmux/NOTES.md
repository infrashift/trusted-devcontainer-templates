# tmux

Installs tmux and the `dev-session` layout, which replaces the SSH
`ForceCommand` the hand-built devpod-neovim image used:

```
┌─────────────────────────┬──────────────┐
│         editor          │    shell     │
└─────────────────────────┴──────────────┘
```

Everything is written by the privileged lane and is root-owned:

| Path | What |
|---|---|
| `/etc/tmux.conf` | system-wide config: tmux-256color, RGB for xterm-256color, mouse, escape-time 10, focus-events. `~/.tmux.conf` still wins. |
| `/usr/local/bin/dev-session` | attach to the session, creating the layout first if needed. `--detach` creates it without attaching. |
| `/etc/profile.d/dev-session.sh` | the login hook |

## When the layout starts by itself

The hook runs `dev-session` only when **all** of these hold:

- the shell is interactive bash, with a terminal on stdin and stdout
- the shell is not already inside tmux
- the terminal is not VS Code's or JetBrains' integrated terminal
- `DEV_SESSION` is not `off`
- `~/.config/dev-session/disabled` does not exist
- the connection is over ssh, if `autostart=ssh`

So `ssh -p 2222 dev@host` and an interactive `devcontainer exec bash` land in
the layout. `ssh host cmd`, VS Code's server, and scripted probes never do.
Detaching (`C-b d`) ends the login, as the old `ForceCommand` did. If
`dev-session` fails, the login falls through to a plain shell rather than
locking you out.

Opting out:

```sh
ssh -t -p 2222 dev@host DEV_SESSION=off bash -l                  # one login
mkdir -p ~/.config/dev-session && touch ~/.config/dev-session/disabled   # always
```

## Terminals the container does not know

When the client's `TERM` has no terminfo entry in the container (for example
`xterm-ghostty` or `xterm-kitty`), `dev-session` falls back to
`TERM=xterm-256color`, because otherwise tmux refuses to start.

| Option | Default | |
|---|---|---|
| `session_name` | `dev` | letters, digits, `_`, `-` (tmux reserves `.` and `:`) |
| `editor_pane_command` | `nvim` | run in the left pane; the pane becomes a login shell when it exits |
| `shell_pane_percent` | `35` | right pane width, 10–90 |
| `autostart` | `interactive` | `interactive`, `ssh`, or `never` |
