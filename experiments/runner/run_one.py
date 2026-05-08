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
import contextlib
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
REFERENCE_LOCK_DIR = REPO / "putnam"


@contextlib.contextmanager
def lock_reference_dir(path: Path = REFERENCE_LOCK_DIR):
    """While the body runs, make `path` untraversable so a sandboxed
    Claude (which has unrestricted Bash under bypassPermissions) cannot
    `cat` the reference formalizations even with absolute paths.
    Locking the top-level dir is sufficient — children become
    unreachable without touching their individual perms.
    """
    if not path.exists():
        yield
        return
    original_mode = path.stat().st_mode
    os.chmod(path, 0o000)
    try:
        yield
    finally:
        os.chmod(path, original_mode)


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
                    settings_src: Path, prompt: str,
                    condition: str, problem_id: str) -> Path:
    """Create the per-attempt workspace and return its path.

    For the `probe_lean` framing (condition `probe_lean`), drop a
    `Theorem.lean` containing the theorem signature instead of the
    LaTeX excerpt — the framing is exactly the difference between
    these two presentations of the same problem.
    """
    tmpdir = Path(tempfile.mkdtemp(prefix=f"exp_{tag}_"))
    workspace = tmpdir / "workspace"
    template = EXPS / "workspace_template"

    # Copy template (without .lake) and symlink the shared .lake.
    shutil.copytree(template, workspace,
                    ignore=shutil.ignore_patterns(".lake"))
    template_lake = template / ".lake"
    if template_lake.exists():
        (workspace / ".lake").symlink_to(template_lake.resolve())

    if condition == "probe_lean":
        stub = (EXPS / "probe_framing" / "lean_stmts"
                / f"{problem_id.replace('.', '_')}.lean")
        if not stub.exists():
            sys.exit(f"missing lean stub for {problem_id}: {stub}")
        shutil.copy2(stub, workspace / "Theorem.lean")
    else:
        shutil.copy2(excerpt_path, workspace / excerpt_path.name)

    (workspace / "PROMPT.md").write_text(prompt)
    (workspace / ".claude").mkdir()
    shutil.copy2(settings_src, workspace / ".claude" / "settings.json")
    return workspace


def run_claude(workspace: Path, prompt: str, results_dir: Path,
               budget_s: int, grace_s: int = 20) -> tuple[int, bool]:
    """Invoke `claude --print` from the workspace, streaming stdout/stderr to
    disk so partial output survives a kill. SIGTERM at the budget; SIGKILL
    after `grace_s` if the process hasn't exited.

    Returns (rc, timed_out). Stream-json output lands at
    `results_dir/claude_stdout.json` (one JSONL event per line).
    """
    cmd = [
        "claude", "--print",
        "--output-format", "stream-json",
        "--verbose",
        prompt,
    ]
    stdout_path = results_dir / "claude_stdout.json"
    stderr_path = results_dir / "claude_stderr.log"
    timed_out = False
    with stdout_path.open("w") as out_f, stderr_path.open("w") as err_f:
        proc = subprocess.Popen(
            cmd,
            cwd=workspace,
            stdout=out_f,
            stderr=err_f,
            text=True,
        )
        try:
            rc = proc.wait(timeout=budget_s)
        except subprocess.TimeoutExpired:
            timed_out = True
            proc.terminate()
            try:
                rc = proc.wait(timeout=grace_s)
            except subprocess.TimeoutExpired:
                proc.kill()
                rc = proc.wait()
    return rc, timed_out


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


def _iter_stream_events(stream_path: Path):
    """Yield each JSONL event from a stream-json transcript on disk.
    Skips malformed lines (e.g. a truncated tail when claude was killed)."""
    if not stream_path.exists():
        return
    with stream_path.open() as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def extract_self_report(stream_path: Path) -> dict | None:
    """Find the last fenced ```json ... ``` block across all assistant text."""
    chunks: list[str] = []
    for ev in _iter_stream_events(stream_path):
        if ev.get("type") != "assistant":
            continue
        for block in (ev.get("message") or {}).get("content", []) or []:
            if block.get("type") == "text":
                chunks.append(block.get("text", ""))
    transcript = "\n".join(chunks)
    blocks = re.findall(r"```json\s*(\{.*?\})\s*```", transcript, re.S)
    for raw in reversed(blocks):
        try:
            return json.loads(raw)
        except Exception:
            continue
    return None


