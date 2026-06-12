#!/usr/bin/env python3
"""Quantify the sampling-fragility *margin* of the geometric corpus.

`verify.py` asserts each problem is "sampling-fragile" as a BINARY
property: at the single naive grid the designer hand-picked, the
forced_textual sampler misses the falsifier. A skeptic can object that
the miss is cherry-picked to that one resolution / alignment, and that
any slightly better-resourced numeric verifier would catch the lie -
which would undermine H8's premise (that forced_visual has a structural
advantage on this corpus because numeric sampling *cannot* easily win).

This script answers the quantitative version: as we scale up the naive
uniform sampler's resolution N (and vary its grid alignment via random
offsets), at what N does it FIRST catch the falsifier?

  - N_any  = smallest N at which >=1 of the tested offsets catches.
  - N_all  = smallest N at which ALL tested offsets catch (robustly
             caught regardless of alignment).

A LARGE N_any means the problem is robustly fragile: even a much
denser uniform numeric check misses the falsifier, so visualization
holds a real structural edge. A SMALL N_any flags a weakness: a
marginally better textual verifier would already win, so the problem
is "heuristic-fragile" (fragile only against the specific naive
strategy in verify.py), not "resolution-fragile".

CPU-only. No agent, no LLM, no network. Run:
    .venv-corpus/bin/python fragility_sweep.py
"""
from __future__ import annotations

import json
import math
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
OUT_JSON = HERE / "fragility_sweep.json"

# Tested alignments: fractions of one grid-cell, to probe whether the
# catch depends on where the grid happens to fall.
OFFSETS = [k / 12.0 for k in range(12)]          # 12 evenly spaced alignments
N_GRID = list(range(3, 401))                     # sweep N = 3 .. 400


# --------------------------------------------------------------------------
# Each `catches(N, off)` returns True if a naive uniform sampler with N
# points and alignment fraction `off in [0,1)` would DETECT the falsifier
# (i.e. the textual verifier would NOT ratify the false claim).
# --------------------------------------------------------------------------
def _uniform_grid(a: float, b: float, N: int, off: float) -> np.ndarray:
    """N points spanning [a, b], shifted by `off` cells, wrapped into [a,b)."""
    step = (b - a) / N
    return a + ((off + np.arange(N)) % N) * step


# geom_01: f - g = 2 (x - 0.43)^2 >= 0, double zero at x=0.43. False claim
# 'f > g strictly'. Caught if any sample has |f-g| < tol.
def catches_01(N: int, off: float) -> bool:
    tol = 1e-3
    x = _uniform_grid(0.0, 1.0, N, off)
    fg = 2.0 * (x - 0.43) ** 2
    return bool(np.any(fg < tol))


# geom_03: f'' = 2 + 0.01*exp(-500 u^2)*(1e6 u^2 - 1000), u=x-0.43. Sharp
# negative dip near 0.43. False claim 'convex'. Caught if any sample f'' < 0.
def catches_03(N: int, off: float) -> bool:
    x = _uniform_grid(-1.0, 1.0, N, off)
    u = x - 0.43
    fpp = 2.0 + 0.01 * np.exp(-500.0 * u**2) * (1.0e6 * u**2 - 1000.0)
    return bool(np.any(fpp < 0.0))


# geom_04: unit disk minus hole r=0.05 at (0.27, 0.13). False claim 'simply
# connected'. Naive N x N containment grid; caught if any grid pt in hole.
def catches_04(N: int, off: float) -> bool:
    g = _uniform_grid(-1.0, 1.0, N, off)
    X, Y = np.meshgrid(g, g)
    in_hole = (X - 0.27) ** 2 + (Y - 0.13) ** 2 < 0.05 ** 2
    return bool(np.any(in_hole))


# geom_06: h = (e^x-1-x-x^2/2) - 0.02*exp(-10000 (x-0.43)^2). Narrow dip
# below 0 near 0.43. False claim 'h >= 0'. Caught if any sample h < 0.
def catches_06(N: int, off: float) -> bool:
    x = _uniform_grid(0.0, 1.0, N, off)
    p = np.exp(x) - 1.0 - x - x**2 / 2.0
    h = p - 0.02 * np.exp(-10000.0 * (x - 0.43) ** 2)
    return bool(np.any(h < 0.0))


# geom_10: f = (x^2-1)(x^2-4) + 3 sin(50x) on [-2.5,2.5], ~47 real zeros.
# False claim 'exactly 4 zeros'. Naive sign-change count on N-pt grid;
# caught only when the count diverges UPWARD past 4 (the sampler starts
# resolving the high-frequency crossings). A count < 4 is mere
# under-sampling and would still mislead about the structure, so it does
# NOT count as catching the '~47 zeros' truth.
def catches_10(N: int, off: float) -> bool:
    x = _uniform_grid(-2.5, 2.5, N, off)
    x = np.sort(x)
    f = (x**2 - 1.0) * (x**2 - 4.0) + 3.0 * np.sin(50.0 * x)
    sign_changes = int(np.sum(f[:-1] * f[1:] < 0.0))
    return sign_changes > 4


CONT = {
    "geom_01": (catches_01, "tangent touch (double root off-grid)"),
    "geom_03": (catches_03, "convexity dip (narrow neg f'')"),
    "geom_04": (catches_04, "disk hole (2D containment)"),
    "geom_06": (catches_06, "inequality dip (narrow neg)"),
    "geom_10": (catches_10, "zero-count (high-freq aliasing)"),
}


