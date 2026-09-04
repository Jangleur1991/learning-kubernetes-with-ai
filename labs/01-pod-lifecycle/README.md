# Lab 1 — Pod Lifecycle

**Domain:** Application Design and Build  
**CKAD skill:** Predict and explain Pod phase and container state based on restart policy and exit codes.

## Learning objective

Predict Pod phase and container state from restart policy and container exit behavior, then verify against cluster observation.

## Before you begin

- Cluster: `kind-ckad`
- Namespace: `lab-01`
- Time budget: `12 min`

```bash
kubectl create namespace lab-01
kubectl config set-context --current --namespace=lab-01
```

## Exercise 1 — Imperative

### Scenario A — Exit with success (Never)

**Predict:**

- Pod phase after container exits:
- Container state after exit:
- What you'll observe in `kubectl get pods`:

**Task:**

Create a Pod named `success-never`.

Requirements:
- image: `busybox`
- command: `sh -c "echo done && exit 0"`
- restartPolicy: Never

**Observe:**

Run the Pod, wait for it to finish, then collect:

```bash
kubectl get pod success-never
kubectl describe pod success-never
kubectl logs success-never
```

What is the phase? What is the container state? Why?

**Explain:**

Account for the Pod phase in terms of the exit code and `restartPolicy`.

---

### Scenario B — Exit with failure (Never)

**Predict:**

- Pod phase:
- Container state:

**Task:**

Create a Pod named `failure-never`.

Requirements:
- image: `busybox`
- command: `sh -c "echo oops && exit 1"`
- restartPolicy: Never

**Observe:**

Same collection as Scenario A.

**Explain:**

How does a non-zero exit code change the result? Why doesn't the container restart?

---

### Scenario C — Exit with failure, allow restarts (OnFailure)

**Predict:**

- Pod phase:
- Container state on first attempt:
- Container state after restart:
- How many restart attempts will you see:

**Task:**

Create a Pod named `failure-onfailure`.

Requirements:
- image: `busybox`
- command: `sh -c "echo attempt $RANDOM && exit 1"`
- restartPolicy: OnFailure
- backoffLimit: 3

**Observe:**

```bash
kubectl get pod failure-onfailure
kubectl describe pod failure-onfailure
kubectl logs failure-onfailure --previous  # see logs from crashed container
```

Collect evidence of each restart. What changes each time?

**Explain:**

Why does the Pod phase differ from Scenario B? What is `restartCount` and how does `backoffLimit` affect Pod behavior?

---

## Exercise 2 — Declarative

### Scenario A — Success and failure cases (declarative)

Both exercises are required. Choose which one to complete first.

**Predict:**

Same predictions as Exercise 1, Scenarios A and B.

**Task:**

Write two Pod manifests (YAML files):

1. A Pod named `declare-success` that exits with code 0, `restartPolicy: Never`
2. A Pod named `declare-failure` that exits with code 1, `restartPolicy: Never`

Apply both to the cluster.

**Observe:**

Collect the same evidence as Exercise 1 (get, describe, logs).

**Explain:**

Compare your YAML structure with the imperative commands. What details does YAML make explicit that `kubectl run` hid?

---

## Comparison

- Which workflow was faster under the time budget?
- What details did you have to think about differently?
- When would you choose imperative vs. declarative in an exam?

## Success criteria

- [ ] A prediction was recorded before each experiment
- [ ] Pod phases match the expected outcome (Succeeded, Failed, CrashLoopBackOff)
- [ ] The learner can explain the relationship between `restartPolicy`, exit code, and Pod phase
- [ ] The learner can explain what `restartCount` represents and how it changes
- [ ] Both imperative and declarative exercises were completed

## Cleanup

```bash
kubectl config set-context --current --namespace=default
kubectl delete ns lab-01
```

## Optional experiments

- What happens if you set `restartPolicy: Always` on a container that exits successfully? (Prediction first: will the Pod ever reach `Succeeded`?)
- Create a Pod with two containers: one exits 0, one exits 1. How does `restartPolicy` apply?
- Inspect the YAML of a running Pod using `kubectl get pod <name> -o yaml`. What fields describe the current state?
