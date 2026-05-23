#!/usr/bin/env bash
# Desktop notification. Called from Notification and Stop hooks.
#
# Args:
#   $1 = "waiting" | "done" (controls the notification title)
#
# macOS: uses osascript for a native notification.
# Linux: uses `notify-send` if present.
# Other / non-interactive: silently no-ops.
#
# This script must not fail loudly; hooks are best-effort and should
# never abort Claude's turn.

set -u

mode="${1:-done}"
case "$mode" in
  waiting) title="Claude Code — waiting" ;;
  done)    title="Claude Code — done"    ;;
  *)       title="Claude Code"           ;;
esac

# Message: project name + first line of git status to give context.
project_name="$(basename "${CLAUDE_PROJECT_DIR:-$PWD}")"
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && command -v git > /dev/null 2>&1; then
  cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || true
  changes="$(git status --short 2>/dev/null | wc -l | tr -d ' ')"
  msg="$project_name — $changes changed file(s)"
else
  msg="$project_name"
fi

if [ "$(uname -s)" = "Darwin" ] && command -v osascript > /dev/null 2>&1; then
  # Escape double-quotes for AppleScript.
  esc_title="${title//\"/\\\"}"
  esc_msg="${msg//\"/\\\"}"
  osascript -e "display notification \"$esc_msg\" with title \"$esc_title\" sound name \"Pop\"" \
    > /dev/null 2>&1 || true
elif command -v notify-send > /dev/null 2>&1; then
  notify-send "$title" "$msg" > /dev/null 2>&1 || true
fi

exit 0
