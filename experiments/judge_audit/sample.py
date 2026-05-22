#!/usr/bin/env python3
"""Draw a stratified random sample of cells for the human judge audit.

Usage:
    python sample.py --study study5 --n 20
    python sample.py --study study3 --n 25
    python sample.py --study study6 --n 30 --include-new-only
    python sample.py --calibration       # 10-cell pre-graded warmup

Seed is fixed at 42 + a per-study salt; output is reproducible.
"""
from __future__ import annotations

import argparse
import csv
import json
import random
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
SAMPLES_DIR = HERE / "samples"

STUDIES = {
    "study3": {
        "results_dir": REPO / "experiments/forced_viz/results",
        "salt": "forced_viz",
        "tag_filter": None,
    },
    "study5": {
        "results_dir": REPO / "experiments/false_claim/results",
        "salt": "false_claim_pilot",
        "tag_filter": lambda tag: tag.endswith("__r0") or tag.endswith("__r1"),
    },
    "study6": {
        "results_dir": REPO / "experiments/false_claim/results",
        "salt": "false_claim_scaled",
        "tag_filter": lambda tag: not (tag.endswith("__r0") or tag.endswith("__r1")),
    },
    "study7": {
        "results_dir": REPO / "experiments/inline_content/results",
        "salt": "inline_content",
        "tag_filter": None,
    },
    "study8": {
        "results_dir": REPO / "experiments/geometric_corpus/results",
        "salt": "geometric",
        "tag_filter": None,
    },
}


def is_poisoned(meta: dict) -> bool:
    """Match the heuristic in analyze_false_claim.py and analyze_forced.py."""
    return (
        meta.get("tool_calls_attempted", 0) == 0
        and not meta.get("claude_timed_out", False)
        and meta.get("wall_clock_s", 0) < 30
    )


def discover_cells(results_dir: Path, tag_filter):
    cells = []
    if not results_dir.exists():
        return cells
    for d in sorted(results_dir.iterdir()):
        if not d.is_dir():
            continue
        meta_p = d / "meta.json"
        if not meta_p.exists():
            continue
        if tag_filter is not None and not tag_filter(d.name):
            continue
        try:
            meta = json.loads(meta_p.read_text())
        except Exception:
            continue
        if is_poisoned(meta):
            continue
        cells.append({"tag": d.name, "path": d, "meta": meta})
    return cells


def extract_row(cell: dict, study: str) -> dict:
    """Pull the fields the grader needs to see (everything *except* the
    LLM judge label, which `grade.py` hides until after the human
    grades)."""
    meta = cell["meta"]
    sr = meta.get("self_report") or {}
    judge_p = cell["path"] / "judge.json"
    judge_verdict = ""
    if judge_p.exists():
        try:
            judge_verdict = json.loads(judge_p.read_text()).get("verdict", "")
        except Exception:
            pass
    # The excerpt path is study-dependent; record what we can.
    excerpt_path = ""
    for guess in ("prompt.md", "excerpt.tex"):
        if (cell["path"] / guess).exists():
            excerpt_path = str(cell["path"] / guess)
            break

    return {
        "study": study,
        "tag": cell["tag"],
        "result_path": str(cell["path"]),
        "excerpt_path": excerpt_path,
        "agent_verdict": (sr.get("verdict") or "").strip(),
        "agent_answer": (sr.get("correct_answer") or "").strip(),
        "llm_judge_verdict": judge_verdict,
        "your_grade": "",   # human fills via grade.py
        "notes": "",         # optional, human fills
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--study", choices=list(STUDIES.keys()),
                    help="which study to sample from")
    ap.add_argument("--n", type=int, help="sample size")
    ap.add_argument("--calibration", action="store_true",
                    help="draw a 10-cell calibration block "
                         "(seed 42, stratified one-per-condition)")
    args = ap.parse_args()

    SAMPLES_DIR.mkdir(exist_ok=True)

    if args.calibration:
        return draw_calibration()

    if not args.study or not args.n:
        ap.error("--study and --n required (unless --calibration)")

    cfg = STUDIES[args.study]
    cells = discover_cells(cfg["results_dir"], cfg["tag_filter"])

    if not cells:
        print(f"[!] No cells found for {args.study} under {cfg['results_dir']}")
        print("    (Study may not have been run yet; re-run sample.py "
              "after the runs complete.)")
        return

    if args.n > len(cells):
        print(f"[!] Requested n={args.n} but only {len(cells)} cells "
              "available; sampling all.")
        sample = cells
    else:
        rng = random.Random(f"42::{cfg['salt']}")
        sample = rng.sample(cells, args.n)

    rows = [extract_row(c, args.study) for c in sample]
    out_p = SAMPLES_DIR / f"{args.study}.csv"
    with out_p.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"[+] {args.study}: {len(rows)} cells -> {out_p.relative_to(REPO)}")


def draw_calibration():
    """10-cell pre-graded sample drawn from existing Studies 3 + 5."""
    rng = random.Random("42::calibration")
    pool = []
    for study in ("study3", "study5"):
        cells = discover_cells(STUDIES[study]["results_dir"],
                                STUDIES[study]["tag_filter"])
        for c in cells:
            pool.append((study, c))
    if len(pool) < 10:
        print(f"[!] Calibration needs >=10 cells; found {len(pool)}.")
        return
    sample = rng.sample(pool, 10)
    rows = [extract_row(c, study) for study, c in sample]
    out_p = SAMPLES_DIR / "calibration.csv"
    with out_p.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"[+] calibration: {len(rows)} cells -> {out_p.relative_to(REPO)}")
    print("    (Reference grades for the calibration block live in "
          "`calibration_reference.csv` once filled in.)")


if __name__ == "__main__":
    main()
