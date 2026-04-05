---
description: "Start a new project. Expands a one-liner into scope.md with problem, smallest useful version, acceptance criteria, stack, deployment target, and data model."
agent: "agent"
argument-hint: "Describe what you want to build..."
---

The user wants to build something new. Your job: produce `scaffolding/scope.md`.

## Steps

1. Create a `scaffolding/` directory in the project root
2. Create a `.gitignore` appropriate for the project's stack (see "First Commit" in copilot-instructions.md). This must exist before the first `git add -A`.
3. From the user's description, produce `scaffolding/scope.md` with these exact sections:

### scope.md format

```markdown
# [Project Name]

## Problem

[What this solves — 1-3 sentences]

## Smallest Useful Version

[The absolute minimum that's worth having. Be ruthless about cutting scope.]

## Acceptance Criteria

- [ ] [When X happens, Y should result — include a measurable threshold where possible]
- [ ] [Specific, testable, checkable items]
- [ ] [At least 3 items]

Every criterion should be **verifiable by running something and checking output**.
Where applicable, include a quantitative measure (response time, file size, throughput, error rate, etc.).
Vague criteria like "it should be fast" are not acceptable — say "responds in < 200ms" instead.

For projects with a **frontend or user-facing design**, include at least one criterion that addresses subjective quality using gradable terms. Don't say "looks good" — instead reference specific design principles:

- **Design quality**: Does it feel like a coherent whole (colors, typography, layout, spacing)?
- **Originality**: Are there deliberate creative choices, or is it generic defaults/templates?
- **Craft**: Typography hierarchy, spacing consistency, color harmony, contrast ratios.
- **Functionality**: Can users find primary actions and complete tasks without guessing?

Weight criteria toward whatever the model is weakest at (usually design quality and originality over craft and functionality).

## Stack

[Technology choices. Reference preferences.md if it exists, or state choices explicitly.]

## Deployment Target

[Where this runs — GitHub Pages, fly.io, local, cron job, etc.]

## Data Model

[What data exists, shapes, persistence. Or "None — stateless" if applicable.]

## Quality Tier

[Shed / House / Skyscraper — see preferences.md for definitions. This determines which artifacts and practices are required.]
```

4. Run the **post-expand gate**:
   - [ ] `scaffolding/scope.md` exists
   - [ ] Has "Acceptance Criteria" section with ≥1 checkable item
   - [ ] At least one acceptance criterion includes a measurable/quantitative threshold
   - [ ] Has "Deployment Target" section with a specific target
   - [ ] Has "Stack" section
   - [ ] Has "Quality Tier" section (shed / house / skyscraper)
   - [ ] "Smallest Useful Version" is genuinely small — not the kitchen sink

5. If any gate condition fails, fix it and recheck.

6. Log the result to `scaffolding/log.md`:

```markdown
## EXPAND — [timestamp]

- **Gate**: PASS (attempt N)
- **Evidence**: [what was checked]
- **Changes**: scaffolding/scope.md created
- **Next**: DESIGN
```

7. Git checkpoint:

   ```
   git add -A && git commit -m "docs(expand): define scope for [project]" -m "[summarize key decisions, acceptance criteria count, stack choice]\nGate: post-expand PASS (attempt N)."
   ```

8. **Auto-continue to DESIGN** (unless user specified stepped mode).

## Rules

- Be opinionated. Don't ask 20 clarifying questions. Make reasonable choices and state them.
- If something is ambiguous, pick the simpler option and note the assumption.
- The scope should fit on one screen. If it doesn't, the scope is too big.
