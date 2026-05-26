# CLAUDE.md

## Project

Test harness for whether autonomous LLM coding agents adopt
visualization tools when those tools are available. Substrate: Lean 4
/ Mathlib formalizations of Putnam real-analysis problems (1985–2025).

## Layout

- `experiments/` — agent rollout harness + per-study runners.
  - `runner/` — core harness (`judge.py`, `setup.sh`).
  - `forced_viz/` — Study 3 (forcing the plot→Read loop).
  - `recall_test/` — Study 4 (zero-tool prose recall, single-shot
    and CoT).
  - `false_claim/` — Study 5 (and Study 6, the n=6 scaled version).
  - `geometric_corpus/` — Study 8 substrate (under construction).
  - `inline_content/` — Study 7 (under construction; needs redesign,
    see *Pending corrections* below).
  - `judge_audit/` — human vs LLM judge calibration tooling.
  - `prompts/`, `settings/`, `workspace_template/` — per-condition
    prompt templates, Claude settings, and a pre-built Mathlib
    workspace.
- `paper/` — long-form draft (`visualization-tools-putnam.md`), AAAI
  2027 submission skeleton (`aaai27/`), publication plan
  (`publication_plan.md`), pre-registration (`pre_registration.md`),
  unattended-Claude setup plan (`unattended_setup_plan.md`).
- `pilot/` — manual interactive sessions used as the positive control
  (Putnam 2025 A-2 and B-2).
- `putnam/` — raw and formalized Putnam problems by year.
- `external/math-reasoning-tools/` — git submodule, pinned to the
  exact MCP-tool commit used by the studies. **Do not edit directly.**

## Conventions

- **Commit style**: short imperative + a one-sentence finding, e.g.
  `"Run forced-viz Study 3 + recall probes (Study 4); reasoning depth
  dominates tool modality."` Match the existing log.
- **Branches**: work on `main` unless a PR is explicitly requested.
- **PRs**: only when the user asks.
- **Submodule**: never modify `external/math-reasoning-tools/`
  directly. If a change is needed, propose it and let the user act
  on the upstream repo.
- **Paper**: the long-form draft is the working diary; the AAAI
  version (`paper/aaai27/`) is the published artifact. Do not try to
  fit the diary into the AAAI page limit.
- **Don't commit**: `.claude/settings.local.json`,
  `.claude/scheduled_tasks.lock`, anything under `.lake/`.

## One-time per-clone setup

```
git config core.hooksPath .githooks
```

This activates the guards in `.githooks/` (`pre-commit`, `pre-push`).

## How to invoke Claude Code on this project

```
cd /path/to/graphical-reasoning
claude
```

`.claude/settings.json` is picked up automatically. Default mode is
`acceptEdits` so edits inside the project don't prompt. Mutating
operations (git commit, push, rm, network calls, dep installs) are in
the `ask` list and will prompt.

For long unattended sessions, no extra flag is needed. Notifications
fire on Stop and on Notification events (macOS only, via osascript;
no-ops on other platforms).

## Pending corrections (do not lose)

1. **Inline-images correction.** `paper/visualization-tools-putnam.md`
   §9.2 ("the agent never actually looked at the pictures") is
   factually wrong. The math-viz upstream switched back to inline
   image content on 2026-05-07 (`1622bac`), so Studies 2–5 all
   received images directly in the tool result. The headline
   negative result is unaffected (actually strengthened). Full
   diagnosis: `paper/unattended_setup_plan.md` §9.

2. **Study 7 redesign — RESOLVED 2026-05-23.** The "inline-content
   fork" was moot; Study 7 has been reframed as a path-only regression
   in `paper/pre_registration.md` and the publication plan.

## Useful files

- `paper/publication_plan.md` — the 13-week AAAI 2027 plan.
- `paper/pre_registration.md` — Studies 6/7/8 + judge audit
  hypotheses; in-repo git history is the timestamping evidence trail
  (no third-party registration; see §7 of that file for rationale).
- `paper/unattended_setup_plan.md` — the agent-safety plan and the
  back-of-mind items.
- `experiments/judge_audit/README.md` — protocol for the 8-hour
  human judge audit.
- `experiments/geometric_corpus/README.md` — protocol for
  constructing the Study 8 corpus.
