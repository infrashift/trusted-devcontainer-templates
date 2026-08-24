# Setup runbook

Everything here must be done once, by a human, before the pipeline can run.
Work top to bottom; later steps depend on earlier ones.

Until steps 1–4 are complete, `release.yml` fails closed by design: the review
job cannot verify build evidence without `build.pub`, and the publish job
refuses to push anything without a review verdict signed by `review.pub`.

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

## 4. Required Reviewers on Review-Actor and Release-Actor

**This is the human gate.** The review key is physically unreachable until a
named person approves the deployment, which is what makes a Review-Actor
signature proof that a human approved — rather than a separate "human signs
this" step that everyone forgets to run.

In the GitHub UI, for each of `Review-Actor` and `Release-Actor`:
Settings → Environments → *(environment)* → **Required reviewers** → add
`@infrashift/security-admins`, and tick **Prevent self-review**.

Without Prevent self-review, the person who opened the PR can approve their own
release and the second actor buys you nothing.

---

## 5. Teams

CODEOWNERS references three teams. If any does not exist, CODEOWNERS matches
nothing for those paths and "require review from Code Owners" becomes a silent
no-op.

```bash
for t in platform-engineers security-admins devops-leads; do
  gh api "orgs/${ORG}/teams/${t}" --jq .slug || echo "MISSING: $t"
done
```

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

Also enable: require a PR before merging, require review from Code Owners,
dismiss stale approvals, and require branches to be up to date.

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
3. `Review Attestations` waits on a Required Reviewer.
4. After approval, `review/cve-policy` resolves and a verdict table is posted
   as a PR comment.
