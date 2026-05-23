# Starting Claude Code on this project

Quick reference. The full policy lives in `.claude/settings.json`
and `paper/unattended_setup_plan.md`; this file is just the recipe.

## Each session

```
cd /Users/silveregangloff/Desktop/graphical-reasoning
claude
```

That's all. The committed `.claude/settings.json` is picked up
automatically. `defaultMode` is `acceptEdits` so Edit/Write inside
the project does **not** prompt.

## On a fresh clone (one-time)

```
git config core.hooksPath .githooks
```

That activates `.githooks/pre-commit` and `.githooks/pre-push`.
Skip on this machine — it's already a per-clone setting you've set.

## What auto-runs (no prompt)

- All read tools (Read, Grep, ToolSearch, …)
- Read-only Bash: `ls`, `cat`, `head`, `tail`, `wc`, `find`, `grep`,
  `rg`, `du`, `stat`, `pwd`, `echo`, `git status/log/diff/show`,
  `git rev-parse`, `git submodule status`
- Project experiment runners: `python3 experiments/*`,
  `python3 paper/*`
- Lake builds in `experiments/workspace_template/`
- All `mcp__math-*`, `mcp__lean-lsp-mcp__*`,
  `mcp__proof-explorer__*`, `mcp__symdyn-*__*`,
  `mcp__commutative-diagrams__*`, `mcp__meta-tools__*`
- Edit / Write on files inside this project

## What will still prompt (by design)

- `git commit`, `git add`, `git rm`, `git tag`
- `git push`, `git pull`, `git fetch`
- `git checkout`, `git switch`, `git merge`, `git rebase`,
  `git stash`, `git cherry-pick`, `git reset` (non-hard)
- `git submodule add/update/deinit`
- `gh ...`, `curl ...`, `wget ...`
- `rm ...`, `rmdir ...`, `mv ...`
- `pip install`, `uv pip install`, `npm install`, `brew install`,
  `pip uninstall`, `uv pip uninstall`

These are the operations where you usually want a glance before
they happen. Saying "yes" once approves the specific call, not all
future ones.

## What is hard-blocked

You won't see a prompt for these — they're refused outright:

- `sudo`, `su`
- `rm -rf /`, `rm -rf ~`, `rm -rf ..`, `rm -rf .`, `rm -rf *`
- `git push --force` / `git push -f`
- `git reset --hard`
- `git clean -fd` / `git clean -fx`
- `git checkout -- .` / `git checkout -- *`
- `git filter-branch`
- `git config --global ...`
- any `--no-verify` or `--no-gpg-sign` flag
- Edit/Write to `.git/**`, `~/.claude/**`, `/etc/**`,
  `~/.zshrc`, `~/.bashrc`, `~/.profile`
- Edit/Write inside `external/math-reasoning-tools/` (the submodule)
- Non-fast-forward push to `main` / `master`
- Commits of files >5 MB, files matching `*.env`/`*.key`/`*.pem`/
  `*secret*`/`*credential*`, or submodule-internal paths

## Notifications

A macOS notification fires when:
- A turn finishes (results are ready to look at)
- Claude is waiting for input

If they don't show up: **System Settings → Notifications → Script
Editor → Allow Notifications**. The fallback sound is `Pop`.

## Stopping a session

- `Ctrl+C` once → interrupt the current tool/turn.
- `Ctrl+C` twice → exit Claude Code.
- Closing the terminal also works. Todos, transcripts, and the auto-
  resume state persist across sessions.

## If something looks wrong

- A tool unexpectedly *blocked*: check
  `.claude/hooks/pre-bash.sh` or `pre-write.sh` for the matching
  pattern. To loosen for this machine only, add an `allow` entry to
  `.claude/settings.local.json` (gitignored, doesn't propagate).
- A tool unexpectedly *prompted*: it's in the `ask` list of
  `.claude/settings.json`. If you want it auto-allowed permanently,
  move it from `ask` to `allow` in the committed settings (and
  push, so others get the same).
- The git hooks aren't firing on commit/push: run the per-clone
  setup once: `git config core.hooksPath .githooks`.
- Notifications silent: check System Settings → Notifications →
  Script Editor. Or fall back to the terminal — every Stop hook
  also prints `git status --short`.