---
id: "01a1833e-d461-7ec7-ac10-3bbc52a40987"
title: "Plan workflow"
type: "guide"
tags:
  - "guide"
  - "plan-workflow"
created: "2026-10-28T11:01:35-05:00"
timestamp: "2026-10-28T11:01:35-05:00"
description: "How to record a multi-step plan in the wiki, link it to its issues, and move it through its state tags."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:35-05:00"
status: "draft"
---

# Plan workflow

This concept tells you how to record and track a plan. A plan records the steps of one piece of work that has more than one step.

## Find plans

* Active plans: `okfw search --type plan --tag active`
* Proposed plans: `okfw search --type plan --tag proposed`

## Record a plan

1. Search the wiki for a plan or an issue about the same work.
2. Create the concept in `plans/` with the tags `plan` and `proposed`.
3. Set `type: plan`.
4. Write the body with the sections below.
5. Link the plan to each issue that it closes. Link each issue back to the plan.
6. Add a link to the plan from the [plans overview](/plans/plans-overview--01a1833f2fed.md).

## Body sections

```markdown
## Goal
The result, in one or two sentences.

## Context
Why the work is necessary. Links to issues and findings.

## Steps
1. One step.

## Verification
How to show that the work is complete.

## Related
- [Issue](/issues/file.md)
```

## Change the state

| From | To | When |
|---|---|---|
| `proposed` | `active` | Work starts |
| `active` | `done` | The verification passes. Then run `okfw set-lifecycle <id> deprecated`. |
| `proposed` | `dropped` | The work will not occur. Add the reason. Then run `okfw set-lifecycle <id> deprecated`. |

Replace the old state tag with the new state tag. Use only one state tag at a time.

## Agent plans

When an AI agent makes a plan in its own tool, record the approved plan here. The wiki keeps the plan after the agent session ends.

## Related

* [Wiki conventions](/guides/wiki-conventions--01a1833ed3fc.md)
* [Issue workflow](/guides/issue-workflow--01a1833ed42f.md)
