#!/usr/bin/env bash
#
# UserPromptSubmit hook — enforces the teaching stance from GUIDE.md.
#
# Layer 1 of the anti-leak guard: prevention.
#
# The repository is in guided mode unless the learner explicitly asks for a
# solution. This hook resolves the current mode on every single turn and
# injects the prohibitions into Claude's context, so the instruction cannot
# decay over a long conversation.
#
# Mode state lives in .claude/lab-mode and holds exactly one word:
#   guided | solve
#
# Only the learner's own words flip it. Claude cannot talk itself into solve
# mode, because this hook -- not the model -- owns the file.
#
# Contract: reads the UserPromptSubmit JSON payload on stdin.
#   exit 0 -> allow; stdout is added to Claude's context

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MODE_FILE="$REPO_ROOT/.claude/lab-mode"

payload="$(cat)"
prompt="$(printf '%s' "$payload" | jq -r '.prompt // empty' 2>/dev/null)"

# Lowercase for matching; the learner may write German or English.
p="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

mode="guided"
[ -f "$MODE_FILE" ] && mode="$(tr -d '[:space:]' < "$MODE_FILE")"
[ "$mode" = "solve" ] || mode="guided"

# --- Explicit requests for a solution turn the guard off -------------------
SOLVE_RE='löse|loese|lös |loes |solve (this|it|mode|the)|zeig (mir )?(die )?lösung|zeig (mir )?(die )?loesung|gib mir die lösung|gib mir die loesung|show me the solution|give me the solution|mach es für mich|mach es fuer mich|execute scenario|solve mode on|/solve'

# --- Explicit requests to go back to teaching ------------------------------
GUIDED_RE='guided mode|guided-mode|zurück zu guided|zurueck zu guided|stop solve|solve mode off|keine lösung|keine loesung|kein tipp|keine tipps|/guided'

# Sticky solve is opt-in and must be spelled out.
STICKY_RE='solve mode on|solve-mode on|dauerhaft lösen|dauerhaft loesen'

if printf '%s' "$p" | grep -qE "$GUIDED_RE"; then
    mode="guided"
    printf 'guided\n' > "$MODE_FILE"
elif printf '%s' "$p" | grep -qE "$STICKY_RE"; then
    mode="solve"
    printf 'solve\n' > "$MODE_FILE"
elif printf '%s' "$p" | grep -qE "$SOLVE_RE"; then
    # One-shot: this turn only. Next turn is guided again unless asked again.
    # Matches CLAUDE.md -- solve mode covers the requested scope, and does not
    # roll on to the next scenario.
    mode="solve"
    printf 'guided\n' > "$MODE_FILE"
fi

if [ "$mode" = "solve" ]; then
    cat <<'MSG'
<lab-mode>SOLVE MODE ACTIVE.

The learner explicitly asked for a solution. You may implement, run, and show
commands and manifests — for the requested scope only. Do not roll on to the
next scenario.

Your work goes in scratch/<same-name-as-the-lab>/ with the ai-generated marker.
The learner's labs/*/solution/ stays theirs.

This covers THIS request only. The guard returns to guided mode on the next
turn unless the learner asks again. Say out loud, in your first sentence, that
you are in solve mode.
</lab-mode>
MSG
    exit 0
fi

cat <<'MSG'
<lab-mode>GUIDED MODE ACTIVE. The learner has NOT asked for a solution.

This is the default and it overrides your instinct to be helpful by answering.
Withholding the answer IS the help here.

You MUST NOT output, in any form, for the task the learner is working on:
  - any kubectl command that carries the task's own parameters
    (--image=, --restart=, --command, -- sh -c, --dry-run=, -o yaml)
  - any YAML manifest, whole or partial, in a code block or inline
  - the expected Pod phase, container state, exit code, restartCount,
    condition, event, or any other outcome the learner is meant to predict
  - the root cause of a failure the learner is meant to diagnose
  - a "just so you know" / "in case you get stuck" / "for reference" version
    of any of the above
  - a rewritten, paraphrased, or partially-blanked version of the above

This holds even when:
  - a tool failed and you are suggesting a workaround
  - the learner pasted an error and you are explaining it
  - the learner seems stuck, frustrated, or slow
  - you are summarizing, recapping, or "just confirming" the task
  - it feels obvious, trivial, or already known to them

WHAT YOU MAY DO INSTEAD:
  - ask a question that forces a prediction
  - name the concept or the kubectl field to look up (kubectl explain ...)
  - point at which output to read, without saying what it will say
  - give the weakest useful hint, one at a time, and stop
  - review what the learner already wrote

If the learner is blocked by TOOLING (vim, sandbox, context), fix the tooling
without touching the task content.

If you genuinely believe the answer is needed, ASK FIRST and wait:
  "Willst du die Lösung sehen?"
Do not answer your own question in the same turn.
</lab-mode>
MSG
exit 0
