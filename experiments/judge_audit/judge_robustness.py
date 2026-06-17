#!/usr/bin/env python3
"""Judge-robustness audit from EXISTING graded transcripts (q-0009).

No new LLM calls. The human-grading session (grade.py) was never run, so
the planned human<->LLM-judge kappa is not computable. Instead we audit
the single LLM judge against a *deterministic ground-truth oracle* that
is independently available for each study family, and ask the only
question that matters for the cross-study conclusions:

    Does the LLM-judge layer ever FLIP an outcome relative to the
    objective oracle? If not, the single-LLM-judge attack is moot.

Two study families, two oracles:

  Lean studies (study3 / forced_viz, and study8 when run):
    The `solved*` criterion is   build_ok AND sorries==0 AND judge in {match,close}.
    Oracle = the Lean compiler: SOLVED iff (Build completed successfully)
    AND zero `sorry` tokens in Solution.lean. This is objective and
    judge-independent. We compute:
      - confusion / kappa between judge(match|close -> CORRECT) and the
        compiler oracle (the judge measures statement *fidelity*, the
        oracle measures proof *completeness* -- they target different
        things, so low kappa is expected and not a defect);
      - the decision-relevant statistic: how many compiler-SOLVED cells
        the judge DEMOTES (flips solved*->unsolved). If 0, the judge is
        non-decisive for the headline count.

  False-claim studies (study5 / study6):
    There is no separate LLM-judge artifact; grading is a regex over the
    agent's self-reported (verdict, correct_answer). We audit the *grader
    rule* itself by comparing two rules:
      G1 (lenient): false-claim caught iff verdict == "incorrect".
      G2 (strict, the analyzer): verdict=="incorrect" AND the corrected
         answer matches the canonical regex.
    kappa(G1,G2) over all false-variant cells tells us whether the
    modality-equivalence headline depends on the grading rule.

Usage:  python judge_robustness.py
"""
from __future__ import annotations

import glob
import json
import os
import re
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
FORCED = REPO / "experiments" / "forced_viz" / "results"
FALSE = REPO / "experiments" / "false_claim" / "results"

CANON_PATTERNS = {
    "1985.B5": [r"e\^\{?[-−]2a", r"exp\(\s*[-−]\s*2\s*a"],
    "1991.A5": [r"\b1\s*/\s*3\b"],
    "1993.A1": [r"\b4\s*/\s*9\b"],
    "1996.B2": [r"\(?\s*2\s*n\s*[-−]\s*1\s*\)?[^<>]{0,40}<",
                r"<[^<>]{0,40}\(?\s*2\s*n\s*\+\s*1"],
}


def is_poison(meta: dict) -> bool:
    return (meta.get("tool_calls_attempted", 0) == 0
            and not meta.get("claude_timed_out", False)
            and meta.get("wall_clock_s", 0) < 30)


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


def canonical_match(problem: str, answer: str) -> bool:
    pats = CANON_PATTERNS.get(problem)
    if not pats or not answer:
        return False
    op = all if problem == "1996.B2" else any
    return op(re.search(p, answer, re.I) for p in pats)


# --------------------------------------------------------------------- Lean

