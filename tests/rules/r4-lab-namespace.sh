#!/usr/bin/env bash
# R4 — Each lab is confined to its own namespace lab-NN.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

while read -r d; do
    [ -n "$d" ] || continue
    readme="$REPO_ROOT/labs/$d/README.md"
    [ -f "$readme" ] || continue
    n="${d%%-*}"
    want="lab-$n"
    if ! grep -qE "Namespace:.*\`?${want}\`?" "$readme"; then
        fail "labs/$d/README.md does not declare 'Namespace: $want'"
    fi
    if grep -qE 'Namespace:.*`?default`?' "$readme"; then
        fail "labs/$d/README.md declares the default namespace"
    fi
    grep -q "delete ns $want\|delete namespace $want" "$readme" \
        || fail "labs/$d/README.md Cleanup does not delete namespace $want"
done < <(lab_dirs)

finish "R4 lab namespace isolation"
