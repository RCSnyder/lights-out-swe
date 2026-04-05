---
description: "Build phase. Takes design.md and writes the actual code, tests, and deployment config. Builds in vertical slices."
agent: "agent"
---

Read `scaffolding/scope.md` and `scaffolding/design.md`. Write the actual software.

## Steps

1. Read both scaffolding docs fully
2. Read `preferences.md` if it exists
3. **Write the integration/e2e test skeleton first** — before any implementation. This is the oracle that guides all subsequent work:
   - Create the test file(s) with one test case per acceptance criterion
   - Each test should call the real entry point (CLI, API endpoint, function) and assert the expected outcome
   - Tests will fail initially — that's the point. They define "done."
4. Build in **vertical slices** — get one acceptance criterion working end-to-end before moving to the next:
   a. Pick the most foundational acceptance criterion
   b. Write the code for it
   c. **Verification ladder**: Does it compile? → Does the unit work? → Does the test pass?
   d. Only move to the next criterion after this one passes
   e. Repeat
5. Follow the directory structure from design.md exactly
6. **Scope lock**: Only build what's in scope.md. If you think something else is needed, note it under "## Deferred" in scope.md and move on.

## Internal QRSPI (think, don't document)

For each vertical slice:

- **Questions**: What do I need to understand?
- **Research**: Look at APIs, docs, existing code
- **Design**: How should this piece work?
- **Structure**: What files/functions?
- **Plan**: Do it

## After all slices are built

### Create project-specific agents (house/skyscraper only)

If the quality tier is **house** or **skyscraper**, evaluate whether the architecture has clear roles that would benefit from custom agents in `.github/agents/`. Only create agents when a role is obvious from the code — don't speculate.

Each `.agent.md` file should have:

- A focused `description` with trigger phrases for discovery
- Minimal `tools` — only what the role needs
- Clear constraints on what the agent should NOT do

Common patterns:

- **Explorer**: read-only, knows module boundaries (`tools: [read, search]`)
- **Test writer**: knows test patterns, fixtures, conventions (`tools: [read, edit, search]`)
- **Reviewer**: knows acceptance criteria, audits against spec (`tools: [read, search]`)
- **Ops**: knows deploy target, runbook, rollback (`tools: [read, search, execute]`)

These agents are **project code** — they survive after scaffolding is archived.

Run the **post-build gate**:

- [ ] Code compiles / typechecks (run the build, check for errors)
- [ ] Every acceptance criterion from scope.md has a corresponding test
- [ ] All tests pass
- [ ] No secrets/credentials in source code
- [ ] Code matches the architecture in design.md

If any gate condition fails, fix it and recheck. Up to 3 retries.

Log the result to `scaffolding/log.md` with passing acceptance criteria listed as evidence.

Git checkpoint:

```
git add -A && git commit -m "feat(build): implement [project] core functionality" -m "[list acceptance criteria with pass/fail status]\nGate: post-build PASS (attempt N)."
```

**Auto-continue to RECONCILE** (house/skyscraper) or **VERIFY** (shed), unless user specified stepped mode.

## Debugging Protocol

When a test or build fails, **diagnose before fixing**. Never blindly retry.

1. **Observe**: What exactly failed? Copy the error output.
2. **Analyze**: Trace the failure to a root cause. Read the relevant code. If the error is in runtime behavior, add logging or inspect state.
3. **Document**: State the root cause in one sentence before writing any fix.
4. **Fix**: Make the minimal change that addresses the root cause.
5. **Verify**: Run the failing test again. Confirm it passes and no other tests broke.

If you cannot identify the root cause after 3 analysis attempts, STOP and report.

## Living Design Document

`scaffolding/design.md` is a **living document**. If implementation reveals that the design needs to change (e.g., an interface doesn't work as specified, a dependency behaves differently than expected, or performance requirements force an architectural change):

1. Update `design.md` to reflect the actual architecture
2. Note what changed and why in the commit message
3. Do NOT silently diverge from the design — the design must always match the code

## Rules

- Build working software, not perfect software
- If something is harder than expected, simplify the approach — don't gold-plate
- If you get stuck on a technical problem for more than 3 attempts, STOP and tell the user what's blocking
- Commit logical chunks — don't write everything then commit once
