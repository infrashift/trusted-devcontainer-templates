package tdt.pdp

# Policy Decision Point for trusted-devcontainer-templates.
#
# TWO ENTRY POINTS
#
#   data.tdt.pdp.repo_decision   Scope: the repository. Secret scanning and
#                                tool-pinning hygiene. Once per PR.
#
#   data.tdt.pdp.decision        Scope: one template. CVE policy over the
#                                built image, plus evidence integrity.
#
# ---------------------------------------------------------------------------
# ONE CVE GATE, FOR EVERY TEMPLATE
#
#   Critical                       -> blocking
#   High with fix_state "fixed"    -> blocking (actionable: a base bump or a
#                                     newer feature release clears it)
#   High with no available fix     -> recorded (non-blocking; nothing we
#                                     control clears it, and blocking would
#                                     gate every template on Fedora's backport
#                                     schedule rather than on anything we own)
#   Medium / Low                   -> recorded
#
# The previous gate blocked on any Critical or High regardless of fix state.
# ADR-004 wrote that against a UBI9 base; Fedora 43 carries newer packages and
# publishes advisories faster, so that rule now gates releases on a distro's
# disclosure cadence. Fix state is the line between "we can act" and "we cannot",
# and it is the only CVE-shaped thing that changed here.
#
# A blocking finding is waived ONLY by an entry in the committed exception
# register that names it, carries a justification and an owner, and has not
# expired as of input.evaluated_at. Waived findings surface in a distinct
# `waived` state. They are never silently dropped.
#
# ---------------------------------------------------------------------------
# DETERMINISM
#
# time.now_ns() is called NOWHERE in this file. Every temporal comparison uses
# input.evaluated_at, supplied by the caller. Re-running the gate on the same
# input a year later yields byte-identical output, which is what makes a signed
# verdict worth signing.
#
# ---------------------------------------------------------------------------
# FAIL-CLOSED CONTRACT. Read before editing anything below.
#
#   1. NUMBERS. `> 0` against a missing or non-numeric value is *undefined* in
#      Rego, which is silently non-violating. Every numeric field has a
#      companion is_number() guard. Never rely on the comparison alone.
#
#   2. ENUMS. Every enum is read through object.get() with a "<missing>"
#      sentinel and tested against a closed set. Unknown or absent violates.
#
#   3. SETS. Partial sets are declared `contains x if`, never `p[x] if`. Rego v1
#      reads the bracket form as a partial OBJECT and `opa check` accepts it, so
#      a clean scan silently returns {} instead of [] -- which is exactly how
#      this gate came to block every release. policies_test.rego pins the shape.

missing := "<missing>"

severities := {"Critical", "High", "Medium", "Low", "Negligible", "Unknown"}

fix_states := {"fixed", "not-fixed", "wont-fix", "unknown"}

# ---------------------------------------------------------------------------
# Shared helpers

# The register is loaded with `--data .github/pdp/exceptions.yaml`, whose single
# top-level key is `waivers`. Read through object.get so a missing or malformed
# file yields an empty register -- which waives nothing -- rather than an
# undefined reference that would make every rule using it silently vanish.
# Referenced as `data.waivers`, not object.get(data, ...): the latter makes the
# entire data document a dependency of this rule, which includes this package
# and is therefore a compile-time recursion error.
default waivers := []

waivers := w if {
	w := data.waivers
	is_array(w)
}

evaluated_at_ns := ns if {
	ns := time.parse_rfc3339_ns(object.get(input, ["evaluated_at"], ""))
	ns > 0
}

evaluated_at_str := object.get(input, ["evaluated_at"], missing)

# ===========================================================================
# REPO SCOPE
# ===========================================================================

default repo_decision := {
	"allow": false,
	"violations": [],
	"warnings": [],
	"error": "policy did not evaluate",
}

