#!/usr/bin/env python3
"""Report the tools whose installed version is behind the newest upstream release.

The CVE gate records a High finding vendored inside a tool instead of blocking
it, on the theory that the fix is a re-pin once upstream ships one. That theory
holds only if someone notices the release. Nothing did: syft sat at 1.42 against
1.51, grype at 0.108 against 0.117 and cue at 0.15.4 against 0.17.1 until a CVE
report happened to show each gap.

What is installed is read from the template SBOMs -- the build evidence, or the
<template>-sbom.json files attached to a release -- rather than from the
declarations that produced it. Versions are declared in four places (the trusted
features repo, the repo-local features, tools.lock and the Fedora base image),
and the SBOM is the one record of what actually landed in all of them.

A newer release counts only once it is THRESHOLD days old: a release hours old
must not raise an alarm, and its follow-up fixes deserve a few days to land.

This is a report, never a gate. It exits 0 whatever it finds, and a source that
cannot be reached makes a tool "unknown" rather than failing the run.

Python and its standard library only, unlike the bash in the rest of scripts/:
the check talks to seven JSON APIs and compares dates and versions, which in
bash would be the kind of code nobody can review.

Usage:
  check-upstream-currency.py --sbom-dir DIR [--tools-lock tools.lock]
      [--registry .github/upstream-tools.json] [--threshold-days N]
      [--now 2026-10-28T00:00:00Z] [--markdown OUT.md] [--json OUT.json]
  check-upstream-currency.py --self-test
"""
import argparse
import datetime as dt
import glob
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

UA = "trusted-devcontainer-templates/check-upstream-currency"
PRERELEASE = re.compile(r"(rc|alpha|beta|pre|dev|preview|canary|next|snapshot)\d*|\d(a|b)\d|-ea\b", re.I)


# --- versions ---------------------------------------------------------------

def clean(v):
    """Strip the prefixes upstreams put on a version: v1.2, go1.27, jq-1.8."""
    return re.sub(r"^(v|go|jq-)", "", str(v).strip())


def _segments(s):
    return tuple((1, int(x)) if x.isdigit() else (0, x.lower())
                 for x in re.findall(r"\d+|[A-Za-z]+", s))


def vkey(v):
    """Sort key in the manner of rpmvercmp, as (version, release).

    Runs of digits compare as numbers, runs of letters as strings, and a digit
    run outranks a letter run. Letters matter: tmux 3.7c is newer than 3.7b.
    The part after the first "-" (an RPM release, or a suffix such as -LTS)
    breaks ties only. Compared as one sequence, 3.7-3 ranked above 3.7c-2,
    because the release's 3 met the version's c. The .fc43 suffix of an RPM
    release is the same on both sides of a comparison, so it cancels out."""
    version, _, release = clean(v).partition("-")
    return (_segments(version), _segments(release))


def is_prerelease(v):
    return bool(PRERELEASE.search(clean(v)))


def same_line(installed, candidate, line):
    if not line:
        return True
    n = 1 if line == "major" else 2
    return vkey(installed)[0][:n] == vkey(candidate)[0][:n]


def parse_time(s):
    if not s:
        return None
    s = str(s).strip().replace("Z", "+00:00")
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}", s):
        s += "T00:00:00+00:00"
    s = re.sub(r"^(\d{4}-\d{2}-\d{2}) ", r"\1T", s)
    t = dt.datetime.fromisoformat(s)
    return t if t.tzinfo else t.replace(tzinfo=dt.timezone.utc)


def assess(installed, releases, line, now, threshold):
    """Classify one installed version against (version, released_at) pairs.

    behind:  a newer release in the line has been out for >= threshold days
    pending: newer releases exist, but every one is younger than the threshold
    current: nothing newer in the line
    """
    newer = sorted(
        ((v, t) for v, t in releases
         if not is_prerelease(v) and same_line(installed, v, line) and vkey(v) > vkey(installed)),
        key=lambda r: vkey(r[0]), reverse=True)
    if not newer:
        return {"status": "current"}
    cutoff = now - dt.timedelta(days=threshold)
    eligible = [(v, t) for v, t in newer if t is not None and t <= cutoff]
    if eligible:
        v, t = eligible[0]
        return {"status": "behind", "newest": clean(v), "released": t.date().isoformat(),
                "days": (now - t).days, "newest_any": clean(newer[0][0])}
    v, t = newer[0]
    return {"status": "pending", "newest": clean(v), "released": t.date().isoformat() if t else None}


# --- upstream sources ---------------------------------------------------------

_cache = {}


def get_json(url):
    if url not in _cache:
        req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=30) as r:
            _cache[url] = json.load(r)
    return _cache[url]