def sweep_continuous():
    rows = []
    for name, (fn, desc) in CONT.items():
        n_any = None
        n_all = None
        for N in N_GRID:
            hits = [fn(N, off) for off in OFFSETS]
            frac = sum(hits) / len(hits)
            if n_any is None and frac > 0:
                n_any = N
            if n_all is None and frac == 1.0:
                n_all = N
            if n_all is not None:
                break
        rows.append({
            "problem": name, "desc": desc,
            "N_any": n_any, "N_all": n_all,
            "designer_N": 11 if name != "geom_04" else 5,
        })
    return rows


# --------------------------------------------------------------------------
# geom_05 and geom_09 are NOT uniform-resolution-fragile; their fragility is
# specific to a particular naive *heuristic* (sparse logspace / decimal-h).
# We probe each honestly rather than forcing it into the N-sweep frame.
# --------------------------------------------------------------------------
def probe_05():
    """a_n = 1/n + (1/200) exp(-(n-47)^2/2). Violation: a_47 > a_46.
    Sweep uniform integer strides s, prefix {1, 1+s, ...} up to 200; the
    bump (n=46,47,48) is caught iff the sampled set brackets the rise."""
    def a(n):
        return 1.0 / n + (1.0 / 200.0) * math.exp(-((n - 47) ** 2) / 2.0)

    def caught_by_stride(s):
        ns = list(range(1, 201, s))
        vals = [a(n) for n in ns]
        return any(vals[i] < vals[i + 1] for i in range(len(vals) - 1))

    strides = list(range(1, 11))
    caught = {s: caught_by_stride(s) for s in strides}
    # smallest exhaustive prefix {1..K} that catches (needs to reach 47)
    def caught_by_prefix(K):
        vals = [a(n) for n in range(1, K + 1)]
        return any(vals[i] < vals[i + 1] for i in range(len(vals) - 1))
    min_prefix = next((K for K in range(2, 201) if caught_by_prefix(K)), None)
    return {
        "stride_caught": caught,
        "min_exhaustive_prefix_K": min_prefix,
        "note": ("uniform stride-1 enumeration catches at K=%s; sparse/"
                 "logspace samplers (verify.py uses {1,2,5,10,20,50,100,200}) "
                 "miss it. Fragility is heuristic-specific, not resolution-"
                 "based: a dense integer scan wins." % min_prefix),
    }


def probe_09():
    """Diff-quotient sin(pi/h). verify.py's decimal-h set gives sin(pi/h)=0.
    A GENERIC uniform grid of h in (0, 0.1] is NOT fragile: most h are not
    divisors of pi, so the oscillation is caught immediately. Quantify."""
    def q(h):
        return math.sin(math.pi / h)

    # uniform grid of N h-values in (0, 0.1], catch if any |q| > 0.5
    def caught_uniform(N):
        hs = np.linspace(0.1 / N, 0.1, N)
        return bool(np.any(np.abs(np.sin(np.pi / hs)) > 0.5))

    n_any = next((N for N in range(2, 50) if caught_uniform(N)), None)
    decimal_hs = [0.1, 0.05, 0.025, 0.01, 0.005, 0.001, 0.0005, 0.0001]
    decimal_max = max(abs(q(h)) for h in decimal_hs)
    return {
        "uniform_grid_N_any": n_any,
        "decimal_heuristic_max_abs_q": decimal_max,
        "note": ("the decimal-h heuristic in verify.py gives max|sin(pi/h)|="
                 "%.2e (ratifies false f'(0)=0), but ANY generic uniform "
                 "h-grid catches at N=%s. Fragility is entirely heuristic-"
                 "specific (decimal h are integer multiples of 1/pi's "
                 "denominator); resolution does not help the LIE survive."
                 % (decimal_max, n_any)),
    }


def main():
    cont = sweep_continuous()
    p05 = probe_05()
    p09 = probe_09()

    print("=" * 72)
    print("SAMPLING-FRAGILITY MARGIN — minimum naive-uniform-sampler N to")
    print("catch the falsifier (12 alignments per N, swept N=3..400)")
    print("=" * 72)
    print(f"{'problem':<10}{'designer_N':>11}{'N_any':>8}{'N_all':>8}  desc")
    for r in cont:
        n_any = r["N_any"] if r["N_any"] is not None else ">400"
        n_all = r["N_all"] if r["N_all"] is not None else ">400"
        print(f"{r['problem']:<10}{r['designer_N']:>11}{str(n_any):>8}"
              f"{str(n_all):>8}  {r['desc']}")
    print()
    print("geom_05 (sequence, heuristic-specific):")
    print("  stride_caught:", p05["stride_caught"])
    print("  min exhaustive prefix K to catch:", p05["min_exhaustive_prefix_K"])
    print("  " + p05["note"])
    print()
    print("geom_09 (diff-quotient, heuristic-specific):")
    print("  uniform-grid N_any:", p09["uniform_grid_N_any"])
    print("  decimal-heuristic max|q|:", f"{p09['decimal_heuristic_max_abs_q']:.2e}")
    print("  " + p09["note"])

    summary = {
        "method": ("min uniform-sampler resolution N to catch the falsifier; "
                   "12 grid alignments per N; sweep N=3..400"),
        "continuous": cont,
        "geom_05": p05,
        "geom_09": p09,
    }
    OUT_JSON.write_text(json.dumps(summary, indent=2))
    print(f"\nwrote {OUT_JSON.relative_to(HERE)}")


if __name__ == "__main__":
    main()
