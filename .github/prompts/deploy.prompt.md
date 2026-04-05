---
description: "Deploy phase. Push to the deployment target, verify it's live, write README."
agent: "agent"
---

Deploy the verified software to its target.

## Steps

1. Read `scaffolding/scope.md` for deployment target
2. Read `scaffolding/design.md` for deployment config details
3. **Pre-flight check** — before attempting deploy, verify access:
   - **GitHub Pages**: `git remote -v` shows a valid remote with push access
   - **fly.io**: `which flyctl` (installed?), `fly auth whoami` (logged in?), `fly.toml` exists
   - **Container registry**: Registry credentials available in env
   - **Any deploy target**: Required env vars / secrets are set (check without printing values)
   - If any pre-flight check fails: STOP. Do not attempt deploy. Report what's missing.
4. Deploy to the specified target:
   - **GitHub Pages**: Build, push to gh-pages branch or configure Actions
   - **fly.io**: `fly deploy` (ensure fly.toml exists)
   - **Container**: Build image, push, deploy
   - **Cron/script**: Set up the schedule, verify it runs
   - **Local/manual**: Document exact run commands
5. Verify it's accessible and working
6. Write `README.md` in the project root with:
   - What this is (one paragraph)
   - How to set up locally
   - How to deploy
   - How to run tests

## Post-Deploy Gate

- [ ] Deployed to specified target
- [ ] Accessible (can reach it, run it, or verify the cron fires)
- [ ] README.md exists with setup + run + deploy instructions
- [ ] If stateful: data persistence verified (can create, read back)

If any gate condition fails, fix it and recheck. Up to 3 retries.

Log the result to `scaffolding/log.md` with URL/access method as evidence.

Git checkpoint:

```
git add -A && git commit -m "chore(deploy): deploy to [target]" -m "[URL or access method]\nGate: post-deploy PASS (attempt N)."
```

**STOP here and report to the user:**

```
✓ FULL PIPELINE COMPLETE.
[URL or access method]
[What was deployed and where]
[Summary of scaffolding/log.md — all phases, all gate results]

Scaffolding in scaffolding/ can be archived whenever you're ready.
```
