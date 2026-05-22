#!/usr/bin/env python3
"""Interactive grading CLI for the human judge audit.

Walks each row of a sample CSV. For each cell:

  1. Prints the LaTeX excerpt, canonical answer (if recoverable from
     the corpus), agent verdict, agent correct_answer.
  2. Hides the LLM judge verdict.
  3. Prompts for c/w/u (CORRECT/WRONG/UNCLEAR) + optional one-line
     note.
  4. Reveals the LLM judge's verdict after you commit.
  5. Writes your grade back to the CSV row.

Usage:
    python grade.py samples/study5.csv

Resumable: skips rows where `your_grade` is non-empty.
"""
from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent


def read_excerpt(row: dict) -> str:
    p = row.get("excerpt_path", "")
    if not p:
        return "[!] no excerpt path on this row"
    try:
        return Path(p).read_text()
    except Exception as e:
        return f"[!] could not read {p}: {e}"


def canonical_for(row: dict) -> str:
    """Try to look up the canonical answer for this cell."""
    tag = row.get("tag", "")
    study = row.get("study", "")

    if study in ("study5", "study6"):
        canon_p = REPO / "experiments/false_claim/canonical.json"
    elif study == "study8":
        canon_p = REPO / "experiments/geometric_corpus/canonical.json"
    elif study == "study3":
        return "(Study 3 — judge against the reference Mathlib formalization)"
    elif study == "study7":
        return "(Study 7 — judge the agent's stated answer against the problem's canonical)"
    else:
        return "(no canonical source configured)"

    if not canon_p.exists():
        return f"(canonical.json missing at {canon_p})"

    try:
        canon = json.loads(canon_p.read_text())
    except Exception as e:
        return f"(could not parse canonical.json: {e})"

    # Tag format: "<problem>__<variant>__<condition>__<run>"
    parts = tag.split("__")
    if len(parts) >= 1:
        problem = parts[0].replace("_", ".")
        return json.dumps(canon.get(problem, "(no entry)"), indent=2)
    return "(could not parse tag)"


def render(row: dict, idx: int, total: int):
    print()
    print("=" * 72)
    print(f"  Cell {idx + 1}/{total}   study={row['study']}   tag={row['tag']}")
    print("=" * 72)
    print()
    print("--- excerpt --------------------------------------------------------")
    print(read_excerpt(row))
    print()
    print("--- canonical (ground truth) --------------------------------------")
    print(canonical_for(row))
    print()
    print("--- agent self-report --------------------------------------------")
    print(f"  verdict        : {row['agent_verdict'] or '(none)'}")
    print(f"  correct_answer : {row['agent_answer'] or '(none)'}")
    print()


def prompt_grade() -> tuple[str, str]:
    while True:
        g = input("  Your grade [c=correct / w=wrong / u=unclear / s=skip]: ").strip().lower()
        if g in ("c", "w", "u", "s"):
            break
        print("    (please type c, w, u, or s)")
    if g == "s":
        return "", ""
    label = {"c": "CORRECT", "w": "WRONG", "u": "UNCLEAR"}[g]
    note = input("  One-line note (optional, ENTER to skip): ").strip()
    return label, note


def reveal(row: dict):
    print()
    print("--- LLM judge verdict (now revealed) -----------------------------")
    j = row.get("llm_judge_verdict", "")
    print(f"  llm_judge_verdict: {j or '(none)'}")
    print()


def save_csv(csv_path: Path, rows: list[dict]):
    with csv_path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)


def main():
    if len(sys.argv) != 2:
        print("usage: python grade.py <samples/study_name.csv>")
        sys.exit(2)

    csv_path = Path(sys.argv[1])
    if not csv_path.exists():
        print(f"[!] {csv_path} not found")
        sys.exit(1)

    with csv_path.open() as f:
        rows = list(csv.DictReader(f))

    if not rows:
        print("[!] empty CSV")
        sys.exit(1)

    pending = [(i, r) for i, r in enumerate(rows) if not r.get("your_grade")]
    if not pending:
        print(f"[*] {csv_path.name}: all {len(rows)} cells already graded.")
        sys.exit(0)

    print(f"[*] {csv_path.name}: "
          f"{len(rows) - len(pending)}/{len(rows)} already graded, "
          f"{len(pending)} pending.")
    print("    (Ctrl-C anywhere to stop; progress is saved per cell.)")

    try:
        for i, row in pending:
            render(row, i, len(rows))
            grade, note = prompt_grade()
            if grade == "":
                print("    skipped.")
                continue
            row["your_grade"] = grade
            row["notes"] = note
            reveal(row)
            save_csv(csv_path, rows)
            print(f"    saved -> {csv_path.name}")
    except KeyboardInterrupt:
        print("\n[*] stopped; progress saved.")


if __name__ == "__main__":
    main()
