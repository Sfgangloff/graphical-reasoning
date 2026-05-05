#!/usr/bin/env python3
"""Drive the full (problem × condition × k) matrix.

Reads `experiments/selection.txt` (one problem_id per line, '#' for
comments) and runs each cell sequentially.

Usage (from repo root):
    python3 experiments/runner/run_matrix.py
        [--k 3]
        [--conditions AB]
        [--budget-minutes 30]
        [--budget-calls 80]
        [--selection experiments/selection.txt]
        [--skip-existing]
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from run_one import run_one  # type: ignore

REPO = Path(__file__).resolve().parents[2]
EXPS = REPO / "experiments"


def load_selection(path: Path) -> list[str]:
    out = []
    for line in path.read_text().splitlines():
        s = line.split("#", 1)[0].strip()
        if s:
            out.append(s)
    return out


def already_done(problem_id: str, condition: str, run_index: int) -> bool:
    tag = f"{problem_id.replace('.', '_')}__{condition}__r{run_index}"
    return (EXPS / "results" / tag / "meta.json").exists()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--k", type=int, default=3,
                    help="Runs per (problem, condition) cell")
    ap.add_argument("--conditions", default="AB")
    ap.add_argument("--budget-minutes", type=int, default=30)
    ap.add_argument("--budget-calls", type=int, default=80)
    ap.add_argument("--selection", type=Path,
                    default=EXPS / "selection.txt")
    ap.add_argument("--skip-existing", action="store_true",
                    help="Skip cells whose meta.json already exists")
    args = ap.parse_args()

    problems = load_selection(args.selection)
    conditions = list(args.conditions)
    total = len(problems) * len(conditions) * args.k
    print(f"Matrix: {len(problems)} problems × {len(conditions)} conditions"
          f" × {args.k} runs = {total} attempts.")

    done = 0
    skipped = 0
    for pid in problems:
        for cond in conditions:
            for r in range(args.k):
                done += 1
                if args.skip_existing and already_done(pid, cond, r):
                    skipped += 1
                    print(f"[{done}/{total}] {pid} {cond} r{r} — already done, skipping.")
                    continue
                print(f"[{done}/{total}] {pid} {cond} r{r}")
                try:
                    run_one(pid, cond, r,
                            args.budget_minutes, args.budget_calls)
                except KeyboardInterrupt:
                    print("Interrupted.")
                    sys.exit(1)
                except Exception as e:
                    print(f"  ! exception: {e}")
    print(f"Done. {done - skipped} attempts run, {skipped} skipped.")


if __name__ == "__main__":
    main()
