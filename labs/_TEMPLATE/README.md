# Lab N — Title

**Domain:** <CKAD domain>
**CKAD skill:** <the capability being practised>

## Learning objective

One or two sentences. A capability, not a topic.

## Before you begin

- Cluster: `kind-ckad`
- Namespace: `lab-NN`
- Time budget: `N min`

```bash
kubectl create namespace lab-NN
kubectl config set-context --current --namespace=lab-NN
```

## Exercise 1 — Imperative

### Scenario A — <name>

**Predict:**

- <observable>:
- <observable>:

**Task:**

<What to achieve.>

Requirements:

- <constraint>
- <constraint>

**Observe:**

<Which state to collect.>

**Explain:**

<What the learner must be able to account for.>

---

## Exercise 2 — Declarative

### Scenario A — <same or equivalent scenario>

Both exercises are required. Choose which one to complete first.

**Predict:** …

**Task:** …

**Observe:** …

**Explain:** …

---

## Comparison

- How did the workflow differ?
- Which is faster under exam conditions?
- What is observable in both cases?

## Success criteria

- [ ] A prediction was recorded before each experiment
- [ ] <observable outcome>
- [ ] The learner can explain <behavior> in Kubernetes terms

## Cleanup

```bash
kubectl config set-context --current --namespace=default
kubectl delete ns lab-NN
```

## Optional experiments

- <variation that is useful but not required>
