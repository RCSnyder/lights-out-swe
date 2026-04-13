# Lights Out SWE

This repo is a **lights-out software engineering** harness. An AI agent runs autonomously through gated phases — from intent to deployed software — with the lights off. The `scaffolding/` directory holds the project's provenance: versioned scopes, design decisions, and experiment logs. It persists alongside the software as a permanent record. The `docs/input/` directory holds reference materials — client briefs, API specs, feedback — that inform every phase. The software stands alone with no runtime dependency on this repo.

**This repo is a GitHub template.** Each new project starts with "Use this template" on GitHub, which creates a fresh repo with these files and no git history. The project code lives in the repo root alongside the harness files. `preferences.md` can be customized per project.

## Project Layout

```
.github/
  copilot-instructions.md   # This file — auto-loaded by Copilot
  agents/                    # Specialist agents with restricted tools
  skills/                    # On-demand execution workflows used by prompts/instructions
  prompts/                   # Phase prompts
preferences.md               # Stack + conventions (customize per project)
docs/
  input/                     # Reference materials — client briefs, API specs, feedback
scaffolding/                  # Persistent — scope, design, log (project provenance)
<project files here>         # The actual software — src/, tests/, etc.
```

**The project code goes in this repo's root.** The directory structure from `scaffolding/design.md` is created at the repo root. The `.github/`, `scaffolding/`, `docs/`, and `preferences.md` files coexist with the project files. Scaffolding and input docs persist as the project's provenance record — they enable iteration, context recovery, and audit.

## First Commit

Before the first `git add -A`, create a `.gitignore` appropriate for the project's stack. At minimum:

```gitignore
# Python
.venv/
__pycache__/
*.pyc
.eggs/
*.egg-info/

# Rust
target/

# Node
node_modules/

# Go
/vendor/

# IDE
.vscode/
.idea/

# General
.env
.DS_Store
*.log
```

Add stack-specific entries during BUILD as needed. **Never commit build artifacts, venvs, or node_modules.**

## How It Works

When the user says "build me X," follow this loop:

### Phase 1: EXPAND

Before writing scope, check two things:

1. **Input docs**: Scan `docs/input/` for reference materials (client briefs, API specs, feedback, domain knowledge). If present, read them all — they inform every section of scope.md.
2. **Preferences confirmation**: Read `preferences.md` and log the stack + deploy target you're using. If the user's request conflicts with preferences, flag it and pause for resolution.
3. **(Optional) Stack audit**: If the input docs describe an unfamiliar domain, many external integrations, or if the user requests it, run `/audit-stack` to validate that preferences.md stack choices are orthodox and right-sized for the problem. Skip for projects that clearly fit the default stack.

Then produce `scaffolding/scope.md` with these exact sections:

- **Problem**: What this solves (1-3 sentences)
- **Smallest Useful Version**: The absolute minimum that's worth having
- **Acceptance Criteria**: Checkable items — "when X happens, Y should result"
- **Stack**: Technology choices (reference `preferences.md`)
- **Deployment Target**: Where this runs
- **Data Model**: What data exists, shapes, persistence (or "none")
- **Estimated Cost**: Monthly infrastructure cost estimate ("$0 — static hosting" is fine for sheds)
- **Quality Tier**: Shed / House / Skyscraper (determines required artifacts and practices)

Then run the **post-expand gate** before proceeding.

### Phase 2: DESIGN

Produce `scaffolding/design.md` with these exact sections:

- **Architecture**: How the pieces fit together (diagram if helpful)
- **Directory Structure**: The actual file tree
- **Interfaces**: Key data shapes, API contracts, module boundaries
- **External Integrations**: What this talks to outside itself, how it handles failure, and **test strategy** for each (mock / recorded / live)
- **Observability**: What needs logging, what you'd check if this breaks at 2am (scales with tier — structured stdout for sheds, OTEL traces + Loki + Grafana alerting for houses, full OTEL instrumentation + Prometheus metrics + dashboards for skyscrapers)
- **Open Questions**: Anything uncertain — resolve before building

For house/skyscraper projects: review the design by tracing key scenarios through the architecture before building.

Then run the **post-design gate** before proceeding.

### Phase 3: BUILD

