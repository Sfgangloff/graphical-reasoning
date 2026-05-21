#!/usr/bin/env python3
"""LLM-judge step: for each result that compiles cleanly, ask whether
the Lean formalization matches the LaTeX problem statement.

Approach: shell out to `claude --print` with a fresh prompt that has
ONLY the LaTeX excerpt + Solution.lean as context. The judge has no
visibility into the experimental conditions.

Writes `judge.json` next to `meta.json` in each result dir.

Usage (from repo root):
    python3 experiments/runner/judge.py [--rejudge]
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
EXPS = REPO / "experiments"
RESULTS = EXPS / "results"

JUDGE_PROMPT = """You are judging whether a Lean 4 / Mathlib formalization
faithfully captures the natural-language problem statement below.

## Original problem (LaTeX)

```latex
{LATEX}
```

## Candidate formalization (Lean 4)

```lean
{LEAN}
```

Score the formalization on **statement match only** (ignore proof
quality):

- "match"     — the Lean theorem statement captures every hypothesis
                and every conclusion of the LaTeX problem, with no
                strengthening or weakening, no missing cases, and no
                extra assumptions.
- "close"     — minor issues (e.g. an open vs closed interval, a typo
                in a constant, a slightly different phrasing of the
                same conclusion) but the mathematical content matches.
- "mismatch"  — the Lean statement diverges materially: missing or
                spurious hypotheses, different conclusion, wrong
                quantifiers, wrong constants in a "compute X" problem.
- "non-statement" — there is no plausible candidate theorem statement
                    in the file at all.

Output exactly one JSON block as your final message:

```json
{{
  "verdict": "match" | "close" | "mismatch" | "non-statement",
  "reason": "<one short sentence>"
}}
```
"""


def run_judge(latex: str, lean: str) -> dict | None:
    prompt = JUDGE_PROMPT.format(LATEX=latex, LEAN=lean)
    try:
        proc = subprocess.run(
            ["claude", "--print", "--output-format", "text", prompt],
            capture_output=True, text=True, timeout=300,
        )
    except subprocess.TimeoutExpired:
        return {"verdict": "error", "reason": "judge timed out (300s)"}
    out = proc.stdout
    blocks = re.findall(r"```json\s*(\{.*?\})\s*```", out, re.S)
    if not blocks:
        return {"verdict": "error", "reason": "no JSON block in judge output",
                "raw": out[-500:]}
    try:
        return json.loads(blocks[-1])
    except Exception as e:
        return {"verdict": "error", "reason": f"parse failure: {e}",
                "raw": blocks[-1]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rejudge", action="store_true",
                    help="Re-judge results that already have judge.json")
    ap.add_argument("--results-root", type=Path, default=RESULTS,
                    help="results dir to judge (default experiments/results)")
    args = ap.parse_args()

    results_dir = args.results_root
    if not results_dir.is_absolute():
        results_dir = (REPO / results_dir).resolve()

    n_judged, n_skipped = 0, 0
    for d in sorted(results_dir.iterdir()):
        if not d.is_dir():
            continue
        meta_p = d / "meta.json"
        sol_p = d / "Solution.lean"
        judge_p = d / "judge.json"
        if not (meta_p.exists() and sol_p.exists()):
            n_skipped += 1
            continue
        if judge_p.exists() and not args.rejudge:
            n_skipped += 1
            continue
        meta = json.loads(meta_p.read_text())
        excerpt = REPO / "experiments" / "problem_excerpts" / (
            meta["problem_id"].replace(".", "_") + ".tex"
        )
        if not excerpt.exists():
            print(f"[{d.name}] excerpt not found, skipping.")
            n_skipped += 1
            continue
        verdict = run_judge(excerpt.read_text(), sol_p.read_text())
        judge_p.write_text(json.dumps(verdict, indent=2))
        n_judged += 1
        v = (verdict or {}).get("verdict", "?")
        print(f"[{d.name}] verdict = {v}")
    print(f"Judged {n_judged}, skipped {n_skipped}.")


if __name__ == "__main__":
    main()