def get_text(url):
    if url not in _cache:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=30) as r:
            _cache[url] = r.read().decode()
    return _cache[url]


def goproxy_escape(module):
    return re.sub(r"[A-Z]", lambda m: "!" + m.group(0).lower(), module)


def releases_goproxy(src, installed):
    base = f"https://proxy.golang.org/{goproxy_escape(src['module'])}/@v/"
    versions = [v for v in get_text(base + "list").split() if v and not is_prerelease(v)]
    # Only the versions that could matter get a second request for their date.
    out = []
    for v in sorted(versions, key=vkey, reverse=True):
        if vkey(v) <= vkey(installed):
            break
        out.append((v, parse_time(get_json(base + f"{v}.info").get("Time"))))
    return out


def releases_pypi(src, installed):
    d = get_json(f"https://pypi.org/pypi/{src['package']}/json")
    out = []
    for v, files in d.get("releases", {}).items():
        live = [f for f in files if not f.get("yanked")]
        if live:
            out.append((v, min(parse_time(f["upload_time_iso_8601"]) for f in live)))
    return out


def releases_npm(src, installed):
    d = get_json(f"https://registry.npmjs.org/{urllib.parse.quote(src['package'], safe='@')}")
    times = d.get("time", {})
    return [(v, parse_time(times.get(v))) for v in d.get("versions", {}) if "-" not in v]


def releases_fedora(src, installed):
    q = urllib.parse.urlencode({"packages": src["package"], "releases": src["release"],
                                "status": "stable", "rows_per_page": 50})
    d = get_json(f"https://bodhi.fedoraproject.org/updates/?{q}")
    out, prefix = [], src["package"] + "-"
    for u in d.get("updates", []):
        for b in u.get("builds", []):
            nvr = b["nvr"]
            # nvr is name-version-release; the name itself may contain dashes.
            if nvr.startswith(prefix) and re.fullmatch(r"[^-]+-[^-]+", nvr[len(prefix):]):
                out.append((nvr[len(prefix):], parse_time(u.get("date_stable") or u.get("date_pushed"))))
    return out


def releases_nodejs(src, installed):
    return [(r["version"], parse_time(r["date"])) for r in get_json("https://nodejs.org/dist/index.json")]


def releases_dotnet(src, installed):
    channel = ".".join(re.findall(r"\d+", clean(installed))[:2])
    d = get_json(f"https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/{channel}/releases.json")
    return [(r["release-version"], parse_time(r["release-date"])) for r in d.get("releases", [])]


def releases_python(src, installed):
    rows = get_json("https://www.python.org/api/v2/downloads/release/?is_published=true")
    return [(r["name"].removeprefix("Python "), parse_time(r["release_date"]))
            for r in rows if not r.get("pre_release") and r["name"].startswith("Python 3.")]


def releases_endoflife(src, installed):
    # One row per release line, carrying only its newest release: enough to see
    # that a line moved on, though not which intermediate releases are old enough.
    rows = get_json(f"https://endoflife.date/api/{src['product']}.json")
    return [(str(r["latest"]), parse_time(r.get("latestReleaseDate"))) for r in rows if r.get("latest")]


SOURCES = {"goproxy": releases_goproxy, "pypi": releases_pypi, "npm": releases_npm,
           "fedora": releases_fedora, "nodejs": releases_nodejs, "dotnet": releases_dotnet, "python": releases_python,
           "endoflife": releases_endoflife}


def describe(src):
    return {"goproxy": lambda s: f"Go proxy `{s['module']}`", "pypi": lambda s: f"PyPI `{s['package']}`",
            "npm": lambda s: f"npm `{s['package']}`", "fedora": lambda s: f"Fedora {s['release']} `{s['package']}`",
            "nodejs": lambda s: "nodejs.org", "python": lambda s: "python.org", "dotnet": lambda s: "Microsoft release metadata",
            "endoflife": lambda s: f"endoflife.date `{s['product']}`"}[src["kind"]](src)


# --- installed versions -------------------------------------------------------

def template_of(path):
    base = os.path.basename(path)
    if base.endswith("-sbom.json"):
        return base[: -len("-sbom.json")]          # release asset: <template>-sbom.json
    return os.path.basename(os.path.dirname(path))  # build evidence: <template>/sbom.json


def installed_from_sboms(sbom_dir, tools):
    """{tool name: {version: set(templates)}} for every registry tool found."""
    found = {t["name"]: {} for t in tools}
    files = sorted(set(glob.glob(os.path.join(sbom_dir, "**", "*sbom.json"), recursive=True)))
    for f in files:
        tpl = template_of(f)
        for p in json.load(open(f)).get("packages", []):
            purl = next((r["referenceLocator"] for r in p.get("externalRefs", [])
                         if r.get("referenceType") == "purl"), "")
            for t in tools:
                m = t["match"]
                if purl.startswith(m["purl"]) and m.get("path", "") in p.get("sourceInfo", ""):
                    v = p.get("versionInfo") or ""
                    if v and v != "UNKNOWN":
                        found[t["name"]].setdefault(v, set()).add(tpl)
    return found, files


