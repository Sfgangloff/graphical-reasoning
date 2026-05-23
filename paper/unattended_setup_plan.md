# Unattended-Claude-Code setup plan

**Goal:** run Claude Code on this repo in long sessions without
constant permission prompts, while preventing it from doing anything
unexpected, destructive, or out-of-scope. Configuration must travel
with the repo so it isn't lost.

**Status:** plan only, not yet implemented. Review and approve before
I commit any of this.

## 1. Current state audit (2026-05-22)

- `.claude/settings.local.json` exists but contains only one allow
  entry (`mcp__lean-lsp-mcp__lean_diagnostic_messages`).
- `.claude/scheduled_tasks.lock` exists (runtime state).
- `.git/hooks/` contains only the default `*.sample` files; no
  active git hook is set up.
- No `CLAUDE.md` at the repo root.
- No `.githooks/` directory.

**If you have an existing git hook I missed, tell me where it lives —
this plan currently assumes nothing is set up.**

## 2. Goals, restated

| Goal | Mechanism |
|---|---|
| Don't constantly ask for permissions on routine operations | `.claude/settings.json` allow-list |
| Block destructive or out-of-scope actions | `.claude/settings.json` deny-list + `.claude/hooks/` PreToolUse filter |
| Protect git history specifically | `.githooks/` pre-commit + pre-push |
| Keep the repo orderly (no garbage in root, no .env leaks, …) | git hooks + a Stop hook that lists changes |
| Configuration travels with the repo | commit `.claude/settings.json`, `.claude/hooks/`, `.githooks/`, `CLAUDE.md` |
| Restrict Claude to this folder | invoke from project root; do not set `additionalDirectories` |

## 3. Five-layer architecture

Defense in depth. Each layer can catch what the layer above missed.

```
Layer 1: working-directory constraint   (invocation)
Layer 2: settings.json permissions       (allow/ask/deny lists)
Layer 3: .claude/hooks (PreToolUse...)   (programmatic filter)
Layer 4: .githooks (pre-commit, ...)     (last line before git mutation)
Layer 5: CLAUDE.md guidance              (model-side intent)
```

### Layer 1 — Working-directory constraint

Claude Code, by default, only reads/writes within the directory you
invoke it from. We rely on this and **do not** set
`additionalDirectories` in any settings file. PNGs that math-viz
writes to `/tmp` are not accessed by Claude Code directly anymore
(math-viz now returns images inline as MCP content blocks — see
correction notes in §9 of this plan).

The experiment runners do read/write `/tmp` workspaces, but they do
so as Python subprocesses that the OS — not Claude Code's permission
system — governs.

### Layer 2 — settings.json permissions

Two files:

- `.claude/settings.json` (**committed**) — the project policy
  everyone gets when they clone the repo.
- `.claude/settings.local.json` (**gitignored**) — per-clone
  overrides if the user wants more leniency for their own machine.

The committed `settings.json` proposed structure (verbatim draft):

```jsonc
{
  "$schema": "https://schemas.anthropic.com/claude-code-settings.json",
  "permissions": {
    "defaultMode": "acceptEdits",
    "additionalDirectories": [],
    "allow": [
      // --- read-only shell inspections ---
      "Bash(ls *)", "Bash(cat *)", "Bash(head *)", "Bash(tail *)",
      "Bash(wc *)", "Bash(find *)", "Bash(grep *)", "Bash(rg *)",
      "Bash(file *)", "Bash(du *)", "Bash(df *)", "Bash(stat *)",
      "Bash(which *)", "Bash(pwd)", "Bash(echo *)",

      // --- read-only git ---
      "Bash(git status*)", "Bash(git log*)", "Bash(git diff*)",
      "Bash(git show*)", "Bash(git branch*)",
      "Bash(git config --get*)", "Bash(git ls-files*)",
      "Bash(git submodule status*)", "Bash(git rev-parse*)",

      // --- experiment runners (in-repo) ---
      "Bash(python3 experiments/*)",
      "Bash(python3 paper/*)",

      // --- lean tooling (build + env inspect, scoped to template) ---
      "Bash(lake env*)", "Bash(lean --version)",
      "Bash(cd experiments/workspace_template && lake build*)",

      // --- python env management when scoped to project ---
      "Bash(python3 -m venv .venv*)",
      "Bash(.venv*/bin/pip install*)",
      "Bash(.venv*/bin/python3 *)",

      // --- our MCP tools, in full ---
      "mcp__math-viz__*",
      "mcp__math-compute__*",
      "mcp__math-search__*",
      "mcp__lean-lsp-mcp__*",
      "mcp__proof-explorer__*",
      "mcp__commutative-diagrams__*",
      "mcp__meta-tools__*",
      "mcp__symdyn-*__*"
    ],
    "ask": [
      // --- mutating git ---
      "Bash(git commit*)", "Bash(git add*)", "Bash(git rm*)",
      "Bash(git mv*)", "Bash(git tag*)",
      "Bash(git push*)", "Bash(git pull*)", "Bash(git fetch*)",
      "Bash(git checkout*)", "Bash(git switch*)",
      "Bash(git merge*)", "Bash(git rebase*)",
      "Bash(git stash*)", "Bash(git cherry-pick*)",
      "Bash(git submodule add*)", "Bash(git submodule update*)",

      // --- external state ---
      "Bash(gh *)",
      "Bash(curl *)", "Bash(wget *)",

      // --- deletion that could lose work ---
      "Bash(rm *)", "Bash(rmdir *)",

      // --- dep installation ---
      "Bash(pip install*)", "Bash(uv pip install*)",
      "Bash(npm install*)", "Bash(brew install*)"
    ],
    "deny": [
      "Bash(sudo *)", "Bash(su *)",
      "Bash(rm -rf /*)", "Bash(rm -rf ~*)", "Bash(rm -rf ..*)",
      "Bash(git push --force*)", "Bash(git push -f *)",
      "Bash(git reset --hard*)",
      "Bash(git clean -fd*)", "Bash(git clean -fx*)",
      "Bash(git checkout -- .)", "Bash(git checkout -- *)",
      "Bash(git filter-branch*)",
      "Bash(git config --global*)",
      "Bash(* --no-verify*)",
      "Bash(* --no-gpg-sign*)",
      "Edit(.git/**)", "Write(.git/**)",
      "Edit(~/.claude/**)", "Write(~/.claude/**)",
      "Edit(~/.zshrc)", "Edit(~/.bashrc)", "Edit(~/.profile)",
      "Edit(/etc/**)", "Write(/etc/**)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-bash.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-write.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/on-stop.sh"
          }
        ]
      }
    ]
  }
}
```

