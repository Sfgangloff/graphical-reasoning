#!/usr/bin/env python3
"""Study 7 — inline-content ablation (Putnam Lean formalization task).

2 x 2 = {forced, optional} x {inline (upstream math-viz), path-only
(math-viz-path-only wrapper)} across the 6 Study-3 problems x 6 runs
per cell = 144 cells. Conditions resolve via the generic harness in
experiments/runner/run_one.py to the per-condition prompt and
settings files in experiments/prompts/ and experiments/settings/.

Primary outcome (H7a from paper/pre_registration.md): voluntary
math-viz adoption rate in `optional_inline` vs `optional_path_only`.
Secondary outcome (H7b): conditional on adoption, fraction of
verdicts referencing image features vs metadata-only features.

The forced_* arms exist to (a) hold tool-side mechanics fixed across
agents that don't volunteer to use viz at all, and (b) feed the H7b
coding sample.

Usage (from repo root):
    python3 experiments/inline_content/run_inline_content.py
    python3 experiments/inline_content/run_inline_content.py --runs 1
    python3 experiments/inline_content/run_inline_content.py \\
        --problems 1985.B5 --conditions optional_inline

Prerequisite: `math-viz-path-only` must be registered as an MCP
server in Claude Code's config (typically ~/.claude.json or a
project-local .mcp.json). See experiments/inline_content/
register_mcp.py for a one-shot helper.
"""
from __future__ import annotations

import argparse
import json
import shutil
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "experiments" / "runner"))

from run_one import run_one  # noqa: E402

PROBLEMS = ["1985.B5", "1989.A2", "1991.A5", "1993.A1", "1996.B2", "2006.A1"]
CONDITIONS = [
    "forced_inline",
    "forced_path_only",
    "optional_inline",
    "optional_path_only",
]
RESULTS_ROOT = REPO / "experiments" / "inline_content" / "results"


def cell_done(tag: str) -> bool:
    """Match forced_viz's cell_done: detect catastrophic claude failures
    (instant 429 with no tool calls) and delete the record so the cell
    is retried on the next launch."""
    meta_p = RESULTS_ROOT / tag / "meta.json"
    if not meta_p.exists():
        return False
    try:
        m = json.loads(meta_p.read_text())
    except Exception:
        shutil.rmtree(RESULTS_ROOT / tag, ignore_errors=True)
        return False
    poisoned = (m.get("tool_calls_attempted", 0) == 0
                and not m.get("claude_timed_out", False)
                and m.get("wall_clock_s", 0) < 30)
    if poisoned:
        print(f"  poisoned record ({tag}) — deleting, will retry.")
        shutil.rmtree(RESULTS_ROOT / tag, ignore_errors=True)
        return False
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--runs", type=int, default=6,
                    help="runs per cell (default 6, per pre-registration)")
    ap.add_argument("--budget-minutes", type=int, default=12,
                    help="per-attempt wall-clock budget (default 12)")
    ap.add_argument("--budget-calls", type=int, default=80)
    ap.add_argument("--problems", nargs="+", default=PROBLEMS)
    ap.add_argument("--conditions", nargs="+", default=CONDITIONS)
    ap.add_argument("--start-index", type=int, default=0,
                    help="run_index of the first run in each cell")
    args = ap.parse_args()

    cells = [(p, c, r)
             for p in args.problems
             for c in args.conditions
             for r in range(args.start_index, args.start_index + args.runs)]
    print(f"inline-content matrix: {len(cells)} cells "
          f"({len(args.problems)} problems × {len(args.conditions)} "
          f"conditions × {args.runs} runs)  "
          f"budget={args.budget_minutes}min/cell")
    t0 = time.time()
    for i, (problem, condition, run_idx) in enumerate(cells, 1):
        elapsed = time.time() - t0
        print(f"\n=== cell {i}/{len(cells)}  "
              f"{problem} / {condition} / r{run_idx}  "
              f"(elapsed {elapsed/60:.1f}min) ===")
        tag = f"{problem.replace('.', '_')}__{condition}__r{run_idx}"
        if cell_done(tag):
            print(f"  already done ({tag}), skipping.")
            continue
        try:
            run_one(problem, condition, run_idx,
                    args.budget_minutes, args.budget_calls,
                    results_root=RESULTS_ROOT)
        except SystemExit as e:
            print(f"  cell failed: {e}")
        except Exception as e:
            print(f"  cell errored: {type(e).__name__}: {e}")
    print(f"\ninline-content study complete in {(time.time()-t0)/60:.1f} min")


if __name__ == "__main__":
    main()
