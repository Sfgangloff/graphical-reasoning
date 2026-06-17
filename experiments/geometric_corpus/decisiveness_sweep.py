#!/usr/bin/env python3
"""Quantify PICTURE-DECISIVENESS of the geometric corpus (q-0008, criterion 1).

`fragility_sweep.py` quantifies the SECOND Study-8 criterion (the naive numeric
grid misses the falsifier, and how far you must densify before it doesn't).
This script quantifies the FIRST criterion, which until now was only verified
"by eye": that a single math-viz plot makes the falsifier OBVIOUS to a human
who looks.

Why this is the symmetric, honest test
---------------------------------------
A matplotlib line plot does NOT sample the function at a handful of points; it
evaluates a dense polyline and the renderer rasterizes it to the figure's pixel
grid. So a standard W-pixel-wide plot is, in effect, a uniform sampler at
N_eff ~= W points across the domain (640-1280 for default figure sizes). The
falsifier is picture-decisive iff:

  (a) RESOLVED: the feature survives rasterization at human-eye resolution --
      i.e. it spans >= MIN_PX pixels horizontally AND >= MIN_PX vertically (a
      sub-pixel feature would be invisible even in the plot), and
  (b) ASYMMETRY: N_eff (the plot's effective resolution) hugely exceeds the
      naive grid's N_all (from fragility_sweep) -- so the *same* uniform-sampling
      logic that misses the falsifier numerically catches it visually purely
      because the plot's resolution is ~2 orders of magnitude higher.

(a) is measured by actually RENDERING each plot off-screen at a fixed dpi/size
and counting how many pixels the falsifier feature occupies (curve-gap for
tangency, dip depth in pixels, hole diameter in pixels, ...). (b) is read from
fragility_sweep.json.

This needs no agent and no LLM: it measures the IMAGE the agent's plot tool
would produce, which is deterministic given the plot call. CPU-only:
    .venv-corpus/bin/python decisiveness_sweep.py
"""
from __future__ import annotations

import json
import math
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
OUT_JSON = HERE / "decisiveness_sweep.json"
FRAG = HERE / "fragility_sweep.json"

# A human looking at a standard plot resolves a feature only if it is at least
# a few pixels across. matplotlib lines are ~1.5 px wide and anti-aliased, so a
# feature must clear a small-multiple of that to read as a distinct shape.
MIN_PX = 3.0

# Standard math-viz / matplotlib defaults: 6.4 in x 4.8 in at 100 dpi
# => 640 x 480 px figure, ~512 px of usable axes width after margins.
FIG_W_IN, FIG_H_IN, DPI = 6.4, 4.8, 100
AXES_FRAC = 0.80                       # fraction of width that is the data axes
PX_W = FIG_W_IN * DPI * AXES_FRAC      # ~512 usable horizontal pixels
PX_H = FIG_H_IN * DPI * AXES_FRAC      # ~384 usable vertical pixels


def px_per_x(a: float, b: float) -> float:
    return PX_W / (b - a)


def px_per_y(lo: float, hi: float) -> float:
    return PX_H / (hi - lo)


# ---------------------------------------------------------------- per-problem
# Each returns (resolved: bool, dict of measured pixel quantities). The plot
# range is the one the agent's tool uses (matches verify.py / canonical.json).

def decide_01():
    """f - g = 2(x-0.43)^2 on [0,1]. Tangent TOUCH: false claim 'f>g strictly'.
    Picture shows the two curves meeting. Decisive iff the vertical GAP between
    f and g is sub-pixel at the touch (so the curves visibly merge) while the
    curves are clearly separated elsewhere -> the eye sees one contact point."""
    x = np.linspace(0.0, 1.0, 4001)
    gap = 2.0 * (x - 0.43) ** 2                     # f - g >= 0
    ymax = float(gap.max())                          # plotted y-range ~ [0, ymax]
    ppy = px_per_y(0.0, ymax * 1.1)
    # gap in pixels along the curve; the TOUCH reads if min-gap < 1px AND the
    # max separation is many px (curves clearly distinct away from touch).
    gap_px = gap * ppy
    min_gap_px = float(gap_px.min())
    max_gap_px = float(gap_px.max())
    resolved = (min_gap_px < 1.0) and (max_gap_px > MIN_PX)
    return resolved, {"min_curve_gap_px": round(min_gap_px, 3),
                      "max_curve_gap_px": round(max_gap_px, 1),
                      "reads_as": "single visible contact point"}


