# Lights Out SWE

_Set the spec. Walk away. Come back to shipped software._

A gated agentic harness for lights-out software engineering. You say "build me X," the agent runs autonomously through phased quality gates, and you come back to working software — or a specific blocker.

## What This Is

A **lights-out software engineering** system. Like a [lights-out factory](https://en.wikipedia.org/wiki/Lights-out_manufacturing) in manufacturing — fully automated, no humans on the floor. You provide intent + preferences, the agent builds through quality gates, you come back to deployed software or a precise blocker.

Three layers:

- **Harness** (this repo) — permanent. The gated protocol that drives autonomous builds.
- **Scaffolding** (`scaffolding/` dir per project) — temporary. Scope, design, logs. Archived when done.
- **Software** (the delivered product) — permanent. Stands alone. Zero dependency on this repo.

## How to Use It

### Quick Start

1. Click **"Use this template"** on GitHub → create a new repo for your project
2. Clone your new repo and open it in VS Code
3. Edit `preferences.md` to set your stack, deploy targets, and conventions
4. Open Copilot chat in agent mode
5. Say `build me [description of what you want]`

The agent takes it from there.

### Prerequisites

- VS Code with GitHub Copilot (agent mode enabled)
- Git initialized (the template handles this)

### The Loop (Auto Mode — Default)

1. Open the project in VS Code
2. Start a Copilot chat in agent mode
3. Say "build me [description of what you want]"
4. Agent runs autonomously: EXPAND → DESIGN → BUILD → RECONCILE → VERIFY → DEPLOY
5. At each phase, the agent checks a gate, logs results to `scaffolding/log.md`, and git-commits a checkpoint
6. If a gate passes → agent auto-continues to the next phase
7. If a gate fails 3× → agent STOPS and reports what's blocking
8. After DEPLOY → agent stops and reports the final result

You come back to either working deployed software, or a specific blocker with options.

### Stepped Mode

Say "stepped mode" for high-stakes projects. Agent pauses after each gate for your confirmation. Say "auto" to switch back.

### The Phases

| Phase         | Input         | Output                  | Gate Checks                                                                  |
| ------------- | ------------- | ----------------------- | ---------------------------------------------------------------------------- |
| **EXPAND**    | "build me X"  | `scaffolding/scope.md`  | Has acceptance criteria, deployment target, stack, smallest useful version   |
| **DESIGN**    | scope.md      | `scaffolding/design.md` | Has directory structure, interfaces, error handling for integrations         |
| **BUILD**     | design.md     | Working code            | Compiles, tests pass, no secrets in code, matches architecture               |
| **RECONCILE** | Code + docs   | Synced scaffolding      | Documents match codebase, no spec-violating drift                            |
| **VERIFY**    | Running code  | Verified system         | Tests pass, runs locally, acceptance criteria met, no security issues        |
| **DEPLOY**    | Verified code | Live system             | Deployed, accessible, README exists, data persistence verified (if stateful) |

### Using Prompt Files

The `.github/prompts/` directory has one prompt file per phase. You can invoke them directly:

- `/expand` — Generate scope from a project idea
- `/design` — Generate architecture from scope
- `/build` — Build code from design
- `/reconcile` — Sync scaffolding docs with actual codebase (auto-runs after BUILD for house/skyscraper)
- `/verify` — Run verification checks (delegates to the read-only verify agent)
- `/deploy` — Deploy and write project README

Or just let the instructions in `.github/copilot-instructions.md` drive the full loop automatically.

### Agents

The `.github/agents/` directory has specialist agents with restricted tool access:

| Agent        | Tools                       | Purpose                                                    |
| ------------ | --------------------------- | ---------------------------------------------------------- |
| `@reconcile` | read, edit, search, execute | Detect and fix drift between scaffolding docs and codebase |
| `@verify`    | read, search, execute       | Independent evaluator — can run code but NOT edit it       |
| `@explore`   | read, search                | Read-only codebase exploration and Q&A                     |

**Why agents?** Tool restrictions enforce behavioral boundaries. The verify agent _cannot_ edit source code, which prevents the "grade your own homework" problem. The explore agent _cannot_ modify anything, making it safe for context recovery and research.

You can invoke agents directly (`@verify`, `@reconcile`, `@explore`) or let the prompts/pipeline invoke them automatically.

## File Structure

```text
.github/
  copilot-instructions.md   # The pipeline loop + discipline rules (auto-loaded by Copilot)
  agents/
    reconcile.agent.md       # Drift detection + document sync
    verify.agent.md          # Independent evaluator (read-only + execute)
    explore.agent.md         # Read-only codebase exploration
  prompts/
    expand.prompt.md         # Phase 1: scope generation
    design.prompt.md         # Phase 2: architecture from scope
    build.prompt.md          # Phase 3: code from design
    reconcile.prompt.md      # Phase 3.5: sync docs with code
    verify.prompt.md         # Phase 4: testing + acceptance
    deploy.prompt.md         # Phase 5: deployment + README
preferences.md               # Stack, infra, conventions, security, quality bar
scaffolding/                  # Created per-project (temporary)
  scope.md                   # What we're building
  design.md                  # How we're building it
  log.md                     # Experiment log — every gate check, every result
docs/
  archive/                   # Old scaffolding from completed projects
  reference/
    system_state_machine.tla # TLA+ formal spec of the pipeline state machine
```

### State Machine

The full pipeline — including gate retries, stepped mode, session recovery, complexity brakes, and on-demand reconcile — is formally specified as a TLA+ state machine in [`docs/reference/system_state_machine.tla`](docs/reference/system_state_machine.tla).

To view the state machine diagram interactively, paste the spec into the source editor at [tlaplus-process-studio.com](https://tlaplus-process-studio.com).

### How It Maps to autoresearch

| autoresearch       | lights-out-swe                               |
| ------------------ | -------------------------------------------- |
| `program.md`       | `copilot-instructions.md` + `preferences.md` |
| `train.py`         | project source code                          |
| val_bpb metric     | gate checks (pass/fail)                      |
| 5-min training run | gate evaluation                              |
| keep experiment    | `git commit` checkpoint                      |
| discard experiment | `git revert HEAD` (non-destructive)          |
| experiment log     | `scaffolding/log.md`                         |
| autonomous loop    | auto-continue on gate pass                   |

## Customization

### `preferences.md`

Edit this to match your stack, infrastructure, conventions, and quality bar. The agent references it during EXPAND (stack selection) and BUILD (conventions).

### Quality Bar

Projects scale on a formality dial:

- **Shed** — Personal tool / script. Works, runs. README optional.
- **House** — Real project with users. Tests for key paths, README required, deploy automated.
- **Skyscraper** — Complex system, multiple users, money. Full tests, formal design, staged deploy, monitoring, runbook.

Pick the right level in scope.md. Don't build skyscraper scaffolding for a shed.

## It's Still Just Git

Lights-out doesn't mean locked-out. Everything is git commits, markdown files, and standard project code. A human can drop in at any point:

- **Read `scaffolding/log.md`** to see exactly what the agent did, decided, and why
- **Read `git log`** for the full audit trail — every checkpoint, every gate result
- **Switch to stepped mode** mid-run to review between phases
- **Edit any file** — scope.md, design.md, code, preferences — the agent picks up from whatever state it finds
- **Override any decision** — the agent works for you, not the other way around

The agent runs autonomously _because you chose to let it_. You can tighten or loosen the leash at any time. Stepped mode for skyscrapers, auto mode for sheds, or just open a file and start typing.

## Discipline Rules

The pipeline enforces BEE-OS (Builder-Grade Engineering OS) discipline:

- **Evidence Rule** — No progress without checkable evidence (compiles, tests pass, HTTP 200)
- **Verification Ladder** — Cheapest feedback first (parse → unit → test suite → e2e → deployed)
- **Scope Lock** — Only build what's in scope.md. Everything else goes to a Deferred section.
- **Complexity Brake** — Auto-stop if file count exceeds 2x design, single file exceeds 300 lines, or 3rd approach to same problem
- **STOP Conditions** — Agent halts and reports when gates fail 3x, external deps break, or safety is uncertain
- **Context Recovery** — On resume, agent reads scaffolding/ first, runs existing tests, picks up where it left off

## Archiving

When a project ships:

1. Move `scaffolding/` to `docs/archive/[project-name]/`
2. The delivered software lives in its own repo with its own README
3. Harness is ready for the next project

## Citations

[1] A. Karpathy, "autoresearch," GitHub, 2025. [Online]. Available: https://github.com/karpathy/autoresearch

[2] P. Rajasekaran, "Harness design for long-running application development," Anthropic Engineering, Mar. 2026. [Online]. Available: https://www.anthropic.com/engineering/harness-design-long-running-apps

[3] J. Blocklove et al., "Design Conductor: An agent autonomously builds a 1.5 GHz Linux-capable RISC-V CPU," arXiv:2603.08716 [cs.AR], Mar. 2025. [Online]. Available: https://arxiv.org/abs/2603.08716
