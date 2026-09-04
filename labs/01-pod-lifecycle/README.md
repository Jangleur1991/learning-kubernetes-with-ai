# Lab 1 — Pod Lifecycle

**Domain:** Application Design and Build / Application Deployment
**CKAD skill:** Predict and explain Pod phase and container state transitions

## Learning objective

Predict, observe, and explain how a Pod's `status.phase` and container states change
through its lifecycle depending on the container's exit code and `restartPolicy`.

## Before you begin

- Cluster: `kind-ckad`
- Namespace: `lab-01`
- Time budget: `12 min`

```bash
kubectl create namespace lab-01
kubectl config set-context --current --namespace=lab-01
```

Create every Pod in this lab in `lab-01`.

## Exercise 1 — Imperative

Create the Pods entirely with `kubectl run`.

### Scenario A — Successful completion

**Predict:**

- Pod phase after completion:
- Container state (Running > Terminated?):
- restartCount:

**Task:**

Create a Pod named `lifecycle-success`.

Requirements:

- image: `busybox`
- command exits with code 0
- restartPolicy: `Never`

After creation, wait until the Pod is no longer Running or Pending.
Then collect evidence and explain the observed state.

---

### Scenario B — Failed completion

**Predict:**

- Pod phase after failure:
- Container state reason:
- restartCount:

**Task:**

Create a Pod named `lifecycle-fail`.

Requirements:

- image: `busybox`
- command exits with code 1
- restartPolicy: `Never`

After creation, wait until the Pod is no longer Running or Pending.
Then collect evidence and explain the observed state.

---

### Scenario C — Container exits with error, restartPolicy: Always

**Predict:**

- Pod phase after the second exit:
- Container state (waiting or running?):
- restartCount:

**Task:**

Create a Pod named `lifecycle-restart-always`.

Requirements:

- image: `busybox`
- command exits with code 1
- restartPolicy: `Always`

After creation, wait until the container has terminated at least twice.
Then collect evidence and explain the observed state.

---

## Exercise 2 — Declarative

Create the same scenarios from Scenario A of Exercise 1 as YAML manifests
and apply them with `kubectl apply -f`.

**Task:**

Create a Pod named `lifecycle-declarative-success`.

Requirements:

- image: `busybox`
- command exits with code 0
- restartPolicy: `Never`

After creation, wait until the Pod is no longer Running or Pending.
Collect evidence and compare the result with Scenario A.

---

## Comparison

Compare Scenario A (imperative) and the declarative scenario:

- How did the workflow differ?
- Which approach would be faster under CKAD exam conditions?
- What information can you observe in both cases?

## Success criteria

- [ ] Each Pod was created with the correct configuration
- [ ] You observed the Pod phase and container state using `kubectl`
- [ ] You can explain why the Pod reached its observed phase based on exit code and restartPolicy
- [ ] You can distinguish between `status.phase` and container state
- [ ] For Scenario C, you can explain why the Pod phase stays Running despite container failures

## Cleanup

```bash
kubectl config set-context --current --namespace=default
kubectl delete ns lab-01
```

## Optional experiments

- What happens with `restartPolicy: OnFailure` and exit code 0?
- What happens with `restartPolicy: OnFailure` and exit code 1?
- What does `kubectl describe` show in `lastState` vs `currentState` after a restart?
