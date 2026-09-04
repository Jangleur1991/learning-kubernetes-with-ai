#!/usr/bin/env bash
# R8 — The PreToolUse guards exist, are executable, and are wired into settings.
#
# Wiring lives in .claude/settings.json (shared, committed).
# .claude/settings.local.json is accepted too, for a machine-local override.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

settings_files=("$REPO_ROOT/.claude/settings.json" "$REPO_ROOT/.claude/settings.local.json")

wired() { # wired <hook-basename>
    local h="$1" f
    for f in "${settings_files[@]}"; do
        [ -f "$f" ] || continue
        grep -q "$h.sh" "$f" && return 0
    done
    return 1
}

any_settings=0
for f in "${settings_files[@]}"; do
    [ -f "$f" ] && any_settings=1
done
[ "$any_settings" -eq 1 ] || fail "no .claude/settings.json or settings.local.json found"

for h in verify-kube-context protect-learner-implementation; do
    hook="$REPO_ROOT/tests/hooks/$h.sh"
    if [ ! -f "$hook" ]; then
        fail "tests/hooks/$h.sh is missing"
        continue
    fi
    [ -x "$hook" ] || fail "tests/hooks/$h.sh is not executable"
    bash -n "$hook" 2>/dev/null || fail "tests/hooks/$h.sh has a syntax error"
    wired "$h" || fail "$h.sh is not wired as a PreToolUse hook in .claude/settings*.json"
done

finish "R8 PreToolUse guards wired"
