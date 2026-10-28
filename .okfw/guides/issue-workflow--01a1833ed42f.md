---
id: "01a1833e-d42f-79db-b7f0-77eef9aac31b"
title: "Issue workflow"
type: "guide"
tags:
  - "guide"
  - "issue-workflow"
created: "2026-10-28T11:01:35-05:00"
timestamp: "2026-10-28T11:01:35-05:00"
description: "How to record, find and close an issue in the wiki, with the body sections and the state tags."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:35-05:00"
status: "draft"
---

# Issue workflow

This concept tells you how to record, find and close an issue. An issue records one problem or one task.

## Find issues

* Open issues: `okfw search --kind issue --tag open`
* Closed issues: `okfw search --kind issue --tag resolved`
* Issues for one template: `okfw search --kind issue --tag open --tag go-cue`

## Record an issue

1. Search the wiki for the problem. If an issue exists, update that issue.
2. Create the concept in `issues/` with the tags `issue` and `open`.
3. Set `type: issue` and `kind: issue`.
4. Write the body with the sections below.
5. Link the issue to the concepts that it affects, for example a template or a component.
6. Add a link to the issue from the [issues overview](/issues/issues-overview--01a1833f2fb9.md).

## Body sections

```markdown
## Problem
What is wrong, or what is necessary. One paragraph.

## Context
Why it is important. What it affects. Evidence, with links.

## Acceptance criteria
- [ ] One check that shows the issue is closed.

## Related
- [Concept](/bundle/file.md)
```

## Close an issue

1. Add a `## Resolution` section. Give the date, the commit or PR, and what changed.
2. Replace the tag `open` with `resolved`.
3. Run `okfw set-lifecycle <id> deprecated`.

Do not delete a closed issue. Other concepts and commit messages refer to it.

## Related

* [Wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md)
* [Plan workflow](/guides/plan-workflow--01a1833ed461.md)