### Layer 3 — `.claude/hooks/` (programmatic filter)

Three small bash scripts under `.claude/hooks/`:

**`pre-bash.sh`** — second-line filter on bash commands. JSON input
on stdin, exit code controls allow/deny.

Blocks:
- `rm -rf` with `/`, `~`, `..`, or `*` as the root target.
- `git push --force`, `git push -f`.
- `git reset --hard`, `git clean -fd`, `git clean -fx`.
- `--no-verify` and `--no-gpg-sign` anywhere on the command line.
- `cd ` followed by `/` or `..` (escaping the project).
- `chmod 777`, `chmod -R 777`.

Returns `{"decision": "block", "reason": "..."}` JSON to Claude on
deny; exits 0 silently to allow.

**`pre-write.sh`** — second-line filter on `Edit`/`Write` tool calls.

Blocks:
- File paths outside `$CLAUDE_PROJECT_DIR` (resolved via `realpath`).
- Paths inside `.git/` (except `.git/info/exclude` which is a legit
  edit target).
- Paths inside `external/math-reasoning-tools/` — that's a submodule;
  the agent should request a redesign rather than editing it
  directly.

**`on-stop.sh`** — Stop hook. Runs `git status --short` and prints
a one-line summary of file changes since the session started.
Provides a clear audit trail.

The hook scripts are short (~30–50 lines each), POSIX-bash, deps:
`jq`, `realpath`. Both come standard on macOS via Homebrew.

### Layer 4 — `.githooks/` (last line before git mutation)

Stored under tracked `.githooks/` (not `.git/hooks/`), wired up by:

```
git config core.hooksPath .githooks
```

**Per-clone setup**: the README will document this. (Git does not
allow `core.hooksPath` to be set via a tracked file alone — there's
no way around the per-clone step.)

Proposed hooks:

**`.githooks/pre-commit`** — block:
- Staged files >5MB.
- Staged files matching `*.env`, `*.key`, `*secret*`,
  `*credentials*`, `*.pem`.
- Staged files inside `external/math-reasoning-tools/` (submodule
  contents must be committed in the submodule).
- Trailing whitespace and empty merge-conflict markers (warning, not
  block).

**`.githooks/pre-push`** — block:
- `git push --force` / `git push -f` to `main` or `master`.
- Direct push of >50 commits in one go (almost always wrong).

Both hooks exit 0 on pass, non-zero with a clear error on block.

### Layer 5 — `CLAUDE.md` (model-side intent)

At repo root. Short — under 100 lines. Contents:

