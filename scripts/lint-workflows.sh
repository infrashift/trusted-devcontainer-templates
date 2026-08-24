#!/usr/bin/env bash
# Mechanical checks over .github/workflows/.
#
# Every rule here exists because the failure it catches is invisible in review:
# a `uses:` on a movable tag looks identical to a pinned one, a required status
# context spelled two ways looks like two correct strings, and a paths: filter
# that has drifted from the gate's own regex looks like nothing at all.
set -euo pipefail

WF=".github/workflows"
fail=0

err() { echo "error: $*" >&2; fail=1; }

# --- 1. Every action pinned to a full commit SHA ---------------------------
# A tag is mutable. `actions/checkout@v4` is a promise from whoever can move
# that tag, and several of these actions run in the job holding the signing key.
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  # Local composite actions (./.github/actions/x) are in-tree, so the commit
  # under review IS the pin.
  case "$ref" in ./*) continue ;; esac
  if ! [[ "$ref" =~ @[0-9a-f]{40}$ ]]; then
    err "action not pinned to a commit SHA: ${ref}"
  fi
done < <(grep -rhoE '^\s*(-\s*)?uses:\s*\S+' "$WF"/ | sed -E 's/^\s*(-\s*)?uses:\s*//' | sort -u)

# --- 2. Every pinned action carries a version comment ----------------------
# A bare 40-hex SHA is unreviewable. The trailing `# v4` is what makes a bump
# legible in a diff.
while IFS= read -r line; do
  [ -n "$line" ] || continue
  if ! [[ "$line" =~ \#[[:space:]]*v?[0-9] ]]; then
    err "pinned action has no version comment: ${line}"
  fi
done < <(grep -rhE '^\s*(-\s*)?uses:\s*\S+@[0-9a-f]{40}' "$WF"/ | sed -E 's/^\s*(-\s*)?//' | sort -u)

# --- 3. No workflow-level write permissions --------------------------------
# Workflow-level grants apply to EVERY job, including ones that only read.
# Least privilege has to be per job.
for f in "$WF"/*.y*ml; do
  # The workflow-level permissions block is the one at column 0.
  if awk '/^permissions:/{flag=1;next} /^[a-z]/{flag=0} flag && /write/{print;exit}' "$f" | grep -q write; then
    err "$(basename "$f"): workflow-level permissions grant write. Move the grant to the job that needs it."
  fi
done

# --- 4. Required status contexts spelled identically everywhere ------------
# pr-gate.yml seeds this context and review.yml resolves it. If the two strings
# ever differ, the seeded check stays pending forever and every PR hangs.
CONTEXTS=$(grep -rhoE '\-f context="[^"]+"' "$WF"/ | sed -E 's/.*context="([^"]+)".*/\1/' | sort -u)
N=$(printf '%s\n' "$CONTEXTS" | grep -c . || true)
if [ "$N" -gt 1 ]; then
  err "more than one status context string in use; they must match exactly:"
  printf '%s\n' "$CONTEXTS" | sed 's/^/       /' >&2
fi

# --- 5. The PR gate must not be path-filtered ------------------------------
# A path-filtered workflow does not run at all, so its required contexts never
# appear and a docs-only PR waits forever on a check that will never report.
if [ -f "$WF/pr-gate.yml" ]; then
  if awk '/^on:/{flag=1;next} /^[a-z]/{flag=0} flag' "$WF/pr-gate.yml" | grep -q 'paths:'; then
    err "pr-gate.yml is path-filtered. It must report on every PR."
  fi
fi

# --- 6. Untrusted values reach run: blocks through env, not interpolation ---
# `${{ }}` inside a run: block is textual substitution before the shell sees it.
# github.event.* fields are attacker-controlled on a fork PR.
while IFS= read -r hit; do
  err "untrusted interpolation inside a run: block -- pass it through env: instead: ${hit}"
done < <(grep -rnE '\$\{\{\s*github\.event\.(pull_request\.(title|body|head\.(ref|label))|issue\.(title|body)|comment\.body)' "$WF"/ || true)

if [ "$fail" -eq 0 ]; then
  echo "OK: workflow lint clean"
fi
exit "$fail"
