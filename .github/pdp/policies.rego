package tdt.pdp

default allow := false

allow if {
    count(violation_security_threshold) == 0
}

# `contains msg if` -- NOT `[msg] if`. Under Rego v1 the bracket form is still
# accepted by `opa check`, but it defines a partial OBJECT, so a clean scan
# evaluates to `{}` instead of `[]` and the release gate rejected every build.
# See ADR-004 and policies_test.rego.
violation_security_threshold contains msg if {
    input.cve_summary.critical > 0
    msg := sprintf("Template '%s' has %d critical CVEs", [input.template_id, input.cve_summary.critical])
}

violation_security_threshold contains msg if {
    input.cve_summary.high > 0
    msg := sprintf("Template '%s' has %d high CVEs", [input.template_id, input.cve_summary.high])
}
