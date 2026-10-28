---
id: "01a1833e-4dc1-765f-a442-ef478098bbfb"
title: "Terminology"
type: "guide"
tags:
  - "guide"
  - "ste"
  - "terminology"
created: "2026-10-28T11:01:00-05:00"
timestamp: "2026-10-28T11:01:00-05:00"
description: "The controlled words of this project: one word for one thing, and one meaning for each word."
generated:
  by: "claude-code/opus-5-5"
  at: "2026-10-28T11:01:00-05:00"
status: "draft"
---

# Terminology

Use these words with these meanings only. If you need a new word, add it here first.

## Rule

* Use one word for one thing. Do not use a synonym for variety.
* Use each word with one meaning. Do not use "feature" to mean "capability".
* Write technical names (commands, paths, flags, file names) in code font.

## Product words

| Word | Meaning | Do not use |
|---|---|---|
| template | One dev container template in `src/<name>/`. The pipeline publishes it as an OCI artifact. | workspace, stack, image |
| feature | One dev container feature. A template declares features in `devcontainer.json`. | plugin, add-on, capability |
| trusted feature | A feature from `ghcr.io/infrashift/trusted-devcontainer-features`. | upstream feature |
| repo-local feature | A feature in `features/src/` of this repository (ADR-009). | local feature, custom feature |
| base image | `trusted/fedora43-minimal` from `ghcr.io/infrashift/trusted-base-images`. | base, OS image |
| shared Containerfile | `shared/Containerfile`. Each template holds an identical copy. | Dockerfile |
| bootstrap | The feature that installs uv and Ansible in `/opt/bootstrap` (ADR-008). | installer |
| dev user | The non-root user `dev`, UID 1001 (ADR-003). | vscode user |

## Supply-chain words

| Word | Meaning | Do not use |
|---|---|---|
| pin | A reference by `sha256` digest. Also the act of setting one. | lock, freeze |
| digest | The `sha256:` value that identifies one image or artifact. | hash, SHA |
| PDP | The policy decision point: the OPA policy in `.github/pdp/`. | gate (alone), checker |
| finding | One vulnerability that the scanner (Grype) reports. | vuln, hit |
| blocking | A finding that stops the release. | failing |
| waived | A finding that a waiver accepts. | ignored, suppressed |
| recorded | A finding that the PDP shows but does not block. | informational |
| waiver | One entry in `.github/pdp/exceptions.yaml`, with an id `EXC-YYYY-NNNN` and an expiry. | exception (alone), allowlist |
| verdict | The signed PDP result for one template: `PASS` or `FAIL`. | decision, result |
| signing actor | One of the three pipeline identities: Build-Actor, Review-Actor, Release-Actor. | role, bot |

## Wiki words

| Word | Meaning | Do not use |
|---|---|---|
| concept | One markdown file in `.okfw/`. It holds one idea. | note, page, doc |
| bundle | One directory in `.okfw/`, with its generated `index.md`. | folder, section |
| overview | The concept that explains one bundle. Tag: `hub`. | readme, landing page |
| wiki actor | The writer of a concept, in `generated.by` or `verified[].by`. | author |
| issue | A concept of kind `issue`. It records one problem or one task. | ticket, bug, TODO |
| plan | A concept of type `plan`. It records the steps of one piece of work. | proposal, spec |
