package tdt.pdp_test

import data.tdt.pdp

# The gate consumes `violations` / `blocking` as JSON ARRAYS. If any of these
# rules is ever written `p[x] if { ... }` instead of `p contains x if { ... }`,
# Rego v1 makes it a partial OBJECT, `opa check --strict` still passes, and a
# clean scan marshals to {} instead of []. That is not hypothetical: it is how
# this gate came to block every release. The shape assertions below are the
# guard, because a type check will not do it.

NOW := "2026-08-23T00:00:00Z"

# ===========================================================================
# repo_decision
# ===========================================================================

clean_repo := {
	"evaluated_at": NOW,
	"gitleaks": {"status": "ran", "findings": [], "config_bytes": 3338, "uses_default_ruleset": true},
	"tools": {"OPA_VERSION": "v1.19.1", "SYFT_VERSION": "v1.51.0"},
	"unpinned_actions": [],
}

test_clean_repo_is_allowed if {
	d := pdp.repo_decision with input as clean_repo
	d.allow
	d.counts.violations == 0
}

test_repo_violations_marshal_as_an_array if {
	d := pdp.repo_decision with input as clean_repo
	json.marshal(d.violations) == "[]"
	json.marshal(d.warnings) == "[]"
}

# --- fail-closed on the input itself ---------------------------------------

test_missing_timestamp_denies if {
	d := pdp.repo_decision with input as object.remove(clean_repo, {"evaluated_at"})
	not d.allow
	some v in d.violations
	v.code == "INPUT_TIMESTAMP_INVALID"
}

test_non_rfc3339_timestamp_denies if {
	d := pdp.repo_decision with input as object.union(clean_repo, {"evaluated_at": "yesterday"})
	not d.allow
}

# A policy that fails to evaluate must deny, never return undefined.
test_default_repo_decision_denies if {
	d := pdp.repo_decision with input as "not-an-object"
	not d.allow
}

# --- secret scanning -------------------------------------------------------

test_gitleaks_not_run_denies if {
	d := pdp.repo_decision with input as object.union(clean_repo, {"gitleaks": {"status": "not-installed", "findings": [], "config_bytes": 3338, "uses_default_ruleset": true}})
	not d.allow
	some v in d.violations
	v.code == "GITLEAKS_DID_NOT_RUN"
}

# The headline case: an empty config means zero rules, so gitleaks scans, finds
# nothing and exits 0 -- indistinguishable from a clean scan unless the byte
# count is what the policy reads.
test_empty_gitleaks_config_denies if {
	d := pdp.repo_decision with input as object.union(clean_repo, {"gitleaks": {"status": "ran", "findings": [], "config_bytes": 0, "uses_default_ruleset": true}})
	not d.allow
	some v in d.violations
	v.code == "GITLEAKS_CONFIG_EMPTY"
	v.bytes == 0
}

test_gitleaks_defaults_disabled_denies if {
	d := pdp.repo_decision with input as object.union(clean_repo, {"gitleaks": {"status": "ran", "findings": [], "config_bytes": 3338, "uses_default_ruleset": false}})
	not d.allow
	some v in d.violations
	v.code == "GITLEAKS_DEFAULTS_DISABLED"
}

test_malformed_findings_denies if {
	d := pdp.repo_decision with input as object.union(clean_repo, {"gitleaks": {"status": "ran", "findings": "none", "config_bytes": 3338, "uses_default_ruleset": true}})
	not d.allow
	some v in d.violations
	v.code == "GITLEAKS_REPORT_MALFORMED"
}

test_non_numeric_config_bytes_denies if {
	d := pdp.repo_decision with input as object.union(clean_repo, {"gitleaks": {"status": "ran", "findings": [], "config_bytes": "3338", "uses_default_ruleset": true}})
	not d.allow
	some v in d.violations
	v.code == "GITLEAKS_CONFIG_UNKNOWN"
}