Write the actual code. Rules:

- During BUILD, ITERATE -> BUILD, and verify-fix cycles, load and follow `.github/skills/build-discipline/SKILL.md`. It defines slice sizing, anti-rationalization checks, debugging, and change summaries.
- Write integration/e2e test skeleton first — one failing test per acceptance criterion — then implement to make them pass
- Reference `scaffolding/design.md` for architecture decisions (update it if implementation forces design changes)
- Follow conventions in `preferences.md`
- Build in vertical slices — get one thing working end-to-end before broadening
- Use QRSPI thinking internally: decompose → research → design → structure → implement
- For house/skyscraper projects: create project-specific agents (`.github/agents/*.agent.md`) as clear roles emerge from the architecture. These are project code, not scaffolding.

Then run the **post-build gate** before proceeding.

### Phase 3.5: REVIEW

After BUILD passes its gate, run the review agent (`/review` or `@review`) to audit the code before reconciliation and verification.

- Review tests first, then implementation
- Review across five axes: correctness, readability, architecture, security, performance
- Label findings by severity: `Critical`, `Required`, `Consider`, `FYI`
- If REVIEW finds blocking issues, the **main agent** fixes them using the build-discipline skill, then REVIEW runs again

Then run the **post-review gate** before proceeding.

### Phase 3.6: RECONCILE

After REVIEW passes its gate — and before VERIFY — run the reconciliation agent (`/reconcile` or `@reconcile`) to detect and fix drift between scaffolding documents and the actual codebase.

The reconcile agent checks six axes:

1. **Directory structure**: Does design.md match the actual file tree?
2. **Interfaces**: Do typed shapes in design.md match the code?
3. **Acceptance criteria**: Does scope.md still describe what was built?
4. **External integrations**: Does design.md list what the code actually uses?
5. **Stack & deploy**: Does scope.md match actual dependencies and deploy config?
6. **Log accuracy**: Does log.md reflect reality (cross-referenced with git log)?

Drift is classified as:

- **Cosmetic**: Auto-fixed silently
- **Structural**: Auto-fixed, annotated in log.md, committed
- **Spec-violating**: STOP and report to user (code gained unauthorized scope, criteria became impossible, etc.)

Reconcile can also be invoked **on demand** at any phase — useful after session recovery, after manual code edits, or whenever documents feel stale.

### Phase 4: VERIFY

- Run all tests via the verify agent (`@verify` — read-only, cannot edit code)
- The verify agent exercises the application and checks each acceptance criterion with real evidence
- If the verify agent finds failures, it produces a report; the **main agent** fixes the code; then the verify agent re-checks
- If the verify-fix cycle makes significant code changes (new files, interface changes), re-run reconcile before the final verify pass
- Check for obvious security issues (secrets in code, SQL injection, etc.)
- Verify deployment config exists and is correct

Then run the **post-verify gate** before proceeding.

### Phase 5: DEPLOY

- Deploy to the target specified in `scaffolding/scope.md`
- Verify it's accessible and working
- Set up monitoring if the project warrants it (stateful/long-running systems)
- Write a minimal `README.md` in the project (not the scaffolding)
- Write `DELIVERY.md` — the client-facing handoff document. All projects get the same structure; depth scales naturally with complexity (a shed's sections are one-liners; a skyscraper's are comprehensive)

Then run the **post-deploy gate**.

### Phase 6: ITERATE (post-delivery, on demand)

After delivery, when the client has feedback, change requests, or new requirements:

1. User adds feedback/requirements to `docs/input/` and runs `/iterate`
2. Agent recovers full project context (git log, scaffolding, codebase, tests)
3. Agent reads new inputs + deferred items from scope.md + known limitations from DELIVERY.md
4. Agent produces an **iteration proposal** — prioritized changes, architecture impact, risk assessment
5. **User confirms** which changes to build (this is NOT auto-continue — iteration is a business decision)
6. Agent versions the current scope, writes v[N+1] acceptance criteria, and re-enters the pipeline at the appropriate point:
   - No architecture changes → BUILD directly
   - Minor architecture changes → quick DESIGN update → BUILD
   - Major re-architecture → full DESIGN → BUILD