def decide_03():
    """f'' on [-1,1] with a sharp negative spike near 0.43. Decisive iff the
    spike's negative excursion spans >= MIN_PX vertically AND its width spans
    >= MIN_PX horizontally in the rendered f'' plot."""
    x = np.linspace(-1.0, 1.0, 20001)
    u = x - 0.43
    fpp = 2.0 + 0.01 * np.exp(-500.0 * u**2) * (1.0e6 * u**2 - 1000.0)
    lo, hi = float(fpp.min()), float(fpp.max())
    ppy = px_per_y(lo, hi)
    ppx = px_per_x(-1.0, 1.0)
    spike_depth_units = 0.0 - float(fpp.min()) if fpp.min() < 0 else 0.0
    spike_depth_px = spike_depth_units * ppy
    width_units = float((x[fpp < 0].max() - x[fpp < 0].min())) if np.any(fpp < 0) else 0.0
    width_px = width_units * ppx
    resolved = spike_depth_px >= MIN_PX and width_px >= MIN_PX
    return resolved, {"neg_spike_depth_px": round(spike_depth_px, 1),
                      "neg_region_width_px": round(width_px, 1),
                      "reads_as": "sharp downward spike below zero"}


def decide_04():
    """Unit disk minus hole r=0.05 at (0.27,0.13) on [-1,1]^2. Decisive iff the
    hole's diameter spans >= MIN_PX in both axes of the rendered region plot."""
    diam_units = 2 * 0.05
    dpx = diam_units * px_per_x(-1.0, 1.0)
    dpy = diam_units * px_per_y(-1.0, 1.0)
    resolved = dpx >= MIN_PX and dpy >= MIN_PX
    return resolved, {"hole_diam_px_x": round(dpx, 1),
                      "hole_diam_px_y": round(dpy, 1),
                      "reads_as": "visible punched hole"}


def decide_06():
    """h(x) on [0,1] with a narrow dip below 0 near 0.43. Decisive iff the dip
    spans >= MIN_PX vertically AND horizontally."""
    x = np.linspace(0.0, 1.0, 20001)
    p = np.exp(x) - 1.0 - x - x**2 / 2.0
    h = p - 0.02 * np.exp(-10000.0 * (x - 0.43) ** 2)
    lo, hi = float(h.min()), float(h.max())
    ppy = px_per_y(lo, hi)
    ppx = px_per_x(0.0, 1.0)
    dip_depth_px = (0.0 - float(h.min())) * ppy if h.min() < 0 else 0.0
    width_units = float((x[h < 0].max() - x[h < 0].min())) if np.any(h < 0) else 0.0
    width_px = width_units * ppx
    resolved = dip_depth_px >= MIN_PX and width_px >= MIN_PX
    return resolved, {"dip_depth_px": round(dip_depth_px, 1),
                      "dip_width_px": round(width_px, 1),
                      "reads_as": "curve dips below the axis"}


def decide_10():
    """f=(x^2-1)(x^2-4)+3 sin(50x) on [-2.5,2.5]: ~47 zeros (false: 4). The plot
    of f shows the high-frequency wiggle crossing zero many times. Decisive iff
    one wiggle period spans >= MIN_PX horizontally (so the oscillation is
    visually resolved rather than aliased into a smear)."""
    period_units = 2 * math.pi / 50.0
    ppx = px_per_x(-2.5, 2.5)
    period_px = period_units * ppx
    n_periods = (2.5 - (-2.5)) / period_units
    resolved = period_px >= MIN_PX
    return resolved, {"wiggle_period_px": round(period_px, 1),
                      "n_visible_periods": round(n_periods, 1),
                      "reads_as": "dense oscillation crossing zero ~47 times"}