test_detected_secret_denies_and_names_the_file if {
	leak := {"File": "cosign.key", "RuleID": "cosign-sigstore-private-key"}
	d := pdp.repo_decision with input as object.union(clean_repo, {"gitleaks": {"status": "ran", "findings": [leak], "config_bytes": 3338, "uses_default_ruleset": true}})
	not d.allow
	some v in d.violations
	v.code == "SECRET_DETECTED"
	v.file == "cosign.key"
}

# --- tool and action pinning ----------------------------------------------

test_unpinned_tool_denies if {
	d := pdp.repo_decision with input as object.union(clean_repo, {"tools": {"OPA_VERSION": "latest"}})
	not d.allow
	some v in d.violations
	v.code == "TOOL_NOT_PINNED"
	v.tool == "OPA_VERSION"
}

test_missing_tools_lock_denies if {
	d := pdp.repo_decision with input as object.remove(clean_repo, {"tools"})
	not d.allow
	some v in d.violations
	v.code == "TOOLS_LOCK_MISSING"
}

test_unpinned_action_denies if {
	d := pdp.repo_decision with input as object.union(clean_repo, {"unpinned_actions": ["actions/checkout@v4"]})
	not d.allow
	some v in d.violations
	v.code == "ACTION_NOT_PINNED"
	v.ref == "actions/checkout@v4"
}

# ===========================================================================
# decision -- CVE policy over one template
# ===========================================================================

scan(matches) := {
	"evaluated_at": NOW,
	"template_id": "python",
	"scan": {"status": "ran"},
	"matches": matches,
}

crit := {"id": "CVE-2026-0001", "severity": "Critical", "package": "openssl", "fix_state": "fixed"}

high_fixed := {"id": "CVE-2026-0002", "severity": "High", "package": "curl", "fix_state": "fixed"}

high_nofix := {"id": "CVE-2026-0003", "severity": "High", "package": "glibc", "fix_state": "not-fixed"}

med := {"id": "CVE-2026-0004", "severity": "Medium", "package": "zlib", "fix_state": "fixed"}

test_clean_scan_passes if {
	d := pdp.decision with input as scan([])
	d.verdict == "PASS"
	d.counts.blocking == 0
	json.marshal(d.blocking) == "[]"
}

test_critical_blocks if {
	d := pdp.decision with input as scan([crit])
	d.verdict == "FAIL"
	d.counts.blocking == 1
}

test_high_with_a_fix_blocks if {
	d := pdp.decision with input as scan([high_fixed])
	d.verdict == "FAIL"
}

# The substantive change from the old gate: a High nobody can act on is
# recorded, not blocking. Otherwise every release waits on Fedora's backport
# schedule rather than on anything this repo controls.
test_high_without_a_fix_is_recorded_not_blocking if {
	d := pdp.decision with input as scan([high_nofix])
	d.verdict == "PASS"
	d.counts.blocking == 0
	d.counts.recorded == 1
}

test_medium_and_low_never_block if {
	d := pdp.decision with input as scan([med])
	d.verdict == "PASS"
	d.counts.recorded == 1
}

test_mixed_scan_counts_each_bucket if {
	d := pdp.decision with input as scan([crit, high_fixed, high_nofix, med])
	d.counts.blocking == 2
	d.counts.recorded == 2
	d.verdict == "FAIL"
}

# --- fail-closed on the scan report ---------------------------------------

test_missing_matches_denies if {
	d := pdp.decision with input as object.remove(scan([]), {"matches"})
	d.verdict == "FAIL"
	some v in d.violations
	v.code == "SCAN_REPORT_MALFORMED"
}

test_scan_that_did_not_run_denies if {
	d := pdp.decision with input as object.union(scan([]), {"scan": {"status": "error"}})
	d.verdict == "FAIL"
	some v in d.violations
	v.code == "SCAN_DID_NOT_RUN"
}

test_missing_template_id_denies if {
	d := pdp.decision with input as object.remove(scan([]), {"template_id"})
	d.verdict == "FAIL"
	some v in d.violations
	v.code == "TEMPLATE_ID_MISSING"
}

