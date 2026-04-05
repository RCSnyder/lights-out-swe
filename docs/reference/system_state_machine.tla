---- MODULE LightsOutSWE ----

VARIABLE pipelineState

PipelineStages == {
    "TemplateForked",
    "RepoCloned",
    "WorkspaceOpened",
    "PreferencesConfigured",
    "Expanding",
    "ExpandGatePassed",
    "ExpandRetrying",
    "Designing",
    "DesignGatePassed",
    "DesignRetrying",
    "Building",
    "BuildGatePassed",
    "BuildRetrying",
    "Verifying",
    "VerifyGatePassed",
    "VerifyFixing",
    "VerifyRetrying",
    "Deploying",
    "DeployRetrying",
    "PipelineComplete",
    "BlockedOnGate",
    "ComplexityBrakeTriggered",
    "SteppedModePaused",
    "SessionDropped",
    "ContextRecovering",
    "Reconciling",
    "ReconcileBlocked",
    "ScaffoldingArchived"
}

\* ================================================================
\* SETUP — Human-driven steps before the agent takes over
\* ================================================================

(* Human clicks "Use this template" on GitHub. A fresh repo is created
   with .github/, preferences.md, and the lights-out-swe harness files.
   No git history carries over — clean slate. The repo contains the
   harness machinery but no project code yet. *)
Init == pipelineState = "TemplateForked"

(* Human clones the new repo to their local machine. Nothing special
   happens yet — the harness is inert until opened in VS Code with
   Copilot enabled. *)
CloneRepo ==
    /\ pipelineState = "TemplateForked"
    /\ pipelineState' = "RepoCloned"

(* Human opens the repo in VS Code. Copilot auto-loads
   .github/copilot-instructions.md which contains the full harness
   protocol. The six phase prompts in .github/prompts/ become
   available as slash commands: /expand, /design, /build, /reconcile,
   /verify, /deploy. Three specialist agents become available:
   @reconcile, @verify (read-only evaluator), @explore (read-only
   research). The agent now understands the closed-loop execution
   model, gate rules, checkpointing protocol, and BEE-OS discipline. *)
OpenInEditor ==
    /\ pipelineState = "RepoCloned"
    /\ pipelineState' = "WorkspaceOpened"

(* Human edits preferences.md to declare their stack (Rust+WASM,
   Python+FastAPI, etc.), deploy target (GitHub Pages, fly.io, etc.),
   conventions, security baseline, and quality bar definitions for
   shed/house/skyscraper tiers. This is the only file that changes
   per project. Everything else is harness machinery. *)
ConfigurePreferences ==
    /\ pipelineState = "WorkspaceOpened"
    /\ pipelineState' = "PreferencesConfigured"

(* Human says "build me X" to Copilot. This is the ignition event.
   From this point the agent runs autonomously through all five phases
   in auto mode, or pauses between phases in stepped mode. The human's
   one-liner description is the only input — the agent infers everything
   else from preferences.md and the harness protocol. *)
RequestBuild ==
    /\ pipelineState = "PreferencesConfigured"
    /\ pipelineState' = "Expanding"

\* ================================================================
\* PHASE 1: EXPAND — Produce scaffolding/scope.md
\* ================================================================

(* Agent creates scaffolding/ directory, writes .gitignore, and produces
   scaffolding/scope.md with: Problem, Smallest Useful Version,
   Acceptance Criteria (with quantitative thresholds), Stack (from
   preferences.md), Deployment Target, Data Model, Quality Tier.
   Post-expand gate checks all seven conditions. Gate passes on first
   or second try. Agent commits checkpoint with conventional commit
   message and logs result to scaffolding/log.md. *)
PassExpandGate ==
    /\ pipelineState = "Expanding"
    /\ pipelineState' = "ExpandGatePassed"

(* Post-expand gate fails: scope.md missing a required section, no
   quantitative threshold in acceptance criteria, smallest useful
   version is too ambitious, or quality tier not specified. Agent
   has retries remaining (fewer than 3 attempts so far). *)
FailExpandGate ==
    /\ pipelineState = "Expanding"
    /\ pipelineState' = "ExpandRetrying"

