# shellcheck shell=bash
# Shared helpers for repository rule checks.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

VIOLATIONS=0

fail() {
    printf '  FAIL  %s\n' "$*" >&2
    VIOLATIONS=$((VIOLATIONS + 1))
}

info() {
    printf '  ....  %s\n' "$*"
}

# List lab directories, e.g. "01-pod-lifecycle". Empty output when none exist.
lab_dirs() {
    [ -d "$REPO_ROOT/labs" ] || return 0
    find "$REPO_ROOT/labs" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null \
        | grep -v '^_' | sort
}

# List scratch lab directories.
scratch_dirs() {
    [ -d "$REPO_ROOT/scratch" ] || return 0
    find "$REPO_ROOT/scratch" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort
}

finish() {
    local name="$1"
    if [ "$VIOLATIONS" -eq 0 ]; then
        printf 'PASS  %s\n' "$name"
        exit 0
    fi
    printf 'FAIL  %s (%d violation(s))\n' "$name" "$VIOLATIONS" >&2
    exit 1
}
