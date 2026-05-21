#!/usr/bin/env python3
"""Study 4a' — Recall with chain-of-thought reasoning (no tools).

Same 6 problems × 3 runs design as 4a, but the prompt explicitly
permits multi-paragraph step-by-step prose reasoning before the final
ANSWER line. Tests whether the 4a → Study-3 gap (30% → 80% answer
correctness) is reasoning depth or tool-mediated feedback.
"""
from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
EXCERPTS = REPO / "experiments" / "problem_excerpts"
RESULTS = REPO / "experiments" / "recall_test" / "results_cot"
RESULTS.mkdir(parents=True, exist_ok=True)

PROBLEMS = ["1985.B5", "1989.A2", "1991.A5", "1993.A1",
            "1996.B2", "2006.A1"]
K = 3
BUDGET_S = 300

PROMPT = """Read the LaTeX problem statement at `{EXCERPT}`.

Solve this problem to determine the closed-form answer.

You **may not use any tools** (no Bash, no math-viz, no lean-lsp,
no symbolic computation). But you **may reason step by step in prose
for as long as you like before answering** — derive, sketch in
words, check special cases mentally, compare to known results.

When you have the answer, end with EXACTLY these two lines, in this
format:

ANSWER: <one-line closed form or true/false verdict>
CONFIDENCE: high | medium | low

For "Evaluate / Find / Compute / Determine X" problems, ANSWER is the
closed form of X.
For "Show that A < B < C" inequality problems, ANSWER is whether the
inequality is true as stated and correctly oriented (yes/no, plus
the correctly-oriented version if no).
For other "Show that ..." claims, ANSWER is whether the claim is true.
"""

SETTINGS = {
    "permissions": {
        "defaultMode": "bypassPermissions",
        "deny": [
            "mcp__math-viz", "mcp__math-compute", "mcp__math-search",
            "mcp__lean-lsp-mcp", "mcp__proof-explorer",
            "mcp__commutative-diagrams", "mcp__symdyn-shifts",
            "mcp__symdyn-tilings", "mcp__symdyn-viz",
            "mcp__symdyn-complexity", "mcp__meta-tools", "mcp__ide",
            "WebFetch", "WebSearch", "Bash", "Edit", "Write",
            "NotebookEdit", "Task",
        ],
    },
}


def parse_answer(stdout: str):
    answer = confidence = None
    for line in stdout.splitlines():
        line = line.strip()
        if not line: continue
        try: ev = json.loads(line)
        except Exception: continue
        if ev.get("type") != "assistant": continue
        for b in (ev.get("message") or {}).get("content") or []:
            if b.get("type") != "text": continue
            for ln in b.get("text", "").splitlines():
                ln = ln.strip()
                if ln.startswith("ANSWER:"):
                    answer = ln[len("ANSWER:"):].strip()
                elif ln.startswith("CONFIDENCE:"):
                    confidence = ln[len("CONFIDENCE:"):].strip()
    return answer, confidence


def run_one(problem_id, run_index):
    tag = f"{problem_id.replace('.', '_')}__recall_cot__r{run_index}"
    out_dir = RESULTS / tag
    out_dir.mkdir(exist_ok=True)
    if (out_dir / "result.json").exists():
        print(f"  {tag} already done, skipping.")
        return
    excerpt = EXCERPTS / (problem_id.replace(".", "_") + ".tex")
    work = Path(tempfile.mkdtemp(prefix=f"recall_cot_{tag}_"))
    shutil.copy2(excerpt, work / excerpt.name)
    (work / ".claude").mkdir()
    (work / ".claude" / "settings.json").write_text(json.dumps(SETTINGS))
    prompt = PROMPT.format(EXCERPT=excerpt.name)
    t0 = time.time()
    try:
        proc = subprocess.run(
            ["claude", "--print", "--output-format", "stream-json",
             "--verbose", prompt],
            cwd=work, capture_output=True, text=True, timeout=BUDGET_S)
        timed_out = False
    except subprocess.TimeoutExpired as e:
        proc = e
        timed_out = True
    elapsed = time.time() - t0
    stdout = getattr(proc, "stdout", "") or ""
    if isinstance(stdout, bytes): stdout = stdout.decode("utf-8", "replace")
    (out_dir / "stdout.json").write_text(stdout)
    answer, confidence = parse_answer(stdout)
    (out_dir / "result.json").write_text(json.dumps({
        "problem_id": problem_id, "run_index": run_index,
        "wall_s": round(elapsed, 1),
        "exit_code": getattr(proc, "returncode", None),
        "timed_out": timed_out, "answer": answer,
        "confidence": confidence,
    }, indent=2))
    print(f"  {tag}  wall={elapsed:5.1f}s  conf={confidence!r:<10s}  "
          f"answer={(answer or '')[:90]!r}")


def main():
    print(f"Study 4a' (recall + CoT): "
          f"{len(PROBLEMS)} problems × {K} runs = {len(PROBLEMS)*K} calls")
    t0 = time.time()
    for p in PROBLEMS:
        for r in range(K):
            try: run_one(p, r)
            except Exception as e:
                print(f"  {p} r{r}  EXC {type(e).__name__}: {e}")
    print(f"\nDone in {(time.time()-t0)/60:.1f} min.")


if __name__ == "__main__":
    main()