(* Agent fixes the specific failing gate conditions — adds missing
   sections, sharpens thresholds, trims scope — then re-runs the
   post-expand gate check. *)
RetryExpand ==
    /\ pipelineState = "ExpandRetrying"
    /\ pipelineState' = "Expanding"

\* ================================================================
\* EXPAND → DESIGN transition
\* ================================================================

(* Auto mode (default): gate passed, log written, git checkpoint
   committed. Agent immediately enters DESIGN without waiting for
   human. Re-reads scope.md and preferences.md fresh at the phase
   boundary to prevent context drift. *)
AutoContinueToDesign ==
    /\ pipelineState = "ExpandGatePassed"
    /\ pipelineState' = "Designing"

\* ================================================================
\* PHASE 2: DESIGN — Produce scaffolding/design.md
\* ================================================================

(* Agent reads scope.md, produces design.md with: Architecture (ASCII
   diagram if >2 components), Directory Structure (exact file tree at
   repo root), Interfaces (typed data shapes, API contracts, module
   boundaries), External Integrations (with failure handling for each),
   Open Questions (resolved or explicitly deferred). For house/skyscraper
   projects: traces 2-3 key scenarios through the architecture, notes
   concerns by severity. Post-design gate passes. *)
PassDesignGate ==
    /\ pipelineState = "Designing"
    /\ pipelineState' = "DesignGatePassed"

(* Post-design gate fails: missing Directory Structure or Interfaces
   section, an external integration lacks error handling notes, open
   questions remain unresolved without deferral rationale, or design
   review not completed for house/skyscraper tier. *)
FailDesignGate ==
    /\ pipelineState = "Designing"
    /\ pipelineState' = "DesignRetrying"

(* Agent resolves the failing conditions — fills in missing sections,
   adds error handling notes, resolves or defers open questions with
   rationale — then re-runs the post-design gate. *)
RetryDesign ==
    /\ pipelineState = "DesignRetrying"
    /\ pipelineState' = "Designing"

\* ================================================================
\* DESIGN → BUILD transition
\* ================================================================

(* Gate passed, checkpoint committed. Agent re-reads scope.md and
   design.md from scratch before building. This prevents the builder
   from carrying assumptions that diverged from the spec. *)
AutoContinueToBuild ==
    /\ pipelineState = "DesignGatePassed"
    /\ pipelineState' = "Building"

\* ================================================================
\* PHASE 3: BUILD — Write code, tests, deployment config
\* ================================================================

