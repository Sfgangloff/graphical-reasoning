#!/usr/bin/env bash
# Filter for Edit / Write / MultiEdit tool calls. Reads JSON on stdin,
# blocks file paths that resolve outside the project, into .git/,
# or into the math-reasoning-tools submodule.

set -u

input="$(cat)"
file_path="$(printf '%s' "$input" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tool_input', {}).get('file_path', ''))" 2>/dev/null || true)"
project_dir="${CLAUDE_PROJECT_DIR:-}"

[ -z "$file_path" ] && exit 0
[ -z "$project_dir" ] && exit 0   # not invoked under Claude — allow

block() {
  python3 -c "import json, sys; print(json.dumps({'decision':'block','reason':sys.argv[1]}))" "$1"
  exit 0
}

# Reject literal-tilde paths up front (they're shorthand for the
# user's home directory, which is outside the project).
case "$file_path" in
  "~"|"~"/*)
    block "Edit/Write to home-dir path blocked: $file_path"
    ;;
esac

# Resolve absolute path.
if [[ "$file_path" != /* ]]; then
  file_path="$project_dir/$file_path"
fi

# Resolve symbolically. python3's os.path.realpath handles
# non-existent paths gracefully.
resolved="$(python3 -c "import os, sys; print(os.path.realpath(sys.argv[1]))" "$file_path" 2>/dev/null || echo "$file_path")"
project_resolved="$(python3 -c "import os, sys; print(os.path.realpath(sys.argv[1]))" "$project_dir" 2>/dev/null || echo "$project_dir")"

# Must be inside the project.
case "$resolved" in
  "$project_resolved"|"$project_resolved"/*)
    ;;
  *)
    block "Edit/Write outside project directory blocked: $file_path"
    ;;
esac

# Must not be inside .git/ — except .git/info/exclude.
case "$resolved" in
  "$project_resolved"/.git/info/exclude)
    ;;
  "$project_resolved"/.git|"$project_resolved"/.git/*)
    block "Edit/Write inside .git/ blocked. Use git commands instead."
    ;;
esac

# Must not modify submodule contents.
case "$resolved" in
  "$project_resolved"/external/math-reasoning-tools|"$project_resolved"/external/math-reasoning-tools/*)
    block "Edit inside external/math-reasoning-tools/ submodule blocked. Propose the change upstream instead."
    ;;
esac

exit 0