# An unknown severity means grype changed its vocabulary, so the classification
# rules can no longer be assumed exhaustive. Deny rather than guess.
test_unknown_severity_denies if {
	d := pdp.decision with input as scan([{"id": "CVE-X", "severity": "Catastrophic", "package": "p", "fix_state": "fixed"}])
	d.verdict == "FAIL"
	some v in d.violations
	v.code == "SEVERITY_UNKNOWN"
}

test_unknown_fix_state_denies if {
	d := pdp.decision with input as scan([{"id": "CVE-X", "severity": "High", "package": "p", "fix_state": "maybe"}])
	d.verdict == "FAIL"
	some v in d.violations
	v.code == "FIX_STATE_UNKNOWN"
}

test_default_decision_denies if {
	d := pdp.decision with input as "not-an-object"
	d.verdict == "FAIL"
}

# ===========================================================================
# Exception register
# ===========================================================================

good_waiver := {
	"id": "EXC-2026-0001",
	"cve": "CVE-2026-0001",
	"expires": "2026-12-01T00:00:00Z",
	"owner": "@ryancraig",
	"justification": "No rebuilt Fedora package yet; path unreachable from any template entrypoint.",
}

test_valid_waiver_moves_blocking_to_waived if {
	d := pdp.decision with input as scan([crit]) with data.waivers as [good_waiver]
	d.verdict == "PASS"
	d.counts.blocking == 0
	d.counts.waived == 1
}

# A waived finding is an accepted risk with an owner and a date. It must remain
# visible in the signed verdict, never silently dropped.
test_waived_finding_stays_visible_with_its_owner if {
	d := pdp.decision with input as scan([crit]) with data.waivers as [good_waiver]
	some e in d.exceptions_applied
	e.cve == "CVE-2026-0001"
	e.owner == "@ryancraig"
	e.expires == "2026-12-01T00:00:00Z"
}

test_expired_waiver_does_not_suppress if {
	expired := object.union(good_waiver, {"expires": "2026-01-01T00:00:00Z"})
	d := pdp.decision with input as scan([crit]) with data.waivers as [expired]
	d.verdict == "FAIL"
	d.counts.blocking == 1
}

test_expired_waiver_is_reported_as_a_warning if {
	expired := object.union(good_waiver, {"expires": "2026-01-01T00:00:00Z"})
	d := pdp.repo_decision with input as clean_repo with data.waivers as [expired]
	some w in d.warnings
	w.code == "WAIVER_EXPIRED"
}

# A malformed waiver must fail closed into "still blocking", never open.
test_waiver_without_justification_suppresses_nothing if {
	bad := object.union(good_waiver, {"justification": "too short"})
	d := pdp.decision with input as scan([crit]) with data.waivers as [bad]
	d.verdict == "FAIL"
}

test_waiver_without_justification_denies_the_repo if {
	bad := object.union(good_waiver, {"justification": "too short"})
	d := pdp.repo_decision with input as clean_repo with data.waivers as [bad]
	not d.allow
	some v in d.violations
	v.code == "WAIVER_NO_JUSTIFICATION"
}

test_waiver_without_expiry_denies_the_repo if {
	bad := object.remove(good_waiver, {"expires"})
	d := pdp.repo_decision with input as clean_repo with data.waivers as [bad]
	not d.allow
	some v in d.violations
	v.code == "WAIVER_NO_EXPIRY"
}

test_waiver_for_a_different_cve_does_not_apply if {
	other := object.union(good_waiver, {"cve": "CVE-9999-9999"})
	d := pdp.decision with input as scan([crit]) with data.waivers as [other]
	d.verdict == "FAIL"
}

# --- scoping ---------------------------------------------------------------

test_waiver_scoped_to_this_template_applies if {
	scoped := object.union(good_waiver, {"templates": ["python", "java"]})
	d := pdp.decision with input as scan([crit]) with data.waivers as [scoped]
	d.verdict == "PASS"
}

test_waiver_scoped_to_another_template_does_not_apply if {
	scoped := object.union(good_waiver, {"templates": ["java"]})
	d := pdp.decision with input as scan([crit]) with data.waivers as [scoped]
	d.verdict == "FAIL"
}