def installed_from_lock(path):
    out = {}
    for line in open(path):
        m = re.match(r"^([A-Z_]+)=(\S+)", line)
        if m:
            out[m.group(1)] = m.group(2)
    return out


# --- report -------------------------------------------------------------------

def run(args):
    reg = json.load(open(args.registry))
    threshold = args.threshold_days if args.threshold_days is not None else reg.get("threshold_days", 7)
    now = parse_time(args.now) if args.now else dt.datetime.now(dt.timezone.utc)

    checks = []  # (name, installed, where, source, line)
    found, files = installed_from_sboms(args.sbom_dir, reg["tools"]) if args.sbom_dir else ({}, [])
    for t in reg["tools"]:
        for v, tpls in sorted(found.get(t["name"], {}).items(), key=lambda kv: vkey(kv[0])):
            where = "all templates" if files and len(tpls) == len({template_of(f) for f in files}) \
                else ", ".join(f"`{x}`" for x in sorted(tpls))
            checks.append((t["name"], v, where, t["source"], t.get("line")))
    if args.tools_lock:
        lock = installed_from_lock(args.tools_lock)
        for var, t in reg.get("tools_lock", {}).items():
            if var in lock:
                checks.append((t["name"], lock[var], "`tools.lock`", t["source"], t.get("line")))

    rows = []
    for name, installed, where, src, line in checks:
        row = {"tool": name, "installed": clean(installed), "where": where, "source": describe(src)}
        try:
            row.update(assess(installed, SOURCES[src["kind"]](src, installed), line, now, threshold))
        except Exception as e:  # one unreachable or malformed source must not end the report
            row.update(status="unknown", error=f"{type(e).__name__}: {e}"[:160])
        rows.append(row)

    by = {s: [r for r in rows if r["status"] == s] for s in ("behind", "pending", "current", "unknown")}
    md = ["### Tools behind upstream", "",
          f"_Installed versions from {len(files)} SBOM(s){' and `tools.lock`' if args.tools_lock else ''}, "
          f"against upstream releases at least {threshold} days old, checked {now.date().isoformat()}._", ""]
    if by["behind"]:
        md += ["| Tool | Installed | Newest upstream | Released | Where |", "|---|---|---|---|---|"]
        md += [f"| {r['tool']} | {r['installed']} | **{r['newest']}** | {r['released']} ({r['days']} days) | {r['where']} |"
               for r in sorted(by["behind"], key=lambda r: -r["days"])]
    else:
        md += ["Every checked tool is on the newest upstream release in its line."]
    md += ["", f"<details><summary>{len(by['current'])} current, {len(by['pending'])} with a release "
               f"younger than {threshold} days, {len(by['unknown'])} unknown</summary>", ""]
    md += [f"- {r['tool']} {r['installed']}: {r['newest']} released {r['released']}, not yet {threshold} days old"
           for r in by["pending"]]
    md += [f"- {r['tool']} {r['installed']}: unknown ({r['error']})" for r in by["unknown"]]
    md += [f"- {r['tool']} {r['installed']} ({r['source']})" for r in by["current"]]
    md += ["", "</details>", ""]
    text = "\n".join(md)

    if args.markdown:
        open(args.markdown, "w").write(text)
    else:
        print(text)
    if args.json:
        json.dump({"checked": now.isoformat(), "threshold_days": threshold, "rows": rows}, open(args.json, "w"), indent=1)
    if os.environ.get("GITHUB_ACTIONS") == "true":
        for r in by["behind"]:
            print(f"::warning title=Tool behind upstream::{r['tool']} {r['installed']} is behind "
                  f"{r['newest']} (released {r['released']}) in {r['where']}")
    print(f"{len(by['behind'])} behind, {len(by['pending'])} pending, {len(by['current'])} current, "
          f"{len(by['unknown'])} unknown", file=sys.stderr)
    return 0


# --- self-test ----------------------------------------------------------------