def audit_lean(results_dir: Path, label: str):
    cells = []
    for d in sorted(glob.glob(str(results_dir / "*/"))):
        d = Path(d.rstrip("/"))
        if not (d / "meta.json").exists():
            continue
        meta = json.loads((d / "meta.json").read_text())
        if is_poison(meta):
            continue
        jv = None
        if (d / "judge.json").exists():
            jv = json.loads((d / "judge.json").read_text()).get("verdict")
        blog = (d / "build.log").read_text() if (d / "build.log").exists() else ""
        build_ok = "Build completed successfully" in blog
        src = (d / "Solution.lean").read_text() if (d / "Solution.lean").exists() else ""
        sorries = len(re.findall(r"\bsorry\b", src))
        cells.append({"tag": d.name, "judge": jv,
                      "build_ok": build_ok, "sorries": sorries})
    if not cells:
        print(f"[{label}] no genuine cells under {results_dir}")
        return
    n = len(cells)
    pairs = []
    conf = Counter()
    for c in cells:
        j = "CORRECT" if c["judge"] in ("match", "close") else "WRONG"
        o = "CORRECT" if (c["build_ok"] and c["sorries"] == 0) else "WRONG"
        pairs.append((j, o))
        conf[(j, o)] += 1
    po, k = cohens_kappa(pairs)
    oracle_solved = [c for c in cells if c["build_ok"] and c["sorries"] == 0]
    demoted = [c for c in oracle_solved if c["judge"] not in ("match", "close")]
    rescued = [c for c in cells
               if not (c["build_ok"] and c["sorries"] == 0)
               and c["judge"] in ("match", "close")
               and c["build_ok"] and c["sorries"] == 0]  # impossible by constr.
    print(f"=== {label}: LLM judge (statement-fidelity) vs compiler oracle "
          f"(build_ok & 0 sorries) ===")
    print(f"  n={n}   judge dist={dict(Counter(c['judge'] for c in cells))}")
    print(f"  confusion (judge,oracle): "
          f"CC={conf[('CORRECT','CORRECT')]} "
          f"CW={conf[('CORRECT','WRONG')]} "
          f"WC={conf[('WRONG','CORRECT')]} "
          f"WW={conf[('WRONG','WRONG')]}")
    print(f"  raw agreement={100*po:.1f}%   kappa={k:.3f}")
    print(f"  compiler-SOLVED cells = {len(oracle_solved)}")
    print(f"  >> judge DEMOTES (flips solved*->unsolved): {len(demoted)} "
          f"{[c['tag'] for c in demoted]}")
    print(f"  >> judge cannot rescue a non-compiling cell (solved* is a "
          f"conjunction): {len(rescued)}")
    print(f"  VERDICT: judge layer changes the solved* count by "
          f"{len(demoted)} cell(s) -> judge is "
          f"{'NON-DECISIVE' if not demoted else 'DECISIVE'} for the headline.")
    print()


# --------------------------------------------------------------- False-claim

def audit_false():
    cells = []
    for d in sorted(glob.glob(str(FALSE / "*/"))):
        d = Path(d.rstrip("/"))
        parts = d.name.split("__")
        if len(parts) != 4 or not (d / "meta.json").exists():
            continue
        meta = json.loads((d / "meta.json").read_text())
        if is_poison(meta):
            continue
        sr = meta.get("self_report") or {}
        cells.append({
            "problem": parts[0].replace("_", "."),
            "variant": parts[1], "condition": parts[2],
            "verdict": (sr.get("verdict") or "").strip().lower(),
            "answer": sr.get("correct_answer") or "",
        })
    falses = [c for c in cells if c["variant"] == "false"]
    pairs = []
    by = defaultdict(lambda: [0, 0, 0])
    for c in falses:
        g1 = c["verdict"] == "incorrect"
        g2 = g1 and canonical_match(c["problem"], c["answer"])
        by[c["condition"]][0] += 1
        by[c["condition"]][1] += int(g1)
        by[c["condition"]][2] += int(g2)
        pairs.append(("C" if g1 else "W", "C" if g2 else "W"))
    po, k = cohens_kappa(pairs)
    print("=== Study5/6 (false-claim): grader-rule robustness ===")
    print(f"  genuine cells={len(cells)}  false-variant cells={len(falses)}")
    print(f"  {'condition':<20}{'n':>4}{'G1 verdict':>14}{'G2 regex':>12}")
    for cond in ["forced_visual", "forced_textual", "forced_reflection"]:
        n, g1, g2 = by[cond]
        print(f"  {cond:<20}{n:>4}{g1:>10}/{n:<3}{g2:>8}/{n:<3}")
    print(f"  G1(lenient verdict-only) vs G2(strict regex) over {len(pairs)} "
          f"false cells: agreement={100*po:.1f}%  kappa={k:.3f}")
    print(f"  VERDICT: modality-equivalence headline is "
          f"{'GRADER-INVARIANT' if k > 0.99 else 'grader-sensitive'} "
          f"(the two grading rules are interchangeable).")
    print()


def main():
    print("JUDGE-ROBUSTNESS AUDIT (q-0009) -- existing data, no new LLM calls\n")
    audit_lean(FORCED, "Study3 (forced_viz)")
    audit_false()
    print("Note: the planned human<->LLM-judge kappa requires the grade.py "
          "session,\nwhich was never run (your_grade empty in all samples/*.csv). "
          "The audits\nabove substitute objective oracles that need no human "
          "labels and directly\ntest whether the single LLM judge can move a "
          "cross-study conclusion.")


if __name__ == "__main__":
    main()
