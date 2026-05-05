#!/usr/bin/env python3
"""Run a single experiment attempt: one (problem, condition, run_index) tuple.

Each attempt:
  1. Builds a fresh workspace (copy of `workspace_template/`, with `.lake/`
     symlinked from the template so Mathlib oleans are reused).
  2. Drops `<problem_id>.tex`, the rendered prompt, and a per-condition
     `.claude/settings.json` into the workspace.
  3. Invokes `claude --print --output-format json` from inside the workspace.
  4. Runs `lake build` afterwards to check whether the solution compiles.
  5. Saves everything to `experiments/results/<tag>/`.

Usage (from repo root):
    python3 experiments/runner/run_one.py <problem_id> <A|B> <run_index>
                                         [--budget-minutes N] [--budget-calls N]

Example:
    python3 experiments/runner/run_one.py 1985.B5 A 0 --budget-minutes 30
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
EXPS = REPO / "experiments"


def load_manifest_row(problem_id: str) -> dict:
    with (EXPS / "manifest.csv").open() as f:
        for row in csv.DictReader(f):
            if row["problem_id"] == problem_id:
                return row
    sys.exit(f"problem_id {problem_id!r} not found in manifest.csv")


def render(template: str, **kwargs) -> str:
    for k, v in kwargs.items():
        template = template.replace("{{" + k + "}}", str(v))
    return template


def setup_workspace(tag: str, excerpt_path: Path,
                    settings_src: Path, prompt: str) -> Path:
    """Create the per-attempt workspace and return its path."""
    tmpdir = Path(tempfile.mkdtemp(prefix=f"exp_{tag}_"))
    workspace = tmpdir / "workspace"
    template = EXPS / "workspace_template"

    # Copy template (without .lake) and symlink the shared .lake.
    shutil.copytree(template, workspace,
                    ignore=shutil.ignore_patterns(".lake"))
    template_lake = template / ".lake"
    if template_lake.exists():
        (workspace / ".lake").symlink_to(template_lake.resolve())

    # Drop the LaTeX excerpt, the prompt, and the settings.
    shutil.copy2(excerpt_path, workspace / excerpt_path.name)
    (workspace / "PROMPT.md").write_text(prompt)
    (workspace / ".claude").mkdir()
    shutil.copy2(settings_src, workspace / ".claude" / "settings.json")
    return workspace


def run_claude(workspace: Path, prompt: str, timeout_s: int) -> tuple[int, str, str]:
    """Invoke `claude --print` from the workspace; return (rc, stdout, stderr)."""
    cmd = [
        "claude", "--print",
        "--output-format", "json",
        prompt,
    ]
    proc = subprocess.run(
        cmd,
        cwd=workspace,
        capture_output=True,
        text=True,
        timeout=timeout_s,
    )
    return proc.returncode, proc.stdout, proc.stderr


def lake_build(workspace: Path, timeout_s: int = 600) -> tuple[bool, str]:
    proc = subprocess.run(
        ["lake", "build"],
        cwd=workspace,
        capture_output=True,
        text=True,
        timeout=timeout_s,
    )
    log = (proc.stdout or "") + "\n--- stderr ---\n" + (proc.stderr or "")
    return (proc.returncode == 0), log


def extract_self_report(transcript: str) -> dict | None:
    """Find the last fenced ```json ... ``` block in Claude's transcript."""
    blocks = re.findall(r"```json\s*(\{.*?\})\s*```", transcript, re.S)
    if not blocks:
        return None
    try:
        return json.loads(blocks[-1])
    except Exception:
        return None


def count_tool_calls(transcript_json_str: str) -> dict:
    """When --output-format json is used, claude returns a structured
    transcript. Extract per-tool counts. Resilient to schema drift:
    falls back to {} if the structure is unexpected."""
    counts: dict[str, int] = {}
    try:
        obj = json.loads(transcript_json_str)
    except Exception:
        return counts
    # Claude Code's print-json output has variants; walk all dicts looking
    # for keys that look like tool-use records.
    def walk(x):
        if isinstance(x, dict):
            tname = x.get("name") or x.get("tool_name") or x.get("tool")
            if tname and (
                "type" in x and "use" in str(x.get("type", ""))
                or "input" in x
            ):
                counts[tname] = counts.get(tname, 0) + 1
            for v in x.values():
                walk(v)
        elif isinstance(x, list):
            for v in x:
                walk(v)
    walk(obj)
    return counts