repo_decision := {
	"allow": count(repo_violations) == 0,
	"counts": {"violations": count(repo_violations), "warnings": count(repo_warnings)},
	"evaluated_at": evaluated_at_str,
	"violations": sort([v | some v in repo_violations]),
	"warnings": sort([w | some w in repo_warnings]),
}

repo_violations contains v if {
	not evaluated_at_ns
	v := {"code": "INPUT_TIMESTAMP_INVALID", "message": "input.evaluated_at is missing or not RFC3339. Denying."}
}

# --- Secret scanning -------------------------------------------------------
# A sibling repo asserted "gitleaks_passed": true as a hardcoded literal in a
# shell heredoc while .gitleaks.toml was 0 bytes and every rule was disabled.
# These rules consume MEASURED facts instead: the tool ran, the config is
# non-trivial, it extends the defaults, and the findings list is a real array.

repo_violations contains v if {
	object.get(input, ["gitleaks", "status"], missing) != "ran"
	v := {"code": "GITLEAKS_DID_NOT_RUN", "message": "gitleaks.status is not \"ran\". A gate that did not execute is not a pass. Denying."}
}

repo_violations contains v if {
	not is_array(object.get(input, ["gitleaks", "findings"], null))
	v := {"code": "GITLEAKS_REPORT_MALFORMED", "message": "gitleaks.findings is missing or not an array. Denying."}
}

repo_violations contains v if {
	not is_number(object.get(input, ["gitleaks", "config_bytes"], null))
	v := {"code": "GITLEAKS_CONFIG_UNKNOWN", "message": "gitleaks.config_bytes is missing or not a number. Denying."}
}

repo_violations contains v if {
	b := object.get(input, ["gitleaks", "config_bytes"], null)
	is_number(b)
	b < 64
	v := {"code": "GITLEAKS_CONFIG_EMPTY", "bytes": b, "message": sprintf(".gitleaks.toml is %v bytes. An empty config silently disables every rule and exits 0. Denying.", [b])}
}

repo_violations contains v if {
	object.get(input, ["gitleaks", "uses_default_ruleset"], false) != true
	v := {"code": "GITLEAKS_DEFAULTS_DISABLED", "message": ".gitleaks.toml must set [extend] useDefault = true. Denying."}
}

repo_violations contains v if {
	some leak in object.get(input, ["gitleaks", "findings"], [])
	v := {
		"code": "SECRET_DETECTED",
		"file": object.get(leak, "File", missing),
		"rule": object.get(leak, "RuleID", missing),
		"message": sprintf("Secret detected in %v (rule %v). Denying.", [object.get(leak, "File", missing), object.get(leak, "RuleID", missing)]),
	}
}

# --- Tool pinning ----------------------------------------------------------
# These binaries run in the same job as the signing key. Before tools.lock the
# devcontainer CLI, syft, grype and OPA all came from mutable refs.

repo_violations contains v if {
	not is_object(object.get(input, ["tools"], null))
	v := {"code": "TOOLS_LOCK_MISSING", "message": "input.tools is missing. tools.lock could not be read. Denying."}
}

repo_violations contains v if {
	some name, version in object.get(input, ["tools"], {})
	not regex.match(`^v?[0-9]+\.[0-9]+\.[0-9]+`, version)
	v := {
		"code": "TOOL_NOT_PINNED",
		"tool": name,
		"message": sprintf("tools.lock pins %v to %q, which is not a concrete version. Denying.", [name, version]),
	}
}

# --- Action pinning --------------------------------------------------------
# Reported by scripts/lint-workflows.sh, decided here.

repo_violations contains v if {
	some ref in object.get(input, ["unpinned_actions"], [])
	v := {
		"code": "ACTION_NOT_PINNED",
		"ref": ref,
		"message": sprintf("%v is not pinned to a full commit SHA. A movable ref is code execution in CI. Denying.", [ref]),
	}
}

# ===========================================================================
# TEMPLATE SCOPE
# ===========================================================================

default decision := {
	"verdict": "FAIL",
	"violations": [],
	"error": "policy did not evaluate",
}

