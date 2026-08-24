# Setup runbook

Everything here must be done once, by a human, before the pipeline can run.
Work top to bottom; later steps depend on earlier ones.

`release.yml` fails closed by design until the keys exist: the review job cannot
verify build evidence without `build.pub`, and the publish job refuses to push
anything without a review verdict signed by `review.pub`.

**Current state** (verified 2026-08-23):

| Step | State |
|---|---|
| 1. Three keypairs generated | done — three distinct keys |
| 2. Public halves committed | done — `8d8d7d3` |
| 3. Environments + secrets | done — all three hold their own key and password |
| 4. Environment reviewers | **not configured** — `protection_rules` is empty on all three |
| 5. Teams | none, deliberately — see that step |
| 6. Branch protection | **not configured** — no rulesets |

So steps 1–3 are history, kept here because they are what you would repeat on a
key rotation. Steps 4 and 6 are what is actually outstanding.

```bash
export ORG=infrashift
export REPO=trusted-devcontainer-templates
export SLUG="${ORG}/${REPO}"
```

---

## 0. Preconditions

```bash
gh auth status          # needs admin:org, repo, write:packages
cosign version          # v2.6.1, matching tools.lock
opa version             # v1.19.1
jq --version
```

The cosign version matters more than it looks. **cosign v3 defaults to
`--new-bundle-format=true`** and writes attestations as OCI referrers, while v2
writes the legacy `sha256-<digest>.att` layout. The sibling repos
(`trusted-service-containers`, `trusted-base-images`) read the v2 layout.
`tools.lock` pins v2.6.1 for that reason. **Migrate the org together, never one
repo at a time.**

---

## 1. Generate three cosign keypairs

**In `/dev/shm`, never in a git working tree.** A sibling repo has three live
private keys sitting in its checkout; treat those as compromised and rotate.

This repo currently has an encrypted `cosign.key` in the working tree. It is
untracked and has never been committed — verified against full history — and
`**/*.key` in `.gitignore` plus `.gitleaks.toml` keep it that way. Move it out
of the tree anyway once the three keypairs below exist.

```bash
WORK=$(mktemp -d -p /dev/shm keygen.XXXXXX)
cd "$WORK"
for actor in build review release; do
  COSIGN_PASSWORD="$(openssl rand -base64 48)"
  export COSIGN_PASSWORD
  cosign generate-key-pair
  mv cosign.key "${actor}.key"
  mv cosign.pub "${actor}.pub"
  printf '%s' "$COSIGN_PASSWORD" > "${actor}.password"
  unset COSIGN_PASSWORD
done
ls -l
```

> `cosign generate-key-pair` produces **ECDSA P-256, not ED25519**. Say ECDSA
> P-256 in any documentation. An inaccurate cryptographic claim in a
> supply-chain repo is worse than a boring accurate one.

---

## 2. Commit the three public halves

These are not secrets. The pipeline verifies against them, and so can anyone
downstream.

```bash
cd "$OLDPWD"          # back to the repo
cp "$WORK"/build.pub   .github/pdp/public-keys/build.pub
cp "$WORK"/review.pub  .github/pdp/public-keys/review.pub
cp "$WORK"/release.pub .github/pdp/public-keys/release.pub
git add .github/pdp/public-keys/
git commit -m "Add build, review and release public keys"
```

`scripts/review-template.sh` reads `build.pub`; `scripts/verify-verdicts.sh`
reads `review.pub`. Both fail with a pointer to this file if the key is absent.

---

## 3. Three environments, each with two secrets

```bash
gh api -X PUT "repos/${SLUG}/environments/Build-Actor"
gh api -X PUT "repos/${SLUG}/environments/Review-Actor"
gh api -X PUT "repos/${SLUG}/environments/Release-Actor"

cd "$WORK"
for actor in build review release; do
  case $actor in
    build)   ENVNAME=Build-Actor   ;;
    review)  ENVNAME=Review-Actor  ;;
    release) ENVNAME=Release-Actor ;;
  esac
  gh secret set COSIGN_PRIVATE_KEY --repo "$SLUG" --env "$ENVNAME" < "${actor}.key"
  gh secret set COSIGN_PASSWORD    --repo "$SLUG" --env "$ENVNAME" < "${actor}.password"
done
```

Then destroy the working directory:

```bash
cd / && rm -rf "$WORK"
```

---

## 4. Environment reviewers — what they do and do not buy

`infrashift` currently has **one member**. That changes what this step means, so
read it before copying the reference repo's wording.

**What key separation buys you, regardless of headcount.** Each environment
holds a *different* private key. The build job can sign evidence but cannot
publish. The release job verifies a review-key signature it has no way to
produce itself. So a compromised action, a malicious dependency, or a bad script
running in the build job **cannot push a signed release** — it does not have the
key. That is the real protection here, and it is fully in force with one
maintainer. It is defence against supply-chain compromise, which is the actual
threat to a solo project.

**What Required Reviewers does not buy you at one member.** It is not separation
of duties: there is no second person, so approval is you approving yourself. It
is a deliberate stop-and-look before a release ships — a speed bump, and a
useful one, but call it that rather than "dual control".

