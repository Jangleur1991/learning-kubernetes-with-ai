# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this repository.

## Repository purpose

This is a hands-on Kubernetes learning repository for CKAD preparation.

The goal is to build understanding through implementation, experimentation,
troubleshooting, and deliberate practice.

## Important files

Read these files before working on the repository:

* `GUIDE.md` — instructions for how Claude should support the learning process
* `RULES.md` — enforceable repository invariants
* `README.md` — project purpose, structure, and learning workflow

`GUIDE.md` is the primary source of instructions for how to interact with the user.

`RULES.md` defines constraints that should be respected and, where possible,
validated automatically.

Do not duplicate the detailed contents of these files here.

## Repository structure

* `labs/` — hands-on Kubernetes exercises
* `notes/` — knowledge learned in context
* `scratch/` — temporary AI-generated reference implementations; never source of truth
* `tests/rules/` — automated checks for rules in `RULES.md`

## Working rules

* Read `GUIDE.md` before starting substantive work.
* Check `RULES.md` when modifying or creating repository content.
* Do not modify the user's implementation unless explicitly asked.
* Put AI-generated reference implementations and experiments in `scratch/`.
* Keep learning artifacts close to the lab where they are discovered.
* Prefer helping the user reason and experiment over providing immediate solutions.

## Common commands

```bash
kubectl apply -f <manifest>
kubectl get pods,svc,deploy -A
kubectl describe <resource> <name>
kubectl logs <pod>
kubectl explain <resource>
```

Rule tests, when present, live under `tests/rules/`.
