---
description: "Reconcile scaffolding documents against the codebase. Detects and fixes drift between scope.md, design.md, log.md, and the actual code."
agent: "reconcile"
argument-hint: "Optional: specific concern or axis to focus on..."
---

Run the reconciliation agent to cross-check all scaffolding documents against the actual codebase.

Use this:

- After REVIEW, before VERIFY
- After resuming from a session drop
- After a BLOCKED → unblock cycle
- Whenever documents feel stale
- After manual code edits outside the pipeline

The agent checks six axes: directory structure, interfaces, acceptance criteria, external integrations, stack/deploy config, and log accuracy. It auto-fixes cosmetic and structural drift, and flags spec-violating drift for your decision.
