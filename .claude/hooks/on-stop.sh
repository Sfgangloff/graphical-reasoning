#!/usr/bin/env bash
# Stop hook — runs after Claude finishes its turn.
#
# 1. Print a one-line audit of `git status --short`.
# 2. Fire a desktop notification so the user knows results are ready.
#    (Reuses notify.sh.)

set -eu

cd "${CLAUDE_PROJECT_DIR:-.}"

status="$(git status --short 2>/dev/null || true)"
if [ -z "$status" ]; then
  echo "[stop] working tree clean."
else
  echo "[stop] changes since session start:"
  printf '%s\n' "$status"
fi

# Notify (best-effort; notify.sh silently no-ops on non-macOS).
"${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/notify.sh" done >/dev/null 2>&1 || true