7. Pipeline runs normally from re-entry: BUILD → REVIEW → RECONCILE → VERIFY → DEPLOY
8. DELIVERY.md is updated with the new version's changes

Iteration preserves all v1 history — scope.md is versioned, not overwritten. The audit trail is continuous.

## Gate Rules

Gates are machine-checkable. After each phase, check the gate conditions. If a gate fails:

1. Report which conditions failed
2. Fix them
3. Recheck
4. Repeat up to 3 times
5. If still failing after 3 attempts, STOP and report to the user what's stuck

**Do not skip gates. Do not proceed with failed gates.**

## Post-Expand Gate

- [ ] `scaffolding/scope.md` exists
- [ ] Has "Acceptance Criteria" section with ≥1 checkable item
- [ ] At least one acceptance criterion includes a measurable/quantitative threshold
- [ ] Has "Deployment Target" section with a specific target
- [ ] Has "Stack" section that references known tech
- [ ] Has "Quality Tier" section (shed / house / skyscraper)
- [ ] Has "Estimated Cost" section
- [ ] Has "Smallest Useful Version" that is genuinely small
- [ ] Smallest Useful Version is genuinely useful — acceptance criteria form a coherent experience, not just independent checkboxes

## Post-Design Gate

- [ ] `scaffolding/design.md` exists
- [ ] Has "Directory Structure" section
- [ ] Has "Interfaces" section with at least one data shape
- [ ] Every external integration has error handling noted
- [ ] Every external integration has a test strategy declared (mock / recorded / live)
- [ ] Has "Observability" section
- [ ] No open questions remain unresolved (or explicitly deferred)
- [ ] Design review completed (house/skyscraper) or skipped with rationale (shed)

## Post-Build Gate

- [ ] Code compiles / typechecks (no errors from `get_errors`)
- [ ] Every acceptance criterion from scope.md has a corresponding test
- [ ] All tests pass
- [ ] No secrets/credentials in source code
- [ ] Dependency audit passes — run the appropriate command (`uvx pip-audit`, `npm audit`, `cargo audit`, etc.) and confirm no high/critical vulnerabilities
- [ ] Lockfile exists if project has dependencies (`uv.lock`, `Cargo.lock`, `package-lock.json`, etc.)
- [ ] Code follows design.md directory structure and interfaces (manual check — reconcile agent runs next for deeper audit)

## Post-Review Gate

- [ ] No `Critical` review findings remain
- [ ] No `Required` review findings remain
- [ ] Any BUILD evidence invalidated by review-fix work has been re-run
- [ ] Dead code, dependency, and maintainability concerns are resolved or explicitly documented

## Post-Verify Gate

- [ ] All tests pass
- [ ] Tests are non-trivial (verify agent confirms real code paths with meaningful assertions)
- [ ] Application runs locally without errors
- [ ] At least one acceptance criterion verified by running the app
- [ ] No critical security issues
- [ ] Deployment config exists and looks correct

## Post-Deploy Gate

- [ ] Deployed to specified target
- [ ] Accessible (can reach it / run it)
- [ ] README.md exists in the project with setup + run instructions
- [ ] DELIVERY.md exists with at minimum: what was built, how to use it, known limitations
- [ ] If stateful: data persistence verified

## BEE-OS Discipline

These are non-negotiable. They apply at every phase, in every project, at every scale.

### Evidence Rule

No progress without evidence. "I wrote the code" is not evidence. "The tests pass" is evidence. "It compiles" is evidence. "I deployed it and got HTTP 200" is evidence. If you can't point to a checkable result, you haven't made progress.

### Verification Ladder

Always prefer the cheapest feedback first:

1. Does it parse / compile / typecheck?
2. Does the smallest unit work? (one function, one endpoint)
3. Do the tests pass?
4. Does it run end-to-end locally?
5. Does it work deployed?

Don't write 500 lines and then check. Write 50, check, write 50, check.

### BUILD Execution Contract

During BUILD, iteration builds, and verify-fix work:

- Use `.github/skills/build-discipline/SKILL.md` as the default execution workflow.
- If a slice touches more than about 5 files or you write more than about 100 lines before verification, split it down further.
- After each successful slice, record: `Changed`, `Not touched`, and `Concerns`.
- When something fails, follow the skill's reproduce -> localize -> reduce -> root-cause -> fix -> guard -> verify loop before continuing.

