#!/usr/bin/env bash
# Run every repository rule check. Exit non-zero if any rule is violated.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
failed=0

for check in "$here"/r[0-9]*-*.sh; do
    [ -f "$check" ] || continue
    if ! bash "$check"; then
        failed=$((failed + 1))
    fi
done

echo
if [ "$failed" -eq 0 ]; then
    echo "All rule checks passed."
    exit 0
fi
echo "$failed rule check(s) failed."
exit 1
