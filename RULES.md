# Repository Rules

A rule is an invariant that must always be true **and** that a machine can
check. Every rule below names the check that detects a violation.

If a requirement cannot be checked automatically, it is not a rule. It belongs
in `GUIDE.md` as a guideline.

Run all checks:

```bash
./tests/rules/run-all.sh
```

---

## R1 — Lab directories use a unique two-digit sequence number

Every lab directory is `labs/NN-kebab-case-name/` where `NN` is a zero-padded
two-digit number, unique across the repository.

The number expresses learning sequence only.

Violation: a malformed directory name, or two labs sharing the same `NN`.

Check: `tests/rules/r1-lab-numbering.sh`

---

## R2 — Lab README has the required sections

Every `labs/NN-*/README.md` contains these headings:

```text
## Learning objective
## Before you begin
## Success criteria
## Cleanup
```

Violation: a missing heading.

Check: `tests/rules/r2-lab-readme-sections.sh`

---

## R3 — Lab title number matches the directory number

`labs/07-pod-lifecycle/README.md` must start with `# Lab 7 — `.

Violation: title number differs from directory number.

Check: `tests/rules/r3-lab-title-matches-dir.sh`

---

## R4 — Each lab is confined to its own namespace

Every lab declares `Namespace: lab-NN` in `## Before you begin`, where `NN` is
the lab number, and has a `## Cleanup` section that deletes that namespace.

`default` must not be used as a lab namespace.

Violation: a missing, mismatched, or `default` namespace declaration.

Check: `tests/rules/r4-lab-namespace.sh`

---

## R5 — Scratch mirrors labs exactly

AI-generated work for a lab lives in `scratch/<same-directory-name-as-the-lab>/`.

For every `scratch/NN-*/` there must be a `labs/NN-*/` with the identical
directory name. Flat files such as `scratch/lab-01-exercise-1.md` are a
violation.

Violation: a scratch lab directory with no identically named lab directory, or
a file directly under `scratch/` other than `README.md` and `.gitkeep`.

Check: `tests/rules/r5-scratch-mirrors-labs.sh`

---

## R6 — AI-generated implementations stay out of `labs/`

The learner's implementation is the only implementation inside a lab, and it
lives in `labs/NN-*/solution/`.

Every AI-authored reference implementation and experiment writeup carries the
marker line `<!-- ai-generated -->` (Markdown) or `# ai-generated` (YAML,
shell) on its first content line, and must exist only under `scratch/`.

Violation: a file below `labs/` carrying the `ai-generated` marker.

Check: `tests/rules/r6-no-ai-impl-in-labs.sh`
Enforcement: `tests/hooks/protect-learner-implementation.sh` blocks writes under
`labs/*/solution/`. Escape hatch for an explicitly requested edit:
`ALLOW_LEARNER_WRITE=1`.

---

## R7 — Lab READMEs do not leak the solution

A lab README states requirements, not implementations.

It must not contain:

* a fenced `yaml` block containing `kind:`;
* `kubectl run` or `kubectl create` invocations carrying the task's own
  parameters (`--image=`, `--restart=`, `--dry-run=`).

Violation: either pattern present in `labs/NN-*/README.md`.

Check: `tests/rules/r7-no-solution-leakage.sh`

---

## R8 — Only the CKAD learning cluster is mutated

Mutating `kubectl` commands run only against the `kind-ckad` context.

This is enforced at runtime by a `PreToolUse` hook, not only by convention.

The same mechanism carries the learner-implementation guard from R6.

Violation: a hook script is missing, not executable, has a syntax error, or is
not wired into `.claude/settings.local.json`.

Check: `tests/rules/r8-context-guard-wired.sh`
Enforcement: `tests/hooks/verify-kube-context.sh`,
`tests/hooks/protect-learner-implementation.sh`

---

## R9 — No credentials in the repository

A kubeconfig, certificate, or key must never be committed.

Violation: a tracked file named `kubeconfig`, `*.kubeconfig`, `*.pem`,
`*.key`, or a tracked file containing `client-key-data:`.

Check: `tests/rules/r9-no-credentials.sh`
