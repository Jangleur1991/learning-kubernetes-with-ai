#!/usr/bin/env bash
#
# Requirement check for Lab 1 — Pod Lifecycle.
#
# Checks only what the task text already states: name, image, restartPolicy.
# It deliberately does NOT check phase, container state, or exit code — those
# are what you are supposed to predict and then discover.
#
# Pods you have not created yet are skipped, so this is safe to run after each
# scenario.

set -uo pipefail
NS="${LAB_NS:-lab-01}"
fails=0

ctx="$(kubectl config current-context 2>/dev/null)"
if [ "$ctx" != "kind-ckad" ]; then
    echo "FAIL  context is '${ctx:-<none>}', expected kind-ckad"
    exit 1
fi

if ! kubectl get ns "$NS" >/dev/null 2>&1; then
    echo "FAIL  namespace $NS does not exist"
    exit 1
fi

field() { kubectl -n "$NS" get pod "$1" -o jsonpath="{$2}" 2>/dev/null; }

check_pod() { # check_pod <name> <expected-restartPolicy>
    local name="$1" want_rp="$2"
    if ! kubectl -n "$NS" get pod "$name" >/dev/null 2>&1; then
        printf 'skip  %-30s not created yet\n' "$name"
        return
    fi

    local img rp
    img="$(field "$name" .spec.containers[0].image)"
    rp="$(field "$name" .spec.restartPolicy)"

    case "$img" in
        busybox|busybox:*|*/busybox|*/busybox:*)
            printf 'ok    %-30s image %s\n' "$name" "$img" ;;
        *)
            printf 'FAIL  %-30s image is "%s", expected busybox\n' "$name" "$img"
            fails=$((fails + 1)) ;;
    esac

    if [ "$rp" = "$want_rp" ]; then
        printf 'ok    %-30s restartPolicy %s\n' "$name" "$rp"
    else
        printf 'FAIL  %-30s restartPolicy is "%s", expected %s\n' "$name" "$rp" "$want_rp"
        fails=$((fails + 1))
    fi
}

echo "== Requirements =="
check_pod lifecycle-success               Never
check_pod lifecycle-fail                  Never
check_pod lifecycle-restart-always        Always
check_pod lifecycle-declarative-success   Never

echo
echo "== Evidence — read it yourself, none of this is graded =="
kubectl -n "$NS" get pods -o custom-columns=\
'NAME:.metadata.name,'\
'PHASE:.status.phase,'\
'READY:.status.containerStatuses[0].ready,'\
'RESTARTS:.status.containerStatuses[0].restartCount' 2>/dev/null

echo
echo "-- container state / lastState --"
for p in lifecycle-success lifecycle-fail lifecycle-restart-always lifecycle-declarative-success; do
    kubectl -n "$NS" get pod "$p" >/dev/null 2>&1 || continue
    printf '%s:\n' "$p"
    kubectl -n "$NS" get pod "$p" -o jsonpath=\
'  state:     {.status.containerStatuses[0].state}{"\n"}  lastState: {.status.containerStatuses[0].lastState}{"\n"}' 2>/dev/null
    echo
done

echo "-- recent events --"
kubectl -n "$NS" get events --sort-by=.lastTimestamp 2>/dev/null | tail -15

echo
if [ "$fails" -eq 0 ]; then
    echo "Requirements met."
else
    echo "$fails requirement(s) not met."
fi
exit "$fails"