(* Agent writes integration/e2e test skeleton FIRST (one failing test
   per acceptance criterion), then implements in vertical slices. Each
   slice: pick most foundational criterion → write code → verification
   ladder (compile? → unit works? → test passes?) → next slice. Uses
   QRSPI thinking internally. For house/skyscraper: creates project-
   specific .github/agents/*.agent.md as roles emerge. Post-build gate:
   code compiles, every criterion has a test, all tests pass, no secrets
   in source, code matches design.md architecture. *)
PassBuildGate ==
    /\ pipelineState = "Building"
    /\ pipelineState' = "BuildGatePassed"

(* Post-build gate fails: compilation errors, missing test coverage
   for an acceptance criterion, test failures, secrets found in source
   code, or code structure diverges from design.md architecture.
   Agent applies debugging protocol: observe error → analyze root
   cause → hypothesize → fix → verify. *)
FailBuildGate ==
    /\ pipelineState = "Building"
    /\ pipelineState' = "BuildRetrying"

(* Agent fixes the identified issues and re-runs the post-build gate.
   Each retry addresses the specific failing conditions rather than
   starting over. *)
RetryBuild ==
    /\ pipelineState = "BuildRetrying"
    /\ pipelineState' = "Building"

(* Complexity brake triggered during BUILD. One of: codebase exceeds
   2x file count from design.md, single file exceeds 300 lines, agent
   is on 3rd approach to the same problem, or adding a dependency not
   in design.md that cannot be justified. Agent STOPS and reports to
   human with the issue and options. This is NOT a gate failure — it
   is a structural concern about the design itself. *)
TriggerComplexityBrake ==
    /\ pipelineState = "Building"
    /\ pipelineState' = "ComplexityBrakeTriggered"

\* ================================================================
\* BUILD → RECONCILE transition (house/skyscraper) or BUILD → VERIFY (shed)
\* ================================================================

(* For house/skyscraper tiers: after BUILD gate passes, the reconcile
   agent runs automatically before VERIFY. This catches drift introduced
   during BUILD — the most common drift source — before the evaluator
   grades against potentially stale specs. For shed tier: skip reconcile
   and go directly to VERIFY. *)
AutoContinueToReconcile ==
    /\ pipelineState = "BuildGatePassed"
    /\ pipelineState' = "Reconciling"

(* Shed-tier shortcut: skip reconcile, go straight to verify. *)
AutoContinueToVerify ==
    /\ pipelineState = "BuildGatePassed"
    /\ pipelineState' = "Verifying"

\* ================================================================
\* PHASE 3.5: RECONCILE — Cross-check documents against codebase
\* ================================================================

(* Reconcile agent reads scope.md, design.md, log.md, preferences.md,
   and the actual file tree + code. Checks six axes: directory structure,
   interfaces, acceptance criteria, external integrations, stack/deploy
   config, and log accuracy. Classifies each inconsistency as cosmetic
   (auto-fix), structural (auto-fix with annotation), or spec-violating
   (STOP for human). Outcome: CLEAN (no drift), REPAIRED (structural
   fixes applied and committed), or BLOCKED (spec-violating drift). *)
ReconcileClean ==
    /\ pipelineState = "Reconciling"
    /\ pipelineState' = "Verifying"

(* Reconcile finds structural drift: design.md directory structure
   doesn't match actual files, interface shapes changed, integrations
   added/removed. Agent auto-fixes the documents to match reality
   (code wins over stale docs), annotates log.md, and commits. Then
   proceeds to VERIFY with accurate specs. *)
ReconcileRepaired ==
    /\ pipelineState = "Reconciling"
    /\ pipelineState' = "Verifying"

(* Reconcile finds spec-violating drift: code has behavior not in
   scope.md (unauthorized scope creep), acceptance criteria are
   impossible given current implementation, or quality tier assumptions
   are broken. Agent STOPS and reports to human in BLOCKED format
   with options: accept the scope change, revert code, or split into
   separate scope items. If this cycles more than 3 times (human keeps
   making choices that don't resolve the drift), BlockAfterThreeRetries
   escalates to BlockedOnGate for a harder stop. *)
ReconcileBlocked ==
    /\ pipelineState = "Reconciling"
    /\ pipelineState' = "ReconcileBlocked"

(* Human resolves the spec-violating drift: updates scope.md to match
   what was built, authorizes code revert, or defers the new behavior.
   Agent re-enters reconcile to verify the fix took. *)
ResolveReconcileBlock ==
    /\ pipelineState = "ReconcileBlocked"
    /\ pipelineState' = "Reconciling"

\* ================================================================
\* PHASE 4: VERIFY — Independent verification of all claims
\* ================================================================

(* Evaluator mindset — now enforced by the verify agent which has
   read + search + execute tools only (NO edit capability). Skeptical
   by default, probes edge cases, does not rationalize issues away.
   Runs all tests. Exercises the actual software against each acceptance
   criterion with real evidence: CLI output, curl responses, Playwright
   browser checks, sample data runs. Records exact command + exact
   output for each criterion. Security scan: grep for secrets, check
   XSS/SQLi/CSRF, verify auth, audit dependency sources. Confirms
   deployment config matches scope.md target. If bugs are found, the
   verify agent reports them but CANNOT fix them — control returns to
   the main agent for fixes. Post-verify gate: all tests pass, app
   runs locally, at least one criterion verified by running the app,
   no critical security issues, deploy config correct. *)
PassVerifyGate ==
    /\ pipelineState = "Verifying"
    /\ pipelineState' = "VerifyGatePassed"

(* Post-verify gate fails: verify agent (read-only) found issues —
   test failure, app crash, acceptance criterion not met, security
   vulnerability, or deploy config problem. The verify agent produces
   a verification report with exact reproduction steps but CANNOT
   fix anything (tools: read, search, execute only). Control passes
   to the main agent for fixes. *)
FailVerifyGate ==
    /\ pipelineState = "Verifying"
    /\ pipelineState' = "VerifyFixing"

(* Main agent (with full edit capability) receives the verify agent's
   bug report and applies the debugging protocol: observe the exact
   failure from the report → analyze root cause → fix the code →
   run the specific failing check to confirm the fix. This is the
   handoff that makes verify-agent independence work: one agent finds
   bugs, a different agent fixes them, then the first agent re-checks. *)
FixVerifyFailures ==
    /\ pipelineState = "VerifyFixing"
    /\ pipelineState' = "Verifying"

(* Main agent cannot resolve the verify failures after retries.
   Escalates to the retry/block mechanism. *)
EscalateVerifyFailure ==
    /\ pipelineState = "VerifyFixing"
    /\ pipelineState' = "VerifyRetrying"

(* VerifyRetrying exists only as a waypoint for BlockAfterThreeRetries.
   If not blocked, the main agent attempts another fix cycle. *)
RetryVerify ==
    /\ pipelineState = "VerifyRetrying"
    /\ pipelineState' = "VerifyFixing"

\* ================================================================
\* VERIFY → DEPLOY transition
\* ================================================================

(* Everything verified. Agent proceeds to deploy. *)
AutoContinueToDeploy ==
    /\ pipelineState = "VerifyGatePassed"
    /\ pipelineState' = "Deploying"

\* ================================================================
\* PHASE 5: DEPLOY — Ship to target, verify live, write README
\* ================================================================

(* Agent runs pre-flight checks (git remote access, flyctl auth,
   container registry creds, required env vars set). If pre-flight
   passes: deploys to target (GitHub Pages, fly.io, container, cron).
   Verifies the deployed system is accessible and working. Writes
   README.md with: what this is, how to set up locally, how to deploy,
   how to run tests. Post-deploy gate: deployed to target, accessible,
   README.md exists, data persistence verified if stateful. Agent
   reports FULL PIPELINE COMPLETE to human and STOPS. This is the
   only mandatory human pause in auto mode. *)
PassDeployGate ==
    /\ pipelineState = "Deploying"
    /\ pipelineState' = "PipelineComplete"

(* Post-deploy gate fails: deploy command errors out, pre-flight
   check fails (missing credentials, no remote access), deployed
   system is not accessible, README missing, or stateful data does
   not persist across restart. *)
FailDeployGate ==
    /\ pipelineState = "Deploying"
    /\ pipelineState' = "DeployRetrying"

(* Agent fixes deploy issues — corrects config, retries with right
   credentials, fixes accessibility — and re-attempts deployment. *)
RetryDeploy ==
    /\ pipelineState = "DeployRetrying"
    /\ pipelineState' = "Deploying"

\* ================================================================
\* CROSS-CUTTING: Gate blockage (applies to all five phases)
\* ================================================================

(* Any gate has now failed 3 times. Agent commits the broken state
   for audit ("fix(<phase>): checkpoint broken state before revert"),
   then reverts with git revert HEAD (non-destructive). Logs failure
   to scaffolding/log.md. Reports to human in BLOCKED format:
   "BLOCKED: [what's wrong]. Options: [A, B, C]. Recommendation: [X]."
   Waits for human input before continuing. *)
BlockAfterThreeRetries ==
    /\ pipelineState \in {"ExpandRetrying", "DesignRetrying", "BuildRetrying", "VerifyRetrying", "DeployRetrying", "ReconcileBlocked"}
    /\ pipelineState' = "BlockedOnGate"

(* Human provides the missing input: answers a question, changes scope,
   picks an option from the BLOCKED report, or authorizes a different
   approach. Agent enters context recovery to re-orient before resuming
   the blocked phase. *)
UnblockByUser ==
    /\ pipelineState = "BlockedOnGate"
    /\ pipelineState' = "ContextRecovering"

\* ================================================================
\* CROSS-CUTTING: Complexity brake (BUILD phase only)
\* ================================================================

(* Human resolves the complexity concern: simplifies design.md, reduces
   scope in scope.md, splits the project, or explicitly authorizes the
   additional complexity. Agent re-enters context recovery to pick up
   from the adjusted design. *)
ResolveComplexityBrake ==
    /\ pipelineState = "ComplexityBrakeTriggered"
    /\ pipelineState' = "ContextRecovering"

\* ================================================================
\* CROSS-CUTTING: Stepped mode (human-gated phase transitions)
\* ================================================================

(* In stepped mode, agent pauses after each gate passes instead of
   auto-continuing. Human reviews the phase output (scope.md, design.md,
   built code, verification results) and says "continue" to proceed.
   Used for high-stakes or skyscraper-tier projects where human review
   between phases is worth the latency cost. *)
PauseForSteppedMode ==
    /\ pipelineState \in {"ExpandGatePassed", "DesignGatePassed", "BuildGatePassed", "VerifyGatePassed"}
    /\ pipelineState' = "SteppedModePaused"

(* REVIEW: In practice, only one of the following four transitions is
   valid depending on which gate-passed state preceded the pause.
   With a single state variable we cannot track which phase paused,
   so all four are modeled as possible. The agent determines the
   correct next phase from scaffolding/log.md. *)
ResumeToDesign ==
    /\ pipelineState = "SteppedModePaused"
    /\ pipelineState' = "Designing"

ResumeToBuild ==
    /\ pipelineState = "SteppedModePaused"
    /\ pipelineState' = "Building"

ResumeToVerify ==
    /\ pipelineState = "SteppedModePaused"
    /\ pipelineState' = "Verifying"

ResumeToDeploy ==
    /\ pipelineState = "SteppedModePaused"
    /\ pipelineState' = "Deploying"

(* In stepped mode after BUILD gate passes, human can review before
   reconcile runs. Useful for reviewing what was built before the
   reconcile agent checks for drift. *)
ResumeToReconcile ==
    /\ pipelineState = "SteppedModePaused"
    /\ pipelineState' = "Reconciling"

\* ================================================================
\* CROSS-CUTTING: Session drop and context recovery
\* ================================================================

(* Chat session ends unexpectedly: context window exhausted, VS Code
   closed, machine restarted, or human walks away mid-phase. All work
   is preserved — git history has every checkpoint commit, scaffolding/
   has scope.md + design.md + log.md. No work is lost because the
   agent commits after every gate pass. *)
DropSession ==
    /\ pipelineState \in {"Expanding", "Designing", "Building", "Reconciling", "Verifying", "VerifyFixing", "Deploying"}
    /\ pipelineState' = "SessionDropped"

(* Human opens a new chat session on the same repo. Agent must recover
   context before doing anything else. *)
StartContextRecovery ==
    /\ pipelineState = "SessionDropped"
    /\ pipelineState' = "ContextRecovering"

(* Context recovery protocol: agent reads git log --oneline -20 for
   recent history, reads scaffolding/scope.md and design.md for plans,
   reads scaffolding/log.md for the experiment narrative, checks what
   code exists, runs existing tests to see current state. Then resumes
   at the appropriate phase. Context recovery always triggers a
   reconcile pass first to catch any drift from the interrupted session.
   The following six transitions represent the possible resume points
   based on what artifacts and code exist. *)

(* No scope.md yet, or scope.md exists but was never committed as
   passing. Resume EXPAND. *)
RecoverToExpand ==
    /\ pipelineState = "ContextRecovering"
    /\ pipelineState' = "Expanding"

(* scope.md exists and gate passed (per log.md) but no design.md.
   Resume DESIGN. *)
RecoverToDesign ==
    /\ pipelineState = "ContextRecovering"
    /\ pipelineState' = "Designing"

(* design.md exists and gate passed but code is incomplete or tests
   are failing. Resume BUILD. *)
RecoverToBuild ==
    /\ pipelineState = "ContextRecovering"
    /\ pipelineState' = "Building"

(* Code exists and build gate passed but verification is incomplete.
   Resume VERIFY. *)
RecoverToVerify ==
    /\ pipelineState = "ContextRecovering"
    /\ pipelineState' = "Verifying"

(* Everything built and verified but deploy was interrupted. Resume
   DEPLOY. *)
RecoverToDeploy ==
    /\ pipelineState = "ContextRecovering"
    /\ pipelineState' = "Deploying"

(* Build was complete but reconcile was interrupted or never ran.
   Resume RECONCILE before proceeding to VERIFY. *)
RecoverToReconcile ==
    /\ pipelineState = "ContextRecovering"
    /\ pipelineState' = "Reconciling"

\* ================================================================
\* CROSS-CUTTING: On-demand reconcile (human-triggered at any phase)
\* ================================================================

(* Human invokes /reconcile at any point during an active phase.
   The reconcile agent runs its full protocol. When complete, the
   harness returns to whichever phase it was in. Modeled as transitions
   from active phases into Reconciling, with return transitions back.
   REVIEW: With a single state variable we lose track of the return
   phase, same limitation as SteppedModePaused. The agent uses
   scaffolding/log.md to determine where to resume. *)
ManualReconcileFromDesigning ==
    /\ pipelineState = "Designing"
    /\ pipelineState' = "Reconciling"

ManualReconcileFromBuilding ==
    /\ pipelineState = "Building"
    /\ pipelineState' = "Reconciling"

ManualReconcileFromVerifying ==
    /\ pipelineState = "Verifying"
    /\ pipelineState' = "Reconciling"

(* After on-demand reconcile completes cleanly, resume the phase
   that was interrupted. Agent determines which phase from log.md. *)
ResumeAfterReconcileToDesigning ==
    /\ pipelineState = "Reconciling"
    /\ pipelineState' = "Designing"

ResumeAfterReconcileToBuilding ==
    /\ pipelineState = "Reconciling"
    /\ pipelineState' = "Building"

\* ================================================================
\* TERMINAL: Archive scaffolding and ship
\* ================================================================

(* Pipeline is complete. Human confirms the live system works. The
   scaffolding/ directory is archived (moved to scaffolding-archive/
   or deleted). preferences.md and .github/ can stay or go — the
   shipped software has zero dependency on the harness. The project
   repo now contains only the software, its tests, its README, and
   its deployment config. Harness fulfilled its purpose. *)
ArchiveScaffolding ==
    /\ pipelineState = "PipelineComplete"
    /\ pipelineState' = "ScaffoldingArchived"

\* ================================================================

Next ==
    \/ CloneRepo
    \/ OpenInEditor
    \/ ConfigurePreferences
    \/ RequestBuild
    \/ PassExpandGate
    \/ FailExpandGate
    \/ RetryExpand
    \/ AutoContinueToDesign
    \/ PassDesignGate
    \/ FailDesignGate
    \/ RetryDesign
    \/ AutoContinueToBuild
    \/ PassBuildGate
    \/ FailBuildGate
    \/ RetryBuild
    \/ TriggerComplexityBrake
    \/ AutoContinueToReconcile
    \/ AutoContinueToVerify
    \/ ReconcileClean
    \/ ReconcileRepaired
    \/ ReconcileBlocked
    \/ ResolveReconcileBlock
    \/ PassVerifyGate
    \/ FailVerifyGate
    \/ FixVerifyFailures
    \/ EscalateVerifyFailure
    \/ RetryVerify
    \/ AutoContinueToDeploy
    \/ PassDeployGate
    \/ FailDeployGate
    \/ RetryDeploy
    \/ BlockAfterThreeRetries
    \/ UnblockByUser
    \/ ResolveComplexityBrake
    \/ PauseForSteppedMode
    \/ ResumeToDesign
    \/ ResumeToBuild
    \/ ResumeToVerify
    \/ ResumeToDeploy
    \/ ResumeToReconcile
    \/ DropSession
    \/ StartContextRecovery
    \/ RecoverToExpand
    \/ RecoverToDesign
    \/ RecoverToBuild
    \/ RecoverToVerify
    \/ RecoverToDeploy
    \/ RecoverToReconcile
    \/ ManualReconcileFromDesigning
    \/ ManualReconcileFromBuilding
    \/ ManualReconcileFromVerifying
    \/ ResumeAfterReconcileToDesigning
    \/ ResumeAfterReconcileToBuilding
    \/ ArchiveScaffolding

====
