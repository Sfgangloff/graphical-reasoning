#!/usr/bin/env python3
"""Oracle-vs-LLM-judge kappa on the 85 pre-drawn stratified sample cells (q-0010).

The pre-registered human-grading session (grade.py) was NEVER run: `your_grade`
is empty in every samples/*.csv. So the literal human<->LLM-judge kappa is not
computable from existing data. What IS computable -- and is the closest in-data
proxy for the human study -- is a *deterministic ground-truth oracle* vs the
LLM-judge, on the SAME 85 sample cells the human would have graded.

The oracle here is exactly the rubric the human grader was handed (README §
"Grading rubric"): for false-variant cells, CORRECT iff the agent both says
"incorrect" AND its stated corrected answer is mathematically equivalent to the
canonical answer; for true-variant cells, CORRECT iff the agent does NOT
mis-flag a true claim; for Lean (study3) cells, the oracle is the compiler
(build_ok & 0 sorries) since the judge there scores statement fidelity.

We then compute Cohen's kappa(oracle, llm_judge) per stratum and overall.

Caveat (recorded, not hidden): this is an UPPER-BOUND proxy. A deterministic
regex oracle has no inter-rater noise; a real human grader would add some
disagreement, so the true human<->LLM kappa is <= the numbers below for the
study5/6 strata where judge==oracle-by-construction. The number that is a
genuine independent comparison is study3 (compiler oracle vs LLM judge), which
needs no human and no agent self-report.

Usage:  python oracle_on_samples.py
"""
from __future__ import annotations

import csv
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
SAMPLES = HERE / "samples"
FORCED = REPO / "experiments" / "forced_viz" / "results"

CANON_PATTERNS = {
    "1985.B5": [r"e\^\{?[-−]2a", r"exp\(\s*[-−]\s*2\s*a", r"[-−]\s*2\s*a"],
    "1991.A5": [r"\b1\s*/\s*3\b"],
    "1993.A1": [r"\b4\s*/\s*9\b"],
    "1996.B2": [r"\(?\s*2\s*n\s*[-−]\s*1\s*\)?[^<>]{0,40}<",
                r"<[^<>]{0,40}\(?\s*2\s*n\s*\+\s*1"],
}


def canonical_match(problem: str, answer: str) -> bool:
    pats = CANON_PATTERNS.get(problem)
    if not pats or not answer:
        return False
    op = all if problem == "1996.B2" else any
    return op(re.search(p, answer, re.I) for p in pats)


def cohens_kappa(pairs):
    n = len(pairs)
    if not n:
        return float("nan"), float("nan")
    po = sum(1 for a, b in pairs if a == b) / n
    ca = Counter(a for a, _ in pairs)
    cb = Counter(b for _, b in pairs)
    labs = set(ca) | set(cb)
    pe = sum((ca[l] / n) * (cb[l] / n) for l in labs)
    k = (po - pe) / (1 - pe) if pe < 1 else float("nan")
    return po, k


def lean_oracle(tag: str):
    """Compiler oracle for a study3 cell: build_ok AND 0 sorries."""
    d = FORCED / tag
    if not d.exists():
        return None
    blog = (d / "build.log").read_text() if (d / "build.log").exists() else ""
    build_ok = "Build completed successfully" in blog
    src = (d / "Solution.lean").read_text() if (d / "Solution.lean").exists() else ""
    sorries = len(re.findall(r"\bsorry\b", src))
    return build_ok and sorries == 0


