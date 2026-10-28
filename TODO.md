# TODO — moved to the wiki

Issues now live in the OKF wiki, in [`.okfw/issues/`](.okfw/issues/index.md). Each issue is one concept, with the tag `open` or `resolved`.

The old numbers stay in each concept as `x.todo`, so a reference such as "#21" in a commit message still finds its issue.

```sh
okfw search --kind issue --tag open        # open issues
okfw search --kind issue --tag resolved    # resolved issues
okfw search "rekor" --kind issue           # find one issue by its words
```

To record or close an issue, follow the issue workflow: `okfw search "issue workflow"`.

The full text of the old file is in git history: `git show 0ce2c16:TODO.md`.