**Do NOT tick "Prevent self-review" while the org has one member.** It would
deadlock every release: the only person who could approve is excluded, and no
one else exists.

```bash
# Add yourself as the reviewer on the two environments that publish or grade.
# This pauses the run and makes you click through before anything ships.
for ENVNAME in Review-Actor Release-Actor; do
  gh api -X PUT "repos/${SLUG}/environments/${ENVNAME}" \
    -F 'reviewers[][type]=User' \
    -F "reviewers[][id]=$(gh api users/ryancraig --jq .id)"
done
```

Verify it took — an empty `rules` array means nothing is enforced:

```bash
for e in Build-Actor Review-Actor Release-Actor; do
  printf '%-14s ' "$e"
  gh api "repos/${SLUG}/environments/$e" --jq '[.protection_rules[]?.type]'
done
```

> Both repos here are **public**, which is what makes environment protection
> rules available on a Free org at all. On a Free plan, deployment protection
> rules and branch protection are public-repo features; a private repo needs
> Team or Enterprise. Worth knowing before making either repo private.

**When a second maintainer joins**, this is the step that changes: add them as a
reviewer, turn on *Prevent self-review*, and the gate becomes what the reference
describes. Do that in the same change as enabling Code Owners review (step 5).

---

## 5. Teams — not yet, and not silently

The org has **no teams**, and CODEOWNERS deliberately does not reference any:

```bash
gh api orgs/infrashift/teams --jq 'length'    # 0
```

Three single-member teams would be structure without the property it is meant to
express. Worse, **"Require review from Code Owners" must stay OFF while the org
has one member** — GitHub does not let you approve your own pull request, so
turning it on would block every PR you open and force an admin bypass on every
merge. A protection everyone routinely bypasses is worse than none, because it
reads as enforced.

`.github/CODEOWNERS` therefore lists `@ryancraig` and functions as reviewer
auto-assignment and as a map of which changes are trust decisions. It gates
nothing today, and says so at the top of the file.

**When a second maintainer joins**, do all of this in one change:

```bash
gh auth refresh -s admin:org,write:org        # current token has read:org only

for t in platform-engineers security-admins devops-leads; do
  gh api -X POST "orgs/${ORG}/teams" -f name="$t" -f privacy=closed
  gh api -X PUT "orgs/${ORG}/teams/${t}/repos/${ORG}/${REPO}" -f permission=push
done
```

Then swap the owners in `.github/CODEOWNERS` from `@ryancraig` to the teams,
enable "Require review from Code Owners", and tick *Prevent self-review* on the
environments from step 4. Doing these together is what keeps the file honest: a
CODEOWNERS naming teams that do not exist matches nothing, and "require review
from Code Owners" silently becomes a no-op.

---

## 6. Branch protection on main

Required status checks — the context strings must match **exactly** what the
workflows publish. `scripts/lint-workflows.sh` asserts the two places in the
repo agree; this is the third place, and only a human can set it.

| Context | Published by |
|---|---|
| `repo-gate` | `pr-gate.yml` |
| `build/gate` | `build.yml` |
| `review/cve-policy` | seeded by `pr-gate.yml`, resolved by `review.yml` |

**Never make individual matrix legs required checks.** Job names change with the
matrix, and a required context that stops reporting blocks every PR forever.
`build/gate` is the aggregate that exists for this reason.

Also enable: require a PR before merging, dismiss stale approvals, and require
branches to be up to date.

**Do not enable "require review from Code Owners" yet** — see step 5. With one
member it blocks every PR you open, because you cannot approve your own.

Required status checks *are* worth turning on now. They gate on CI results
rather than on a second human, so they work perfectly well solo — and they are
the checks that actually catch the failure modes this pipeline was built for.

> The retired `Sync Containerfile Check` workflow may still be configured as a
> required context. Remove it — the check now runs inside `repo-gate` as
> `make check-sync`, and a required context nothing publishes blocks every PR.

---

## 7. Verify

```bash
make check          # repo gate, policy tests, workflow lint -- all local
```

Then open a throwaway PR touching `src/python/` and confirm:

1. `repo-gate` and `build/gate` report.
2. `review/cve-policy` appears as **pending**, seeded by `pr-gate.yml`.
3. `Review Attestations` pauses for the environment reviewer from step 4.
4. After you approve, `review/cve-policy` resolves and a verdict table is posted
   as a PR comment.

Then check the thing most likely to be quietly wrong — that the protection you
think you configured is actually recorded:

```bash
for e in Build-Actor Review-Actor Release-Actor; do
  printf '%-14s ' "$e"
  gh api "repos/${SLUG}/environments/$e" --jq '[.protection_rules[]?.type]'
done
gh api "repos/${SLUG}/rulesets" --jq '.[].name'
```

An empty array here means the environment exists and holds a key but enforces
nothing. That is the state this repo was in before step 4 — and it is the state
the reference repo `trusted-service-containers` is in today, despite its
comments describing a human gate. Configuration that only exists in a comment
is the failure this whole pipeline is meant to make visible.
