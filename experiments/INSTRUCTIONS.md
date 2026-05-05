# Running the experiments

Goal: compare Claude Code's ability to **formalize-and-prove** Putnam
real-analysis problems under
* **Condition A** — `lean-lsp` only.
* **Condition B** — `lean-lsp` + `math-viz`.

The hypothesis is that visualization helps on graph-friendly subtopics
(integral-evaluation, integral-inequality, derivative-inequality,
asymptotic, ode, iteration). Design rationale lives in `design.md`;
this file is the operational checklist.

---

## 0. Prerequisites

Verify each is installed and on `$PATH`:

| Tool | Purpose | Check |
| --- | --- | --- |
| `claude` (Claude Code CLI) | runs each attempt | `claude --version` |
| `lake` / `elan` (Lean 4) | builds the candidate solution | `lake --version` |
| `python3` (≥ 3.10) | runner / scoring | `python3 --version` |
| `scipy` (optional) | paired Wilcoxon in scoring | `python3 -c "import scipy"` |

The `lean-lsp-mcp` and `math-viz` MCP servers must be **registered
globally** in your Claude Code config. Source and setup:

> [Sfgangloff/math-reasoning-tools](https://github.com/Sfgangloff/math-reasoning-tools)

Verify with:
```bash
claude mcp list
```
You should see at least `lean-lsp-mcp` (or similarly-named) and
`math-viz` listed.

---

## 1. One-time setup

From the repo root:

```bash
bash experiments/runner/setup.sh
```

This:
1. (Re)builds `experiments/manifest.csv` and per-problem
   `experiments/problem_excerpts/*.tex`.
2. Pre-fetches Mathlib oleans into
   `experiments/workspace_template/.lake/`. Each per-attempt workspace
   then symlinks this directory, so no attempt has to re-download
   Mathlib.

Sanity-check:
```bash
python3 experiments/runner/run_one.py 1985.B5 A 0 --budget-minutes 5
```

You should see `experiments/results/1985_B5__A__r0/` populated with
`Solution.lean`, `meta.json`, `claude_stdout.json`, `build.log`.

---

## 2. Pilot calibration (recommended)

Before committing to the full matrix, run the 5-problem pilot to set a
realistic budget. With `k=1` per cell:

```bash
python3 experiments/runner/run_matrix.py \
    --selection experiments/pilot_selection.txt \
    --k 1 \
    --budget-minutes 30 \
    --budget-calls 80
```

Then judge and score:
```bash
python3 experiments/runner/judge.py
python3 experiments/runner/score.py
```

Inspect `experiments/summary.csv` and the per-attempt
`experiments/results/*/meta.json` to decide:

* What's the actual wall-clock distribution? Is 30 minutes too tight?
* Are tool-call counts close to 80? If so, budget may be the bottleneck.
* Did Claude self-rate budgets correctly (`outcome` field in the
  self-report)?

Adjust `--budget-minutes` and `--budget-calls` for the full run.

---

## 3. Full experiment

```bash
python3 experiments/runner/run_matrix.py \
    --selection experiments/selection.txt \
    --k 3 \
    --budget-minutes <calibrated> \
    --budget-calls <calibrated> \
    --skip-existing
```

This runs 20 problems × 2 conditions × 3 = **120 attempts** sequentially.
`--skip-existing` makes resumption safe (interrupts won't waste prior
work).

---

## 4. Judge & score

```bash
python3 experiments/runner/judge.py        # LLM-judge statement match
python3 experiments/runner/score.py        # aggregate
```

Outputs:
* `experiments/results/<tag>/judge.json` — one per attempt.
* `experiments/summary.csv` — one row per (problem, condition).
* stdout: category × condition solve-rate breakdown + paired Wilcoxon
  (per-problem A vs B).

---

## 5. What "solved" means

A run counts as **solved** iff all three hold:

1. `lake build` returned 0 in the workspace.
2. `Solution.lean` contains zero occurrences of `sorry`.
3. The LLM judge returned `"match"` or `"close"` on the
   statement-vs-LaTeX comparison.

Anything else is `partial` / `failed` / `timeout` (see Claude's
self-report in `meta.json`) but does not count toward the solve rate.

---

## 6. Adjusting the design

* **Different selection of problems**: edit `experiments/selection.txt`.
* **Different conditions** (e.g. add a Condition C with
  math-compute): clone `experiments/settings/condition_b.settings.json`,
  drop the relevant tool prefixes from the deny list, add a matching
  prompt template in `experiments/prompts/`, and pass `--conditions ABC`.
* **Different `k`**: pass `--k N` to `run_matrix.py`.

---

## 7. Cleaning up

Per-attempt workspaces live under `$TMPDIR` (typically `/tmp`) and are
*not* auto-deleted (kept for postmortem). Their paths are recorded in
each attempt's `meta.json["workspace"]`. To purge:

```bash
rm -rf /tmp/exp_*
```

Results in `experiments/results/` are the durable artifact and should
not be deleted unless re-running from scratch.