def count_tool_calls(stream_path: Path) -> dict:
    """Per-tool {attempted, succeeded} from a stream-json transcript.

    `attempted` counts every `tool_use` block. `succeeded` counts those whose
    matching `tool_result` (by `tool_use_id`) is not flagged `is_error: true`
    — so permission denials and runtime failures don't masquerade as real
    tool usage in the meta.json totals.
    """
    name_by_id: dict[str, str] = {}
    attempted: dict[str, int] = {}
    succeeded: dict[str, int] = {}
    for ev in _iter_stream_events(stream_path):
        kind = ev.get("type")
        content = (ev.get("message") or {}).get("content", []) or []
        if kind == "assistant":
            for block in content:
                if block.get("type") == "tool_use":
                    name = block.get("name") or "<unknown>"
                    tid = block.get("id")
                    if tid:
                        name_by_id[tid] = name
                    attempted[name] = attempted.get(name, 0) + 1
        elif kind == "user":
            for block in content:
                if block.get("type") != "tool_result":
                    continue
                tid = block.get("tool_use_id")
                name = name_by_id.get(tid)
                if name and not block.get("is_error"):
                    succeeded[name] = succeeded.get(name, 0) + 1
    names = set(attempted) | set(succeeded)
    return {n: {"attempted": attempted.get(n, 0),
                "succeeded": succeeded.get(n, 0)} for n in sorted(names)}


CONDITION_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_]*$")


def run_one(problem_id: str, condition: str, run_index: int,
            budget_minutes: int, budget_calls: int,
            results_root: Path | None = None) -> Path:
    if not CONDITION_RE.match(condition):
        sys.exit(f"condition {condition!r} must match {CONDITION_RE.pattern}")
    row = load_manifest_row(problem_id)
    excerpt_path = REPO / row["excerpt_path"]

    template_path = EXPS / "prompts" / f"condition_{condition.lower()}.template.md"
    wrapup_minutes = max(1, budget_minutes - 1)
    prompt = render(
        template_path.read_text(),
        PROBLEM_ID=problem_id,
        EXCERPT_PATH=excerpt_path.name,
        BUDGET_MINUTES=str(budget_minutes),
        WRAPUP_MINUTES=str(wrapup_minutes),
        BUDGET_TOOL_CALLS=str(budget_calls),
    )
    settings_src = EXPS / "settings" / f"condition_{condition.lower()}.settings.json"

    tag = f"{problem_id.replace('.', '_')}__{condition}__r{run_index}"
    workspace = setup_workspace(tag, excerpt_path, settings_src, prompt,
                                condition, problem_id)
    print(f"[{tag}] workspace = {workspace}")

    results_dir = (results_root or (EXPS / "results")) / tag
    results_dir.mkdir(parents=True, exist_ok=True)
    (results_dir / "prompt.md").write_text(prompt)

    started = time.time()
    with lock_reference_dir():
        rc, timed_out = run_claude(
            workspace, prompt, results_dir,
            budget_s=budget_minutes * 60 + 60,
        )
    ended = time.time()

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

    stream_path = results_dir / "claude_stdout.json"
    self_report = extract_self_report(stream_path)
    tool_counts = count_tool_calls(stream_path)

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
        "tool_calls_attempted": sum(c["attempted"] for c in tool_counts.values()),
        "tool_calls_succeeded": sum(c["succeeded"] for c in tool_counts.values()),
        "self_report": self_report,
        "workspace": str(workspace),
    }
    (results_dir / "meta.json").write_text(json.dumps(meta, indent=2))

    flag = "OK" if (build_ok and sorries == 0) else "X"
    print(f"[{tag}] {flag}  build={build_ok}  sorries={sorries}  "
          f"wall={meta['wall_clock_s']:.1f}s  "
          f"tools={meta['tool_calls_succeeded']}/{meta['tool_calls_attempted']}")
    print(f"  -> {results_dir.relative_to(REPO)}")
    return results_dir


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("problem_id")
    ap.add_argument("condition")
    ap.add_argument("run_index", type=int)
    ap.add_argument("--budget-minutes", type=int, default=30)
    ap.add_argument("--budget-calls", type=int, default=80)
    ap.add_argument("--results-root",
                    help="override results dir (default: experiments/results)")
    args = ap.parse_args()
    results_root = Path(args.results_root) if args.results_root else None
    run_one(args.problem_id, args.condition, args.run_index,
            args.budget_minutes, args.budget_calls,
            results_root=results_root)


if __name__ == "__main__":
    main()
