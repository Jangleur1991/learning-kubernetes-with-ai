#!/usr/bin/env bash
# R2 — Lab README has the required sections.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

REQUIRED=("## Learning objective" "## Before you begin" "## Success criteria" "## Cleanup")

while read -r d; do
    [ -n "$d" ] || continue
    readme="$REPO_ROOT/labs/$d/README.md"
    if [ ! -f "$readme" ]; then
        fail "labs/$d/README.md is missing"
        continue
    fi
    for h in "${REQUIRED[@]}"; do
        grep -qxF "$h" "$readme" || fail "labs/$d/README.md missing heading: $h"
    done
done < <(lab_dirs)

finish "R2 lab README sections"
