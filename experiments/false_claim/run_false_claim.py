#!/usr/bin/env python3
"""Study 5 — adversarial sanity check.

For each of 4 problems × 2 variants (true/false claim asserted) × 3
conditions (forced_visual / forced_textual / forced_reflection) × k
runs, ask the model to determine whether the asserted claim is
correct. Tests: (i) whether forced viz catches a subtle near-miss
false claim (corrective mode); (ii) whether the corrective work
comes from the picture, the numerics, or just the forced pause.

Output is prose JSON, not Lean. Hardened against limit-poisoning
from the start: poisoned records (instant 429 from the API, no tool
calls) are auto-deleted and retried on next launch.

Usage (from repo root):
    python3 experiments/false_claim/run_false_claim.py
    python3 experiments/false_claim/run_false_claim.py --runs 1
    python3 experiments/false_claim/run_false_claim.py \\
        --problems 1996.B2 --conditions forced_visual
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]

PROBLEMS = ["1985.B5", "1991.A5", "1993.A1", "1996.B2"]
VARIANTS = ["true", "false"]
CONDITIONS = ["forced_visual", "forced_textual", "forced_reflection"]
RESULTS = HERE / "results"
EXCERPTS = HERE / "excerpts"


def render(template: str, **kw) -> str:
    for k, v in kw.items():
        template = template.replace("{{" + k + "}}", str(v))
    return template


def cell_done(tag: str) -> bool:
    meta_p = RESULTS / tag / "meta.json"
    if not meta_p.exists():
        return False
    try:
        m = json.loads(meta_p.read_text())
    except Exception:
        shutil.rmtree(RESULTS / tag, ignore_errors=True)
        return False
    poisoned = (m.get("tool_calls_attempted", 0) == 0
                and not m.get("claude_timed_out", False)
                and m.get("wall_clock_s", 0) < 30)
    if poisoned:
        print(f"  poisoned record ({tag}) — deleting, will retry.")
        shutil.rmtree(RESULTS / tag, ignore_errors=True)
        return False
    return True


def parse_self_report(stream_path: Path):
    chunks = []
    for line in stream_path.open() if stream_path.exists() else []:
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
            if b.get("type") == "text":
                chunks.append(b.get("text", ""))
    text = "\n".join(chunks)
    blocks = re.findall(r"```json\s*(\{.*?\})\s*```", text, re.S)
    for raw in reversed(blocks):
        try:
            return json.loads(raw)
        except Exception:
            continue
    return None


def count_tool_calls(stream_path: Path):
    name_by_id, attempted, succeeded = {}, {}, {}
    for line in stream_path.open() if stream_path.exists() else []:
        line = line.strip()
        if not line:
            continue
        try:
            ev = json.loads(line)
        except Exception:
            continue
        content = (ev.get("message") or {}).get("content") or []
        if ev.get("type") == "assistant":
            for b in content:
                if b.get("type") == "tool_use":
                    name = b.get("name") or "<unk>"
                    if b.get("id"):
                        name_by_id[b["id"]] = name
                    attempted[name] = attempted.get(name, 0) + 1
        elif ev.get("type") == "user":
            for b in content:
                if b.get("type") != "tool_result":
                    continue
                name = name_by_id.get(b.get("tool_use_id"))
                if name and not b.get("is_error"):
                    succeeded[name] = succeeded.get(name, 0) + 1
    names = set(attempted) | set(succeeded)
    return {n: {"attempted": attempted.get(n, 0),
                "succeeded": succeeded.get(n, 0)} for n in sorted(names)}


def png_read_back(stream_path: Path) -> bool:
    for line in stream_path.open() if stream_path.exists() else []:
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
            if b.get("type") != "tool_use" or b.get("name") != "Read":
                continue
            p = str((b.get("input") or {}).get("file_path", ""))
            if p.lower().endswith(".png"):
                return True
    return False


def run_one(problem_id: str, variant: str, condition: str,
            run_index: int, budget_minutes: int,
            budget_calls: int) -> None:
    tag = f"{problem_id.replace('.', '_')}__{variant}__{condition}__r{run_index}"
    if cell_done(tag):
        print(f"  already done ({tag}), skipping.")
        return

    excerpt = EXCERPTS / f"{problem_id.replace('.', '_')}_{variant}.tex"
    if not excerpt.exists():
        print(f"  MISSING excerpt {excerpt}")
        return
    tpl = HERE / "prompts" / f"{condition}.template.md"
    settings = HERE / "settings" / f"{condition}.settings.json"

    wrapup = max(1, budget_minutes - 1)
    prompt = render(
        tpl.read_text(),
        PROBLEM_ID=problem_id,
        VARIANT=variant,
        EXCERPT_PATH=excerpt.name,
        BUDGET_MINUTES=str(budget_minutes),
        WRAPUP_MINUTES=str(wrapup),
        BUDGET_TOOL_CALLS=str(budget_calls),
    )

    work = Path(tempfile.mkdtemp(prefix=f"fc_{tag}_"))
    shutil.copy2(excerpt, work / excerpt.name)
    (work / ".claude").mkdir()
    shutil.copy2(settings, work / ".claude" / "settings.json")

    out_dir = RESULTS / tag
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "prompt.md").write_text(prompt)

    t0 = time.time()
    timed_out = False
    stdout_path = out_dir / "claude_stdout.json"
    stderr_path = out_dir / "claude_stderr.log"
    with stdout_path.open("w") as out_f, stderr_path.open("w") as err_f:
        proc = subprocess.Popen(
            ["claude", "--print", "--output-format", "stream-json",
             "--verbose", prompt],
            cwd=work, stdout=out_f, stderr=err_f, text=True,
        )
        try:
            rc = proc.wait(timeout=budget_minutes * 60 + 60)
        except subprocess.TimeoutExpired:
            timed_out = True
            proc.terminate()
            try:
                rc = proc.wait(timeout=20)
            except subprocess.TimeoutExpired:
                proc.kill()
                rc = proc.wait()
    elapsed = time.time() - t0

    self_report = parse_self_report(stdout_path)
    tool_counts = count_tool_calls(stdout_path)
    meta = {
        "problem_id": problem_id,
        "variant": variant,
        "condition": condition,
        "run_index": run_index,
        "started_at": t0,
        "wall_clock_s": round(elapsed, 1),
        "claude_exit_code": rc,
        "claude_timed_out": timed_out,
        "tool_counts": tool_counts,
        "tool_calls_attempted": sum(c["attempted"]
                                    for c in tool_counts.values()),
        "tool_calls_succeeded": sum(c["succeeded"]
                                    for c in tool_counts.values()),
        "png_read_back": png_read_back(stdout_path),
        "self_report": self_report,
        "workspace": str(work),
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2))
    sr_verdict = (self_report or {}).get("verdict", "?")
    print(f"  {tag:<55s}  wall={elapsed:5.1f}s  "
          f"tools={meta['tool_calls_attempted']:>2}  "
          f"verdict={sr_verdict}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--runs", type=int, default=2,
                    help="runs per cell (default 2)")
    ap.add_argument("--budget-minutes", type=int, default=12)
    ap.add_argument("--budget-calls", type=int, default=80)
    ap.add_argument("--problems", nargs="+", default=PROBLEMS)
    ap.add_argument("--variants", nargs="+", default=VARIANTS,
                    choices=VARIANTS)
    ap.add_argument("--conditions", nargs="+", default=CONDITIONS,
                    choices=CONDITIONS)
    ap.add_argument("--start-index", type=int, default=0)
    args = ap.parse_args()

    cells = [(p, v, c, r) for p in args.problems
             for v in args.variants for c in args.conditions
             for r in range(args.start_index,
                            args.start_index + args.runs)]
    print(f"Study 5 — false-claim ablation: {len(cells)} cells "
          f"({len(args.problems)} probs × {len(args.variants)} variants "
          f"× {len(args.conditions)} conditions × {args.runs} runs)  "
          f"budget={args.budget_minutes}min/cell")
    t0 = time.time()
    for i, (p, v, c, r) in enumerate(cells, 1):
        print(f"\n=== cell {i}/{len(cells)}  "
              f"{p} / {v} / {c} / r{r}  "
              f"(elapsed {(time.time()-t0)/60:.1f}min) ===")
        try:
            run_one(p, v, c, r, args.budget_minutes, args.budget_calls)
        except Exception as e:
            print(f"  cell errored: {type(e).__name__}: {e}")
    print(f"\nDone in {(time.time()-t0)/60:.1f} min")


if __name__ == "__main__":
    main()
