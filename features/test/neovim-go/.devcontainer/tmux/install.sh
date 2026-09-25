#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# tmux-feature/install.sh
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Maintainer: infrashift.sh
#
# Thin wrapper. All installation logic lives in ansible-role-feature/.
# The shared runner is provided by the 'bootstrap' feature (see dependsOn).
#
# --privileged: installs a system RPM and writes /etc/tmux.conf,
# /etc/profile.d/dev-session.sh and /usr/local/bin/dev-session, so the runner
# keeps this as root instead of dropping to the target user. Those files are
# root-owned on purpose: the account the layout starts for cannot rewrite the
# hook that starts it.
set -euo pipefail

# Fail in the shell when a mandatory option resolves empty. None of these has a
# safe fallback, and a fallback here would be a second source of truth.
: "${SESSION_NAME:?feature option 'session_name' resolved empty — devcontainer-feature.json must declare a default}"
: "${EDITOR_PANE_COMMAND:?feature option 'editor_pane_command' resolved empty — devcontainer-feature.json must declare a default}"
: "${SHELL_PANE_PERCENT:?feature option 'shell_pane_percent' resolved empty — devcontainer-feature.json must declare a default}"
: "${AUTOSTART:?feature option 'autostart' resolved empty — devcontainer-feature.json must declare a default}"

exec /opt/bootstrap/run-feature.sh \
    --role ansible-role-feature \
    --privileged \
    -e "_tmux_session_name=${SESSION_NAME}" \
    -e "_tmux_editor_pane_command=${EDITOR_PANE_COMMAND}" \
    -e "_tmux_shell_pane_percent=${SHELL_PANE_PERCENT}" \
    -e "_tmux_autostart=${AUTOSTART}"
