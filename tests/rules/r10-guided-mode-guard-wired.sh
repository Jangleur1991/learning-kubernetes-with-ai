#!/usr/bin/env bash
# R10 — The guided-mode anti-leak guards exist and are wired.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

settings="$REPO_ROOT/.claude/settings.json"
mode_file="$REPO_ROOT/.claude/lab-mode"

[ -f "$settings" ] || fail ".claude/settings.json is missing"

for h in guided-mode-guard detect-solution-leak; do
    hook="$REPO_ROOT/tests/hooks/$h.sh"
    if [ ! -f "$hook" ]; then
        fail "tests/hooks/$h.sh is missing"
        continue
    fi
    [ -x "$hook" ] || fail "tests/hooks/$h.sh is not executable"
    bash -n "$hook" 2>/dev/null || fail "tests/hooks/$h.sh has a syntax error"
    grep -q "$h.sh" "$settings" 2>/dev/null \
        || fail "$h.sh is not wired in .claude/settings.json"
done

grep -q '"UserPromptSubmit"' "$settings" 2>/dev/null \
    || fail ".claude/settings.json has no UserPromptSubmit hook"
grep -q '"Stop"' "$settings" 2>/dev/null \
    || fail ".claude/settings.json has no Stop hook"

if [ ! -f "$mode_file" ]; then
    fail ".claude/lab-mode is missing (the guard defaults to guided without it,"
    fail "  but the file must exist so the mode is visible and auditable)"
else
    m="$(tr -d '[:space:]' < "$mode_file")"
    case "$m" in
        guided|solve) ;;
        *) fail ".claude/lab-mode holds '$m'; expected 'guided' or 'solve'" ;;
    esac
fi

finish "R10 guided-mode guards wired"
