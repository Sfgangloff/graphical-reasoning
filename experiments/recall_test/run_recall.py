#!/usr/bin/env python3
"""Study 4a — Closed-form recall test.

For each of the 6 problems used in Study 3, ask claude --print to
state the closed-form answer from memory, with no tools beyond
Read on the LaTeX excerpt. No Lean, no math-viz, no Bash. The
question this answers: did the model already know every answer,
making Study 3's null result inevitable regardless of viz?

6 problems × 3 runs = 18 calls. Each call is fast (no tool use).
"""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
EXCERPTS = REPO / "experiments" / "problem_excerpts"
RESULTS = REPO / "experiments" / "recall_test" / "results"
RESULTS.mkdir(parents=True, exist_ok=True)

PROBLEMS = ["1985.B5", "1989.A2", "1991.A5", "1993.A1",
            "1996.B2", "2006.A1"]
K = 3
BUDGET_S = 180  # generous; expected ~20-40s per call

PROMPT = """Read the LaTeX problem statement at `{EXCERPT}`.

State the closed-form answer to this problem, **from memory only —
no tools, no Bash, no computation**.

- If the problem asks "Evaluate / Find / Compute / Determine X",
  state the closed-form value of X.
- If the problem is "Show that A < B < C" or similar inequality,
  state whether the inequality is true as stated and correctly
  oriented (yes/no, and the correctly-oriented version if no).
- If the problem is a "Show that ..." identity / claim, state
  whether the claim is true.

Reply with EXACTLY two lines, in this format, and nothing else:
ANSWER: <one-line closed form or true/false verdict>
CONFIDENCE: high | medium | low
"""

# Deny essentially everything; allow Read of the workspace file only.
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


def parse_answer(stdout: str) -> tuple[str | None, str | None]:
    """Find the last assistant text in the stream and pull
    ANSWER:/CONFIDENCE: lines."""
    answer = confidence = None
    for line in stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            ev = json.loads(line)
        except Exception:
            continue
        if ev.get("type") != "assistant":
            continue
        for b in (ev.get("message") or {}).get("content") or []:
            if b.get("type") != "text":
                continue
            for ln in b.get("text", "").splitlines():
                ln = ln.strip()
                if ln.startswith("ANSWER:"):
                    answer = ln[len("ANSWER:"):].strip()
                elif ln.startswith("CONFIDENCE:"):
                    confidence = ln[len("CONFIDENCE:"):].strip()
    return answer, confidence


def run_one(problem_id: str, run_index: int) -> None:
    tag = f"{problem_id.replace('.', '_')}__recall__r{run_index}"
    out_dir = RESULTS / tag
    out_dir.mkdir(exist_ok=True)
    if (out_dir / "result.json").exists():
        print(f"  {tag} already done, skipping.")
        return
    excerpt = EXCERPTS / (problem_id.replace(".", "_") + ".tex")
    if not excerpt.exists():
        print(f"  {tag}  MISSING excerpt {excerpt}")
        return

    work = Path(tempfile.mkdtemp(prefix=f"recall_{tag}_"))
    shutil.copy2(excerpt, work / excerpt.name)
    (work / ".claude").mkdir()
    (work / ".claude" / "settings.json").write_text(json.dumps(SETTINGS))

    prompt = PROMPT.format(EXCERPT=excerpt.name)
    t0 = time.time()
    try:
        proc = subprocess.run(
            ["claude", "--print", "--output-format", "stream-json",
             "--verbose", prompt],
            cwd=work, capture_output=True, text=True,
            timeout=BUDGET_S,
        )
        timed_out = False
    except subprocess.TimeoutExpired as e:
        proc = e
        timed_out = True
    elapsed = time.time() - t0

    stdout = getattr(proc, "stdout", "") or ""
    if isinstance(stdout, bytes):
        stdout = stdout.decode("utf-8", "replace")
    (out_dir / "stdout.json").write_text(stdout)
    answer, confidence = parse_answer(stdout)

    (out_dir / "result.json").write_text(json.dumps({
        "problem_id": problem_id,
        "run_index": run_index,
        "wall_s": round(elapsed, 1),
        "exit_code": getattr(proc, "returncode", None),
        "timed_out": timed_out,
        "answer": answer,
        "confidence": confidence,
    }, indent=2))
    print(f"  {tag}  wall={elapsed:5.1f}s  conf={confidence!r:<10s}  "
          f"answer={answer!r}")


def main() -> None:
    print(f"Study 4a — recall test: {len(PROBLEMS)} problems × {K} runs "
          f"= {len(PROBLEMS)*K} calls")
    t0 = time.time()
    for p in PROBLEMS:
        for r in range(K):
            try:
                run_one(p, r)
            except Exception as e:
                print(f"  {p} r{r}  EXC {type(e).__name__}: {e}")
    print(f"\nDone in {(time.time()-t0)/60:.1f} min. "
          f"Results in {RESULTS}")


if __name__ == "__main__":
    main()
