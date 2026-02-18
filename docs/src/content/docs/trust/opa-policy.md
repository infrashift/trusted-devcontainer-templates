---
title: OPA Policy Gate
description: How OPA Rego policies enforce security thresholds in the release pipeline.
---

The release pipeline uses [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) to enforce CVE thresholds before templates are published. If a template's CVE scan exceeds the configured limits, the pipeline fails and the template is not published.

## Policy Location

The Rego policy lives at `.github/pdp/policies.rego` in the repository.

## How It Works

1. **Grype scans** the built devcontainer image and produces a JSON CVE report
2. **jq extracts** CVE counts by severity (critical, high, medium, low)
3. **OPA evaluates** the counts against the policy's threshold rules
4. If any `violation_security_threshold` rules fire, the pipeline **fails**

### Pipeline Integration

```bash
# Extract CVE counts from Grype report
critical=$(jq '[.matches[] | select(.vulnerability.severity == "Critical")] | length' cve-report.json)
high=$(jq '[.matches[] | select(.vulnerability.severity == "High")] | length' cve-report.json)

# Build OPA input
cat > opa-input.json <<EOF
{
  "template_id": "python",
  "cve_summary": {
    "critical": ${critical},
    "high": ${high},
    "medium": ${medium},
    "low": ${low}
  }
}
EOF

# Evaluate policy
violations=$(opa eval \
  -d .github/pdp/policies.rego \
  -i opa-input.json \
  "data.tdt.pdp.violation_security_threshold" \
  --format raw)

if [ "$violations" != "[]" ] && [ -n "$violations" ]; then
  echo "Policy violations: ${violations}"
  exit 1
fi
```

## Policy Behavior

The policy evaluates the `cve_summary` object from the input. The `violation_security_threshold` rule set produces an array of violation messages. An empty array (`[]`) means the template passes.

Typical threshold behavior:
- **Critical CVEs** — any critical vulnerability causes a violation
- **High CVEs** — configurable threshold (e.g., more than 0 causes a violation)

## Evidence Chain

The OPA evaluation is part of the scan job, which also produces signed evidence:

1. SBOM (signed) — what's in the image
2. CVE report (signed) — what vulnerabilities exist
3. OPA input — the summary fed to policy evaluation
4. SLSA provenance (signed) — build context and source reference

All evidence is uploaded as a GitHub Actions artifact and attached to the release.
