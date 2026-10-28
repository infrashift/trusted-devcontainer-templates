# operations

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Build and test one template locally](build-and-test-one-template-locally--01a183491958.md) - Run make test-template TEMPLATE=<name> to build one template with the devcontainer CLI and run its smoke test from test/<name>/test.sh.
* [Cut a release of the templates](cut-a-release-of-the-templates--01a183491a78.md) - Set one version in every template, merge, and push a matching vX.Y.Z tag; approve the Review-Actor and Release-Actor deployments.
* [Operations overview](operations-overview--01a1833f2f85.md) - Runbooks: the steps to set up, test, re-pin, release and verify the templates.
* [Re-pin the trusted features and the base image](re-pin-the-trusted-features-and-the-base-image--01a183491a09.md) - Run make pin-features to pin each feature to its newest digest; edit the FROM digest in shared/Containerfile and sync it to move the base image.
* [Release the repo-local features](release-the-repo-local-features--01a183491acc.md) - Bump the feature version and merge to main; release-features.yml stages, reviews and promotes it; then pin the new digest in a second pull request.
* [Run the static checks and the repo gate locally](run-the-static-checks-and-the-repo-gate-locally--01a1834919aa.md) - Run make check before a push. It runs the static checks of the repo-gate CI job, including the PDP, without container builds.
* [Set up the GitHub environments and signing keys](set-up-the-github-environments-and-signing-keys--01a183491902.md) - Make the three cosign keypairs, the three GitHub environments, their secrets, reviewers and ref policies, and the main ruleset, as SETUP-ENVIRONMENTS.md tells.
* [Verify a published template](verify-a-published-template--01a183491b30.md) - Verify a template signature and its attestations with release.pub, the evidence files with build.pub, and the verdict with review.pub.

