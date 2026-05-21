#!/usr/bin/env python3
"""Aggregate the forced-viz study.

Per (problem, condition) and per-condition:
  - viz invocation rate (any mcp__math-viz__ call)
  - PNG read-back rate (a Read tool_use whose path ends in .png — the
    second half of the plot->Read loop the conditions are testing)
  - build_ok, sorries==0
  - statement-match judge verdict distribution (if judge.json present)
  - self-report viz fields (viz_changed_approach, sample verdicts)

Run judge first if you want the verdict column populated:
    python3 experiments/runner/judge.py \
        --results-root experiments/forced_viz/results

Usage:
    python3 experiments/forced_viz/analyze_forced.py
"""
from __future__ import annotations

import json
import statistics
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
RESULTS = REPO / "experiments" / "forced_viz" / "results"

CONDITIONS = ["b", "vizprimed", "forced"]
PROBLEMS = ["1985.B5", "1989.A2", "1991.A5", "1993.A1", "1996.B2", "2006.A1"]


def family_of(name: str) -> str:
    if name.startswith("mcp__lean-lsp-mcp__"):
        return "lean"
    if name.startswith("mcp__math-viz__"):
        return "viz"
    if name.startswith("mcp__"):
        return "other-mcp"
    return "host"


def parse_tag(tag: str):
    parts = tag.split("__")
    if len(parts) != 3:
        return None
    try:
        run_idx = int(parts[2].lstrip("r"))
    except ValueError:
        return None
    return parts[0].replace("_", "."), parts[1], run_idx


def png_read_back(stream_path: Path) -> bool:
    """True if any Read tool_use targeted a .png path (the loop's
    second step). Robust to stream truncation."""
    if not stream_path.exists():
        return False
    with stream_path.open() as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except json.JSONDecodeError:
                continue
            if ev.get("type") != "assistant":
                continue
            for b in (ev.get("message") or {}).get("content", []) or []:
                if b.get("type") != "tool_use" or b.get("name") != "Read":
                    continue
                path = str((b.get("input") or {}).get("file_path", ""))
                if path.lower().endswith(".png"):
                    return True
    return False


def load_runs():
    runs = []
    for d in sorted(RESULTS.iterdir() if RESULTS.exists() else []):
        if not d.is_dir() or not (d / "meta.json").exists():
            continue
        parsed = parse_tag(d.name)
        if not parsed:
            continue
        problem, condition, run_idx = parsed
        meta = json.loads((d / "meta.json").read_text())
        # Skip limit-poisoned records (claude never really ran: no tool
        # calls, not a real timeout, returned in seconds). These pollute
        # build/sorry/viz aggregates if counted.
        if (meta.get("tool_calls_attempted", 0) == 0
                and not meta.get("claude_timed_out", False)
                and meta.get("wall_clock_s", 0) < 30):
            continue
        judge = None
        if (d / "judge.json").exists():
            judge = json.loads((d / "judge.json").read_text())
        runs.append({
            "tag": d.name, "problem": problem, "condition": condition,
            "run_index": run_idx, "meta": meta, "judge": judge,
            "png_read": png_read_back(d / "claude_stdout.json"),
        })
    return runs


def viz_calls(meta: dict) -> int:
    return sum(c.get("succeeded", 0)
               for n, c in meta["tool_counts"].items()
               if family_of(n) == "viz")


def main():
    runs = load_runs()
    if not runs:
        print(f"no runs under {RESULTS}")
        return

    by_cond = defaultdict(list)
    by_cell = defaultdict(list)
    for r in runs:
        by_cond[r["condition"]].append(r)
        by_cell[(r["problem"], r["condition"])].append(r)

    print(f"forced-viz study: {len(runs)} runs")
    print(f"  problems:   {sorted({r['problem'] for r in runs})}")
    print(f"  conditions: {sorted({r['condition'] for r in runs})}\n")

    print("== Per-condition aggregate ==")
    hdr = (f"{'cond':<11} {'n':>3} {'viz/run':>8} {'%w/viz':>7} "
           f"{'%png-read':>10} {'build_ok':>9} {'sorries=0':>10} "
           f"{'solved*':>8}  judge(m/c/mi/ns)")
    print(hdr)
    for cond in CONDITIONS:
        cell = by_cond.get(cond, [])
        if not cell:
            continue
        n = len(cell)
        vmean = statistics.mean(viz_calls(r["meta"]) for r in cell)
        nviz = sum(1 for r in cell if viz_calls(r["meta"]) > 0)
        npng = sum(1 for r in cell if r["png_read"])
        nbuild = sum(1 for r in cell if r["meta"]["build_ok"])
        nzero = sum(1 for r in cell
                    if r["meta"]["sorries_remaining"] == 0)
        # solved* = build_ok & sorries==0 & judge in {match, close}
        nsolved = sum(
            1 for r in cell
            if r["meta"]["build_ok"]
            and r["meta"]["sorries_remaining"] == 0
            and (r["judge"] or {}).get("verdict") in ("match", "close"))
        jc = defaultdict(int)
        for r in cell:
            jc[(r["judge"] or {}).get("verdict", "—")] += 1
        jstr = (f"{jc.get('match',0)}/{jc.get('close',0)}/"
                f"{jc.get('mismatch',0)}/{jc.get('non-statement',0)}")
        print(f"{cond:<11} {n:>3} {vmean:>8.1f} "
              f"{100*nviz/n:>6.0f}% {100*npng/n:>9.0f}% "
              f"{nbuild:>4}/{n:<4d} {nzero:>4}/{n:<5d} "
              f"{nsolved:>3}/{n:<4d}  {jstr}")

    print("\n== Per-cell (problem × condition): "
          "viz / png-read / build / sorries=0 / judge ==")
    for problem in PROBLEMS:
        for cond in CONDITIONS:
            cell = by_cell.get((problem, cond), [])
            if not cell:
                continue
            n = len(cell)
            nviz = sum(1 for r in cell if viz_calls(r["meta"]) > 0)
            npng = sum(1 for r in cell if r["png_read"])
            nbuild = sum(1 for r in cell if r["meta"]["build_ok"])
            nzero = sum(1 for r in cell
                        if r["meta"]["sorries_remaining"] == 0)
            verds = ",".join(
                (r["judge"] or {}).get("verdict", "—")[:5] for r in cell)
            print(f"  {problem:<9} {cond:<11} n={n} "
                  f"viz={nviz}/{n} png={npng}/{n} "
                  f"build={nbuild}/{n} sorry0={nzero}/{n}  [{verds}]")

    print("\n== Self-report viz fields (forced + vizprimed) ==")
    for cond in ("vizprimed", "forced"):
        cell = by_cond.get(cond, [])
        if not cell:
            continue
        changed = 0
        verdicts = []
        for r in cell:
            sr = r["meta"].get("self_report") or {}
            if sr.get("viz_changed_approach") is True:
                changed += 1
            v = sr.get("viz_verdict")
            if v:
                verdicts.append(f"[{r['problem']}] {v}")
        print(f"  [{cond}] viz_changed_approach=true: "
              f"{changed}/{len(cell)}")
        for v in verdicts[:12]:
            print(f"     • {v}")


if __name__ == "__main__":
    main()
