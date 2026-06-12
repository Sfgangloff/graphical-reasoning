#!/usr/bin/env python3
"""Content analysis of forced_visual verdict grounding (Studies 5+6).

The cross-study claim (a-0005/a-0006) was that in the forced_visual arm
the agent grounds its verdict in the plot tool's NUMERIC metadata, never
in a visual property "read by eye". That was supported by hand-picked
1985.B5 examples. This script quantifies it across ALL forced_visual
cells by classifying each `viz_verdict` self-report string as:

  - NUMERIC grounding  : cites a concrete scalar value (a decimal number,
                         or an =/≈ comparison of computed magnitudes).
  - RELATIONAL grounding: cites a spatial/ordinal property of the curves
                         ("lies above", "sandwich", "brackets between",
                         "ordering reversed") — the kind of thing a
                         picture conveys but a table of numbers does not.

A verdict may carry BOTH signals. The lexicons are deliberately simple
and printed below so the classification is auditable. This is a keyword
heuristic over 47 short verdict strings, not an LLM grader — read it as
a transparent tally, not a semantic judgment.

NOTE: `png_read_back` (an explicit Read of a .png) is NOT used as a
"did it look" signal: math-viz returns the image inline (CLAUDE.md
correction #1), so a False there does not mean the picture was unseen.
We only analyze the text the agent itself wrote as its verdict.
"""
from __future__ import annotations

import json
import glob
import os
import re
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")

# A decimal number (0.2399, 18.47, 1e-9, -1.2e-17) — the fingerprint of
# a cited scalar magnitude. Bare small integers / "1/3" alone are NOT
# counted as numeric grounding (they are answer labels, not measurements).
NUM_RE = re.compile(r"\d+\.\d+|\d+e[+-]?\d+|≈\s*[-+]?\d|~\s*[-+]?\d", re.I)

# Spatial / ordinal language about the plotted objects.
RELATIONAL_LEX = [
    "above", "below", "lies", "sits", "sandwich", "bracket",
    "between", "on top", "uniformly larger", "far above", "strictly above",
    "separate", "reversed", "ordering", "increasing", "monoton",
    "rises", "rising", "peaks", "topping out", "caps at", "widen",
    "curve", "lobe", "region", "shape", "convex",
]
REL_RE = re.compile("|".join(re.escape(w) for w in RELATIONAL_LEX), re.I)


def genuine(m: dict) -> bool:
    return not (m.get("tool_calls_attempted", 0) == 0
                and not m.get("claude_timed_out", False)
                and m.get("wall_clock_s", 0) < 30)


def main():
    cells = []
    for d in sorted(glob.glob(os.path.join(RESULTS, "*forced_visual*"))):
        if not os.path.isdir(d):
            continue
        m = json.load(open(os.path.join(d, "meta.json")))
        if not genuine(m):
            continue
        sr = m.get("self_report") or {}
        vv = (sr.get("viz_verdict") or "").strip()
        prob = m.get("problem_id")
        var = m.get("variant")
        cells.append({"prob": prob, "var": var, "text": vv,
                      "num": bool(NUM_RE.search(vv)),
                      "rel": bool(REL_RE.search(vv))})

    n = len(cells)
    nonempty = [c for c in cells if c["text"]]
    print(f"forced_visual genuine cells: {n}  (non-empty verdict: {len(nonempty)})")
    print(f"png_read_back is NOT used as a signal (image returned inline).\n")

    print("Lexicon (relational):", ", ".join(RELATIONAL_LEX))
    print('Numeric = matches a decimal/scientific value (e.g. "0.2399", "≈0", "1e-9")\n')

    def cat(c):
        if c["num"] and c["rel"]:
            return "BOTH"
        if c["num"]:
            return "NUMERIC_only"
        if c["rel"]:
            return "RELATIONAL_only"
        return "NEITHER"

    overall = defaultdict(int)
    for c in nonempty:
        overall[cat(c)] += 1
    print("== Overall grounding of verdict text ==")
    for k in ["NUMERIC_only", "RELATIONAL_only", "BOTH", "NEITHER"]:
        print(f"  {k:<16} {overall[k]:>3}/{len(nonempty)}")
    n_num = sum(1 for c in nonempty if c["num"])
    n_rel = sum(1 for c in nonempty if c["rel"])
    print(f"  any-numeric      {n_num:>3}/{len(nonempty)}")
    print(f"  any-relational   {n_rel:>3}/{len(nonempty)}")

    print("\n== By problem (which grounding the verdict uses) ==")
    by_prob = defaultdict(list)
    for c in nonempty:
        by_prob[c["prob"]].append(c)
    print(f"{'problem':<10} {'n':>3} {'numeric':>8} {'relational':>11} {'both':>5}")
    for prob in sorted(by_prob):
        cs = by_prob[prob]
        nn = sum(1 for c in cs if c["num"])
        rr = sum(1 for c in cs if c["rel"])
        bb = sum(1 for c in cs if c["num"] and c["rel"])
        print(f"{prob:<10} {len(cs):>3} {nn:>8} {rr:>11} {bb:>5}")

    print("\nInterpretation: pure-numeric grounding dominates on scalar-answer")
    print("integral problems; the inequality/ordering problem (1996.B2) is")
    print("where verdicts pick up relational curve-position language.")


if __name__ == "__main__":
    main()