def check_registry(path):
    """Every entry must name a known source with the fields that source reads,
    so a typo fails the PR gate instead of becoming an "unknown" every week."""
    need = {"goproxy": ["module"], "pypi": ["package"], "npm": ["package"],
            "fedora": ["package", "release"], "nodejs": [], "dotnet": [], "python": [],
            "endoflife": ["product"]}
    reg = json.load(open(path))
    errors = []
    entries = [(t.get("name", "?"), t) for t in reg.get("tools", [])]
    entries += [(f"tools_lock.{k}", t) for k, t in reg.get("tools_lock", {}).items()]
    for name, t in entries:
        src = t.get("source", {})
        if src.get("kind") not in need:
            errors.append(f"{name}: unknown source kind {src.get('kind')!r}")
            continue
        errors += [f"{name}: source {src['kind']} needs {f!r}" for f in need[src["kind"]] if not src.get(f)]
        if t.get("line") not in (None, "major", "minor"):
            errors.append(f"{name}: line must be major or minor")
    for t in reg.get("tools", []):
        if not str(t.get("match", {}).get("purl", "")).startswith("pkg:"):
            errors.append(f"{t.get('name', '?')}: match.purl must be a package-URL prefix")
    return errors


def self_test(registry=None):
    now = parse_time("2026-10-28T00:00:00Z")
    d = lambda s: parse_time(s)
    rel = [("v0.121.0", d("2026-10-19")), ("v0.122.0", d("2026-10-26")), ("v0.123.0-rc1", d("2026-10-01"))]
    cases = [
        # (installed, releases, line, expected status, expected newest)
        ("v0.121.0", rel, None, "pending", "0.122.0"),            # newer, but only 2 days old
        ("v0.120.0", rel, None, "behind", "0.121.0"),             # the newest OLD-ENOUGH release
        ("v0.122.0", rel, None, "current", None),                 # a release candidate is not newer
        ("22.23.4", [("v22.23.4", d("2026-10-20")), ("v26.13.0", d("2026-09-01"))], "major", "current", None),
        ("22.20.0", [("v22.23.4", d("2026-10-20")), ("v26.13.0", d("2026-09-01"))], "major", "behind", "22.23.4"),
        ("3.7.1-6.fc43", [("3.7.1-6.fc43", d("2026-08-25")), ("3.8.1-1.fc43", d("2026-10-01"))], None, "behind", "3.8.1-1.fc43"),
        ("3.7c-2.fc43", [("3.7b-3.fc43", d("2026-07-12")), ("3.7c-2.fc43", d("2026-09-01"))], None, "current", None),  # letters count
        ("3.7c-2.fc43", [("3.7c-10.fc43", d("2026-09-01"))], None, "behind", "3.7c-10.fc43"),  # release 10 > 2
        ("3.7c-2.fc43", [("3.7-3.fc43", d("2026-07-10"))], None, "current", None),  # version before release
        ("21.0.13+9-LTS", [("21.0.13+9", d("2026-10-22"))], "major", "current", None),
        ("go1.27.1", [("1.27.3", d("2026-10-19")), ("1.28.0", d("2026-09-01"))], "minor", "behind", "1.27.3"),
        ("1.0.0", [("1.1.0", None)], None, "pending", "1.1.0"),   # an undated release never counts as old
        ("3.14.8", [("3.15.0a1", d("2026-01-01")), ("3.14.9", d("2026-09-01"))], None, "behind", "3.14.9"),  # PEP 440 alpha skipped
    ]
    bad = 0
    for installed, releases, line, want, newest in cases:
        got = assess(installed, releases, line, now, 7)
        if got["status"] != want or (newest and got.get("newest") != newest):
            print(f"FAIL {installed} {line}: want {want} {newest}, got {got}", file=sys.stderr)
            bad += 1
    assert template_of("assets/neovim-go-sbom.json") == "neovim-go"
    assert template_of("evidence-java/java/sbom.json") == "java"
    assert goproxy_escape("github.com/BurntSushi/toml") == "github.com/!burnt!sushi/toml"
    print(f"self-test: {len(cases) - bad}/{len(cases)} assessments passed", file=sys.stderr)
    if registry:
        errors = check_registry(registry)
        for e in errors:
            print(f"error: {registry}: {e}", file=sys.stderr)
        bad += len(errors)
        if not errors:
            print(f"self-test: {registry} is well formed", file=sys.stderr)
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--sbom-dir")
    ap.add_argument("--tools-lock")
    ap.add_argument("--registry", default=".github/upstream-tools.json")
    ap.add_argument("--threshold-days", type=int)
    ap.add_argument("--now", help="evaluate as of this instant (ISO 8601), for replay and tests")
    ap.add_argument("--markdown", help="write the report here instead of stdout")
    ap.add_argument("--json", help="also write the rows as JSON here")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()
    if args.self_test:
        return self_test(args.registry)
    if not (args.sbom_dir or args.tools_lock):
        ap.error("give --sbom-dir, --tools-lock, or both")
    return run(args)


if __name__ == "__main__":
    sys.exit(main())