test_empty_template_list_means_all_templates if {
	scoped := object.union(good_waiver, {"templates": []})
	d := pdp.decision with input as scan([crit]) with data.waivers as [scoped]
	d.verdict == "PASS"
}

test_absent_register_waives_nothing if {
	d := pdp.decision with input as scan([crit])
	d.verdict == "FAIL"
}

# --- batched waivers -------------------------------------------------------

batch_waiver := {
	"id": "EXC-2026-0002",
	"cves": ["CVE-2026-0001", "CVE-2026-0002"],
	"expires": "2026-12-01T00:00:00Z",
	"owner": "@ryancraig",
	"justification": "Distro-packaged binary; only the packager can rebuild it against a patched module.",
}

test_batch_waiver_covers_every_listed_cve if {
	d := pdp.decision with input as scan([crit, high_fixed]) with data.waivers as [batch_waiver]
	d.verdict == "PASS"
	d.counts.waived == 2
	d.counts.blocking == 0
}

test_batch_waiver_does_not_cover_an_unlisted_cve if {
	other := {"id": "CVE-2026-9999", "severity": "Critical", "package": "p", "fix_state": "fixed"}
	d := pdp.decision with input as scan([other]) with data.waivers as [batch_waiver]
	d.verdict == "FAIL"
	d.counts.blocking == 1
}

# An empty `cves` list falls back to the single `cve` field. Documented here
# because it is the surprising branch: `cves: []` reads like "waive nothing" but
# a sibling `cve` still applies. The count(cs) > 0 guard in waiver_cves is what
# makes this deliberate rather than accidental.
test_empty_cves_list_falls_back_to_the_single_cve_field if {
	empty := object.union(batch_waiver, {"cves": [], "cve": "CVE-2026-0001"})
	d := pdp.decision with input as scan([crit]) with data.waivers as [empty]
	d.verdict == "PASS"
	d.counts.waived == 1
}

test_batch_waiver_still_expires if {
	expired := object.union(batch_waiver, {"expires": "2026-01-01T00:00:00Z"})
	d := pdp.decision with input as scan([crit, high_fixed]) with data.waivers as [expired]
	d.verdict == "FAIL"
	d.counts.blocking == 2
}

test_batch_waiver_still_needs_a_justification if {
	bad := object.union(batch_waiver, {"justification": "too short"})
	d := pdp.decision with input as scan([crit]) with data.waivers as [bad]
	d.verdict == "FAIL"
}

# Two entries covering the same CVE is normal, not a mistake: a stdlib finding
# appears in every Go binary, so a git-lfs waiver and an fzf waiver both name it.
# Before matching_waivers existed this raised eval_conflict_error -- the policy
# did not fail closed, it failed to evaluate, which the gate reports as a crash
# rather than a verdict. Found by real scan data, not by the suite.
overlapping_a := {
	"id": "EXC-A",
	"cves": ["CVE-2026-0001"],
	"expires": "2026-12-01T00:00:00Z",
	"owner": "@ryancraig",
	"justification": "Distro-packaged binary A; only the packager can rebuild it.",
}

overlapping_b := {
	"id": "EXC-B",
	"cves": ["CVE-2026-0001"],
	"expires": "2026-12-01T00:00:00Z",
	"owner": "@ryancraig",
	"justification": "Distro-packaged binary B, which shares the same stdlib finding.",
}

test_overlapping_waivers_resolve_deterministically if {
	d := pdp.decision with input as scan([crit]) with data.waivers as [overlapping_a, overlapping_b]
	d.verdict == "PASS"
	d.counts.waived == 1
	count(d.exceptions_applied) == 1
}

# Order in the register must not change the outcome.
test_overlapping_waivers_are_order_independent if {
	forward := pdp.decision with input as scan([crit]) with data.waivers as [overlapping_a, overlapping_b]
	reverse := pdp.decision with input as scan([crit]) with data.waivers as [overlapping_b, overlapping_a]
	forward == reverse
}

