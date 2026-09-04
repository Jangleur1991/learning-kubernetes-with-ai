#!/usr/bin/env bash
# R1 — Lab directories use a unique two-digit sequence number.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

seen=""
while read -r d; do
    [ -n "$d" ] || continue
    if ! [[ "$d" =~ ^[0-9]{2}-[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
        fail "labs/$d does not match NN-kebab-case-name"
        continue
    fi
    n="${d%%-*}"
    case " $seen " in
        *" $n "*) fail "duplicate lab number $n (labs/$d)" ;;
        *) seen="$seen $n" ;;
    esac
done < <(lab_dirs)

finish "R1 lab numbering"
