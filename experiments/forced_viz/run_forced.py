#!/usr/bin/env python3
"""Forced-viz study: 6 viz-friendly problems × 3 conditions × N runs.

Conditions (all share the same tool surface: lean-lsp + math-viz):
  - b          : flat "viz available, optional" prompt  [control;
                 reuses the existing condition_b template/settings].
  - vizprimed  : viz still optional, but the two harness frictions are
                 fixed — top-level "math-viz returns a path you must
                 Read" + a worked plot->Read->conclude primer.
  - forced     : the plot->Read->one-line-verdict loop is a hard
                 requirement before the final Solution.lean.

The only variable across conditions is the prompt. Problem set is held
to the viz-friendly integral/asymptotic subset where the manual pilot
showed visualization was decisive for the answer term.

Results go to experiments/forced_viz/results/<tag>/ (same per-attempt
layout as the main runner, so judge.py --results-root and the analyzer
both work).

Usage (from repo root):
    python3 experiments/forced_viz/run_forced.py                 # full matrix
    python3 experiments/forced_viz/run_forced.py --runs 1         # 1 run/cell
    python3 experiments/forced_viz/run_forced.py --conditions forced
    python3 experiments/forced_viz/run_forced.py --problems 1985.B5
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
CONDITIONS = ["b", "vizprimed", "forced"]
RESULTS_ROOT = REPO / "experiments" / "forced_viz" / "results"


def cell_done(tag: str) -> bool:
    """A cell counts as done only if it has a meta.json AND that record
    is not a catastrophic claude failure (e.g. a usage-limit hit that
    returned in seconds with no tool calls). Poisoned records are
    deleted here so the cell is retried on this run — making the matrix
    robustly resumable across repeated limit interruptions without
    manual cleanup."""
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
    ap.add_argument("--runs", type=int, default=3,
                    help="runs per cell (default 3)")
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
    print(f"forced-viz matrix: {len(cells)} cells "
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
    print(f"\nforced-viz study complete in {(time.time()-t0)/60:.1f} min")


if __name__ == "__main__":
    main()
