#!/usr/bin/env bash
#
# PreToolUse hook — enforces the learning-ownership invariant.
#
# The learner's implementation under labs/<lab>/solution/ is the source of truth
# for learning progress. Claude must not write, edit, or repair it on its own
# initiative. AI-authored implementations belong in scratch/<same-lab-dir>/.
#
# Escape hatch, for when the learner explicitly asks Claude to change their file:
#
#   ALLOW_LEARNER_WRITE=1
#
# Contract: reads the PreToolUse JSON payload on stdin.
#   exit 0 -> allow
#   exit 2 -> block; stderr is returned to Claude as the reason

set -uo pipefail

[ "${ALLOW_LEARNER_WRITE:-0}" = "1" ] && exit 0

payload="$(cat)"

tool="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null)"
case "$tool" in
    Write|Edit|NotebookEdit) ;;
    *) exit 0 ;;
esac

path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
[ -n "$path" ] || exit 0

case "$path" in
    */labs/*/solution/*)
        lab="$(printf '%s' "$path" | sed -E 's#.*/labs/([^/]+)/solution/.*#\1#')"
        cat >&2 <<MSG
BLOCKED by tests/hooks/protect-learner-implementation.sh (RULES.md R6)

  $path

That path is the learner's own implementation. Do not write or repair it.

Instead:
  - put your reference implementation in scratch/$lab/
  - describe the problem you found and let the learner fix it

If the learner explicitly asked you to edit this file, re-run the tool with
ALLOW_LEARNER_WRITE=1 set, and say out loud that you are doing so.
MSG
        exit 2
        ;;
esac

exit 0
