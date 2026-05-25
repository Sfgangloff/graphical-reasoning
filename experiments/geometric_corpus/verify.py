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
    """Simple-connectedness of unit disk with a small off-grid circular hole.

    R = {(x, y) : x^2 + y^2 <= 1 and (x - 0.27)^2 + (y - 0.13)^2 >= 0.05^2}.
    A small disk of radius 0.05 centered at (0.27, 0.13) is removed
    from the unit disk; the result is topologically an annulus, NOT
    simply connected.

    Picture-decisive: a plot of R shows the small hole clearly.

    Sampling-fragile: a naive 5x5 uniform-grid containment check on
    [-1, 1]^2 places sample points at (i/2, j/2) for i, j in {-2,...,2}.
    The hole center (0.27, 0.13) is at distance >= 0.155 from every
    grid point, while the hole radius is 0.05; no grid point lands in
    the hole. Naive containment check says "all 25 grid points are in
    R" -> ratifies the FALSE 'simply connected' claim.
    """
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np

    log("\n=== geom_04: simple-connectedness of disk with off-grid hole ===")

    hole_c = (0.27, 0.13)
    hole_r = 0.05

    # (1) Picture: shade the region, mark the hole.
    n = 400
    xs = np.linspace(-1.1, 1.1, n)
    ys = np.linspace(-1.1, 1.1, n)
    X, Y = np.meshgrid(xs, ys)
    in_disk = X**2 + Y**2 <= 1
    out_hole = (X - hole_c[0])**2 + (Y - hole_c[1])**2 >= hole_r**2
    mask = in_disk & out_hole
    fig, ax = plt.subplots(figsize=(5, 5))
    ax.imshow(mask.astype(float), extent=(-1.1, 1.1, -1.1, 1.1),
              origin="lower", cmap="Greys", alpha=0.4)
    ax.add_patch(mpatches.Circle(hole_c, hole_r, fill=False,
                                 edgecolor="red", lw=1.5,
                                 label="hole boundary"))
    ax.add_patch(mpatches.Circle((0, 0), 1.0, fill=False,
                                 edgecolor="black", lw=1.0))
    ax.set_xlim(-1.15, 1.15); ax.set_ylim(-1.15, 1.15)
    ax.set_aspect("equal"); ax.grid(True, alpha=0.3); ax.legend()
    ax.set_title("geom_04: unit disk with hole at (0.27, 0.13), r=0.05")
    PNG_DIR.mkdir(exist_ok=True)
    out = PNG_DIR / "geom_04.png"
    fig.savefig(out, dpi=120); plt.close(fig)
    log(f"  picture saved -> {out.relative_to(HERE)}; INSPECT BY EYE.")

    # (2) Naive 5x5 grid containment check.
    grid_pts = [(i / 2.0, j / 2.0) for i in range(-2, 3)
                for j in range(-2, 3)]
    in_R = [(px**2 + py**2 <= 1) and
            ((px - hole_c[0])**2 + (py - hole_c[1])**2 >= hole_r**2)
            for px, py in grid_pts]
    n_in = sum(in_R)
    n_in_disk = sum(1 for px, py in grid_pts if px**2 + py**2 <= 1)
    n_caught_hole = n_in_disk - n_in
    log(f"  naive 5x5 grid: {n_in}/{len(grid_pts)} points in R "
        f"(of which {n_in_disk} were in the disk; {n_caught_hole} "
        f"landed inside the hole).")
    if n_caught_hole == 0:
        log("  PASS sampling-fragile: no grid point lands in the hole, "
            "so a naive 'is every sample in R?' containment check "
            "ratifies the FALSE 'simply connected' claim. The hole is "
            "only visible from the picture.")
    else:
        log(f"  FAIL sampling-fragile: {n_caught_hole} grid points "
            "land in the hole; tune hole_c off-grid further or shrink "
            "hole_r.")


def verify_geom_05():
    log("\n=== geom_05 === TODO: implement monotonicity wiggle check.")


def verify_geom_06():
    """Inequality with a narrow off-grid negative dip.

    h(x) = (e^x - 1 - x - x^2/2) - 0.02 * exp(-10000 (x - 0.43)^2).

    The smooth part p(x) = e^x - 1 - x - x^2/2 = x^3/6 + x^4/24 + ...
    is strictly positive on (0, 1] and ~0.0145 at x = 0.43. The
    Gaussian dip subtracts 0.02 at x = 0.43 (so h(0.43) = -0.0055)
    but its half-width (~1/sqrt(10000) = 0.01) is much narrower than
    the 11-point grid spacing of 0.1, and the dip center is off-grid.

    Picture-decisive: a plot of h(x) on [0, 1] (or zoomed to
    [0.3, 0.6]) shows a sharp negative spike near x = 0.43.

    Sampling-fragile: a naive 11-point grid samples of h(x) on
    {0, 0.1, ..., 1.0} gives h(x) >= 0 everywhere; the dip is missed.
    Sympy.solve on h(x) = 0 won't find a closed-form root either,
    because of the exp(-10000 (x - c)^2) transcendental term.
    """
    import matplotlib.pyplot as plt
    import numpy as np
    import sympy as sp

    log("\n=== geom_06: inequality with narrow negative dip near x = 0.43 ===")

    x = sp.Symbol("x", real=True)
    p = sp.exp(x) - 1 - x - x ** 2 / 2
    dip = sp.Rational(2, 100) * sp.exp(
        -10000 * (x - sp.Rational(43, 100)) ** 2)
    h = p - dip
    h_num = sp.lambdify(x, h, "numpy")

    # (1) Picture: plot h on [0, 1] with a zoom panel near x=0.43.
    xs1 = np.linspace(0, 1, 400)
    xs2 = np.linspace(0.40, 0.46, 400)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 4))
    ax1.plot(xs1, h_num(xs1), lw=1.2)
    ax1.axhline(0, color="black", lw=0.5)
    ax1.set_title("h(x) on [0, 1]")
    ax1.grid(True, alpha=0.3)
    ax2.plot(xs2, h_num(xs2), lw=1.2)
    ax2.axhline(0, color="black", lw=0.5)
    ax2.set_title("h(x) zoom: dip below 0 near x = 0.43")
    ax2.grid(True, alpha=0.3)
    PNG_DIR.mkdir(exist_ok=True)
    out = PNG_DIR / "geom_06.png"
    fig.savefig(out, dpi=120); plt.close(fig)
    log(f"  picture saved -> {out.relative_to(HERE)}; INSPECT BY EYE.")

    # (2) Naive 11-point grid sample of h.
    grid = [i / 10.0 for i in range(11)]
    vals = [float(h.subs(x, sp.Rational(i, 10))) for i in range(11)]
    log("  naive 11-pt grid samples of h(x):")
    for g, v in zip(grid, vals):
        log(f"    x = {g:.1f}   h(x) = {v:.6f}")
    grid_min = min(vals)
    log(f"  min h on grid: {grid_min:.6f}")

    # Truth check: h does dip negative at x = 0.43.
    truth_x = 0.43
    truth_h = float(h.subs(x, sp.Rational(43, 100)))
    log(f"  TRUTH: h({truth_x}) = {truth_h:.6f}")

    if grid_min >= 0 and truth_h < 0:
        log("  PASS sampling-fragile: naive 11-pt grid sees h(x) >= 0 "
            "everywhere, ratifying the FALSE 'inequality holds' claim. "
            "Picture shows the negative dip near x = 0.43.")
    else:
        log("  FAIL sampling-fragile: tune dip width / offset or grid.")


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
