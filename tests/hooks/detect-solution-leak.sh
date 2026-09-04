#!/usr/bin/env bash
#
# Stop hook — enforces the no-solution-leakage stance at runtime.
#
# Layer 2 of the anti-leak guard: detection.
#
# Claude Code has no hook that can filter assistant text before the learner
# sees it. What it does have is a Stop hook, which can refuse to let the turn
# end. So this script reads back what Claude just said and, in guided mode,
# blocks completion when the message hands the learner a solution.
#
# The leak is on screen by then. The point is that Claude is forced to retract
# it in the same turn instead of it passing unnoticed.
#
# Contract: reads the Stop JSON payload on stdin.
#   exit 0 -> allow the turn to end
#   exit 2 -> block; stderr goes back to Claude

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MODE_FILE="$REPO_ROOT/.claude/lab-mode"

payload="$(cat)"

# Never loop: if we already blocked once this turn, let it through.
active="$(printf '%s' "$payload" | jq -r '.stop_hook_active // false' 2>/dev/null)"
[ "$active" = "true" ] && exit 0

mode="guided"
[ -f "$MODE_FILE" ] && mode="$(tr -d '[:space:]' < "$MODE_FILE")"
[ "$mode" = "guided" ] || exit 0

transcript="$(printf '%s' "$payload" | jq -r '.transcript_path // empty' 2>/dev/null)"
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# Last assistant text block. content may be a string or a content array.
last="$(tail -n 400 "$transcript" 2>/dev/null \
    | jq -c 'select(.type == "assistant")' 2>/dev/null \
    | tail -n 1 \
    | jq -r 'if (.message.content | type) == "string"
             then .message.content
             else (.message.content[]? | select(.type == "text") | .text)
             end' 2>/dev/null)"
[ -n "$last" ] || exit 0

hits=""

# A solving kubectl/k invocation: the verb plus the task's own parameters.
if printf '%s' "$last" | grep -qE '\b(kubectl|k)[[:space:]]+(run|create)\b' \
   && printf '%s' "$last" | grep -qE '\-\-image=|\-\-restart=|\-\-dry-run=|\-\-command\b|--[[:space:]]+sh[[:space:]]+-c'; then
    hits="$hits
  - a kubectl run/create invocation carrying the task's own parameters"
fi

# A manifest: a fenced yaml block containing a resource kind.
if printf '%s' "$last" | awk '
    /^[[:space:]]*```[[:space:]]*(yaml|yml)[[:space:]]*$/ { inblk = 1; next }
    /^[[:space:]]*```[[:space:]]*$/                       { inblk = 0; next }
    inblk && /^[[:space:]]*kind:[[:space:]]*[A-Z]/        { found = 1 }
    END { exit !found }
'; then
    hits="$hits
  - a Kubernetes manifest inside a yaml block"
fi

# An apiVersion/kind pair anywhere, fenced or not.
if printf '%s' "$last" | grep -qE '^[[:space:]]*apiVersion:[[:space:]]*v1' \
   && printf '%s' "$last" | grep -qE '^[[:space:]]*kind:[[:space:]]*(Pod|Deployment|Service|Job|CronJob|ConfigMap|Secret)'; then
    hits="$hits
  - an apiVersion/kind manifest pair"
fi

# A pre-revealed outcome the learner is meant to predict.
if printf '%s' "$last" | grep -qiE '\b(phase|status|state) (is|will be|wird|ist)\b.*\b(Succeeded|Failed|Running|Pending|CrashLoopBackOff|Completed|Terminated)\b' \
   || printf '%s' "$last" | grep -qiE '\b(der pod|the pod|pod)\b.*\b(geht|wird|goes|enters|reaches|ends up)\b.*\b(Succeeded|Failed|CrashLoopBackOff|Completed)\b'; then
    hits="$hits
  - a pre-revealed Pod phase or container state"
fi

[ -n "$hits" ] || exit 0

cat >&2 <<MSG
BLOCKED by tests/hooks/detect-solution-leak.sh

GUIDED MODE is active and your last message leaked the solution:
$hits

The learner did not ask for this. You just did the exercise for them.

Do this now, in this turn:
  1. Say plainly that you leaked the answer and that it was not asked for.
  2. Do NOT repeat the leaked content, not even to explain what you leaked.
  3. Replace it with the weakest useful hint, or with a question that forces a
     prediction, or with nothing at all.
  4. If you think the answer is genuinely needed, ask whether the learner wants
     it and stop there.

If the learner DID ask for a solution, they can say "löse das" or "solve this"
and the guard turns itself off.
MSG
exit 2
