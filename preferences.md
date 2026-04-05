# Preferences

## Stack Preferences

| Project Type       | Default Stack                                  | Deploy Target                |
| ------------------ | ---------------------------------------------- | ---------------------------- |
| Static tool / SPA  | Rust + WASM (Leptos or vanilla)                | GitHub Pages + Namecheap DNS |
| Data pipeline      | Python                                         | fly.io or cron on VPS        |
| LLM-powered engine | Python + LLM API                               | fly.io                       |
| Full-stack web app | Python (FastAPI) or Rust + TypeScript frontend | fly.io + Neon                |
| CLI tool           | Rust                                           | Binary release on GitHub     |

## Infrastructure

- **Domains**: Namecheap
- **Static hosting**: GitHub Pages
- **Compute**: fly.io
- **Database**: Neon (Postgres)
- **Auth**: Clerk (when needed)
- **Secrets**: Doppler (or env vars for simple projects)
- **CI/CD**: GitHub Actions
- **Monitoring**: Grafana Cloud (for long-running systems)
- **Email**: Resend (when needed)

## Conventions

- **Always defer to idiomatic, orthodox solutions.** Use the standard way a language/framework community solves a problem. Don't invent novel patterns when established ones exist. Boring technology wins.
- Prefer simplicity. One file > elegant abstractions for small projects.
- Tests for business logic. Don't test boilerplate.
- README.md in every project — what, how to run, how to deploy.
- No frameworks for the sake of frameworks. Vanilla when it's simpler.
- Error messages should say what went wrong AND what to do about it.
- When making a design decision, ask: "what would a senior, principle engineer at a serious company do?" Do that.
- **Periodically audit scaffolding overhead.** Every process step encodes an assumption about what the model can't do on its own. As models improve, re-examine whether each step is still load-bearing. Strip what's no longer necessary; add new steps where the model's expanded capability enables more ambitious outcomes.

## Security Baseline

- No secrets in source code. Ever. Use env vars or secrets manager.
- Parameterized queries for all database access.
- HTTPS everywhere.
- Input validation at system boundaries.
- Dependencies from known registries only.

## Quality Bar

Three tiers. Pick the right one in `scaffolding/scope.md`. When in doubt, go one tier up.

### Shed (personal tool, quick script, POC, simple package, client-side WASM tool)

May have users, but no tracking, no accounts, no server-side state.

| Artifact / Practice | Required?                                                                     |
| ------------------- | ----------------------------------------------------------------------------- |
| README.md           | Yes — what it is + how to run (5 lines minimum)                               |
| .gitignore          | Yes                                                                           |
| Tests               | Yes — agent writes tests for verification loop. Proves it works autonomously. |
| CI/CD               | No                                                                            |
| Deploy              | Manual / local / publish to registry                                          |
| Monitoring          | No                                                                            |
| Security review     | Basic — no secrets in code                                                    |
| LICENSE             | No — user adds later if needed                                                |
| CONTRIBUTING.md     | No                                                                            |
| Scaffolding fate    | Archive or delete when done                                                   |

### House (real project, tracked users, persistent data)

| Artifact / Practice | Required?                                                   |
| ------------------- | ----------------------------------------------------------- |
| README.md           | Yes — what, setup, run, deploy, test                        |
| .gitignore          | Yes                                                         |
| Tests               | Yes — key paths, business logic                             |
| CI/CD               | Yes — automated tests on push                               |
| Deploy              | Automated to single target                                  |
| Monitoring          | Error tracking at minimum                                   |
| Security review     | Input validation, dependency audit, no secrets              |
| LICENSE             | No — user adds later if needed                              |
| CONTRIBUTING.md     | If open-source or team project                              |
| CHANGELOG.md        | Recommended                                                 |
| Custom agents       | Yes — create `.github/agents/` as roles emerge during BUILD |
| Scaffolding fate    | Archive to docs/ when shipped                               |

### Skyscraper (complex system, multiple users, money)

| Artifact / Practice | Required?                                                   |
| ------------------- | ----------------------------------------------------------- |
| README.md           | Yes — comprehensive, onboarding-grade                       |
| .gitignore          | Yes                                                         |
| Tests               | Full — unit, integration, e2e                               |
| CI/CD               | Yes — with staging environment                              |
| Deploy              | Staged (canary or blue-green)                               |
| Monitoring          | Metrics, alerts, dashboards                                 |
| Security review     | Threat model, dependency scanning, secrets rotation         |
| LICENSE             | No — user adds later if needed                              |
| CONTRIBUTING.md     | Yes                                                         |
| CHANGELOG.md        | Yes                                                         |
| RUNBOOK.md          | Yes — incident response, rollback procedures                |
| Architecture docs   | design.md stays permanent (not archived)                    |
| Custom agents       | Yes — create `.github/agents/` as roles emerge during BUILD |
| Scaffolding fate    | scope.md archived; design.md + log.md stay with the project |

## Toolchain Rules

These prevent common agent tarpits. Follow them exactly.

### Python

- **Use `uv`**, not pip, not poetry, not conda. Always.
- Project init: `uv init` → produces `pyproject.toml` (the single source of truth for deps, metadata, tool config).
- Add deps: `uv add <package>`. Dev deps: `uv add --dev <package>`.
- Run anything: `uv run python ...`, `uv run pytest`, etc.
- Build: use setuptools as the build backend (default from `uv init`). `pyproject.toml` only — no `setup.py`, no `setup.cfg`.
- **Never activate a venv.** `uv run` handles it. Venv activation does not persist between terminal calls in agent mode — this is a tarpit.
- **Never use `pip install`.**

### Rust

- Project init: `cargo init` (existing dir) or `cargo new <name>`
- Build: `cargo build`. Test: `cargo test`. Run: `cargo run`.
- For WASM: use `trunk` (install: `cargo install trunk`). Build: `trunk build`. Serve: `trunk serve`.
- Expect first compile to be slow (minutes). This is normal, not a hang.

### Go

- Project init: `go mod init <module-path>`
- Always use modules. Never rely on GOPATH.

### Node / TypeScript

- **Use `npm`** unless the project already has a different lockfile.
- Always `npm install` before running anything.
- For global CLI tools: `npx <tool>` instead of global install.

### Browser Testing (Playwright)

- Install: `uv add playwright` then `uv run playwright install --with-deps`
- The `--with-deps` flag installs system browser dependencies. Without it, tests will fail on a fresh machine.

### General Anti-Tarpits

- **Always pass `-y` or `--yes`** to any command that might prompt for confirmation (apt, brew, npm init, etc.).
- **Never run interactive commands.** If a tool requires interactive input, find the non-interactive flag or config file alternative.
- **Always check tool availability first.** Before using ANY tool for the first time in a session, run `which <tool>` (Unix) or `where <tool>` (Windows). If missing, install it or STOP. Do not assume anything is on PATH.
- **Timeouts on long commands.** If a build or test takes longer than expected, check if it's actually running (not hung). Rust compiles and `playwright install` are legitimately slow.
- **No global installs** unless it's a CLI tool you'll reuse (trunk, flyctl, uv itself). Everything else goes in the project.