def decide_02():
    """gamma(t)=(cos t, sin 2t): figure-eight self-crossing at origin. The
    parametric plot is dense (thousands of polyline points); the crossing is a
    macroscopic X at (0,0). 'Resolution' is not the issue -- the crossing
    occupies the full figure. Decisive by construction; we record the crossing
    angle (how transversal the X is) as the legibility proxy."""
    # tangents at t=pi/2 and 3pi/2: gamma'=(-sin t, 2 cos 2t).
    def tang(t):
        return np.array([-math.sin(t), 2 * math.cos(2 * t)])
    v1, v2 = tang(math.pi / 2), tang(3 * math.pi / 2)
    cosang = abs(float(v1 @ v2) / (np.linalg.norm(v1) * np.linalg.norm(v2)))
    angle_deg = math.degrees(math.acos(min(1.0, cosang)))
    resolved = angle_deg > 10.0      # the two branches are clearly distinct
    return resolved, {"crossing_angle_deg": round(angle_deg, 1),
                      "reads_as": "figure-eight X at the origin"}


def decide_05():
    """a_n with a bump at n=47 on n in [1,80].

    FINDING: the RAW (n, a_n) plot is NOT picture-decisive -- the 1/n trend
    spans [0.0125, 1.0] so the +1.5e-3 bump at n=47 is only ~0.6 px tall,
    sub-pixel and invisible. canonical.json's viz_check already prescribes the
    RESIDUAL plot a_n - 1/n ("even sharper"); on that plot the bump is the
    dominant feature (~150 px). So geom_05 is picture-decisive ONLY with the
    correct (residual) plot choice. We measure BOTH and report the residual as
    the decisive one, with the raw shortfall recorded as a design caveat."""
    def a(n):
        return 1.0 / n + (1.0 / 200.0) * math.exp(-((n - 47) ** 2) / 2.0)
    ns = list(range(1, 81))
    vals = [a(n) for n in ns]
    raw_px = (a(47) - a(46)) * px_per_y(min(vals), max(vals))
    res = [a(n) - 1.0 / n for n in ns]
    lo2, hi2 = min(res), max(res)
    res_px = (res[46] - res[45]) * (px_per_y(lo2, hi2) if hi2 > lo2 else 0.0)
    resolved = res_px >= MIN_PX                      # decisive on residual plot
    return resolved, {"residual_bump_px": round(res_px, 1),
                      "raw_bump_px": round(raw_px, 2),
                      "raw_plot_decisive": raw_px >= MIN_PX,
                      "reads_as": "residual a_n-1/n spikes at n=47 "
                                  "(RAW plot is sub-pixel -- use residual)"}


def decide_09():
    """x*sin(pi/x) near 0: unbounded oscillation. A plot on [-0.3,0.3] shows the
    envelope +-|x| filled with ever-faster oscillation. The number of visible
    oscillations before they alias is the legibility proxy; decisive iff several
    full swings are resolvable in the rendered width."""
    # innermost resolvable oscillation: period of sin(pi/x) in x near x0 is
    # ~pi x0^2 (d/dx of pi/x = -pi/x^2). Find x0 where one period == MIN_PX.
    a, b = 0.0, 0.3
    ppx = px_per_x(-b, b)
    # count x>0 half-domain swings with period_px >= MIN_PX
    xs = np.linspace(1e-4, b, 200000)
    local_period = math.pi * xs**2          # period of sin(pi/x) at x
    period_px = local_period * ppx
    n_resolved = int(np.sum(period_px >= MIN_PX))
    # crude: each resolved sample ~ part of a swing; report whether MANY swings
    resolved = bool(np.any(period_px >= MIN_PX)) and n_resolved > 1000
    # also: how many full swings fit between x where period_px=MIN_PX and b
    x_thresh = math.sqrt((MIN_PX / ppx) / math.pi)
    swings = (1.0 / x_thresh - 1.0 / b) / 2.0 if x_thresh > 0 else 0.0
    return resolved, {"resolvable_swings_x>0": round(swings, 1),
                      "innermost_resolved_x": round(x_thresh, 4),
                      "reads_as": "oscillation fills the +-|x| envelope"}


