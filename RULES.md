# Kubernetes Rules

Rules describe invariants that must always be true and that can be
checked automatically.

A rule consists of:

1. What must be true.
2. How a violation is detected.

If a requirement cannot be objectively checked, it is not a rule.
Keep it as a guideline in `GUIDE.md` instead.

## Rules

## Rule: User implementations are immutable

Files inside `labs/` that are part of the user's implementation must not be
modified, overwritten, or deleted by Claude unless the user explicitly asks
for it.

Violation:
- Claude modifies, overwrites, or deletes a user's implementation file.

Detection:
- Git diff shows changes to an existing user implementation file that were not
  explicitly requested.

## Rule: AI-generated implementations belong in scratch

AI-generated reference implementations and temporary experiments must not be
stored in `labs/`.

They must be stored under `scratch/`.

Violation:
- Claude creates an AI-generated implementation inside `labs/`.

Detection:
- Files created by Claude that contain reference implementations or temporary
  experiments exist below `labs/` without being part of the user's requested
  implementation.

## Rule: Only use the CKAD learning cluster

Claude must only interact with the Kubernetes cluster using the
`kind-ckad` context.

Violation:
- A mutating Kubernetes command is executed against a different context.

Detection:
- The current Kubernetes context is not `kind-ckad` before a mutating command.