# An expired entry must not shadow a valid one covering the same CVE.
test_expired_overlap_does_not_shadow_a_valid_waiver if {
	expired := object.union(overlapping_a, {"expires": "2026-01-01T00:00:00Z"})
	d := pdp.decision with input as scan([crit]) with data.waivers as [expired, overlapping_b]
	d.verdict == "PASS"
	d.counts.waived == 1
}

# ===========================================================================
# Waiver scoping
# ===========================================================================
#
# The register matched on CVE id alone, so an entry justified as "38 findings in
# /usr/bin/git-lfs" also waived the same stdlib CVE ids inside syft and grype --
# 14 real findings, in artifacts the justification never mentions, whose
# versions this org actually controls. Found by comparing what the register
# claimed against where the waived CVEs really lived.

crit_at(loc) := {
	"id": "CVE-2026-0001",
	"severity": "Critical",
	"package": "golang.org/x/crypto",
	"fix_state": "fixed",
	"location": loc,
}

scoped_waiver := {
	"id": "EXC-SCOPED",
	"cves": ["CVE-2026-0001"],
	"locations": ["/usr/bin/git-lfs"],
	"expires": "2026-12-01T00:00:00Z",
	"owner": "@ryancraig",
	"justification": "Distro-packaged binary; only the packager can rebuild it against a patched module.",
}

test_location_scoped_waiver_applies_at_that_location if {
	d := pdp.decision with input as scan([crit_at("/usr/bin/git-lfs")]) with data.waivers as [scoped_waiver]
	d.verdict == "PASS"
	d.counts.waived == 1
}

# The finding this fix exists for: same CVE, different binary, must still block.
test_location_scoped_waiver_does_not_leak_to_another_binary if {
	d := pdp.decision with input as scan([crit_at("/home/dev/.local/bin/syft")]) with data.waivers as [scoped_waiver]
	d.verdict == "FAIL"
	d.counts.blocking == 1
	d.counts.waived == 0
}

# Fail closed: evidence produced before `location` existed must not satisfy a
# location-scoped waiver just because the field is missing.
test_location_scoped_waiver_does_not_match_a_finding_without_a_location if {
	no_loc := object.remove(crit_at(""), {"location"})
	d := pdp.decision with input as scan([no_loc]) with data.waivers as [scoped_waiver]
	d.verdict == "FAIL"
	d.counts.blocking == 1
}

test_empty_location_is_treated_as_absent if {
	d := pdp.decision with input as scan([crit_at("")]) with data.waivers as [scoped_waiver]
	d.verdict == "FAIL"
}

# An unscoped waiver keeps applying everywhere, so scoping is opt-in.
test_unscoped_waiver_still_applies_regardless_of_location if {
	unscoped := object.remove(scoped_waiver, {"locations"})
	d := pdp.decision with input as scan([crit_at("/home/dev/.local/bin/syft")]) with data.waivers as [unscoped]
	d.verdict == "PASS"
}

# --- package scoping -------------------------------------------------------

pkg_waiver := object.union(object.remove(scoped_waiver, {"locations"}), {"packages": ["golang.org/x/crypto"]})

test_package_scoped_waiver_applies_to_that_package if {
	d := pdp.decision with input as scan([crit_at("/usr/bin/git-lfs")]) with data.waivers as [pkg_waiver]
	d.verdict == "PASS"
}

test_package_scoped_waiver_does_not_cover_another_package if {
	other := object.union(crit_at("/usr/bin/git-lfs"), {"package": "google.golang.org/grpc"})
	d := pdp.decision with input as scan([other]) with data.waivers as [pkg_waiver]
	d.verdict == "FAIL"
}

# Both dimensions must hold, not either.
test_both_scopes_must_match if {
	both := object.union(pkg_waiver, {"locations": ["/usr/bin/git-lfs"]})
	right_pkg_wrong_loc := object.union(crit_at("/home/dev/.local/bin/syft"), {"package": "golang.org/x/crypto"})
	d := pdp.decision with input as scan([right_pkg_wrong_loc]) with data.waivers as [both]
	d.verdict == "FAIL"
}

