#!/usr/bin/env python3
"""Auto-resume orchestrator for Study 7 (inline-content ablation).

Same shape as experiments/false_claim/auto_resume.py. One call
decides and acts, returns a status line and an exit code. Designed
to be polled from cron, a /loop, or an outer wrapper that sleeps
between calls.

  COMPLETE   (0)  -> target genuine cells reached, driver dead
  RUNNING    (10) -> driver alive
  WAIT_LIMIT (11) -> driver dead, quota still 429
  RELAUNCHED (12) -> driver was dead, quota OK, relaunched
  INCONCLUSIVE (13) -> probe ambiguous
  STALL      (20) -> repeated relaunches with no new genuine cells

Default target: 6 problems x 4 conditions x 6 runs = 144 cells.

Use this when (re-)launching Study 7 across multiple rate-limit
windows. The poisoned cells from prior partial runs are cleaned up
automatically on the next driver launch (the driver's `cell_done`
hook deletes any meta.json whose record matches the poisoned
heuristic).
"""
from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
RESULTS = HERE / "results"
STATE = HERE / ".auto_resume_state.json"
RUN_LOG = HERE / "run.log"
TARGET = 6 * 4 * 6              # = 144
MAX_STALLED_RELAUNCHES = 3
PROBE = REPO / "experiments" / "forced_viz" / "probe_limit.py"
DRIVER = HERE / "run_inline_content.py"


def counts() -> tuple[int, int]:
    g = p = 0
    for d in RESULTS.iterdir() if RESULTS.exists() else []:
        mp = d / "meta.json"
        if not mp.exists():
            continue
        try:
            m = json.loads(mp.read_text())
        except Exception:
            continue
        if (m.get("tool_calls_attempted", 0) == 0
                and not m.get("claude_timed_out", False)
                and m.get("wall_clock_s", 0) < 30):
            p += 1
        else:
            g += 1
    return g, p


def driver_alive() -> bool:
    r = subprocess.run(["pgrep", "-f", "run_inline_content.py"],
                       capture_output=True, text=True)
    return r.returncode == 0 and r.stdout.strip() != ""


def probe() -> int:
    r = subprocess.run([sys.executable, str(PROBE)],
                       capture_output=True, text=True)
    sys.stderr.write(f"  probe: {r.stdout.strip()}\n")
    return r.returncode


def relaunch() -> None:
    with RUN_LOG.open("a") as log:
        subprocess.Popen(
            [sys.executable, str(DRIVER),
             "--runs", "6", "--budget-minutes", "12"],
            cwd=str(REPO), stdout=log, stderr=subprocess.STDOUT,
            start_new_session=True)


def load_state() -> dict:
    try:
        return json.loads(STATE.read_text())
    except Exception:
        return {"stalled_relaunches": 0, "last_genuine_at_relaunch": -1}


def main() -> int:
    g, p = counts()
    alive = driver_alive()
    st = load_state()
    if g >= TARGET and not alive:
        print(f"COMPLETE genuine={g}")
        return 0
    if alive:
        print(f"RUNNING genuine={g} poisoned={p}")
        return 10
    pc = probe()
    if pc == 1:
        print(f"WAIT_LIMIT genuine={g} poisoned={p}")
        return 11
    if pc == 2:
        print(f"INCONCLUSIVE genuine={g}")
        return 13
    if g <= st.get("last_genuine_at_relaunch", -1):
        st["stalled_relaunches"] = st.get("stalled_relaunches", 0) + 1
    else:
        st["stalled_relaunches"] = 0
    if st["stalled_relaunches"] >= MAX_STALLED_RELAUNCHES:
        print(f"STALL genuine={g} (no progress over "
              f"{MAX_STALLED_RELAUNCHES} relaunches)")
        return 20
    st["last_genuine_at_relaunch"] = g
    st["last_relaunch_ts"] = time.time()
    STATE.write_text(json.dumps(st))
    relaunch()
    print(f"RELAUNCHED genuine={g} poisoned={p} "
          f"(stall_counter={st['stalled_relaunches']})")
    return 12


if __name__ == "__main__":
    raise SystemExit(main())
