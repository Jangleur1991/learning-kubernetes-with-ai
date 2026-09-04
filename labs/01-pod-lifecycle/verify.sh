#!/usr/bin/env bash
#
# Requirement check for Lab 1 — Pod Lifecycle.
#
# Checks only what the task text already states. It must never assert an
# expected phase, state, or exit code — that would hand the learner the answer.
# Predict first, then run this, then read the evidence dump.

set -uo pipefail
NS="${LAB_NS:-lab-01}"
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
req "pod success-never exists" kubectl -n "$NS" get pod success-never
req "pod failure-never exists" kubectl -n "$NS" get pod failure-never
req "pod failure-onfailure exists" kubectl -n "$NS" get pod failure-onfailure
req "pod declare-success exists" kubectl -n "$NS" get pod declare-success
req "pod declare-failure exists" kubectl -n "$NS" get pod declare-failure

req "success-never uses image busybox" test "$(field success-never .spec.containers[0].image)" = "busybox"
req "failure-never uses image busybox" test "$(field failure-never .spec.containers[0].image)" = "busybox"
req "failure-onfailure uses image busybox" test "$(field failure-onfailure .spec.containers[0].image)" = "busybox"
req "declare-success uses image busybox" test "$(field declare-success .spec.containers[0].image)" = "busybox"
req "declare-failure uses image busybox" test "$(field declare-failure .spec.containers[0].image)" = "busybox"

req "success-never has restartPolicy: Never" test "$(field success-never .spec.restartPolicy)" = "Never"
req "failure-never has restartPolicy: Never" test "$(field failure-never .spec.restartPolicy)" = "Never"
req "failure-onfailure has restartPolicy: OnFailure" test "$(field failure-onfailure .spec.restartPolicy)" = "OnFailure"
req "declare-success has restartPolicy: Never" test "$(field declare-success .spec.restartPolicy)" = "Never"
req "declare-failure has restartPolicy: Never" test "$(field declare-failure .spec.restartPolicy)" = "Never"

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
