#!/usr/bin/env bash
# R7 — Lab READMEs do not leak the solution.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

while read -r d; do
    [ -n "$d" ] || continue
    readme="$REPO_ROOT/labs/$d/README.md"
    [ -f "$readme" ] || continue

    # A manifest inside a fenced ```yaml block.
    while read -r ln; do
        [ -n "$ln" ] && fail "labs/$d/README.md:$ln manifest inside a yaml block"
    done < <(awk '
        /^```yaml[[:space:]]*$/ { inblk=1; next }
        /^```[[:space:]]*$/     { inblk=0; next }
        inblk && /^[[:space:]]*kind:[[:space:]]*[A-Z]/ { print NR }
    ' "$readme")

    # A kubectl invocation that hands the learner the answer.
    while read -r ln; do
        [ -n "$ln" ] && fail "labs/$d/README.md:$ln solving kubectl invocation"
    done < <(grep -nE 'kubectl (run|create)[^|]*(--image=|--restart=|--dry-run=)' "$readme" | cut -d: -f1)
done < <(lab_dirs)

finish "R7 no solution leakage"
