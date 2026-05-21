#!/usr/bin/env python3
"""Aggregate Study 5 (false-claim ablation).

Per (condition × variant): correct-verdict rate (the agent's verdict
matches ground truth), correct-answer rate (in the false variant, did
the agent state the right corrected value), png-read-back rate
(forced_visual only), per-condition tool counts.

Per-cell: each run's verdict / correct_answer / one-line evidence
field (viz_verdict / numeric_verdict / reflection).

Headline question: did forced_visual catch any false claim that
forced_textual or forced_reflection did NOT?
"""
from __future__ import annotations

import json
import os
import re
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
RESULTS = HERE / "results"

CONDITIONS = ["forced_visual", "forced_textual", "forced_reflection"]
PROBLEMS = ["1985.B5", "1991.A5", "1993.A1", "1996.B2"]
VARIANTS = ["true", "false"]

# Canonical correct-answer patterns per problem (the answer the agent
# should commit to in either variant; in the false variant the agent
# also needs verdict=incorrect).
CANON_PATTERNS = {
    "1985.B5": [r"e\^\{?[-−]2a", r"exp\(\s*[-−]\s*2\s*a"],
    "1991.A5": [r"\b1\s*/\s*3\b"],
    "1993.A1": [r"\b4\s*/\s*9\b"],
    # For 1996.B2 the right answer is "lower bound < product < upper",
    # i.e. ((2n-1)/e)^... < ... < ((2n+1)/e)^...
    "1996.B2": [r"\(?\s*2\s*n\s*[-−]\s*1\s*\)?[^<>]{0,40}<",
                r"<[^<>]{0,40}\(?\s*2\s*n\s*\+\s*1"],
}


def parse_tag(name: str):
    # tag = problem__variant__condition__rN
    parts = name.split("__")
    if len(parts) != 4:
        return None
    problem = parts[0].replace("_", ".")
    variant = parts[1]
    condition = parts[2]
    try:
        run = int(parts[3].lstrip("r"))
    except ValueError:
        return None
    return problem, variant, condition, run


def canonical_match(problem: str, answer: str) -> bool:
    pats = CANON_PATTERNS.get(problem)
    if not pats or not answer:
        return False
    # For 1996.B2 the two patterns capture lower-bound-on-left AND
    # upper-bound-on-right — both must match (direction matters).
    # For 1985.B5 the patterns are alternative spellings of e^{-2a}
    # vs exp(-2a) — either one matching suffices.
    op = all if problem == "1996.B2" else any
    return op(re.search(p, answer, re.I) for p in pats)


def grade(cell: dict) -> str:
    """Return one of: CORRECT / WRONG_VERDICT / VERDICT_OK_ANSWER_WRONG /
    MISSING. Ground truth: TRUE→agent should say correct, FALSE→agent
    should say incorrect AND state the canonical answer."""
    sr = cell["meta"].get("self_report") or {}
    v = (sr.get("verdict") or "").strip().lower()
    a = sr.get("correct_answer") or ""
    if not v:
        return "MISSING"
    if cell["variant"] == "true":
        return "CORRECT" if v == "correct" else "WRONG_VERDICT"
    # false variant
    if v == "incorrect":
        return ("CORRECT" if canonical_match(cell["problem"], a)
                else "VERDICT_OK_ANSWER_WRONG")
    return "WRONG_VERDICT"


def load() -> list[dict]:
    out = []
    for d in sorted(RESULTS.iterdir() if RESULTS.exists() else []):
        if not d.is_dir() or not (d / "meta.json").exists():
            continue
        parsed = parse_tag(d.name)
        if not parsed:
            continue
        problem, variant, condition, run = parsed
        meta = json.loads((d / "meta.json").read_text())
        if (meta.get("tool_calls_attempted", 0) == 0
                and not meta.get("claude_timed_out", False)
                and meta.get("wall_clock_s", 0) < 30):
            continue  # poisoned
        out.append({
            "tag": d.name, "problem": problem, "variant": variant,
            "condition": condition, "run": run, "meta": meta,
        })
    return out


def viz_count(meta):
    return sum(c.get("succeeded", 0)
               for n, c in meta.get("tool_counts", {}).items()
               if n.startswith("mcp__math-viz__"))


def compute_count(meta):
    return sum(c.get("succeeded", 0)
               for n, c in meta.get("tool_counts", {}).items()
               if n.startswith("mcp__math-compute__"))


