#!/usr/bin/env python3
"""Run the framing probe: 3 problems × 3 framings × N runs.

Each cell drops to `experiments/runner/run_one.py`. Results go to
`experiments/probe_framing/results/<tag>/`. The probe varies only the
PROMPT FRAMING — tool surface (lean-lsp + math-viz + math-compute) is
identical across the three framings.

Usage (from repo root):
    python3 experiments/probe_framing/run_probe.py            # full matrix
    python3 experiments/probe_framing/run_probe.py --runs 1   # 1 run/cell
    python3 experiments/probe_framing/run_probe.py --problems 1985.B5
    python3 experiments/probe_framing/run_probe.py --framings probe_lean
"""
from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "experiments" / "runner"))

from run_one import run_one  # noqa: E402


PROBLEMS = ["1985.B5", "1989.A2", "1996.B2"]
FRAMINGS = ["probe_prose", "probe_nudge", "probe_lean"]
RESULTS_ROOT = REPO / "experiments" / "probe_framing" / "results"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--runs", type=int, default=3,
                    help="runs per cell (default 3)")
    ap.add_argument("--budget-minutes", type=int, default=10,
                    help="per-attempt wall-clock budget (default 10)")
    ap.add_argument("--budget-calls", type=int, default=80)
    ap.add_argument("--problems", nargs="+", default=PROBLEMS)
    ap.add_argument("--framings", nargs="+", default=FRAMINGS)
    ap.add_argument("--start-index", type=int, default=0,
                    help="run_index of the first run in each cell")
    args = ap.parse_args()

    cells = [(p, f, r) for p in args.problems for f in args.framings
             for r in range(args.start_index, args.start_index + args.runs)]
    print(f"probe matrix: {len(cells)} cells "
          f"({len(args.problems)} problems × {len(args.framings)} framings "
          f"× {args.runs} runs)  budget={args.budget_minutes}min/cell")
    t0 = time.time()
    for i, (problem, framing, run_idx) in enumerate(cells, 1):
        elapsed = time.time() - t0
        print(f"\n=== cell {i}/{len(cells)}  "
              f"{problem} / {framing} / r{run_idx}  "
              f"(elapsed {elapsed/60:.1f}min) ===")
        try:
            run_one(problem, framing, run_idx,
                    args.budget_minutes, args.budget_calls,
                    results_root=RESULTS_ROOT)
        except SystemExit as e:
            print(f"  cell failed: {e}")
        except Exception as e:
            print(f"  cell errored: {type(e).__name__}: {e}")
    print(f"\nprobe complete in {(time.time()-t0)/60:.1f} min")


if __name__ == "__main__":
    main()
