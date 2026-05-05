#!/usr/bin/env python3
"""Parse putnam/real_analysis/real_analysis_problems.tex into a CSV manifest
and a per-problem .tex excerpt under experiments/problem_excerpts/.

Each row:
    problem_id, year, letter, number, tags, category, excerpt_path

`category` is "graph-friendly" or "not", derived from tags via the mapping
below. `excerpt_path` is the per-problem .tex file (a self-contained
fragment usable directly in the experiment prompt).

Usage (from repo root):
    python3 experiments/runner/extract_manifest.py
"""
from __future__ import annotations

import csv
import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SRC = REPO / "putnam" / "real_analysis" / "real_analysis_problems.tex"
OUT_DIR = REPO / "experiments"
EXCERPTS_DIR = OUT_DIR / "problem_excerpts"
MANIFEST = OUT_DIR / "manifest.csv"

# Tag -> "graph-friendly" mapping. A problem is graph-friendly if ANY of
# its tags is in this set.
GRAPH_FRIENDLY_TAGS = {
    "integral-evaluation",
    "integral-inequality",
    "derivative-inequality",
    "asymptotic",
    "ode",
    "iteration",
}

PARAGRAPH_RE = re.compile(
    r"\\paragraph\{"
    r"(?P<year>\d{4})\s+(?P<letter>[AB])--(?P<num>\d+)\s+"
    r"\\textnormal\{\[\\texttt\{(?P<tags>[^\}]*)\}\]\}"
    r"\}"
)
SECTION_RE = re.compile(r"^\\section\*?\{")


def parse() -> list[dict]:
    text = SRC.read_text()
    lines = text.splitlines()
    problems: list[dict] = []
    cur: dict | None = None
    body: list[str] = []

    def flush():
        if cur is not None:
            cur["body"] = "\n".join(body).strip()
            problems.append(cur)

    for line in lines:
        m = PARAGRAPH_RE.match(line.strip())
        if m:
            flush()
            tags = [t.strip() for t in m.group("tags").split(",") if t.strip()]
            category = "graph-friendly" if any(
                t in GRAPH_FRIENDLY_TAGS for t in tags
            ) else "not"
            cur = {
                "problem_id": f"{m.group('year')}.{m.group('letter')}{m.group('num')}",
                "year": m.group("year"),
                "letter": m.group("letter"),
                "number": m.group("num"),
                "tags": tags,
                "category": category,
                "header": line.rstrip(),
            }
            body = []
            continue
        if SECTION_RE.match(line.strip()):
            flush()
            cur = None
            body = []
            continue
        if cur is not None:
            body.append(line)

    flush()
    return problems


def write_excerpts(problems: list[dict]) -> None:
    EXCERPTS_DIR.mkdir(parents=True, exist_ok=True)
    for p in problems:
        path = EXCERPTS_DIR / f"{p['year']}_{p['letter']}{p['number']}.tex"
        content = f"{p['header']}\n{p['body']}\n"
        path.write_text(content)
        p["excerpt_path"] = str(path.relative_to(REPO))


def write_manifest(problems: list[dict]) -> None:
    with MANIFEST.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(
            ["problem_id", "year", "letter", "number", "tags", "category",
             "excerpt_path"]
        )
        for p in problems:
            w.writerow([
                p["problem_id"], p["year"], p["letter"], p["number"],
                "|".join(p["tags"]), p["category"], p["excerpt_path"],
            ])


def main() -> None:
    problems = parse()
    write_excerpts(problems)
    write_manifest(problems)
    n = len(problems)
    n_gf = sum(1 for p in problems if p["category"] == "graph-friendly")
    print(f"Parsed {n} problems "
          f"({n_gf} graph-friendly, {n - n_gf} not).")
    print(f"Manifest: {MANIFEST.relative_to(REPO)}")
    print(f"Excerpts: {EXCERPTS_DIR.relative_to(REPO)}/")


if __name__ == "__main__":
    main()
