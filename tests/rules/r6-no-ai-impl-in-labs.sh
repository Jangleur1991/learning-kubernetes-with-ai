#!/usr/bin/env bash
# R6 — AI-generated implementations stay out of labs/.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

if [ -d "$REPO_ROOT/labs" ]; then
    while read -r f; do
        [ -n "$f" ] || continue
        fail "${f#"$REPO_ROOT"/} carries the ai-generated marker; move it to scratch/"
    done < <(grep -rlE '^[[:space:]]*(<!--|#)[[:space:]]*ai-generated' "$REPO_ROOT/labs" 2>/dev/null | sort)
fi

finish "R6 no AI implementations in labs"