def main():
    cells = load()
    if not cells:
        print("no genuine cells under", RESULTS)
        return
    by_cv = defaultdict(list)  # (condition, variant) -> [cell]
    by_pcv = defaultdict(list)  # (problem, condition, variant) -> [cell]
    for c in cells:
        c["grade"] = grade(c)
        by_cv[(c["condition"], c["variant"])].append(c)
        by_pcv[(c["problem"], c["condition"], c["variant"])].append(c)

    print(f"Study 5 — adversarial sanity check: {len(cells)} genuine cells")
    print(f"  problems: {sorted({c['problem'] for c in cells})}")
    print(f"  conditions: {sorted({c['condition'] for c in cells})}")
    print(f"  variants: {sorted({c['variant'] for c in cells})}\n")

    print("== Per (condition × variant) aggregate ==")
    print(f"{'condition':<20} {'variant':<7} {'n':>3} "
          f"{'CORRECT':>9} {'WRONG_V':>9} {'V_OK_A_X':>9} "
          f"{'MISS':>5} {'viz/r':>7} {'comp/r':>7} {'%png-rb':>8}")
    for cond in CONDITIONS:
        for var in VARIANTS:
            cell = by_cv.get((cond, var), [])
            if not cell:
                continue
            n = len(cell)
            g = {k: sum(1 for c in cell if c["grade"] == k)
                 for k in ["CORRECT", "WRONG_VERDICT",
                          "VERDICT_OK_ANSWER_WRONG", "MISSING"]}
            vz = sum(viz_count(c["meta"]) for c in cell) / max(n, 1)
            cm = sum(compute_count(c["meta"]) for c in cell) / max(n, 1)
            pn = sum(1 for c in cell if c["meta"].get("png_read_back"))
            print(f"{cond:<20} {var:<7} {n:>3} "
                  f"{g['CORRECT']:>9} {g['WRONG_VERDICT']:>9} "
                  f"{g['VERDICT_OK_ANSWER_WRONG']:>9} "
                  f"{g['MISSING']:>5} "
                  f"{vz:>7.1f} {cm:>7.1f} {100*pn/n:>6.0f}%")

    print("\n== Per cell: verdict, correct_answer ==")
    for prob in PROBLEMS:
        for cond in CONDITIONS:
            for var in VARIANTS:
                cs = by_pcv.get((prob, cond, var), [])
                if not cs: continue
                cs.sort(key=lambda c: c["run"])
                verds = []
                for c in cs:
                    sr = c["meta"].get("self_report") or {}
                    v = (sr.get("verdict") or "?")
                    a = (sr.get("correct_answer") or "")[:50]
                    verds.append(f"r{c['run']}:{c['grade'][:4]}/{v}/{a!r}")
                print(f"  {prob:<8} {var:<5} {cond:<20}  "
                      + "  ".join(verds))

    print("\n== Headline test: false claims caught (per condition) ==")
    print(f"{'condition':<20} caught(false)/total  (per-problem)")
    for cond in CONDITIONS:
        falses = [c for c in cells
                  if c["condition"] == cond and c["variant"] == "false"]
        per = {p: 0 for p in PROBLEMS}
        per_n = {p: 0 for p in PROBLEMS}
        for c in falses:
            per_n[c["problem"]] += 1
            if c["grade"] == "CORRECT":
                per[c["problem"]] += 1
        total_caught = sum(per.values())
        total_n = sum(per_n.values())
        pp = ", ".join(f"{p}={per[p]}/{per_n[p]}"
                       for p in PROBLEMS if per_n[p])
        print(f"  {cond:<20} {total_caught}/{total_n}    [{pp}]")

    print("\n== Which problems were caught by SOME conditions but not others? ==")
    # For each (problem, run-index pair), look at the (cond1, cond2)
    # pattern of CORRECT vs not on the false variant.
    for prob in PROBLEMS:
        per_cond = {}
        for cond in CONDITIONS:
            cs = by_pcv.get((prob, cond, "false"), [])
            per_cond[cond] = [c["grade"] == "CORRECT" for c in cs]
        # Did any condition catch this prob that another did not?
        any_caught = {cond: any(per_cond[cond]) for cond in CONDITIONS}
        all_caught = {cond: all(per_cond[cond]) if per_cond[cond] else False
                      for cond in CONDITIONS}
        print(f"  {prob}:  "
              + "  ".join(f"{c}={sum(per_cond[c])}/{len(per_cond[c])}"
                          for c in CONDITIONS)
              + (f"  <- DIVERGENCE" if len(set(any_caught.values())) > 1
                 else ""))

    print("\n== Sample evidence (false variants only) ==")
    for cond in CONDITIONS:
        key = {"forced_visual": "viz_verdict",
               "forced_textual": "numeric_verdict",
               "forced_reflection": "reflection"}[cond]
        print(f"\n  [{cond}] field={key}")
        for c in cells:
            if c["condition"] != cond or c["variant"] != "false":
                continue
            sr = c["meta"].get("self_report") or {}
            ev = sr.get(key, "")
            if not ev: continue
            tag = (f"{c['problem']} r{c['run']} "
                   f"grade={c['grade']} verdict={sr.get('verdict')}")
            print(f"    [{tag}] {ev[:240]}")


if __name__ == "__main__":
    main()
