package tdt.pdp_test

import data.tdt.pdp

# The gate reads violation_security_threshold as a JSON array. If the rule is
# ever written as `violation_security_threshold[msg] if { ... }` it silently
# becomes a partial object -- `opa check` still passes -- and a clean scan
# returns `{}` rather than `[]`. is_array is what catches that.

clean := {"template_id": "python", "cve_summary": {"critical": 0, "high": 0, "medium": 9, "low": 4}}

test_clean_scan_yields_an_empty_array if {
    v := pdp.violation_security_threshold with input as clean
    count(v) == 0
    json.marshal(v) == "[]"
}

test_clean_scan_is_allowed if {
    pdp.allow with input as clean
}

test_critical_blocks if {
    v := pdp.violation_security_threshold with input as
        {"template_id": "java", "cve_summary": {"critical": 2, "high": 0, "medium": 0, "low": 0}}
    v == {"Template 'java' has 2 critical CVEs"}
    not pdp.allow with input as
        {"template_id": "java", "cve_summary": {"critical": 2, "high": 0, "medium": 0, "low": 0}}
}

test_high_blocks if {
    v := pdp.violation_security_threshold with input as
        {"template_id": "go-cue", "cve_summary": {"critical": 0, "high": 1, "medium": 0, "low": 0}}
    v == {"Template 'go-cue' has 1 high CVEs"}
}

test_critical_and_high_both_reported if {
    v := pdp.violation_security_threshold with input as
        {"template_id": "python", "cve_summary": {"critical": 3, "high": 5, "medium": 0, "low": 0}}
    count(v) == 2
}

# Medium and Low are recorded in the evidence but do not gate a release (ADR-004).
test_medium_and_low_do_not_block if {
    pdp.allow with input as
        {"template_id": "ansible-cue", "cve_summary": {"critical": 0, "high": 0, "medium": 40, "low": 100}}
}
