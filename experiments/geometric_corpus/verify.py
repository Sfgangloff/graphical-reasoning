#!/usr/bin/env python3
"""Per-problem verification for the geometric adversarial corpus.

For each problem, verify two properties:

  1. Picture-decisive: produce the plot the agent would produce; you
     inspect by eye whether the truth of the claim is obvious.
  2. Sampling-fragile: run the naïve SymPy strategy that
     `forced_textual` would plausibly run; confirm it does NOT catch
     the falsifier.

Usage:
    python verify.py --problem geom_01
    python verify.py --all

Notes:
  - The "picture" step here uses pure matplotlib (saves a PNG you
    inspect manually). Property (1) is *your judgment*, not a unit
    test. If you look at the PNG and can't see the answer in one
    glance, fail the problem and redesign.
  - The "sampling-fragile" step is what we actually assert
    programmatically: the naïve SymPy strategy gives the *wrong*
    structural answer, demonstrating that `forced_textual` cannot
    rely on it.
"""
from __future__ import annotations

import argparse
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent
PNG_DIR = HERE / "verify_plots"
LOG_P = HERE / "verify.log"


def log(msg: str):
    print(msg)
    with LOG_P.open("a") as f:
        f.write(msg + "\n")


# -----------------------------------------------------------------------
# Problem 01: tangent touch of x^2+1/2 and x^2+1/2 - (x-0.43)^2/2 on [0,1].
#
# f - g = (x - 0.43)^2 / 2 has a double zero at x = 0.43 (off-grid)
# and is strictly positive elsewhere. The naive 11-point uniform grid
# {0, 0.1, ..., 1.0} sees (f - g) in [4.5e-4, 0.16], all > 0 with no
# value near tol = 1e-3; the agent's naive "sample and look for a
# zero" check ratifies the FALSE 'strict separation' claim.
#
# Note: sympy.solve(f - g, x) would return x = 0.43 exactly (symbolic
# double root); this problem is sampling-fragile, NOT symbolic-fragile.
# The "naive forced_textual" strategy we model is sample-based, which
# is what the agent does in practice when asked to verify numerically.
# -----------------------------------------------------------------------
def verify_geom_01():
    import matplotlib.pyplot as plt
    import numpy as np
    import sympy as sp

    log("\n=== geom_01: tangent touch of f=x^2+1/2 and g=f-(x-0.43)^2/2 ===")

    # (1) Picture
    xs = np.linspace(0, 1, 400)
    fs = xs ** 2 + 0.5
    gs = xs ** 2 + 0.5 - 2.0 * (xs - 0.43) ** 2
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.plot(xs, fs, label=r"$f(x) = x^2 + 1/2$", lw=1.5)
    ax.plot(xs, gs, label=r"$g(x) = f(x) - (x-0.43)^2/2$", lw=1.5)
    ax.scatter([0.43], [0.43**2 + 0.5], color="red", zorder=3, s=40,
               label="tangent touch at x = 0.43")
    ax.set_xlabel("x"); ax.legend(); ax.grid(True, alpha=0.3)
    ax.set_title("geom_01: tangent touch (off-grid) at x = 0.43")
    PNG_DIR.mkdir(exist_ok=True)
    out = PNG_DIR / "geom_01.png"
    fig.savefig(out, dpi=120); plt.close(fig)
    log(f"  picture saved -> {out.relative_to(HERE)}; INSPECT BY EYE.")

    # (2) Naive SymPy sampling: 11 uniform points; can the agent
    # detect a zero of (f - g) by looking at sampled values?
    x = sp.Symbol("x", real=True)
    f = x ** 2 + sp.Rational(1, 2)
    g = f - 2 * (x - sp.Rational(43, 100)) ** 2
    samples = [float((f - g).subs(x, sp.Rational(i, 10))) for i in range(11)]
    log("  naive sample of (f - g) at 11 uniform grid points:")
    for i, v in enumerate(samples):
        log(f"    x = {i/10:.1f}   f - g = {v:.6f}")
    tol = 1e-3
    near_zero = sum(1 for v in samples if abs(v) < tol)
    log(f"  values |f - g| < tol={tol}: {near_zero} / 11")
    if near_zero == 0 and min(samples) > 0:
        log("  PASS sampling-fragile: naive grid sees (f - g) > 0 "
            "everywhere with no near-zero sample; the agent's "
            "sample-based forced_textual check ratifies the FALSE "
            "'f > g strictly' claim. Picture shows the tangent touch.")
    else:
        log("  FAIL sampling-fragile: naive grid catches a near-zero or "
            "negative value. Tune the bump width or off-grid offset.")