def run_one(problem_id: str, condition: str, run_index: int,
            budget_minutes: int, budget_calls: int) -> Path:
    assert condition in {"A", "B"}, "condition must be 'A' or 'B'"
    row = load_manifest_row(problem_id)
    excerpt_path = REPO / row["excerpt_path"]

    template_path = EXPS / "prompts" / f"condition_{condition.lower()}.template.md"
    prompt = render(
        template_path.read_text(),
        PROBLEM_ID=problem_id,
        EXCERPT_PATH=excerpt_path.name,
        BUDGET_MINUTES=str(budget_minutes),
        BUDGET_TOOL_CALLS=str(budget_calls),
    )
    settings_src = EXPS / "settings" / f"condition_{condition.lower()}.settings.json"

    tag = f"{problem_id.replace('.', '_')}__{condition}__r{run_index}"
    workspace = setup_workspace(tag, excerpt_path, settings_src, prompt)
    print(f"[{tag}] workspace = {workspace}")

    started = time.time()
    try:
        rc, stdout, stderr = run_claude(
            workspace, prompt,
            timeout_s=budget_minutes * 60 + 120,
        )
        timed_out = False
    except subprocess.TimeoutExpired as e:
        rc = -1
        stdout = (e.stdout or b"").decode("utf-8", errors="replace") if isinstance(e.stdout, (bytes, bytearray)) else (e.stdout or "")
        stderr = (e.stderr or b"").decode("utf-8", errors="replace") if isinstance(e.stderr, (bytes, bytearray)) else (e.stderr or "")
        timed_out = True
    ended = time.time()

    # Save artifacts.
    results_dir = EXPS / "results" / tag
    results_dir.mkdir(parents=True, exist_ok=True)
    (results_dir / "claude_stdout.json").write_text(stdout)
    (results_dir / "claude_stderr.log").write_text(stderr)
    (results_dir / "prompt.md").write_text(prompt)

    # Copy Solution.lean if Claude wrote one.
    sol_in = workspace / "Solution.lean"
    sol_out = results_dir / "Solution.lean"
    if sol_in.exists():
        shutil.copy2(sol_in, sol_out)
        sorries = sol_out.read_text().count("sorry")
    else:
        sorries = -1  # not produced

    # Build check.
    if sol_in.exists():
        build_ok, build_log = lake_build(workspace)
    else:
        build_ok, build_log = False, "Solution.lean not produced."
    (results_dir / "build.log").write_text(build_log)

    # Self-report JSON from Claude.
    self_report = extract_self_report(stdout)

    # Tool counts (best-effort).
    tool_counts = count_tool_calls(stdout)

    meta = {
        "problem_id": problem_id,
        "condition": condition,
        "run_index": run_index,
        "tags": row["tags"],
        "category": row["category"],
        "started_at": started,
        "ended_at": ended,
        "wall_clock_s": ended - started,
        "budget_minutes": budget_minutes,
        "budget_tool_calls": budget_calls,
        "claude_exit_code": rc,
        "claude_timed_out": timed_out,
        "solution_produced": sol_in.exists(),
        "build_ok": build_ok,
        "sorries_remaining": sorries,
        "tool_counts": tool_counts,
        "tool_calls_total": sum(tool_counts.values()),
        "self_report": self_report,
        "workspace": str(workspace),
    }
    (results_dir / "meta.json").write_text(json.dumps(meta, indent=2))

    flag = "OK" if (build_ok and sorries == 0) else "X"
    print(f"[{tag}] {flag}  build={build_ok}  sorries={sorries}  "
          f"wall={meta['wall_clock_s']:.1f}s  tools={meta['tool_calls_total']}")
    print(f"  -> {results_dir.relative_to(REPO)}")
    return results_dir


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("problem_id")
    ap.add_argument("condition", choices=["A", "B"])
    ap.add_argument("run_index", type=int)
    ap.add_argument("--budget-minutes", type=int, default=30)
    ap.add_argument("--budget-calls", type=int, default=80)
    args = ap.parse_args()
    run_one(args.problem_id, args.condition, args.run_index,
            args.budget_minutes, args.budget_calls)


if __name__ == "__main__":
    main()