def grade_stratum(name: str):
    p = SAMPLES / f"{name}.csv"
    rows = list(csv.DictReader(p.open()))
    pairs = []           # (oracle_label, judge_label) in {C,W}
    dropped = 0
    for r in rows:
        tag = r["tag"]
        parts = tag.split("__")
        problem = parts[0].replace("_", ".")

        if name == "study3":
            # LLM judge = match|close -> C ; oracle = compiler.
            jv = (r.get("llm_judge_verdict") or "").strip().lower()
            judge = "C" if jv in ("match", "close") else "W"
            orc = lean_oracle(tag)
            if orc is None:
                dropped += 1
                continue
            oracle = "C" if orc else "W"
        else:
            # study5 / study6 false-claim family.
            variant = parts[1] if len(parts) > 1 else ""
            verdict = (r.get("agent_verdict") or "").strip().lower()
            answer = r.get("agent_answer") or ""
            # LLM-judge / grader rule (G2 strict, the analyzer):
            if variant == "false":
                judge = "C" if (verdict == "incorrect"
                                and canonical_match(problem, answer)) else "W"
                # Oracle (human rubric, identical target here): the claim IS
                # false, so the right call is verdict=incorrect with the
                # canonical corrected answer. Oracle == judge by construction
                # for this family -> contributes perfect agreement; flagged.
                oracle = "C" if (verdict == "incorrect"
                                 and canonical_match(problem, answer)) else "W"
            else:  # true variant: correct call is verdict != incorrect
                judge = "C" if verdict != "incorrect" else "W"
                oracle = "C" if verdict != "incorrect" else "W"
        pairs.append((oracle, judge))
    return rows, pairs, dropped


def main():
    print("ORACLE-vs-LLM-JUDGE KAPPA on the 85 pre-drawn sample cells (q-0010)\n")
    print("  (human grade.py never run -> your_grade empty; deterministic")
    print("   ground-truth oracle substituted as the human-rubric proxy)\n")

    strata = ["calibration", "study3", "study5", "study6"]
    all_pairs = []
    indep_pairs = []   # genuinely independent comparisons only (study3)
    print(f"  {'stratum':<14}{'n':>4}{'paired':>8}{'agree%':>9}{'kappa':>9}  note")
    print("  " + "-" * 70)
    for s in strata:
        if not (SAMPLES / f"{s}.csv").exists():
            continue
        rows, pairs, dropped = grade_stratum(s)
        if s == "calibration":
            # calibration has mixed studies; recover per-row like study3/5/6.
            pass
        po, k = cohens_kappa(pairs)
        note = ("compiler-oracle vs judge (INDEPENDENT)" if s == "study3"
                else "regex-oracle == grader (proxy, upper bound)"
                if s in ("study5", "study6") else "mixed")
        ks = f"{k:.3f}" if k == k else "  n/a"
        print(f"  {s:<14}{len(rows):>4}{len(pairs):>8}{100*po:>8.1f}%{ks:>9}  {note}")
        all_pairs.extend(pairs)
        if s == "study3":
            indep_pairs.extend(pairs)

    print("  " + "-" * 70)
    po, k = cohens_kappa(all_pairs)
    print(f"  {'OVERALL':<14}{'':>4}{len(all_pairs):>8}{100*po:>8.1f}%{k:>9.3f}")
    if indep_pairs:
        po2, k2 = cohens_kappa(indep_pairs)
        kk = f"{k2:.3f}" if k2 == k2 else "n/a (judge degenerate: all match|close)"
        print(f"  {'study3-only':<14}{'':>4}{len(indep_pairs):>8}"
              f"{100*po2:>8.1f}%  {kk}")
    print()
    print("  Pre-registered bar: kappa >= 0.6 overall, >= 0.5 per stratum.")
    print()
    print("  READING:")
    print("  - study5/study6 rows: oracle==grader by construction (both apply the")
    print("    same canonical rule to the agent self-report) -> agreement 100%,")
    print("    kappa undefined/1.0. This confirms the GRADER is internally")
    print("    consistent but is NOT an independent human check.")
    print("  - study3 rows: compiler oracle vs LLM statement-fidelity judge is a")
    print("    genuine independent comparison. The judge is near-degenerate")
    print("    (48/54 'match'), so kappa is low/undefined -- the judge and the")
    print("    compiler measure DIFFERENT things (fidelity vs completeness).")
    print("  - BOTTOM LINE: the literal pre-registered human<->LLM kappa is")
    print("    UNCOMPUTABLE without a human session. No proxy clears the 0.6 bar")
    print("    as an independent check; the bar can only be tested by running")
    print("    grade.py with a real grader.")


if __name__ == "__main__":
    main()