### Scope Lock

Only build what's in `scaffolding/scope.md`. If you think something else is needed:

1. Note it in `scaffolding/scope.md` under a "## Deferred" section
2. Do NOT build it
3. The user decides whether to expand scope

### Complexity Brake

If during BUILD:

- The codebase exceeds 2x the file count in design.md → STOP, reassess
- You're on your 3rd approach to the same problem → STOP, tell the user
- A single file exceeds 300 lines → split it or question the design
- You're adding a dependency not in design.md → pause, justify, continue only if essential

### STOP Conditions

STOP and report to the user when:

- A gate fails 3 times
- You're stuck on the same error after 3 different approaches
- You realize the scope is significantly larger than scope.md suggests
- An external dependency is unavailable or behaves unexpectedly
- You're uncertain whether something is safe (security, data loss, cost)

Say exactly: "BLOCKED: [what's wrong]. Options: [A, B, C]. Recommendation: [X]."

After any BLOCKED event, append a post-mortem to the log entry:

```markdown
### Post-Mortem

- **What went wrong**: [root cause, not symptoms]
- **What to try differently**: [concrete next approach, not vague "try harder"]
- **What to avoid**: [approaches that were tried and failed — save the next session from repeating them]
```

This accumulates institutional knowledge. The next session's context recovery reads this and avoids repeating dead ends.

### Context Recovery

If you're resuming work on an existing project:

1. Run `git log --oneline -20` to understand recent history and decisions
2. Read `scaffolding/scope.md` and `scaffolding/design.md` first
3. Read `scaffolding/log.md` for the experiment narrative
4. Check what code already exists
5. Run existing tests to see current state
6. Pick up from wherever the last session left off

**Session handoff**: When context is getting long, a session is ending, or you're pausing work: commit all current state (`git add -A && git commit`) with a WIP message explaining where you are and what comes next. Update `scaffolding/log.md` with current state and the immediate next step. This ensures the next session (or a different model instance) can pick up cleanly.

**Phase transitions also require context recovery.** When moving from one phase to the next (e.g., DESIGN → BUILD, BUILD → VERIFY), re-read `scaffolding/scope.md` and `scaffolding/design.md` from scratch. Do not rely on carried context from the previous phase — treat each phase transition as a clean start with the scaffolding artifacts as your source of truth. This prevents context drift and ensures the evaluator (VERIFY) is not influenced by the builder's assumptions.

The scaffolding/ directory + git history IS the persistent context. Both survive across sessions. The scaffolding tells you WHAT was planned. The git log tells you WHAT was done, WHEN, and WHY.

### Tool Discipline

- Before running a command: state what you expect to happen
- After running a command: interpret the result
- Before editing a file: read it (or the relevant section) first
- Before creating a file: check it doesn't already exist
- Prefer reading large sections over many small reads

## Closed Loop Execution

This system runs as an **autonomous loop**, not a step-by-step wizard. Like autoresearch: the human writes the program (these instructions + `preferences.md`), the agent runs the loop, the gates are the metric.

### Default behavior: auto-continue

When a gate passes:

1. Log the result to `scaffolding/log.md`
2. Git commit the checkpoint (see Checkpointing below)
3. **Immediately continue to the next phase** — do NOT wait for the user

When a gate fails 3 times:

1. Log the failure
2. **STOP** — report to the user with the BLOCKED format
3. Wait for user input before continuing

The only mandatory human pause is after **DEPLOY** — confirm the live system is correct.

### Experiment Log

Maintain `scaffolding/log.md`. Append after every gate check:

```markdown
## [Phase] — [timestamp]

- **Gate**: PASS / FAIL (attempt N)
- **Evidence**: [what was checked and the result]
- **Changes**: [what was created/modified this phase]
- **Retries**: [total gate attempts this phase — a proxy for cost/effort]
- **Next**: [what phase comes next, or BLOCKED]
```

This is the equivalent of autoresearch's experiment log. When you come back in the morning, `scaffolding/log.md` tells you everything that happened.

### Checkpointing (non-destructive, auditable)

