#!/bin/bash
# One-time setup for the experiment harness.
#
#   1. Builds the manifest from real_analysis_problems.tex.
#   2. Pre-fetches Mathlib oleans into experiments/workspace_template/.lake
#      so that each per-attempt workspace can symlink them and skip the
#      download step.
#
# Run from the repo root:
#     bash experiments/runner/setup.sh
#
# Prerequisites already installed and on PATH:
#   - claude        (Claude Code CLI)
#   - lake / elan   (Lean 4 toolchain manager)
#   - python3
#   - The lean-lsp-mcp and math-viz MCP servers, registered globally
#     in your Claude Code config (see Sfgangloff/math-reasoning-tools).

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "[setup] Building manifest from real_analysis_problems.tex..."
python3 experiments/runner/extract_manifest.py

echo
echo "[setup] Pre-fetching Mathlib oleans for the workspace template..."
echo "        (this can take several minutes the first time.)"
pushd experiments/workspace_template > /dev/null
lake update
lake exe cache get
popd > /dev/null

echo
echo "[setup] Done. Sanity-check by attempting a single problem:"
echo "    python3 experiments/runner/run_one.py 1985.B5 A 0 --budget-minutes 5"
