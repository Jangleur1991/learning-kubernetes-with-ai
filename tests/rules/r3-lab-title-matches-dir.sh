#!/usr/bin/env bash
# R3 — Lab title number matches the directory number.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

title_re='^# Lab ([0-9]+) '

while read -r d; do
    [ -n "$d" ] || continue
    readme="$REPO_ROOT/labs/$d/README.md"
    [ -f "$readme" ] || continue
    n="${d%%-*}"
    expected=$((10#$n))
    title="$(head -n1 "$readme")"
    if [[ ! "$title" =~ $title_re ]]; then
        fail "labs/$d/README.md first line is not '# Lab N — ...': $title"
        continue
    fi
    got="${BASH_REMATCH[1]}"
    [ "$got" -eq "$expected" ] || fail "labs/$d title says 'Lab $got', directory says $expected"
done < <(lab_dirs)

finish "R3 lab title matches directory"