Git history is the audit trail. Future agent sessions will read it to recover context. **Every commit must explain WHY, not just what.**

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

<body — explain WHY this change was made, what decision it reflects,
and what the gate/evidence status was>
```

**Types:**

| Type       | When to use                                              |
| ---------- | -------------------------------------------------------- |
| `feat`     | New functionality (vertical slice, acceptance criterion) |
| `fix`      | Bug fix or gate failure repair                           |
| `docs`     | Scaffolding docs, README, log updates                    |
| `chore`    | Config, dependencies, tooling                            |
| `refactor` | Restructuring without behavior change                    |
| `test`     | Adding or fixing tests                                   |
| `revert`   | Undoing a previous commit (see below)                    |

**Scope** is the phase or component: `expand`, `design`, `build`, `verify`, `deploy`, or a module name.

**Examples:**

```
docs(expand): define scope for video editor project

Acceptance criteria: 5 items covering timeline, export, preview.
Stack: Rust + WASM per preferences.md.
Gate: post-expand PASS (attempt 1).
```

```
feat(build): implement timeline component with drag reordering

First vertical slice — timeline renders clips and supports reorder.
Verification ladder: compiles ✓, unit test passes ✓.
Addresses acceptance criterion #1 from scope.md.
```

```
revert: revert "feat(build): add codec abstraction layer"

Gate: post-build FAIL (attempt 3/3). Codec abstraction added
complexity without solving the rendering bug. Reverting to
last known-good state. BLOCKED: need user input on codec strategy.
```

**After each gate passes**, commit the checkpoint:

```
git add -A && git commit -m "<type>(<phase>): <summary>" -m "<body with WHY + evidence>"
```

**Non-destructive history is mandatory.** Never use:

- `git reset --hard`
- `git push --force`
- `git rebase` (interactive or otherwise)
- Any operation that rewrites or destroys commit history

If a phase produces broken state (gate fails after 3 retries):

1. **Commit the broken state** with an explanation:
   ```
   git add -A && git commit -m "fix(<phase>): checkpoint broken state before revert" -m "Gate failed 3x. Evidence: [what failed]. Preserving state for audit before reverting."
   ```
2. **Revert** using `git revert HEAD` (creates a NEW commit that undoes the change)
3. Log the failure in `scaffolding/log.md`
4. STOP and report to the user

This way `git log` is a complete, non-destructive record of everything the agent did, including failed experiments and why they were abandoned. Future agents recovering context should run `git log --oneline -20` as part of Context Recovery.

### Run modes

- **Auto** (default): Agent runs EXPAND → DESIGN → BUILD → REVIEW → RECONCILE → VERIFY → DEPLOY autonomously. Only stops on gate failure or after DEPLOY.
- **Stepped**: User says "stepped mode" — agent pauses after each gate for user confirmation. Use this for high-stakes or skyscraper-level projects.

The user can switch modes at any time by saying "auto" or "stepped."

### The full autonomous run

When the user says "build me X":

```
EXPAND → gate → log → commit → DESIGN → gate → log → commit →
BUILD → gate → log → commit → REVIEW → gate → log → commit → RECONCILE → log → commit →
VERIFY → gate → log → commit → DEPLOY → gate → log → commit →
STOP (report to user)
```

When the user says "/iterate" on a shipped project:

```
ITERATE (propose) → user confirms → version scope → re-enter pipeline →
BUILD → gate → log → commit → REVIEW → gate → log → commit → RECONCILE → log → commit →
VERIFY → gate → log → commit → DEPLOY → gate → log → commit →
STOP (report to user)
```

If any gate fails 3×: STOP at that point. The user sees the log, the checkpoints, and exactly where it got stuck.

## QRSPI Inside BUILD

When building complex features, use the QRSPI thinking pattern internally:

1. **Questions**: What do I need to understand to build this?
2. **Research**: Look at the codebase, docs, APIs
3. **Design**: How should this piece be structured?
4. **Structure**: Break into vertical slices
5. **Plan**: Sequence the work

You don't need to produce separate QRSPI documents unless the project is complex enough to warrant it (skyscraper-level). For sheds and houses, QRSPI is internal thinking, not document production.
