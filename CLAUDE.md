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
* `cluster/` — local Kubernetes cluster configuration and documentation
* `tests/rules/` — automated checks for rules in `RULES.md`

## Working rules

* Read `GUIDE.md` before starting substantive work.
* Check `RULES.md` when modifying or creating repository content.
* Do not modify the user's implementation unless explicitly asked.
* Put AI-generated reference implementations and experiments in `scratch/`.
* Keep learning artifacts close to the lab where they are discovered.
* Prefer helping the user reason and experiment over providing immediate solutions.
* Do not treat `scratch/` as the source of truth.
* The user's implementations in `labs/` are the source of truth for learning progress.

## Kubernetes cluster safety

The Kubernetes learning cluster is the only Kubernetes cluster Claude may
interact with.

Expected Kubernetes context:

`kind-ckad`

Expected kubeconfig:

`~/.kube/ckad-learning-config`

Before any mutating Kubernetes command:

1. Verify the current context with `kubectl config current-context`.
2. Continue only if the context is `kind-ckad`.
3. Never switch to another Kubernetes context.
4. Never modify resources outside `kind-ckad`.
5. Never delete or recreate the `kind-ckad` cluster unless explicitly requested.

Read-only Kubernetes commands may be used to inspect the cluster and diagnose
problems.

Mutating commands include, but are not limited to:

* `kubectl apply`
* `kubectl create`
* `kubectl delete`
* `kubectl patch`
* `kubectl edit`
* `kubectl replace`
* `kubectl scale`
* `kubectl rollout`

When a command can modify cluster state, verify the context first.

## Docker and host safety

Docker is not part of the normal Kubernetes learning workflow.

Do not use Docker commands for Kubernetes learning tasks.

Do not modify:

* Docker configuration
* Docker permissions
* Docker daemon settings
* WSL configuration
* Windows configuration
* Kubernetes configuration outside the dedicated learning kubeconfig

Do not access or modify the Docker socket.

Do not create, delete, or modify Docker resources unless explicitly requested.

Cluster lifecycle operations such as creating, deleting, or recreating the
kind cluster require explicit user approval.

## Kubernetes command execution

`kubectl` may be used to interact with the `kind-ckad` learning cluster.

The Kubernetes learning environment uses the dedicated kubeconfig:

`~/.kube/ckad-learning-config`

Do not replace it with the user's general kubeconfig.

Before troubleshooting or modifying cluster state, verify:

```bash
kubectl config current-context
```

Expected result:

```text
kind-ckad
```

If the context is different, stop and ask the user before proceeding.

## Learning workflow

Follow `GUIDE.md` for the learning workflow.

In particular:

* give the user opportunities to solve tasks independently;
* do not reveal solutions prematurely;
* use the cluster for experimentation and verification;
* evaluate actual Kubernetes state where relevant;
* distinguish between the user's implementation and AI-generated reference implementations;
* consider both conceptual understanding and CKAD time efficiency.

## Common Kubernetes commands

```bash
kubectl apply -f <manifest>
kubectl get pods,svc,deploy -A
kubectl describe <resource> <name>
kubectl logs <pod>
kubectl exec <pod> -- <command>
kubectl explain <resource>
kubectl get events
```

Use read-only commands freely for inspection and troubleshooting, while
respecting the cluster safety rules above.

## Repository changes

When creating a new lab:

* put the task description and requirements in the lab's `README.md`;
* do not create or modify the user's implementation unless explicitly asked;
* keep generated reference implementations in `scratch/`;
* keep reusable knowledge in `notes/`;
* check `RULES.md` for applicable repository invariants.

Rule tests, when present, live under `tests/rules/`.

## General principle

Optimize for:

1. understanding;
2. hands-on practice;
3. independent problem solving;
4. safe experimentation;
5. reusable knowledge;
6. CKAD exam efficiency.

Do not optimize primarily for producing YAML or commands as quickly as possible.
