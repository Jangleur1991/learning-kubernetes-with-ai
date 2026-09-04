#!/usr/bin/env bash
#
# PreToolUse hook — enforces RULES.md R8.
#
# Blocks any mutating kubectl command unless the effective Kubernetes context is
# the CKAD learning cluster, and blocks kind cluster lifecycle operations
# outright (those need explicit human approval).
#
# Contract: reads the PreToolUse JSON payload on stdin.
#   exit 0 -> allow
#   exit 2 -> block; stderr is returned to Claude as the reason
#
# Test it by hand:
#   echo '{"tool_name":"Bash","tool_input":{"command":"kubectl delete pod x"}}' \
#     | tests/hooks/verify-kube-context.sh; echo "exit=$?"

set -uo pipefail

EXPECTED_CONTEXT="kind-ckad"

payload="$(cat)"

tool="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -n "$cmd" ] || exit 0

block() {
    printf 'BLOCKED by tests/hooks/verify-kube-context.sh (RULES.md R8)\n\n%s\n' "$1" >&2
    exit 2
}

# --- Cluster lifecycle always needs explicit human approval ---------------
if printf '%s' "$cmd" | grep -qE '\bkind[[:space:]]+(create|delete)[[:space:]]+cluster\b'; then
    block "Cluster lifecycle operation detected:
  $cmd

Creating or deleting the kind cluster requires explicit approval from the user.
Ask first, then run it yourself if approved."
fi

# --- Context switching is never allowed ----------------------------------
if printf '%s' "$cmd" | grep -qE '\bkubectl[[:space:]]+config[[:space:]]+(use-context|set-context|delete-context|rename-context)\b'; then
    block "Kubernetes context modification detected:
  $cmd

The learning workflow must never switch or rewrite contexts."
fi

# --- Only mutating kubectl verbs are gated -------------------------------
MUTATING='apply|create|delete|patch|edit|replace|scale|rollout|drain|cordon|uncordon|taint|annotate|label|set|expose|autoscale'
if ! printf '%s' "$cmd" | grep -qE "\bkubectl[[:space:]]+([^|;&]*[[:space:]])?($MUTATING)\b"; then
    exit 0
fi

# An explicit --context flag wins; it must name the learning cluster.
explicit="$(printf '%s' "$cmd" | grep -oE '\-\-context[= ][^ ]+' | head -n1 | sed -E 's/^--context[= ]//')"
if [ -n "$explicit" ]; then
    if [ "$explicit" != "$EXPECTED_CONTEXT" ]; then
        block "Mutating command targets context '$explicit', expected '$EXPECTED_CONTEXT':
  $cmd"
    fi
    exit 0
fi

# Otherwise resolve the context the command would actually use.
current="$(kubectl config current-context 2>/dev/null)"
rc=$?

if [ $rc -ne 0 ] || [ -z "$current" ]; then
    block "Could not determine the current Kubernetes context, so this mutating
command cannot be verified safe:
  $cmd

Check KUBECONFIG. The learning cluster uses:
  export KUBECONFIG=~/.kube/ckad-learning-config"
fi

if [ "$current" != "$EXPECTED_CONTEXT" ]; then
    block "Current context is '$current', expected '$EXPECTED_CONTEXT'.
Refusing to run a mutating command against a non-learning cluster:
  $cmd"
fi

exit 0
