#!/usr/bin/env bash
# Second-line filter on Bash tool calls. Reads JSON on stdin and
# either exits 0 silently (allow) or prints a
# `{"decision":"block","reason":...}` JSON to stdout (block).
#
# The settings.json `deny` list catches most bad patterns. This hook
# is the backup for patterns the deny-list cannot precisely express
# (e.g. unusual rm flag orderings, --no-verify mid-command,
# cd-out-of-tree).
#
# Uses python3 for JSON parsing — no external deps beyond a Python 3
# that ships with macOS.

set -u

input="$(cat)"
cmd="$(printf '%s' "$input" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))" 2>/dev/null || true)"

[ -z "$cmd" ] && exit 0

block() {
  python3 -c "import json, sys; print(json.dumps({'decision':'block','reason':sys.argv[1]}))" "$1"
  exit 0
}

# Destructive rm patterns. The deny-list catches the most common
# forms; this re-check handles unusual flag orderings.
if printf '%s' "$cmd" | grep -qE 'rm[[:space:]]+-[a-zA-Z]*[rRf][a-zA-Z]*[[:space:]]+(/|~|\.\.|\*[[:space:]]*$)'; then
  block "Destructive rm pattern blocked by pre-bash hook."
fi

# Force-push.
if printf '%s' "$cmd" | grep -qE 'git[[:space:]]+push[[:space:]].*--force([[:space:]]|$|=)|git[[:space:]]+push[[:space:]]+(.*[[:space:]])?-[a-zA-Z]*f([[:space:]]|$)'; then
  block "git push --force is blocked. Push without force or ask explicitly."
fi

# git reset --hard.
if printf '%s' "$cmd" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard'; then
  block "git reset --hard is blocked (could lose uncommitted work)."
fi

# git clean with -f and (d or x).
if printf '%s' "$cmd" | grep -qE 'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*(d|x)|git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*(d|x)[a-zA-Z]*f'; then
  block "git clean -fd / -fx is blocked (could delete untracked work)."
fi

# Hook-skip flags anywhere on the command line.
if printf '%s' "$cmd" | grep -qE '(^|[[:space:]])--no-verify([[:space:]]|$|=)|(^|[[:space:]])--no-gpg-sign([[:space:]]|$|=)'; then
  block "Skipping git hooks (--no-verify / --no-gpg-sign) is blocked."
fi

# cd outside the project. Allow cd into subdirs.
if printf '%s' "$cmd" | grep -qE '(^|[[:space:]]|;|&&|\|\|)cd[[:space:]]+(/|~|\.\.)'; then
  block "cd outside the project directory is blocked."
fi

# chmod 777 in any -R form.
if printf '%s' "$cmd" | grep -qE 'chmod[[:space:]]+(-R[[:space:]]+)?[0-7]*7[7-7][7-7]'; then
  block "chmod 777 is blocked."
fi

# sudo / su (also in deny-list).
if printf '%s' "$cmd" | grep -qE '(^|[[:space:]]|;|&&|\|\|)(sudo|su)([[:space:]]|$)'; then
  block "sudo/su is blocked."
fi

exit 0
