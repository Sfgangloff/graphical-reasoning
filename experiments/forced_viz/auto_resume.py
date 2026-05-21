#!/usr/bin/env python3
"""Auto-resume orchestrator for the forced-viz matrix.

One call decides and acts. Prints a single status line and exits with a
code the monitor maps to an action:

  COMPLETE       (0)  -> 54 genuine cells, driver dead: run judge+analyze
  RUNNING        (10) -> driver alive, still working: just reschedule
  RELAUNCHED     (12) -> driver was dead, quota OK: relaunched it
  WAIT_LIMIT     (11) -> driver dead, quota still 429: reschedule, wait
  INCONCLUSIVE   (13) -> probe ambiguous: reschedule, retry
  STALL          (20) -> relaunched repeatedly with no new genuine
                         cells: stop and report (a non-limit failure)

Stall guard: a small JSON state file tracks the genuine count at each
relaunch. If three consecutive relaunches produce zero new genuine
cells, something other than the usage limit is broken; emit STALL so
the monitor stops instead of looping forever.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
RESULTS = HERE / "results"
STATE = HERE / ".auto_resume_state.json"
RUN_LOG = HERE / "run.log"
MAX_STALLED_RELAUNCHES = 3


def counts() -> tuple[int, int]:
    genuine = poisoned = 0
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
            poisoned += 1
        else:
            genuine += 1
    return genuine, poisoned


def driver_alive() -> bool:
    r = subprocess.run(["pgrep", "-f", "run_forced.py"],
                        capture_output=True, text=True)
    return r.returncode == 0 and r.stdout.strip() != ""


def probe() -> int:
    """0 OK, 1 LIMITED, 2 inconclusive."""
    r = subprocess.run(
        [sys.executable, str(HERE / "probe_limit.py")],
        capture_output=True, text=True)
    sys.stderr.write(f"  probe: {r.stdout.strip()}\n")
    return r.returncode


def relaunch() -> None:
    with RUN_LOG.open("a") as log:
        subprocess.Popen(
            [sys.executable, str(HERE / "run_forced.py"),
             "--runs", "3", "--budget-minutes", "12"],
            cwd=str(REPO), stdout=log, stderr=subprocess.STDOUT,
            start_new_session=True)


def load_state() -> dict:
    try:
        return json.loads(STATE.read_text())
    except Exception:
        return {"stalled_relaunches": 0, "last_genuine_at_relaunch": -1}


def main() -> int:
    genuine, poisoned = counts()
    alive = driver_alive()
    st = load_state()

    if genuine >= 54 and not alive:
        print(f"COMPLETE genuine={genuine}")
        return 0

    if alive:
        print(f"RUNNING genuine={genuine} poisoned={poisoned}")
        return 10

    # driver dead, genuine < 54
    p = probe()
    if p == 1:
        print(f"WAIT_LIMIT genuine={genuine} poisoned={poisoned}")
        return 11
    if p == 2:
        print(f"INCONCLUSIVE genuine={genuine}")
        return 13

    # quota OK and work remains -> stall check, then relaunch
    if genuine <= st.get("last_genuine_at_relaunch", -1):
        st["stalled_relaunches"] = st.get("stalled_relaunches", 0) + 1
    else:
        st["stalled_relaunches"] = 0
    if st["stalled_relaunches"] >= MAX_STALLED_RELAUNCHES:
        print(f"STALL genuine={genuine} "
              f"(no progress over {MAX_STALLED_RELAUNCHES} relaunches; "
              f"likely a non-limit failure — inspect a fresh poisoned "
              f"cell's claude_stdout.json)")
        return 20
    st["last_genuine_at_relaunch"] = genuine
    st["last_relaunch_ts"] = time.time()
    STATE.write_text(json.dumps(st))
    relaunch()
    print(f"RELAUNCHED genuine={genuine} poisoned={poisoned} "
          f"(stall_counter={st['stalled_relaunches']})")
    return 12


if __name__ == "__main__":
    raise SystemExit(main())
