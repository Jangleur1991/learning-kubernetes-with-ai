#!/usr/bin/env bash
#
# Requirement check for Lab N.
#
# Checks only what the task text already states. It must never assert an
# expected phase, state, or exit code — that would hand the learner the answer.
# Predict first, then run this, then read the evidence dump.

set -uo pipefail
NS="${LAB_NS:-lab-NN}"
fails=0

ctx="$(kubectl config current-context 2>/dev/null)"
[ "$ctx" = "kind-ckad" ] || { echo "FAIL  context is '$ctx', expected kind-ckad"; exit 1; }

req() { # req <description> <test-command...>
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        printf 'ok    %s\n' "$desc"
    else
        printf 'FAIL  %s\n' "$desc"; fails=$((fails + 1))
    fi
}

field() { kubectl -n "$NS" get pod "$1" -o jsonpath="{$2}" 2>/dev/null; }

echo "== Requirements =="
# req "pod <name> exists" kubectl -n "$NS" get pod <name>
# req "<name> uses image busybox" test "$(field <name> .spec.containers[0].image)" = "busybox"

echo
echo "== Evidence (read this yourself; nothing here is graded) =="
kubectl -n "$NS" get pods -o wide 2>/dev/null
echo
kubectl -n "$NS" get pods \
    -o custom-columns='NAME:.metadata.name,PHASE:.status.phase,RESTARTS:.status.containerStatuses[0].restartCount,STATE:.status.containerStatuses[0].state,LASTSTATE:.status.containerStatuses[0].lastState' 2>/dev/null
echo
kubectl -n "$NS" get events --sort-by=.lastTimestamp 2>/dev/null | tail -20

echo
[ "$fails" -eq 0 ] && echo "Requirements met." || echo "$fails requirement(s) not met."
exit "$fails"
