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
# Problem 01: sin(πx) vs x²(2−x) on [0,1]: tangent or transverse?
# -----------------------------------------------------------------------
def verify_geom_01():
    import matplotlib.pyplot as plt
    import numpy as np
    import sympy as sp

    log("\n=== geom_01: sin(πx) vs x²(2−x) on [0,1] ===")

    # (1) Picture
    xs = np.linspace(0, 1, 400)
    fs = np.sin(np.pi * xs)
    gs = xs ** 2 * (2 - xs)
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.plot(xs, fs, label=r"$f(x) = \sin(\pi x)$")
    ax.plot(xs, gs, label=r"$g(x) = x^2(2-x)$")
    ax.set_title("geom_01: tangent intersection near x ≈ 0.69")
    ax.legend(); ax.grid(True, alpha=0.3)
    PNG_DIR.mkdir(exist_ok=True)
    out = PNG_DIR / "geom_01.png"
    fig.savefig(out, dpi=120); plt.close(fig)
    log(f"  picture saved -> {out.relative_to(HERE)}; INSPECT BY EYE.")

    # (2) Naive SymPy sampling: 11 uniform points; do we see a sign
    # change of (f - g)?
    x = sp.Symbol("x", real=True)
    f = sp.sin(sp.pi * x)
    g = x ** 2 * (2 - x)
    samples = [float((f - g).subs(x, sp.Rational(i, 10))) for i in range(11)]
    signs = [1 if s > 0 else (-1 if s < 0 else 0) for s in samples]
    sign_changes = sum(1 for a, b in zip(signs, signs[1:]) if a * b < 0)
    log(f"  naive sample diffs (11 pts): "
        f"{[round(v, 4) for v in samples]}")
    log(f"  -> sign changes: {sign_changes}")
    if sign_changes >= 1:
        log("  FAIL sampling-fragile: naive grid sampling DETECTS the "
            "transverse crossing, so it can distinguish transverse from "
            "tangent. This problem is SAMPLING-EASY, not sampling-fragile.")
        log("  ACTION: replace geom_01 with a real tangency problem "
            "where the relevant sign change is below grid resolution "
            "(e.g. f(x) vs f(x) + (x-c)^4 with a narrow Gaussian bump).")
    else:
        log("  PASS sampling-fragile.")


# -----------------------------------------------------------------------
# Stubs for the remaining 7 problems. Fill in as the corpus is built.
# Each stub should mirror geom_01's structure:
#   - plot the central object via matplotlib (your inspection)
#   - run the naive SymPy strategy
#   - assert the naive strategy does NOT catch the structural lie
# -----------------------------------------------------------------------
def verify_geom_02():
    log("\n=== geom_02 === TODO: implement parametric self-intersection check.")


def verify_geom_03():
    log("\n=== geom_03 === TODO: implement convexity (f'' dip) check.")


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