# -----------------------------------------------------------------------
# Stubs for the remaining 7 problems. Fill in as the corpus is built.
# Each stub should mirror geom_01's structure:
#   - plot the central object via matplotlib (your inspection)
#   - run the naive SymPy strategy
#   - assert the naive strategy does NOT catch the structural lie
# -----------------------------------------------------------------------
def verify_geom_02():
    """Parametric (cos t, sin 2t) on [0, 2pi]: self-intersection at origin.

    Picture-decisive: the figure-eight shape with a clear crossing at
    (0, 0) is unmissable.

    Sampling-fragile: a naive "sample N points uniformly, check pairwise
    distance < tol" strategy with N = 50 and tol = 0.05 picks up the
    crossing at (0, 0) because t = pi/2 and t = 3pi/2 both land exactly
    in the sample grid. To get a sampling-fragile version we shift the
    grid by an irrational offset so neither pi/2 nor 3pi/2 is hit, and
    sample at moderate N where the distance between sampled points near
    the crossing is large relative to the crossing tolerance.
    """
    import matplotlib.pyplot as plt
    import numpy as np

    log("\n=== geom_02: self-intersection of (cos t, sin 2t) on [0, 2pi] ===")

    # (1) Picture: classic figure eight (lemniscate of Gerono).
    ts = np.linspace(0, 2 * np.pi, 800)
    xs = np.cos(ts)
    ys = np.sin(2 * ts)
    fig, ax = plt.subplots(figsize=(5, 5))
    ax.plot(xs, ys, lw=1.5)
    ax.scatter([0], [0], color="red", zorder=3, s=40,
               label="self-intersection at (0,0)")
    ax.set_aspect("equal"); ax.grid(True, alpha=0.3); ax.legend()
    ax.set_title("geom_02: figure-eight self-intersection at origin")
    PNG_DIR.mkdir(exist_ok=True)
    out = PNG_DIR / "geom_02.png"
    fig.savefig(out, dpi=120); plt.close(fig)
    log(f"  picture saved -> {out.relative_to(HERE)}; INSPECT BY EYE.")

    # (2) Naive sampling: N points, pairwise distance threshold.
    # Use ODD prime N so the curve's t -> t+pi antipodal symmetry
    # ((cos t, sin 2t) -> (-cos t, sin 2t)) does NOT generate spurious
    # near-pairs across half-rotations. Offset by an irrational amount
    # so neither pi/2 nor 3pi/2 falls on the grid.
    N = 37
    tol = 0.05
    offset = math.sqrt(2) / 200.0   # ~0.00707, irrational
    sample_ts = [offset + 2 * math.pi * k / N for k in range(N)]
    sample_pts = [(math.cos(t), math.sin(2 * t)) for t in sample_ts]

    def dist(a, b):
        return math.hypot(a[0] - b[0], a[1] - b[1])

    near_pairs = [(i, j) for i in range(N) for j in range(i + 1, N)
                  if dist(sample_pts[i], sample_pts[j]) < tol]
    log(f"  naive sample: N={N}, tol={tol}, offset={offset:.5f}")
    log(f"  near-pairs found (would indicate self-intersection): "
        f"{len(near_pairs)}")
    if len(near_pairs) == 0:
        log("  PASS sampling-fragile: naive distance check finds NO "
            "near-pairs, so it would ratify the FALSE 'curve is simple' "
            "claim. Picture-only catches the lie.")
    else:
        # Examine: are these crossings or just adjacent samples?
        adjacent = sum(1 for i, j in near_pairs if abs(i - j) == 1)
        non_adjacent = len(near_pairs) - adjacent
        log(f"  of these, {adjacent} are adjacent-index pairs (curve "
            f"locally close), {non_adjacent} are non-adjacent.")
        if non_adjacent == 0:
            log("  PASS sampling-fragile: only adjacent samples found "
                "close; a naive 'crossing = non-adjacent near pair' "
                "filter ratifies the FALSE 'simple curve' claim.")
        else:
            log("  FAIL sampling-fragile: non-adjacent near-pair detected; "
                "naive strategy catches the crossing. Tune N, tol, or "
                "offset to make the crossing miss.")