decision := {
	"verdict": verdict,
	"template": object.get(input, ["template_id"], missing),
	"evaluated_at": evaluated_at_str,
	"counts": {
		"blocking": count(blocking_findings),
		"waived": count(waived_findings),
		"recorded": count(recorded_findings),
	},
	"violations": sort([v | some v in template_violations]),
	"blocking": sort([f | some f in blocking_findings]),
	"waived": sort([f | some f in waived_findings]),
	"exceptions_applied": sort([e | some e in exceptions_applied]),
}

verdict := "PASS" if {
	count(template_violations) == 0
	count(blocking_findings) == 0
} else := "FAIL"

# --- Input integrity -------------------------------------------------------

template_violations contains v if {
	not evaluated_at_ns
	v := {"code": "INPUT_TIMESTAMP_INVALID", "message": "input.evaluated_at is missing or not RFC3339. Denying."}
}

template_violations contains v if {
	not is_string(object.get(input, ["template_id"], null))
	v := {"code": "TEMPLATE_ID_MISSING", "message": "input.template_id is missing or not a string. Denying."}
}

template_violations contains v if {
	not is_array(object.get(input, ["matches"], null))
	v := {"code": "SCAN_REPORT_MALFORMED", "message": "input.matches is missing or not an array. A scan that produced no report is not a clean scan. Denying."}
}

template_violations contains v if {
	object.get(input, ["scan", "status"], missing) != "ran"
	v := {"code": "SCAN_DID_NOT_RUN", "message": "input.scan.status is not \"ran\". Denying."}
}

# An unrecognised severity or fix state means grype changed its vocabulary and
# the classification rules below can no longer be trusted to be exhaustive.
template_violations contains v if {
	some m in object.get(input, ["matches"], [])
	not object.get(m, "severity", missing) in severities
	v := {
		"code": "SEVERITY_UNKNOWN",
		"id": object.get(m, "id", missing),
		"message": sprintf("Finding %v has severity %q, outside the known set. Denying.", [object.get(m, "id", missing), object.get(m, "severity", missing)]),
	}
}

template_violations contains v if {
	some m in object.get(input, ["matches"], [])
	not object.get(m, "fix_state", missing) in fix_states
	v := {
		"code": "FIX_STATE_UNKNOWN",
		"id": object.get(m, "id", missing),
		"message": sprintf("Finding %v has fix_state %q, outside the known set. Denying.", [object.get(m, "id", missing), object.get(m, "fix_state", missing)]),
	}
}

# --- Classification --------------------------------------------------------

candidate_blocking contains m if {
	some m in object.get(input, ["matches"], [])
	object.get(m, "severity", missing) == "Critical"
}

candidate_blocking contains m if {
	some m in object.get(input, ["matches"], [])
	object.get(m, "severity", missing) == "High"
	object.get(m, "fix_state", missing) == "fixed"
}

blocking_findings contains f if {
	some m in candidate_blocking
	not waiver_for(m)
	f := {
		"id": object.get(m, "id", missing),
		"severity": object.get(m, "severity", missing),
		"package": object.get(m, "package", missing),
		"fix_state": object.get(m, "fix_state", missing),
	}
}

waived_findings contains f if {
	some m in candidate_blocking
	w := waiver_for(m)
	f := {
		"id": object.get(m, "id", missing),
		"severity": object.get(m, "severity", missing),
		"package": object.get(m, "package", missing),
		"waiver_id": object.get(w, "id", missing),
		"waiver_expires": object.get(w, "expires", missing),
		"waiver_owner": object.get(w, "owner", missing),
	}
}

recorded_findings contains f if {
	some m in object.get(input, ["matches"], [])
	not m in candidate_blocking
	f := {
		"id": object.get(m, "id", missing),
		"severity": object.get(m, "severity", missing),
		"package": object.get(m, "package", missing),
	}
}