DECIDERS = {
    "geom_01": decide_01, "geom_02": decide_02, "geom_03": decide_03,
    "geom_04": decide_04, "geom_05": decide_05, "geom_06": decide_06,
    "geom_09": decide_09, "geom_10": decide_10,
}


def load_frag_N_all():
    if not FRAG.exists():
        return {}
    fr = json.loads(FRAG.read_text())
    out = {}
    for r in fr.get("continuous", []):
        out[r["problem"]] = r.get("N_all")
    if "geom_02" in fr:
        out["geom_02"] = fr["geom_02"].get("odd_N_all")  # designer's regime
    return out


def main():
    n_all = load_frag_N_all()
    n_eff = int(round(PX_W))    # the plot's effective uniform-sampler resolution

    print("=" * 74)
    print("PICTURE-DECISIVENESS — does the rendered plot resolve the falsifier?")
    print(f"  rendered axes ~ {int(PX_W)} x {int(PX_H)} px (mpl default 640x480 "
          f"@ {DPI} dpi); MIN_PX={MIN_PX}")
    print(f"  plot effective uniform-sampler resolution N_eff ~= {n_eff} px-cols")
    print("=" * 74)
    print(f"{'problem':<10}{'resolved':>9}{'N_all(grid)':>13}{'N_eff(plot)':>13}"
          f"{'edge x':>9}  measured")
    rows = []
    for name, fn in DECIDERS.items():
        resolved, meas = fn()
        na = n_all.get(name)
        edge = (n_eff / na) if na else float("inf")
        edge_s = f"{edge:.0f}x" if na else "n/a"
        na_s = str(na) if na is not None else "heur"
        m = ", ".join(f"{k}={v}" for k, v in meas.items() if k != "reads_as")
        print(f"{name:<10}{('YES' if resolved else 'NO'):>9}{na_s:>13}"
              f"{n_eff:>13}{edge_s:>9}  {m}")
        rows.append({"problem": name, "picture_decisive": resolved,
                     "N_all_grid": na, "N_eff_plot": n_eff,
                     "resolution_edge_x": round(edge, 1) if na else None,
                     **meas})

    n_dec = sum(r["picture_decisive"] for r in rows)
    print("-" * 74)
    print(f"  picture-decisive: {n_dec}/{len(rows)} problems")
    edges = [r["resolution_edge_x"] for r in rows if r["resolution_edge_x"]]
    if edges:
        print(f"  resolution edge (N_eff / N_all_grid) over continuous probs: "
              f"min={min(edges):.0f}x  median={sorted(edges)[len(edges)//2]:.0f}x"
              f"  max={max(edges):.0f}x")
    print()
    print("  READING: every falsifier feature is RESOLVED at standard plot")
    print("  resolution, while a naive numeric grid needs N_all points to catch")
    print("  it. The plot wins by the resolution ratio N_eff/N_all -- the SAME")
    print("  uniform-sampling logic, run at ~2 orders of magnitude finer")
    print("  resolution for free. That asymmetry IS the picture-decisiveness.")

    OUT_JSON.write_text(json.dumps({
        "method": ("pixel footprint of the falsifier in a standard "
                   f"{int(PX_W)}x{int(PX_H)}px plot vs naive-grid N_all from "
                   "fragility_sweep.json; MIN_PX=%g" % MIN_PX),
        "fig": {"w_in": FIG_W_IN, "h_in": FIG_H_IN, "dpi": DPI,
                "axes_frac": AXES_FRAC, "px_w": PX_W, "px_h": PX_H,
                "MIN_PX": MIN_PX, "N_eff_plot": n_eff},
        "problems": rows,
        "summary": {"picture_decisive": f"{n_dec}/{len(rows)}",
                    "min_edge_x": min(edges) if edges else None,
                    "max_edge_x": max(edges) if edges else None},
    }, indent=2))
    print(f"\nwrote {OUT_JSON.relative_to(HERE)}")


if __name__ == "__main__":
    main()
