#!/usr/bin/env bash
# R5 — Scratch mirrors labs exactly.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

while read -r s; do
    [ -n "$s" ] || continue
    [ -d "$REPO_ROOT/labs/$s" ] \
        || fail "scratch/$s has no matching labs/$s (scratch must mirror lab directory names)"
done < <(scratch_dirs)

if [ -d "$REPO_ROOT/scratch" ]; then
    while read -r f; do
        [ -n "$f" ] || continue
        case "$f" in
            README.md|.gitkeep) ;;
            *) fail "scratch/$f is a loose file; put it in scratch/<lab-dir-name>/" ;;
        esac
    done < <(find "$REPO_ROOT/scratch" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' 2>/dev/null | sort)
fi

finish "R5 scratch mirrors labs"
