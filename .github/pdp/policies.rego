package tdt.pdp

default allow := false

allow if {
    count(violation_security_threshold) == 0
}

violation_security_threshold[msg] if {
    input.cve_summary.critical > 0
    msg := sprintf("Template '%s' has %d critical CVEs", [input.template_id, input.cve_summary.critical])
}

violation_security_threshold[msg] if {
    input.cve_summary.high > 0
    msg := sprintf("Template '%s' has %d high CVEs", [input.template_id, input.cve_summary.high])
}