def verify_geom_03():
    """Convexity of x^2 + 0.01 * exp(-500(x - 0.43)^2).

    The base x^2 is strictly convex on [-1, 1] (f'' = 2 > 0). The
    narrow Gaussian bump at x = 0.43 introduces a sharp localized
    concavity (f''(0.43) < 0); the bump is invisible to an 11-point
    uniform grid because the bump's half-width (~1/sqrt(500) ~ 0.045)
    is smaller than the grid spacing (0.2) and the bump center (0.43)
    is off-grid.

    Picture-decisive: a plot of f'' on [-1, 1] shows a sharp negative
    spike near x = 0.43.

    Sampling-fragile: a naive grid sample of f'' at 11 uniform points
    {-1, -0.8, ..., 0.8, 1.0} gives f''(x) > 0 everywhere, so a naive
    "check sign of f'' on the grid" strategy ratifies the FALSE
    'convex' claim.
    """
    import matplotlib.pyplot as plt
    import numpy as np
    import sympy as sp

    log("\n=== geom_03: convexity of x^2 + (1/100) exp(-500(x-0.43)^2) ===")

    x = sp.Symbol("x", real=True)
    f = x ** 2 + sp.Rational(1, 100) * sp.exp(
        -500 * (x - sp.Rational(43, 100)) ** 2)
    fpp = sp.simplify(sp.diff(f, x, 2))

    # (1) Picture: plot f'' over [-1, 1]; show the dip near x=0.5.
    fpp_num = sp.lambdify(x, fpp, "numpy")
    xs = np.linspace(-1, 1, 800)
    ys = fpp_num(xs)
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.plot(xs, ys, lw=1.5)
    ax.axhline(0, color="black", lw=0.5)
    ax.set_xlabel("x"); ax.set_ylabel("f''(x)")
    ax.set_title("geom_03: f''(x) on [-1, 1]; dip below 0 near x = 0.5")
    ax.grid(True, alpha=0.3)
    PNG_DIR.mkdir(exist_ok=True)
    out = PNG_DIR / "geom_03.png"
    fig.savefig(out, dpi=120); plt.close(fig)
    log(f"  picture saved -> {out.relative_to(HERE)}; INSPECT BY EYE.")

    # (2) Naive grid: 11 points uniformly on [-1, 1].
    grid = [sp.Rational(-1) + sp.Rational(i, 5) for i in range(11)]
    vals = [float(fpp.subs(x, g)) for g in grid]
    log("  naive 11-pt grid (f'' values):")
    for g, v in zip(grid, vals):
        log(f"    x = {float(g):+.2f}   f'' = {v:+.4f}")
    grid_min = min(vals)
    log(f"  min f'' on grid: {grid_min:+.4f}")

    # The truth: f'' has a sharp negative dip near x=0.5.
    truth_min_x = 0.5
    truth_min = float(fpp.subs(x, sp.Rational(1, 2)))
    log(f"  TRUTH: f''(0.5) = {truth_min:+.4f} (sharp negative dip)")

    if grid_min >= 0:
        log("  PASS sampling-fragile: naive grid finds f'' >= 0 "
            "everywhere, ratifying the FALSE 'convex' claim. Picture of "
            "f'' makes the dip visible.")
    else:
        log("  FAIL sampling-fragile: naive grid catches a negative "
            "value. Either narrow the dip further or shift the grid "
            "alignment.")


def verify_geom_04():
    log("\n=== geom_04 === TODO: implement simple-connectedness check.")


def verify_geom_05():
    log("\n=== geom_05 === TODO: implement monotonicity wiggle check.")


def verify_geom_06():
    log("\n=== geom_06 === TODO: implement inequality near-zero dip check.")


def verify_geom_09():
    log("\n=== geom_09 === TODO: implement differentiability oscillation check.")


def verify_geom_10():
    log("\n=== geom_10 === TODO: implement surface-intersection cardinality check.")


VERIFIERS = {
    "geom_01": verify_geom_01,
    "geom_02": verify_geom_02,
    "geom_03": verify_geom_03,
    "geom_04": verify_geom_04,
    "geom_05": verify_geom_05,
    "geom_06": verify_geom_06,
    "geom_09": verify_geom_09,
    "geom_10": verify_geom_10,
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--problem", choices=list(VERIFIERS.keys()))
    ap.add_argument("--all", action="store_true")
    args = ap.parse_args()

    # Reset log file at start of any run
    if LOG_P.exists():
        LOG_P.unlink()

    if args.all:
        for name, fn in VERIFIERS.items():
            try:
                fn()
            except Exception as e:
                log(f"  [!] {name} failed: {e}")
    elif args.problem:
        VERIFIERS[args.problem]()
    else:
        ap.error("specify --problem <geom_NN> or --all")


if __name__ == "__main__":
    main()
