#!/usr/bin/env python3
"""Aggregate results/ into a summary table.

A run is **solved** iff:
  * `build_ok` is True,
  * `sorries_remaining` == 0,
  * the LLM judge verdict is "match" or "close".

Outputs:
  - `experiments/summary.csv` — one row per (problem, condition):
      problem_id, category, condition, k, n_solved, mean_wall_s,
      mean_tool_calls
  - stdout: a brief table broken down by category × condition,
    plus paired Wilcoxon (per-problem A vs B solve rates) if scipy
    is installed.

Usage (from repo root):
    python3 experiments/runner/score.py
"""
from __future__ import annotations

import csv
import json
import sys
from collections import defaultdict
from pathlib import Path
from statistics import mean

REPO = Path(__file__).resolve().parents[2]
EXPS = REPO / "experiments"
RESULTS = EXPS / "results"


def is_solved(meta: dict, judge: dict | None) -> bool:
    if not meta.get("build_ok"):
        return False
    if meta.get("sorries_remaining", -1) != 0:
        return False
    if judge is None:
        return False
    return judge.get("verdict") in {"match", "close"}


def collect():
    by_cell = defaultdict(list)  # (problem_id, condition) -> list[run_dict]
    for d in sorted(RESULTS.iterdir()):
        if not d.is_dir():
            continue
        meta_p = d / "meta.json"
        if not meta_p.exists():
            continue
        meta = json.loads(meta_p.read_text())
        judge_p = d / "judge.json"
        judge = json.loads(judge_p.read_text()) if judge_p.exists() else None
        run = {
            "meta": meta,
            "judge": judge,
            "solved": is_solved(meta, judge),
        }
        key = (meta["problem_id"], meta["condition"])
        by_cell[key].append(run)
    return by_cell


def write_csv(by_cell: dict, out: Path) -> None:
    with out.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["problem_id", "category", "condition", "k",
                    "n_solved", "mean_wall_s", "mean_tool_calls"])
        for (pid, cond), runs in sorted(by_cell.items()):
            cat = runs[0]["meta"]["category"]
            k = len(runs)
            n_solved = sum(r["solved"] for r in runs)
            wall = [r["meta"].get("wall_clock_s", 0) for r in runs]
            tools = [r["meta"].get("tool_calls_total", 0) for r in runs]
            w.writerow([pid, cat, cond, k, n_solved,
                        f"{mean(wall):.1f}",
                        f"{mean(tools):.1f}"])
    print(f"Wrote {out.relative_to(REPO)}")


def category_breakdown(by_cell: dict) -> None:
    # (category, condition) -> per-problem solve rates
    bucket = defaultdict(list)
    for (pid, cond), runs in by_cell.items():
        cat = runs[0]["meta"]["category"]
        rate = sum(r["solved"] for r in runs) / max(1, len(runs))
        bucket[(cat, cond)].append((pid, rate))

    print()
    print(f"{'category':<18}{'cond':<6}{'n_problems':<12}"
          f"{'mean_solve_rate':<18}")
    print("-" * 54)
    for (cat, cond), rows in sorted(bucket.items()):
        rates = [r for _, r in rows]
        print(f"{cat:<18}{cond:<6}{len(rates):<12}"
              f"{mean(rates):<18.2f}")


def paired_wilcoxon(by_cell: dict) -> None:
    # Build paired (A, B) per problem.
    pids = sorted({pid for (pid, _) in by_cell.keys()})
    pairs = []
    for pid in pids:
        runs_a = by_cell.get((pid, "A"))
        runs_b = by_cell.get((pid, "B"))
        if not (runs_a and runs_b):
            continue
        ra = sum(r["solved"] for r in runs_a) / len(runs_a)
        rb = sum(r["solved"] for r in runs_b) / len(runs_b)
        pairs.append((pid, ra, rb))
    if not pairs:
        print("\n(No paired data for Wilcoxon)")
        return
    print(f"\nPaired solve-rate comparison (per problem, A vs B):")
    for pid, ra, rb in pairs:
        print(f"  {pid:<10}  A={ra:.2f}  B={rb:.2f}  Δ={rb-ra:+.2f}")
    try:
        from scipy.stats import wilcoxon  # type: ignore
        a = [ra for _, ra, _ in pairs]
        b = [rb for _, _, rb in pairs]
        if a == b:
            print("  Wilcoxon: A==B identically; no test.")
        else:
            stat, p = wilcoxon(b, a, zero_method="wilcox", alternative="two-sided")
            print(f"  Wilcoxon (B vs A): stat={stat:.2f}, p={p:.4g}")
    except ImportError:
        print("  (scipy not installed; install for Wilcoxon.)")


def main():
    by_cell = collect()
    if not by_cell:
        print("No results yet.", file=sys.stderr)
        sys.exit(1)
    write_csv(by_cell, EXPS / "summary.csv")
    category_breakdown(by_cell)
    paired_wilcoxon(by_cell)


if __name__ == "__main__":
    main()
