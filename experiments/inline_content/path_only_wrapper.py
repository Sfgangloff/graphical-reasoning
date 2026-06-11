#!/usr/bin/env python3
"""Path-only wrapper around the in-tree math-viz MCP server.

Used by Study 7 (publication_plan.md §3.2) as the regression arm of
the 2x2 = {forced, optional} x {inline (upstream), path-only}
inline-content ablation. Imports the upstream math-viz server module
from the pinned submodule at external/math-reasoning-tools/, then
monkey-patches the module-level `_image(fig, description)` helper so
every plot/draw/render tool returns ONLY a "Saved to <path>" text
block -- no inline `Image` content. From the agent's perspective the
tool surface is identical to upstream math-viz; the difference is
that the agent must call Read on the saved PNG to see the picture.

How it works
------------
math-viz registers every visual tool with `@mcp.tool()` and each
visual tool ends with `return _image(fig, "...")`. The upstream
`_image` returns `[Image(data=raw, format="png"), f"Saved to {path}"]`
-- inline image + text path. We patch `_image` to return only the
text. Python looks up `_image` in `math_viz.server.__dict__` at
call-time, so monkey-patching the module attribute affects every
already-registered tool.

How to register with Claude Code
--------------------------------
Add an entry to the MCP server config (typically `~/.claude.json` or
a project-local `.mcp.json`) under a distinct server name, e.g.:

    "math-viz-path-only": {
      "type": "stdio",
      "command": "uv",
      "args": [
        "run",
        "--directory",
        "<repo>/external/math-reasoning-tools/servers/math-viz",
        "python",
        "<repo>/experiments/inline_content/path_only_wrapper.py"
      ],
      "env": {}
    }

Tools will appear as `mcp__math-viz-path-only__plot_function`, etc.
The Study-7 condition settings will then deny one or the other of
`mcp__math-viz` / `mcp__math-viz-path-only` per arm so the agent
sees exactly one inline-content variant per cell.

Self-test
---------
Run with `--self-test` to confirm the monkey-patch took effect on a
known tool (`plot_function`) without spawning the MCP server:

    python path_only_wrapper.py --self-test
"""
from __future__ import annotations

import sys
from pathlib import Path

# Make the in-tree (submodule-pinned) math-viz src importable. Use
# the submodule path so this wrapper always uses the pinned commit,
# not whatever global checkout the user has on their PATH.
_REPO = Path(__file__).resolve().parents[2]
_MATH_VIZ_SRC = (
    _REPO / "external" / "math-reasoning-tools"
    / "servers" / "math-viz" / "src"
)
if not _MATH_VIZ_SRC.is_dir():
    raise SystemExit(
        f"math-viz src not found at {_MATH_VIZ_SRC}; the submodule "
        "may not be initialised. Run `git submodule update --init "
        "--recursive` in the repo root."
    )
sys.path.insert(0, str(_MATH_VIZ_SRC))

# Import the upstream server module. Triggers all `@mcp.tool()`
# registrations against `math_viz.server.mcp`.
import math_viz.server as upstream  # noqa: E402


_original_image = upstream._image  # kept for diagnostics


def _path_only_image(fig, description: str):
    """Save the figure normally, return only the path-as-text.

    Drop-in replacement for upstream `_image`. We keep the on-disk
    side effect identical (save a PNG, return the absolute path so
    the agent can Read it back) and strip the inline Image content
    block that the upstream emits as the first element.
    """
    from io import BytesIO

    import matplotlib.pyplot as plt

    buf = BytesIO()
    fig.savefig(buf, format="png", dpi=upstream._DPI, bbox_inches="tight")
    plt.close(fig)
    raw = buf.getvalue()
    path = upstream._save_png(raw, description)
    return [f"Saved to {path}"]


# Monkey-patch the module-level helper. Every already-decorated tool
# looks up `_image` from `math_viz.server.__dict__` at call-time, so
# this rebind affects every tool without re-registration.
upstream._image = _path_only_image


def _self_test() -> int:
    """Smoke-test: call `plot_function` directly, assert no Image content.

    FastMCP 3.x exposes registered tools via the async `mcp.get_tool(name)`
    method, which returns a `FunctionTool`. The underlying Python callable
    is `FunctionTool.fn`; calling it bypasses MCP transport entirely.
    """
    import asyncio

    import matplotlib

    matplotlib.use("Agg")

    async def _get():
        return await upstream.mcp.get_tool("plot_function")

    tool = asyncio.run(_get())
    if tool is None:
        print("FAIL: plot_function tool not registered on upstream.mcp")
        return 2
    fn = getattr(tool, "fn", None)
    if fn is None:
        print(f"FAIL: tool {tool!r} has no .fn attribute")
        return 2
    result = fn(expressions=["x**2"], x_min=-1.0, x_max=1.0)
    if not isinstance(result, list):
        print(f"FAIL: expected list result, got {type(result).__name__}")
        return 2
    types = [type(x).__name__ for x in result]
    if any("Image" in t for t in types):
        print(f"FAIL: result still contains an Image block: types={types}")
        return 2
    if not (len(result) == 1 and isinstance(result[0], str)
            and result[0].startswith("Saved to ")):
        print(f"FAIL: expected exactly one 'Saved to ...' string, "
              f"got {result!r}")
        return 2
    print(f"OK: plot_function returned text-only result: {result[0]}")
    return 0


def main() -> None:
    if "--self-test" in sys.argv:
        sys.exit(_self_test())
    upstream.mcp.run()


if __name__ == "__main__":
    main()