exceptions_applied contains e if {
	some m in candidate_blocking
	w := waiver_for(m)
	e := {
		"cve": object.get(m, "id", missing),
		"waiver_id": object.get(w, "id", missing),
		"owner": object.get(w, "owner", missing),
		"expires": object.get(w, "expires", missing),
		"justification": object.get(w, "justification", missing),
	}
}

# --- Exception register ----------------------------------------------------
# A waiver must name the CVE, scope itself to a template, carry an owner and a
# justification, and carry an expiry that has not passed as of evaluated_at.
# Every field is required: a waiver missing any of them does not apply, so a
# malformed entry fails closed into "still blocking" rather than open.

# A waiver may name one CVE or a batch. A batch is not a shortcut: it exists so
# that findings sharing ONE rationale -- 36 CVEs inside a single distro-packaged
# binary nobody here can rebuild -- are one reviewed decision with one
# justification, rather than 36 near-identical records nobody reads.
waiver_cves(w) := cs if {
	cs := object.get(w, "cves", null)
	is_array(cs)
	count(cs) > 0
} else := [object.get(w, "cve", missing)]

# Two waivers can legitimately cover the same finding: a stdlib CVE appears in
# every Go binary, so an entry for git-lfs and an entry for fzf both name it.
# A function that yields both is an eval_conflict_error -- the policy does not
# fail closed, it fails to evaluate at all, which the release gate reports as a
# crash rather than a verdict. Collect the matches and take the first by sort
# order so the outcome is deterministic and the register can overlap freely.
matching_waivers(m) := sort([w |
	some w in waivers
	object.get(m, "id", "<no-id>") in waiver_cves(w)
	waiver_scope_matches(w)
	is_string(object.get(w, "id", null))
	is_string(object.get(w, "owner", null))
	is_string(object.get(w, "justification", null))
	count(object.get(w, "justification", "")) >= 20
	expiry := time.parse_rfc3339_ns(object.get(w, "expires", ""))
	expiry > evaluated_at_ns
])

waiver_for(m) := w if {
	ws := matching_waivers(m)
	count(ws) > 0
	w := ws[0]
}

# A waiver either names templates explicitly or applies to all of them. An
# empty or absent list means "all", which is deliberate and visible in the
# register rather than implied by omission.
waiver_scope_matches(w) if {
	not object.get(w, "templates", null)
}

waiver_scope_matches(w) if {
	ts := object.get(w, "templates", [])
	count(ts) == 0
}

waiver_scope_matches(w) if {
	ts := object.get(w, "templates", [])
	object.get(input, ["template_id"], missing) in ts
}

# --- Expired and malformed waivers are reported, never silent --------------

repo_warnings contains w if {
	some e in waivers
	expiry := time.parse_rfc3339_ns(object.get(e, "expires", ""))
	expiry <= evaluated_at_ns
	w := {
		"code": "WAIVER_EXPIRED",
		"waiver_id": object.get(e, "id", missing),
		"message": sprintf("Waiver %v for %v expired at %v. It no longer suppresses anything.", [object.get(e, "id", missing), object.get(e, "cve", missing), object.get(e, "expires", missing)]),
	}
}

repo_violations contains v if {
	some e in waivers
	not time.parse_rfc3339_ns(object.get(e, "expires", ""))
	v := {
		"code": "WAIVER_NO_EXPIRY",
		"waiver_id": object.get(e, "id", missing),
		"message": sprintf("Waiver %v has no parseable RFC3339 `expires`. A waiver without an end date is a permanent silent exception. Denying.", [object.get(e, "id", missing)]),
	}
}

repo_violations contains v if {
	some e in waivers
	count(object.get(e, "justification", "")) < 20
	v := {
		"code": "WAIVER_NO_JUSTIFICATION",
		"waiver_id": object.get(e, "id", missing),
		"message": sprintf("Waiver %v has no meaningful justification. Denying.", [object.get(e, "id", missing)]),
	}
}
