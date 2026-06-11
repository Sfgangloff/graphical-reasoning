#!/usr/bin/env python3
"""Register the `math-viz-path-only` MCP server in ~/.claude.json.

Study 7 needs the path-only wrapper exposed as an MCP server with a
distinct name from upstream `math-viz` so the per-condition
settings.json files can grant access to exactly one of the two per
arm. This script adds the registration to the user's
`~/.claude.json` under `mcpServers`.

Defaults to **dry-run**: prints the diff and exits without writing.
Pass `--apply` to actually modify `~/.claude.json` (a timestamped
backup is written next to the file before any change).

Idempotent: if `math-viz-path-only` is already present with matching
command/args, the script is a no-op (prints "already registered").

Usage:
    python3 experiments/inline_content/register_mcp.py            # dry run
    python3 experiments/inline_content/register_mcp.py --apply    # commit
    python3 experiments/inline_content/register_mcp.py --remove   # unregister (dry run unless --apply)
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import shutil
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
WRAPPER = REPO / "experiments" / "inline_content" / "path_only_wrapper.py"
MATH_VIZ_DIR = (
    REPO / "external" / "math-reasoning-tools"
    / "servers" / "math-viz"
)
CLAUDE_JSON = Path.home() / ".claude.json"
SERVER_NAME = "math-viz-path-only"


def desired_entry() -> dict:
    """The MCP-server registration block to add."""
    return {
        "type": "stdio",
        "command": "uv",
        "args": [
            "run",
            "--directory",
            str(MATH_VIZ_DIR),
            "python",
            str(WRAPPER),
        ],
        "env": {},
    }


def load_config() -> dict:
    if not CLAUDE_JSON.exists():
        sys.exit(f"~/.claude.json not found at {CLAUDE_JSON}; "
                 "open Claude Code at least once to create it.")
    return json.loads(CLAUDE_JSON.read_text())


def backup(cfg_path: Path) -> Path:
    stamp = _dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    bk = cfg_path.with_suffix(f".json.bak-{stamp}")
    shutil.copy2(cfg_path, bk)
    return bk


def show_action(action: str, entry: dict | None) -> None:
    print(f"[{action}] {SERVER_NAME}:")
    if entry is not None:
        print(json.dumps(entry, indent=2))


def add(apply: bool) -> int:
    cfg = load_config()
    want = desired_entry()
    have = cfg.get("mcpServers", {}).get(SERVER_NAME)
    if have == want:
        print(f"already registered: {SERVER_NAME}")
        return 0
    if have is not None:
        print(f"NOTE: existing {SERVER_NAME} registration differs:")
        print("  have:", json.dumps(have, indent=2))
        print("  want:", json.dumps(want, indent=2))
    if not WRAPPER.exists():
        sys.exit(f"wrapper not found at {WRAPPER}; create it first.")
    if not MATH_VIZ_DIR.is_dir():
        sys.exit(f"math-viz dir not found at {MATH_VIZ_DIR}; "
                 "did you `git submodule update --init --recursive`?")
    show_action("would write" if not apply else "writing", want)
    if not apply:
        print("(dry-run; pass --apply to commit)")
        return 0
    bk = backup(CLAUDE_JSON)
    cfg.setdefault("mcpServers", {})[SERVER_NAME] = want
    CLAUDE_JSON.write_text(json.dumps(cfg, indent=2))
    print(f"wrote {CLAUDE_JSON} (backup at {bk})")
    return 0


def remove(apply: bool) -> int:
    cfg = load_config()
    have = cfg.get("mcpServers", {}).get(SERVER_NAME)
    if have is None:
        print(f"not registered: {SERVER_NAME}")
        return 0
    show_action("would remove" if not apply else "removing", have)
    if not apply:
        print("(dry-run; pass --apply to commit)")
        return 0
    bk = backup(CLAUDE_JSON)
    cfg["mcpServers"].pop(SERVER_NAME, None)
    CLAUDE_JSON.write_text(json.dumps(cfg, indent=2))
    print(f"wrote {CLAUDE_JSON} (backup at {bk})")
    return 0


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true",
                    help="actually write ~/.claude.json (default: dry run)")
    ap.add_argument("--remove", action="store_true",
                    help="remove the registration instead of adding it")
    args = ap.parse_args()
    if args.remove:
        sys.exit(remove(args.apply))
    sys.exit(add(args.apply))


if __name__ == "__main__":
    main()