# ===========================================================================
# Remediation: vendored vs direct
# ===========================================================================
#
# A High with an available fix blocks because a fix implies action is possible.
# That is true when the finding names the artifact we install, and false when it
# names a dependency vendored inside one -- a stdlib finding in the grype binary
# is fixed by nobody but Anchore. These cases came from real scans.

high_typed(pkg, typ) := {
	"id": "CVE-2026-7000",
	"severity": "High",
	"package": pkg,
	"fix_state": "fixed",
	"type": typ,
	"location": "/somewhere",
}

crit_typed(typ) := object.union(high_typed("stdlib", typ), {"id": "CVE-2026-7001", "severity": "Critical"})

# --- direct: still blocks ---------------------------------------------------

test_high_in_an_rpm_still_blocks if {
	d := pdp.decision with input as scan([high_typed("sqlite-libs", "rpm")])
	d.verdict == "FAIL"
	d.counts.blocking == 1
}

test_high_in_a_python_distribution_still_blocks if {
	d := pdp.decision with input as scan([high_typed("ansible-core", "python")])
	d.verdict == "FAIL"
}

test_high_in_an_installed_binary_still_blocks if {
	d := pdp.decision with input as scan([high_typed("python", "binary")])
	d.verdict == "FAIL"
}

# --- vendored: recorded, not blocking ---------------------------------------

test_high_in_a_vendored_go_module_is_recorded if {
	d := pdp.decision with input as scan([high_typed("stdlib", "go-module")])
	d.verdict == "PASS"
	d.counts.blocking == 0
	d.counts.recorded == 1
}

test_high_in_a_vendored_npm_dependency_is_recorded if {
	d := pdp.decision with input as scan([high_typed("minimatch", "npm")])
	d.verdict == "PASS"
	d.counts.recorded == 1
}

test_high_in_a_vendored_dotnet_dependency_is_recorded if {
	d := pdp.decision with input as scan([high_typed("System.Security.Cryptography.Xml", "dotnet")])
	d.verdict == "PASS"
}

# --- the carve-out must be earned, not granted by absence -------------------

test_high_with_an_unknown_type_still_blocks if {
	d := pdp.decision with input as scan([high_typed("mystery", "unknown")])
	d.verdict == "FAIL"
	d.counts.blocking == 1
}

test_high_with_no_type_field_still_blocks if {
	no_type := object.remove(high_typed("mystery", "rpm"), {"type"})
	d := pdp.decision with input as scan([no_type])
	d.verdict == "FAIL"
	d.counts.blocking == 1
}

# --- Critical is unaffected anywhere ----------------------------------------

test_critical_in_a_vendored_module_still_blocks if {
	d := pdp.decision with input as scan([crit_typed("go-module")])
	d.verdict == "FAIL"
	d.counts.blocking == 1
}

test_critical_in_a_vendored_npm_dependency_still_blocks if {
	d := pdp.decision with input as scan([crit_typed("npm")])
	d.verdict == "FAIL"
}

# A vendored Critical is still waivable -- that is the decision it deserves.
test_vendored_critical_can_be_waived_explicitly if {
	w := {
		"id": "EXC-V",
		"cves": ["CVE-2026-7001"],
		"expires": "2026-12-01T00:00:00Z",
		"owner": "@ryancraig",
		"justification": "Vendored in a binary we cannot rebuild; accepted and dated deliberately.",
	}
	d := pdp.decision with input as scan([crit_typed("go-module")]) with data.waivers as [w]
	d.verdict == "PASS"
	d.counts.waived == 1
}

# An unfixable High was already recorded; being vendored must not change that.
test_vendored_high_without_a_fix_is_still_recorded_once if {
	nofix := object.union(high_typed("stdlib", "go-module"), {"fix_state": "not-fixed"})
	d := pdp.decision with input as scan([nofix])
	d.verdict == "PASS"
	d.counts.recorded == 1
}
