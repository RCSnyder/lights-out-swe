---
description: "Distill raw input materials into structured reference docs. Use when docs/input/ contains messy client briefs, API specs, meeting notes, or domain knowledge that needs structuring before EXPAND."
agent: "agent"
argument-hint: "Optional: focus area or specific docs to distill..."
---

Read everything in `docs/input/` and produce structured reference documents that the pipeline can consume reliably.

## When to use

- Before `/expand` when input docs are messy, verbose, or unstructured
- When a client sends a wall of text and you need to extract requirements
- When integrating with an external API and you have raw docs
- When ingesting feedback for `/iterate` and the feedback is scattered

## Steps

1. List and read all files in `docs/input/`
2. For each file, classify its content type:
   - **Requirements** → extract into a structured requirements doc
   - **API/integration specs** → extract endpoints, auth, data shapes, error codes
   - **Data schemas** → extract entities, relationships, constraints
   - **Domain knowledge** → extract rules, glossary, constraints
   - **Feedback** → extract specific issues, change requests, feature requests with priority
   - **Mixed/messy** → decompose into the above categories

3. Produce structured output docs back into `docs/input/`, named with a `distilled-` prefix:

### Requirements doc format

```markdown
# Distilled Requirements — [source file(s)]

Source: [list of input files this was distilled from]

## Core Requirements

- [REQ-1] [Specific, testable requirement]
- [REQ-2] ...

## Constraints

- [CON-1] [Hard constraint — must be true]

## Assumptions

- [ASM-1] [Assumption made during distillation — verify with client]

## Out of Scope (explicitly mentioned)

- [item]

## Ambiguities (need clarification)

- [item] — assumed [X], could also mean [Y]
```

### Integration spec format

```markdown
# Distilled Integration — [service name]

Source: [list of input files this was distilled from]

## Endpoint Summary

| Method | Path | Purpose | Auth |
| ------ | ---- | ------- | ---- |

## Data Shapes

[Key request/response types]

## Error Handling

[Error codes, retry strategy, failure modes]

## Rate Limits / Constraints

[Anything that affects design]
```

### Feedback doc format

```markdown
# Distilled Feedback — [source]

Source: [list of input files this was distilled from]

## Change Requests (prioritized)

1. [HIGH] [Specific change] — Reason: [why]
2. [MED] [Specific change] — Reason: [why]
3. [LOW] [Specific change] — Reason: [why]

## Bug Reports

- [Description] — Steps to reproduce: [steps]

## Feature Requests

- [Description] — Value: [why client wants this]

## Positive Feedback (keep these)

- [What's working well]
```

4. After distillation, summarize what was produced:

```
Distilled [N] input docs into:
- distilled-requirements.md (X requirements, Y constraints)
- distilled-integration-stripe.md (Z endpoints)
- distilled-v1-feedback.md (A changes, B bugs, C features)

Ambiguities flagged: [list]
Ready for /expand or /iterate.
```

## Rules

- Do NOT delete or modify the original input docs. Distilled docs are additive.
- Flag ambiguities explicitly — don't silently resolve them. The user or client decides.
- If an input doc is already well-structured, skip it. Say "already structured, no distillation needed."
- Keep distilled docs concise. The goal is machine-consumable structure, not a rewrite.
- **Each distilled doc must list its source file(s)** at the top so the pipeline knows which raw docs have been distilled and can prefer the distilled version.
