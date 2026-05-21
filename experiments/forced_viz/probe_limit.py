#!/usr/bin/env python3
"""Cheap usage-limit probe.

Fires one minimal `claude --print` call and inspects the `result`
event. A rate/usage-limit hit comes back as `api_error_status: 429`
with a "You've hit your limit" message in ~seconds and consumes no
tokens, so this is a near-zero-cost way to tell whether the account
quota has reset.

Exit code: 0 = quota OK (not limited), 1 = LIMITED, 2 = inconclusive.
Prints one line: OK | LIMITED [reset msg] | INCONCLUSIVE <reason>.
"""
from __future__ import annotations

import json
import subprocess
import sys

PROMPT = "Reply with exactly: ok"


def main() -> int:
    try:
        proc = subprocess.run(
            ["claude", "--print", "--output-format", "json", PROMPT],
            capture_output=True, text=True, timeout=90,
        )
    except subprocess.TimeoutExpired:
        print("INCONCLUSIVE probe-timeout")
        return 2
    out = proc.stdout.strip()
    obj = None
    # --output-format json emits a single JSON object (the result).
    try:
        obj = json.loads(out)
    except Exception:
        for line in reversed(out.splitlines()):
            try:
                e = json.loads(line)
            except Exception:
                continue
            if e.get("type") == "result":
                obj = e
                break
    if obj is None:
        print(f"INCONCLUSIVE no-json rc={proc.returncode} "
              f"out={out[:160]!r}")
        return 2
    if obj.get("api_error_status") == 429 or (
            "hit your limit" in str(obj.get("result", "")).lower()):
        print(f"LIMITED {obj.get('result')!r}")
        return 1
    if obj.get("is_error"):
        print(f"INCONCLUSIVE error {obj.get('result')!r}")
        return 2
    print("OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
