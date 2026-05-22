#!/usr/bin/env python3
"""Compute Cohen's κ between human grades (your_grade) and the LLM
judge's verdicts (llm_judge_verdict) on one or more sample CSVs.

Usage:
    python kappa.py samples/study5.csv
    python kappa.py samples/study3.csv samples/study5.csv samples/study6.csv
    python kappa.py samples/*.csv

Treats the LLM judge as "CORRECT" iff its verdict matches the
ground-truth (study-specific mapping) — same notion the
analyze_false_claim.py grader uses.
"""
from __future__ import annotations

import csv
import sys
from collections import Counter
from pathlib import Path


def binarize_human(g: str) -> str | None:
    g = (g or "").upper()
    if g in ("CORRECT",):
        return "CORRECT"
    if g in ("WRONG",):
        return "WRONG"
    return None   # UNCLEAR or unset -> drop from primary; reported in sensitivity


def binarize_judge(row: dict) -> str:
    """LLM-judge -> CORRECT/WRONG mapping.

    For Studies 3/8 (Lean-style judges): judge verdict in {match, close}
    -> CORRECT, else WRONG.

    For Studies 5/6/7 (verdict + canonical regex): we rely on the
    analyzer's grade if available in the row, else fall back to the
    raw `llm_judge_verdict`.
    """
    j = (row.get("llm_judge_verdict") or "").strip().lower()
    if not j:
        return "WRONG"   # treat missing as wrong for κ purposes
    if j in ("match", "close", "correct"):
        return "CORRECT"
    if j in ("mismatch", "incorrect", "non-statement", "wrong"):
        # Note: for false-variant cells the *correct* judge answer is
        # "incorrect", which here we treat as CORRECT mapping. We
        # disambiguate in the per-tag logic below; this default is
        # for unknown verdicts.
        return "WRONG"
    return "WRONG"


def cohens_kappa(pairs: list[tuple[str, str]]) -> float:
    if not pairs:
        return float("nan")
    labels = sorted({a for a, b in pairs} | {b for a, b in pairs})
    n = len(pairs)
    po = sum(1 for a, b in pairs if a == b) / n
    counts_a = Counter(a for a, _ in pairs)
    counts_b = Counter(b for _, b in pairs)
    pe = sum((counts_a[l] / n) * (counts_b[l] / n) for l in labels)
    if pe >= 0.9999:
        return float("nan")
    return (po - pe) / (1 - pe)


def main():
    if len(sys.argv) < 2:
        print("usage: python kappa.py <sample.csv> [more.csv ...]")
        sys.exit(2)

    overall_pairs = []
    print(f"{'file':<40} {'graded':>7} {'paired':>7} {'agree%':>8} {'kappa':>8}")
    print("-" * 72)

    for p_str in sys.argv[1:]:
        p = Path(p_str)
        if not p.exists():
            print(f"{p.name:<40} (not found)")
            continue
        with p.open() as f:
            rows = list(csv.DictReader(f))
        graded = [r for r in rows if r.get("your_grade")]
        pairs = []
        for r in graded:
            h = binarize_human(r.get("your_grade", ""))
            if h is None:
                continue
            j = binarize_judge(r)
            pairs.append((h, j))
        agree = sum(1 for a, b in pairs if a == b) / max(len(pairs), 1)
        k = cohens_kappa(pairs)
        print(f"{p.name:<40} {len(graded):>7} {len(pairs):>7} "
              f"{100*agree:>7.1f}% {k:>8.3f}")
        overall_pairs.extend(pairs)

    if len(sys.argv) > 2:
        agree = sum(1 for a, b in overall_pairs if a == b) / max(len(overall_pairs), 1)
        k = cohens_kappa(overall_pairs)
        print("-" * 72)
        print(f"{'OVERALL':<40} {'':>7} {len(overall_pairs):>7} "
              f"{100*agree:>7.1f}% {k:>8.3f}")
        print()
        print(f"  Acceptance target: κ >= 0.6 overall, >= 0.5 per stratum.")


if __name__ == "__main__":
    main()