- Project one-liner ("test harness for advertised-tool adoption with
  Lean / Putnam formalizations").
- File layout (what lives under `experiments/`, `paper/`, `pilot/`,
  `putnam/`, `external/`).
- Commit message style (match recent log: short imperative + short
  finding line).
- Submodule rule: don't touch `external/math-reasoning-tools/`
  directly; if a change is needed, propose it.
- Branch rule: work on `main`; PRs only when explicitly requested.
- Paper rule: the long-form draft lives at
  `paper/visualization-tools-putnam.md`; the AAAI submission lives
  at `paper/aaai27/main.tex`.
- Pending corrections (so future-Claude sees them):
  - Inline-images correction (math-viz returns images inline as of
    commit `1622bac`; §9.2 of the long-form draft is wrong; see
    §9 of this plan).
  - Study 7 needs a redesign (path-only regression, not
    inline-content fork).

## 4. What gets committed vs. ignored

### Commit

- `.claude/settings.json` (the policy)
- `.claude/hooks/pre-bash.sh`
- `.claude/hooks/pre-write.sh`
- `.claude/hooks/on-stop.sh`
- `.githooks/pre-commit`
- `.githooks/pre-push`
- `CLAUDE.md` (project guidance)
- `paper/unattended_setup_plan.md` (this doc)

### Add to `.gitignore`

```
# Claude Code per-machine state
.claude/settings.local.json
.claude/scheduled_tasks.lock
.claude/ide/
.claude/cache/
.claude/paste-cache/
.claude/history.jsonl

# But explicitly track committed parts of .claude/
!.claude/settings.json
!.claude/hooks/
```

Note: a `.claude/` blanket-ignore in `.gitignore` would block the
files we want to commit. The pattern above is "ignore specific
per-machine subpaths, allow the rest."

## 5. How to invoke Claude Code after this is in place

**One-time setup per clone** (this is the only step that can't be
automated by the repo, because `core.hooksPath` is a per-clone
setting):

```
git config core.hooksPath .githooks
```

The repo's CLAUDE.md and the README will say this out loud.

**Each session, restricted to this folder**:

```
cd /Users/silveregangloff/Desktop/graphical-reasoning
claude
```

That is enough. The defaults give cwd-only access, and the committed
`settings.json` picks up automatically.

**For long unattended runs**, default mode is `acceptEdits` (set in
the committed `settings.json`). If you want even less prompting:

```
claude --permission-mode acceptEdits   # already the project default
```

We deliberately do **not** recommend `--dangerously-skip-permissions`
because it bypasses every layer we just built.

For a truly headless batch run:

```
claude --print --output-format text "Run Study 6 and report progress"
```

(Combined with the `ask`-list, this still asks for git mutations,
which you'll see when you check back. For full automation of a
specific known-safe task, write a one-off script that calls `claude
--print` with the explicit prompt.)

## 6. Verification recipe

After implementation, run these 6 checks before turning the agent
loose unattended. Each should produce the documented behavior.

| Check | Expected |
|---|---|
| `claude --print "Show git status"` | auto-approves, runs, prints |
| `claude --print "Read paper/visualization-tools-putnam.md"` | auto-approves |
| `claude --print "Run rm -rf /tmp/foo"` | hook blocks before tool runs |
| `claude --print "Edit ~/.zshrc to add an alias"` | denied by both settings.json deny + pre-write.sh |
| `claude --print "Commit a change to README.md"` | settings.json `ask`-list prompts for `git commit` |
| Try `git commit` with a 10MB binary staged | `.githooks/pre-commit` blocks |

## 7. Risks and what *won't* be caught

Honest list:

- **Subprocess escape.** Anything Claude runs *via* a shell command
  can spawn a subprocess that does what it wants (e.g.
  `python -c "import os; os.unlink('/some/file')"`). We allow
  `python3 experiments/*` so a malicious script in
  `experiments/` could do harm. The defense here is reading the
  scripts Claude writes before running them — we cannot statically
  block this.
- **Side-effects of MCP tools.** Our MCP tools are allowed in full.
  We trust them. A malicious MCP server we don't control would be a
  problem; pin via the submodule (already done).
- **Network exfiltration via allowed tools.** `mcp__math-search__*`
  hits the network. A compromised search server could exfiltrate via
  query strings. Mitigation: the submodule pin.
- **`acceptEdits` mode autoaccepts edits.** If you want every edit
  to prompt, switch the project default to `default` or remove
  `defaultMode` from `settings.json`. Trade-off: more prompting.

## 8. Implementation order (when approved)

1. Draft and commit:
   - `.claude/settings.json`
   - `.claude/hooks/{pre-bash,pre-write,on-stop}.sh`
   - `.githooks/{pre-commit,pre-push}`
   - `CLAUDE.md`
   - `.gitignore` updates
2. Verify all 6 checks in §6.
3. Document the `core.hooksPath` step in the README.
4. Resume the AAAI-2027 work plan from where we paused (see §9).

## 9. Back-of-mind reminders (preserved here so they aren't lost)

While drafting this setup we found two items that need attention
*after* the setup is in place:

1. **Inline-images correction.** `math-viz` upstream switched back
   to returning images inline (commit `1622bac` on 2026-05-07).
   Studies 2–5 all ran *after* this switch. So §9.2 of
   `paper/visualization-tools-putnam.md` ("the agent never actually
   looked at the pictures") is factually wrong — the agent received
   inline image content. Verified by inspecting transcripts. The
   §8.1 finding ("PNG read-back rate = 0%") is correct but
   irrelevant for those studies (no second step is needed). The
   *headline negative finding* (zero voluntary adoption) gets
   stronger, since it persists even with inline images.
2. **Study 7 redesign.** The proposed "inline-content fork" is now
   moot — upstream already returns inline content. Study 7 must be
   redesigned as a *path-only regression*: build a wrapper that
   strips the inline `Image` block from the tool result, leaving
   only the path; compare against the current inline behavior. The
   pre-registration in `paper/pre_registration.md` needs to be
   revised before it is posted to OSF.

These two items belong in the next iteration of the publication
plan, after the unattended setup is in place.
