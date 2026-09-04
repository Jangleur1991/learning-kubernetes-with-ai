#!/usr/bin/env bash
# R9 — No credentials in the repository.
#
# RULES.md and tests/ are excluded: they name the forbidden patterns in order
# to document and detect them.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

cd "$REPO_ROOT" || exit 1
git rev-parse --git-dir >/dev/null 2>&1 || { info "not a git repository; skipping"; finish "R9 no credentials"; }

while read -r f; do
    [ -n "$f" ] && fail "tracked credential-like file: $f"
done < <(git ls-files | grep -iE '(^|/)(kubeconfig|.*\.kubeconfig|.*\.pem|.*\.key|id_rsa)$' || true)

while read -r f; do
    [ -n "$f" ] && fail "tracked file contains key material: $f"
done < <(git grep -lE 'client-key-data:|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY' -- . ':!RULES.md' ':!tests/' 2>/dev/null || true)

finish "R9 no credentials"
