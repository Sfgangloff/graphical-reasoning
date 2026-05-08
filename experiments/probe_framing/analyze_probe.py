#!/usr/bin/env python3
"""Aggregate probe results: tool invocations per (problem, framing).

Splits tools into families:
  - lean        : mcp__lean-lsp-mcp__*
  - viz         : mcp__math-viz__*
  - compute     : mcp__math-compute__*
  - other-mcp   : any other mcp__*
  - host        : non-MCP tools (Read, Edit, Write, Bash, etc.)

Usage:
    python3 experiments/probe_framing/analyze_probe.py
"""
from __future__ import annotations

import json
import statistics
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
RESULTS = REPO / "experiments" / "probe_framing" / "results"

FRAMINGS = ["probe_prose", "probe_nudge", "probe_lean"]
PROBLEMS = ["1985.B5", "1989.A2", "1996.B2"]


def family_of(tool_name: str) -> str:
    if tool_name.startswith("mcp__lean-lsp-mcp__"):
        return "lean"
    if tool_name.startswith("mcp__math-viz__"):
        return "viz"
    if tool_name.startswith("mcp__math-compute__"):
        return "compute"
    if tool_name.startswith("mcp__"):
        return "other-mcp"
    return "host"


def parse_tag(tag: str) -> tuple[str, str, int] | None:
    parts = tag.split("__")
    if len(parts) != 3:
        return None
    problem = parts[0].replace("_", ".")
    framing = parts[1]
    try:
        run_idx = int(parts[2].lstrip("r"))
    except ValueError:
        return None
    return (problem, framing, run_idx)


def load_runs() -> list[dict]:
    runs = []
    for d in sorted(RESULTS.iterdir() if RESULTS.exists() else []):
        if not d.is_dir():
            continue
        meta_path = d / "meta.json"
        if not meta_path.exists():
            continue
        meta = json.loads(meta_path.read_text())
        parsed = parse_tag(d.name)
        if not parsed:
            continue
        problem, framing, run_idx = parsed
        runs.append({
            "tag": d.name, "problem": problem, "framing": framing,
            "run_index": run_idx, "meta": meta,
        })
    return runs


def family_totals(tool_counts: dict, key: str = "succeeded") -> dict:
    """Sum tool calls per family."""
    out = defaultdict(int)
    for name, cts in tool_counts.items():
        out[family_of(name)] += cts.get(key, 0)
    return dict(out)


def main():
    runs = load_runs()
    if not runs:
        print(f"no runs under {RESULTS}")
        return

    # Per-cell aggregation
    by_cell = defaultdict(list)  # (problem, framing) -> list of run dicts
    for r in runs:
        by_cell[(r["problem"], r["framing"])].append(r)

    # Per-framing aggregation across all problems
    by_framing = defaultdict(list)
    for r in runs:
        by_framing[r["framing"]].append(r)

    # Family columns to display
    families = ["lean", "viz", "compute", "other-mcp", "host"]

    print(f"Probe results: {len(runs)} runs total")
    print(f"  problems: {sorted({r['problem'] for r in runs})}")
    print(f"  framings: {sorted({r['framing'] for r in runs})}\n")

    # Table 1: per-cell mean tool calls by family
    print("== Per-cell mean tool calls (succeeded), by family ==")
    header = f"{'problem':<10} {'framing':<14} {'n':>3} " + \
        " ".join(f"{fam:>9}" for fam in families) + \
        f"  {'total':>7}  {'build_ok':>8}  {'sorries=0':>9}"
    print(header)
    for problem in PROBLEMS:
        for framing in FRAMINGS:
            cell = by_cell.get((problem, framing), [])
            if not cell:
                continue
            n = len(cell)
            fam_means = []
            for fam in families:
                vals = [family_totals(r["meta"]["tool_counts"]).get(fam, 0)
                        for r in cell]
                fam_means.append(statistics.mean(vals) if vals else 0)
            totals = [r["meta"]["tool_calls_succeeded"] for r in cell]
            builds = [bool(r["meta"]["build_ok"]) for r in cell]
            zeros = [r["meta"]["sorries_remaining"] == 0 for r in cell]
            row = (f"{problem:<10} {framing:<14} {n:>3} " +
                   " ".join(f"{m:>9.1f}" for m in fam_means) +
                   f"  {statistics.mean(totals):>7.1f}" +
                   f"  {sum(builds):>4}/{n:<3d}" +
                   f"  {sum(zeros):>4}/{n:<4d}")
            print(row)

    # Table 2: per-framing aggregate (across all 3 problems)
    print("\n== Per-framing aggregate across all problems ==")
    print(f"{'framing':<14} {'n':>3} " +
          " ".join(f"{fam:>9}" for fam in families) +
          f"  {'total':>7}  {'%runs w/viz':>11}  {'%runs w/comp':>12}")
    for framing in FRAMINGS:
        cell = by_framing.get(framing, [])
        if not cell:
            continue
        n = len(cell)
        fam_means = []
        for fam in families:
            vals = [family_totals(r["meta"]["tool_counts"]).get(fam, 0)
                    for r in cell]
            fam_means.append(statistics.mean(vals))
        totals = [r["meta"]["tool_calls_succeeded"] for r in cell]
        any_viz = sum(
            1 for r in cell
            if family_totals(r["meta"]["tool_counts"]).get("viz", 0) > 0)
        any_comp = sum(
            1 for r in cell
            if family_totals(r["meta"]["tool_counts"]).get("compute", 0) > 0)
        print(f"{framing:<14} {n:>3} " +
              " ".join(f"{m:>9.1f}" for m in fam_means) +
              f"  {statistics.mean(totals):>7.1f}" +
              f"  {any_viz}/{n} ({100*any_viz/n:>5.0f}%)" +
              f"  {any_comp}/{n} ({100*any_comp/n:>5.0f}%)")

    # Table 3: per-tool breakdown for general-purpose families
    print("\n== Per-tool counts (succeeded) for non-Lean families, by framing ==")
    for framing in FRAMINGS:
        cell = by_framing.get(framing, [])
        if not cell:
            continue
        per_tool = defaultdict(int)
        for r in cell:
            for name, cts in r["meta"]["tool_counts"].items():
                fam = family_of(name)
                if fam in ("viz", "compute", "other-mcp"):
                    per_tool[name] += cts.get("succeeded", 0)
        if not per_tool:
            print(f"  [{framing}] (no non-Lean tools used)")
            continue
        print(f"  [{framing}]  total non-Lean MCP calls: "
              f"{sum(per_tool.values())}")
        for name, count in sorted(per_tool.items(),
                                  key=lambda kv: -kv[1]):
            print(f"    {count:>4}  {name}")


if __name__ == "__main__":
    main()
